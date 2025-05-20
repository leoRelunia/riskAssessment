// ignore_for_file: file_names, must_be_immutable
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:bfems/dialogs/validation_dialog.dart';
import 'package:bfems/widgets/buttons/add_button.dart';
import 'package:bfems/widgets/buttons/save_button.dart';
import 'package:bfems/widgets/buttons/update_button.dart';
import 'package:bfems/widgets/context/form.dart';
import 'package:bfems/widgets/context/table.dart';
import 'package:bfems/widgets/search_bar.dart' as custom;
import 'package:http/http.dart' as http;

class SitRepPage extends StatefulWidget {
  const SitRepPage({super.key});

  @override
  _SitRepPageState createState() => _SitRepPageState();
}

class _SitRepPageState extends State<SitRepPage> {
  int _currentPage = 0;
  final int _itemsPerPage = 15;
  List<Map<String, dynamic>> _allRecords = [];
  String _searchQuery = ""; // Stores search input

  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  Future<void> _fetchRecords() async {
    try {
      final url = Uri.parse('http://localhost/bfeps/riskassessment_module/sitrep/get_report.php'); 
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          _allRecords = List<Map<String, dynamic>>.from(data);
          // Sort records by date in descending order
          _allRecords.sort((a, b) => DateTime.parse(b['created_at']).compareTo(DateTime.parse(a['created_at'])));
        });
      } else {
        throw Exception('Failed to load records');
      }
    } catch (e) {
      print('Error fetching records: $e');
    }
  }

  void _deleteReport(String id) async {
    ValidationDialog.showDeleteDialog(
      context: context, 
      message: 'Are you sure you want to delete this report?',
      onConfirm: () async {
        Navigator.of(context).pop(); 
        try {
          final url = Uri.parse('http://localhost/bfeps/riskassessment_module/sitrep/delete_report.php');
          final response = await http.post(url, body: {'id': id});
          if (response.statusCode == 200) {
            var responseData = json.decode(response.body);
            if (responseData['success'] == true) {
              // Refresh reports
              await _fetchRecords();
              print('Report deleted successfully');
            } else {
              print('Failed to delete report: ${responseData['message']}');
            }
          } else {
            print('Failed to connect to the server');
          }
        } catch (e) {
          print('Error deleting report: $e');
        }
      },
    );
  }

  List<Map<String, dynamic>> _getPaginatedRecords() {
    String normalizedQuery = _searchQuery.trim().toLowerCase().replaceAll(',', '');

    List<String> queryWords = normalizedQuery.split(RegExp(r'\s+'));

    List<Map<String, dynamic>> filteredRecords = _allRecords.where((report) {

      String fullName = "${report['calamity'] ?? ''}"
          .replaceAll(',', '')
          .trim()
          .toLowerCase();
 

      bool nameMatches = queryWords.every((word) => fullName.contains(word));

      return nameMatches;
    }).toList();

    int start = _currentPage * _itemsPerPage;
    int end = start + _itemsPerPage;
    if (end > filteredRecords.length) {
      end = filteredRecords.length;
    }

    return filteredRecords.sublist(start, end);
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
      _currentPage = 0; 
    });
  }

  void _goToNextPage() {
    int totalFilteredRecords = _allRecords
        .where((report) =>
            report['calamity'].toString().toLowerCase().contains(_searchQuery.toLowerCase()))
        .length;

    int maxPages = (totalFilteredRecords / _itemsPerPage).ceil();

    if (_currentPage + 1 < maxPages) {
      setState(() {
        _currentPage++;
      });
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }

  Widget _buildPagination() {
    int start = _currentPage * _itemsPerPage + 1;
    int end = start + _itemsPerPage - 1; 
    if (end > _allRecords.length) {
      end = _allRecords.length;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '$start-$end of ${_allRecords.length}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: 'Poppins',
            color: Color(0xFF9E9E9E),
          ),
        ),
        const SizedBox(width: 8), 
        Row(
          mainAxisSize: MainAxisSize.min, 
          children: [
            ElevatedButton(
              onPressed: _currentPage > 0 ? _goToPreviousPage : null,
              style: ElevatedButton.styleFrom(
                foregroundColor: Color(0xFF4B4B4B), 
                shape: const CircleBorder(
                  side: BorderSide(color: Color(0xFFCCCCCC), width: 1),
                ),
                backgroundColor: Color(0xFFFFFFFF), 
                padding: const EdgeInsets.all(5),
                minimumSize: const Size(40,40), 
              ),
              child: const Icon(Icons.navigate_before_rounded, color: Color(0xFF4B4B4B), size: 22),
            ),
            const SizedBox(width: 8), 
            ElevatedButton(
              onPressed: (_currentPage + 1) * _itemsPerPage < _allRecords.length ? _goToNextPage : null,
              style: ElevatedButton.styleFrom(
                foregroundColor: Color(0xFF4B4B4B), 
                shape: const CircleBorder(
                  side: BorderSide(color: Color(0xFFCCCCCC), width: 1),
                ),
                backgroundColor: Color(0xFFFFFFFF), 
                padding: const EdgeInsets.all(5),
                minimumSize: const Size(40, 40), 
              ),
              child: const Icon(Icons.navigate_next_rounded, color: Color(0xFF4B4B4B), size: 22),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 custom.SearchBar(onSearch: _updateSearchQuery), 
                AddButton(
                  label: 'Add Report',
                  onPressed: () {
                    _showSitRepForm(context, null, isViewMode: false);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildIndividualTable(),
            const SizedBox(height: 20), 
            _buildPagination(),
          ],
        ),
      ),
    );
  }

  Widget _buildIndividualTable() {
    return Container(
      width: double.infinity,
      height: 650,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFCCCCCC)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          Expanded(
            child: _getPaginatedRecords().isEmpty
                ? const Center(
                    child: Text(
                      'No Records available.',
                      style: TextStyle(
                        color: Color(0xFFCBCBCB),
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  )
                : _buildTableRows(),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFCCCCCC))),
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      child: Row(
        children: [ 
          const HeaderCellWidget(label: 'ID', flex: 2, center: true),
          const HeaderCellWidget(label: 'Date/Time', flex: 2, center: true),
          const HeaderCellWidget(label: 'Calamity', flex: 2, center: true),
          const HeaderCellWidget(label: 'Action', flex: 6, center: true),
        ],
      ),
    );
  }

 Widget _buildTableRows() {
  List<Map<String, dynamic>> paginatedRecords = _getPaginatedRecords();
  return ListView.builder(
    itemCount: paginatedRecords.length,
    itemBuilder: (context, index) {
      final report = paginatedRecords[index];
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFCCCCCC))),
        ),
        child: Row(
          children: [
            DataCellWidget(value: report['id'] ?? '', flex: 2, center: true),
            DataCellWidget(value: report['created_at'] ?? '', flex: 2, center: true),
            DataCellWidget(value: report['calamity'] ?? '', flex: 2, center: true),
            Expanded(
  flex: 6,
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      // View button - green bg, white text, shadowed border
      ElevatedButton(
        onPressed: () {
          _showSitRepForm(context, report, isViewMode: true);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          elevation: 4, // adds shadow
          shadowColor: Colors.black45,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // adjust curve here
          ),
        ),
        child: const Text('View'),
      ),
      const SizedBox(width: 2),

      // Print button - blue bg, white text, shadowed border
      ElevatedButton(
        onPressed: () {
          // Add your print logic here
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: Colors.black45,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // adjust curve here
          ),
        ),
        child: const Text('Print'),
      ),
      const SizedBox(width: 2),

      // Delete button - same bg color, white text, shadowed border
      ElevatedButton(
        onPressed: () {
          _deleteReport(report['id']);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF55555), // same as before
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: Colors.black45,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // adjust curve here
          ),
        ),
        child: const Text('Delete'),
      ),
    ],
  ),
),
          ],
        ),
      );
    },
  );
}


  void _showSitRepForm(BuildContext context, Map<String, dynamic>? existingData, {bool isViewMode = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SitRepForm(
            onSave: (newRecord) {
              setState(() {
                // Update the existing record in _allRecords
                if (existingData != null) {
                  int index = _allRecords.indexWhere((record) => record['id'] == existingData['id']);
                  if (index != -1) {
                    _allRecords[index] = newRecord; // Update the existing record
                  }
                } else {
                  _allRecords.add(newRecord); // Add new record if existingData is null
                }
              });
              _fetchRecords();
            },
            existingData: existingData, 
            isViewMode: isViewMode, 
            isUpdateMode: existingData != null,
          ),
        );
      },
    );
  }
}

class SitRepForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave; 
  final Map<String, dynamic>? existingData; 
  bool isViewMode;
  final bool isUpdateMode;

  SitRepForm({
    required this.onSave, 
    this.existingData, 
    this.isViewMode = false,  
    this.isUpdateMode = false
  }); 

  @override
  _SitRepFormState createState() => _SitRepFormState();
}

class _SitRepFormState extends State<SitRepForm> {
  // Existing controllers
  final TextEditingController calamityController = TextEditingController();
  final TextEditingController situationOverviewController = TextEditingController();
  final TextEditingController responseActionsController = TextEditingController();
  final TextEditingController immediateNeedsController = TextEditingController();
  final TextEditingController recommendationsController = TextEditingController();


  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      // Populate the fields with existing data if available
      calamityController.text = widget.existingData!['calamity'] ?? '';
      situationOverviewController.text = widget.existingData!['situation_overview'] ?? '';
      responseActionsController.text = widget.existingData!['response_actions'] ?? '';
      immediateNeedsController.text = widget.existingData!['immediate_needs'] ?? '';
      recommendationsController.text = widget.existingData!['recommendations'] ?? '';
    }
  }

  @override
Widget build(BuildContext context) {
  return SizedBox(
    width: 1000,
    height: 575,
    child: Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFCBCBCB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SITUATIONAL REPORT FORM',
                style: TextStyle(
                  color: Color(0xFF5576F5),
                  fontSize: 24,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
             _buildForm(),
            ],
          ),
        ),
        _buildCloseButton(),
        if (!widget.isViewMode) _buildSaveButton(),
        if (widget.isViewMode) _buildUpdateButton(),
      ],
    ),
  );
}
  
  
  Widget _buildUpdateButton() {
    return Positioned(
      bottom: 14,
      right: 25,
      child: UpdateButton(
        onPressed: () {
          setState(() {
            widget.isViewMode = false; 
          });
        },
        label: 'Edit', 
      ),
    );
  }

  Widget _buildForm() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CALAMITY INFORMATION',
                          style: TextStyle(
                          color: Color.fromARGB(255, 122, 122, 122),
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
            _buildRow([
            FormHelper.buildTextField('Name/Type of Calamity*', calamityController, isReadOnly: widget.isViewMode),
          ]),
          const SizedBox(height: 40),
          const Text(
              'SITUATION INFORMATION',
                          style: TextStyle(
                          color: Color.fromARGB(255, 122, 122, 122),
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
          const SizedBox(height: 10),
          _buildRow([
            FormHelper.buildTextField('Situation Overview*', situationOverviewController, isReadOnly: widget.isViewMode, height: 150),
            FormHelper.buildTextField('Response Actions*', responseActionsController, isReadOnly: widget.isViewMode, height: 150),
          ]),
          const SizedBox(height: 10),
          _buildRow([
            FormHelper.buildTextField('Immediate Needs*', immediateNeedsController, isReadOnly: widget.isViewMode, height: 150),
            FormHelper.buildTextField('Reccomendations*', recommendationsController, isReadOnly: widget.isViewMode, height: 150),
          ]),
      
          ],
        ),
      ),
    );
  }
  /*Widget _buildFirstForm() {
    return Container(
            padding: const EdgeInsets.fromLTRB(20, 35, 35, 60),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFCBCBCB))
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Calamity Information',
                  style: TextStyle(
                    color:  Color(0xFF5576F5),
                    fontSize: 24,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height:8),

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 5,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRow([
            FormHelper.buildTextField('Name/Type of Calamity *', calamityController, isReadOnly: widget.isViewMode),
            const SizedBox(width: 8),
          ]), 
        ],
      ),
                  ),
                ),
                   ],
            ),

    );
  }

   Widget _buildSecondForm() {
    return Container(
            padding: const EdgeInsets.all(80.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFCBCBCB))
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Situational Report',
                  style: TextStyle(
                    color:  Color(0xFF5576F5),
                    fontSize: 24,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height:10),

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(23),
                  decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 5,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                
 child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          _buildRow([
            FormHelper.buildTextBigField('Situation Overview *', situationOverviewController, isReadOnly: widget.isViewMode),
          ]),
          const SizedBox(height: 10),
          _buildRow([
            FormHelper.buildTextBigField('Response Actions *', responseActionsController, isReadOnly: widget.isViewMode),
          ]),
          const SizedBox(height: 10),
          _buildRow([
            FormHelper.buildTextBigField('Immediate Needs *', immediateNeedsController, isReadOnly: widget.isViewMode),
          ]),
          const SizedBox(height: 10),
          _buildRow([
            FormHelper.buildTextBigField('Reccomendations *', recommendationsController, isReadOnly: widget.isViewMode),
          ]),
        ],
      ),
 ),
                  ),
                ),
              ],
            ),

    );
  } */

  Widget _buildCloseButton() {
    return Positioned(
      top: 8,
      right: 8,
      child: IconButton(
        icon: const Icon(Icons.close, color: Color(0xFF9E9E9E)),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _buildSaveButton() {
    return Positioned(
      bottom: 14,
      right: 25,
      child: SaveButton(
        onPressed: () {
          _saveData(context);
        },
        label: 'Save',
      ),
    );
  }
  
  Widget _buildRow(List<Widget> children) {
    return Row(
      children: children
          .expand(
              (widget) => [Expanded(child: widget), const SizedBox(width: 8)])
          .toList()
        ..removeLast(),
    );
  }

  String toCamelCase(String input) {
    if (input.isEmpty) return input;
    return input.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Future<void> _saveData(BuildContext context) async {
    if (calamityController.text.isNotEmpty &&
        situationOverviewController.text.isNotEmpty &&
        responseActionsController.text.isNotEmpty &&
        immediateNeedsController.text.isNotEmpty &&
        recommendationsController.text.isNotEmpty) {
      try {
        final data = { 
          'calamity': toCamelCase(calamityController.text),
          'situation_overview': situationOverviewController.text,
          'response_actions': responseActionsController.text,
          'immediate_needs': immediateNeedsController.text,
          'recommendations': recommendationsController.text,
        };

        var url = widget.isUpdateMode 
            ? Uri.parse('http://localhost/bfeps/riskassessment_module/sitrep/update_report.php') 
            : Uri.parse('http://localhost/bfeps/riskassessment_module/sitrep/save_report.php');

        var response = await http.post(url, body: json.encode(data), headers: {"Content-Type": "application/json"});
        // Log the response for debugging
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        var responseBody = jsonDecode(response.body);
        if (response.statusCode == 200 && responseBody["success"] == true) {
          print('Data saved successfully');

          // Call the onSave callback to update the records in the parent widget
          widget.onSave(data); // Pass the new data to the parent

          // Clear the form fields
          setState(() {
            calamityController.clear();
            situationOverviewController.clear();
            responseActionsController.clear();
            immediateNeedsController.clear();
            recommendationsController.clear();
          });

          // Show success dialog
          ValidationDialog.showSuccessDialog(
            context,
            'Data saved successfully!',
            () {
              Navigator.pop(context); // Close success dialog
              Navigator.pop(context); // Close form
            },
          );
        } else {
          print('Failed to save data: ${response.body}');
          ValidationDialog.showErrorDialog(context, 'Failed to save data. Please try again.');
        }
      } catch (e) {
        print('Error: $e');
        ValidationDialog.showErrorDialog(context, 'An error occurred. Please try again later.');
      }
    } else {
      ValidationDialog.showErrorDialog(context, 'Please fill in all fields marked with an asterisk *');
    }
  }
}
