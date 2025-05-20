import 'dart:convert';

//import 'package:lib/pages/risk_assessment/flood_risk_page.dart';
import 'package:bfems/pages/risk_assessment/flood_updates.dart';
import 'package:bfems/pages/risk_assessment/ra_report_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../constants/dropdown_options.dart';
import '../../dialogs/validation_dialog.dart';
import '../../widgets/buttons/add_button.dart';
import '../../widgets/buttons/save_button.dart';
import '../../widgets/buttons/update_button.dart';
import '../../widgets/context/form.dart';
import '../../widgets/context/table.dart';
import '../../widgets/search_bar.dart' as custom;

class CalamityPage extends StatefulWidget {
  const CalamityPage({super.key});

  @override
  CalamityPageState createState() => CalamityPageState();
}

class CalamityPageState extends State<CalamityPage> {
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
      final url = Uri.parse('http://localhost/bfeps/riskassessment_module/api/evacuation/get_calamity.php'); 
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          _allRecords = List<Map<String, dynamic>>.from(data);
        });
      } else {
        throw Exception('Failed to load records');
      }
    } catch (e) {
      print('Error fetching records: $e');
    }
  }

  void _deleteCalamity(String id) async {
    ValidationDialog.showDeleteDialog(
      context: context, 
      message: 'Are you sure you want to delete this calamity?',
      onConfirm: () async {
        Navigator.of(context).pop(); 
        try {
          final url = Uri.parse('http://localhost/bfeps/riskassessment_module/api/evacuation/delete_calamity.php');
          final response = await http.post(url, body: {'id': id});
          if (response.statusCode == 200) {
            var responseData = json.decode(response.body);
            if (responseData['success'] == true) {
              // Refresh calamity
              await _fetchRecords();
              print('Calamity deleted successfully');
            } else {
              print('Failed to delete calamity: ${responseData['message']}');
            }
          } else {
            print('Failed to connect to the server');
          }
        } catch (e) {
          print('Error deleting calamity: $e');
        }
      },
    );
  }

  List<Map<String, dynamic>> _getPaginatedRecords() {
    String normalizedQuery = _searchQuery.trim().toLowerCase().replaceAll(',', '');

    List<String> queryWords = normalizedQuery.split(RegExp(r'\s+'));

    List<Map<String, dynamic>> filteredRecords = _allRecords.where((calamity) {

      String calamityName = "${calamity['calamity_name'] ?? ''}"
          .replaceAll(',', '')
          .trim()
          .toLowerCase();


      String date = "${calamity['date'] ?? ''}".trim().toLowerCase(); 

      bool nameMatches = queryWords.every((word) => calamityName.contains(word));
      bool dateMatches = queryWords.every((word) => date.contains(word));

      return nameMatches || dateMatches;
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
        .where((calamity) =>
            calamity['date'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            calamity['calamity_name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()))
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
                  label: 'Add Calamity',
                  onPressed: () {
                    _showReliefForm(context, null, isViewMode: false);
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
          const HeaderCellWidget(label: 'Date & Time', flex: 2),
          const HeaderCellWidget(label: 'Type of Calamity', flex: 2),
          const HeaderCellWidget(label: 'Calamity Name', flex: 2),
          const HeaderCellWidget(label: 'Severity Level', flex: 2),
          const HeaderCellWidget(label: 'Cause of Calamity', flex: 2),
          const HeaderCellWidget(label: 'Evacuation Alert Level Issued', flex: 3),
          const HeaderCellWidget(label: 'Status', flex: 2, center: true),
          const HeaderCellWidget(label: 'Action', flex: 1, center: true),
        ],
      ),
    );
  }

Widget _buildTableRows() {
  List<Map<String, dynamic>> paginatedRecords = _getPaginatedRecords();
  return ListView.builder(
    itemCount: paginatedRecords.length,
    itemBuilder: (context, index) {
      final calamity = paginatedRecords[index];
      bool isResolved = calamity['current_status'] == 'Resolved'; // Check if resolved
      bool isOngoing = calamity['current_status'] == 'Ongoing'; // Check if resolved

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFCCCCCC))),
        ),
        child: Row(
          children: [
            DataCellWidget(value: calamity['date'] ?? '', flex: 2),
            DataCellWidget(value: calamity['calamity_name'] ?? '', flex: 2),
            DataCellWidget(value: calamity['calamity_type'] ?? '', flex: 2),
            DataCellWidget(value: calamity['severity_level'] ?? '', flex: 2),
            DataCellWidget(value: calamity['flood_cause'] ?? '', flex: 2),
            DataCellWidget(value: calamity['alert_level'] ?? '', flex: 3),
            DataCellWidget(value: calamity['current_status'] ?? '', flex: 2, center: true),
            Expanded(
              flex: 1,
              child: Center(
                child: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'Update' && !isResolved) {
                      _showReliefForm(context, calamity, isViewMode: false);
                    } else if (value == 'Delete' && !isResolved) {
                      _deleteCalamity(calamity['id']);
                    } /*else if (value == 'Evacuation Center') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Evacuationcenters(
                            calamity: calamity,
                          ),
                        ),
                      );
                    }*/
                    else if (value == 'RA Report' && !isOngoing) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RaReportPage(),
                        ),
                      );
                    } else if (value == 'Flood Updates'  && !isResolved) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FloodUpdatesPage(),
                        ),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    if (!isResolved) const PopupMenuItem(value: 'Update', child: Text('Update')),
                    if (!isResolved) const PopupMenuItem(value: 'Delete', child: Text('Delete')),
                    if (!isResolved) const PopupMenuItem(value: 'Flood Updates', child: Text('Flood Updates')),
                    if (!isOngoing) const PopupMenuItem(value: 'RA Report', child: Text('Ra Report')),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}




  void _showReliefForm(BuildContext context, Map<String, dynamic>? existingData, {bool isViewMode = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: CalamityForm(
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

class CalamityForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave; 
  final Map<String, dynamic>? existingData; 
  bool isViewMode;
  final bool isUpdateMode;

  CalamityForm({super.key, 
    required this.onSave, 
    this.existingData, 
    this.isViewMode = false,  
    this.isUpdateMode = false
  }); 

  @override
  CalamityFormState createState() => CalamityFormState();
}

class CalamityFormState extends State<CalamityForm> {
  bool _isDirty = false; // Track if the form is dirty
  // Existing controllers
  final TextEditingController dateController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  // Existing dropdown variables
  String? selectedCalamityType;
  String? selectedLevel;
  String? selectedCause;
  String? selectedAlert;
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      // Populate the fields with existing data if available
      dateController.text = widget.existingData!['date'] ?? '';
      nameController.text = widget.existingData!['calamity_name'] ?? '';
      selectedCalamityType = widget.existingData!['calamity_type'];
      selectedLevel = widget.existingData!['severity_level'];
      selectedCause = widget.existingData!['flood_cause'];
      selectedAlert = widget.existingData!['alert_level'];
      selectedStatus = widget.existingData!['current_status'];
    }
  }

  void _markDirty(String value) {
  setState(() {
    _isDirty = true;
  });
}

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 800,
      height: 300,
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
                  'CALAMITY INFORMATION FORM',
                  style: TextStyle(
                    color: Color(0xFF5576F5),
                    fontSize: 24,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                _buildForm({
                  'selectedCalamityType' : selectedCalamityType,
                  'selectedLevel': selectedLevel,
                  'selectedCause' : selectedCause,
                  'selectedAlert': selectedAlert,
                  'selectedStatus': selectedStatus,
                })
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

  Widget _buildForm(Map<String, String?> dropdownValues) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRow([
             FormHelper.buildTextField('Calamity Name*', nameController, isReadOnly: widget.isViewMode, /*onChanged: _markDirty*/),
          ]),
          const SizedBox(height: 10),
          _buildRow([
            FormHelper.buildDateField(context, dateController, 'Date & Time*', isReadOnly: widget.isViewMode, /*isDateTime: true, onChanged: _markDirty*/),
            _buildDropdown('Type of Calamity*', 'selectedCalamityType' ,calamityTypeOptions, dropdownValues, isReadOnly: widget.isViewMode),
          ]),
          const SizedBox(height: 10),
          _buildRow([
            _buildDropdown('Severity Level', 'selectedLevel', severityLevelOptions, dropdownValues, isReadOnly: widget.isViewMode),
            _buildDropdown('Cause of Flood*', 'selectedCause', floodCauseOptions, dropdownValues, isReadOnly: widget.isViewMode),
          ]),
          const SizedBox(height: 10),
          _buildRow([
            _buildDropdown('Evacuation Alert Level Issued*', 'selectedAlert' ,alertIssuedOptions, dropdownValues, isReadOnly: widget.isViewMode),
            _buildDropdown('Current Status*', 'selectedStatus' ,statusOptions, dropdownValues, isReadOnly: widget.isViewMode),
          ]),
        ],
      ),
    );
  }

  Widget _buildCloseButton() {
    return Positioned(
      top: 8,
      right: 8,
      child: IconButton(
        icon: const Icon(Icons.close, color: Color(0xFF9E9E9E)),
        onPressed: () {
          if (_isDirty) {
            ValidationDialog.showDiscardChangesDialog(
              context: context,
              onDiscard: () {
                Navigator.of(context).pop(); 
                Navigator.of(context).pop(); 
              },
            );
          } else {
            Navigator.of(context).pop();
          }
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

  Widget _buildDropdown(String label, String key, List<String> options, Map<String, String?> dropdownValues, {bool isReadOnly = false}) {
    return SizedBox(
      height: 35,
      child: DropdownButtonFormField<String>(
        decoration: FormHelper.inputDecoration(label), 
        dropdownColor: Colors.white,
        value: dropdownValues[key] != null && options.contains(dropdownValues[key]) ? dropdownValues[key] : null,
        items: options.map((value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
          );
        }).toList(),
        menuMaxHeight: 200.0,
        isDense: true,
        onChanged: isReadOnly ? null : (newValue) {
          setState(() {
            if (key == 'selectedCalamityType') {
              selectedCalamityType = newValue;
            } else if (key == 'selectedLevel') {
              selectedLevel = newValue;
            } else if (key == 'selectedCause') {
              selectedCause = newValue;
            } else if (key == 'selectedAlert') {
              selectedAlert = newValue;
            } else if (key == 'selectedStatus') {
              selectedStatus = newValue;
            }
            _isDirty = true; 
          });
        },
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
    if (dateController.text.isNotEmpty &&
        nameController.text.isNotEmpty &&
        selectedCalamityType != null &&
        selectedLevel != null &&
        selectedCause != null &&
        selectedAlert != null &&
        selectedStatus != null) {
      try {
        final data = {
          'id': widget.existingData?['id'], // Include the ID for updates
          'date': dateController.text,
          'calamity_name': toCamelCase(nameController.text),
          'calamity_type': selectedCalamityType,
          'severity_level': selectedLevel,
          'flood_cause': selectedCause,
          'alert_level': selectedAlert,
          'current_status': selectedStatus,
        };

        var url = widget.isUpdateMode 
            ? Uri.parse('http://localhost/bfeps/riskassessment_module/api/evacuation/update_calamity.php') 
            : Uri.parse('http://localhost/bfeps/riskassessment_module/api/evacuation/save_calamity.php');

        var response = await http.post(url, body: json.encode(data), headers: {"Content-Type": "application/json"});
        // Log the response for debugging
        print('Response current_status: ${response.statusCode}');
        print('Response body: ${response.body}');

        var responseBody = jsonDecode(response.body);
        if (response.statusCode == 200 && responseBody["success"] == true) {
          print('Data saved successfully');

          // Call the onSave callback to update the records in the parent widget
          widget.onSave(data); // Pass the new data to the parent

          // Clear the form fields
          setState(() {
            dateController.clear();
            nameController.clear();
            selectedCalamityType = null;
            selectedLevel = null;
            selectedCause = null;
            selectedAlert = null;
            selectedStatus = null;
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