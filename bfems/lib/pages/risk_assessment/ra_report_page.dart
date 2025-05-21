// ignore_for_file: file_names, must_be_immutable
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:bfems/constants/dropdown_options.dart';
import 'package:bfems/dialogs/validation_dialog.dart';
import 'package:bfems/widgets/buttons/add_button.dart';
import 'package:bfems/widgets/buttons/save_button.dart';
import 'package:bfems/widgets/buttons/update_button.dart';
import 'package:bfems/widgets/context/form.dart';
import 'package:bfems/widgets/context/table.dart';
import 'package:bfems/widgets/search_bar.dart' as custom;
import 'package:http/http.dart' as http;

class RaReportPage extends StatefulWidget {
  const RaReportPage({super.key});

  @override
  RaReportPageState createState() => RaReportPageState();
}

class RaReportPageState extends State<RaReportPage> {
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
      final url = Uri.parse('http://localhost/bfeps/riskassessment_module/riskassessmentreport/get_report.php'); 
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

  void _deleteReport(String id) async {
    ValidationDialog.showDeleteDialog(
      context: context, 
      message: 'Are you sure you want to delete this report?',
      onConfirm: () async {
        Navigator.of(context).pop(); 
        try {
          final url = Uri.parse('http://localhost/BFEPS/riskassessment_module/riskassessmentreport/delete_report.php');
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

      String fullName = "${report['household_name'] ?? ''}"
          .replaceAll(',', '')
          .trim()
          .toLowerCase();

      String zoneNum = "${report['zone_num'] ?? ''}"
          .replaceAll(',', '')
          .trim()
          .toLowerCase();

      //String date = "${report['created_at'] ?? ''}".trim().toLowerCase(); 

      bool nameMatches = queryWords.every((word) => fullName.contains(word));
      bool itemnameMatches = queryWords.every((word) => zoneNum.contains(word));
      //bool dateMatches = queryWords.every((word) => date.contains(word));

      return nameMatches || itemnameMatches; //dateMatches
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
            //report['created_at'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            report['household_name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            report['zone_num'].toString().toLowerCase().contains(_searchQuery.toLowerCase()))
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
      appBar: AppBar(backgroundColor: const Color(0xFFF6F7F9),),
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
                    _showRAForm(context, null, isViewMode: false); 
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
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
        const HeaderCellWidget(label: 'ID', flex: 1),
        const HeaderCellWidget(label: 'Zone', flex: 1),
        const HeaderCellWidget(label: 'Household Head', flex: 1),
        const HeaderCellWidget(label: 'Risk Type', flex: 1),
        const HeaderCellWidget(label: 'PWD(s)', flex: 1),
        const HeaderCellWidget(label: 'Senior Citizen(s)', flex: 1),
        const HeaderCellWidget(label: 'Infant/Toddler(s)', flex: 1),
        const HeaderCellWidget(label: 'Flood Fatality(s)', flex: 1),
        const HeaderCellWidget(label: 'Property Damage(s)', flex: 1),
        const HeaderCellWidget(label: 'Impact Level', flex: 1),
        const HeaderCellWidget(label: 'Probability Level', flex: 1),
        const HeaderCellWidget(label: 'Severity Level', flex: 1),
        const HeaderCellWidget(label: 'Action Needed', flex: 1, center: true),
        // Added header for PopupMenuWidget action column
        const HeaderCellWidget(label: 'Options', flex: 1, center: true),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFCCCCCC))),
        ),
        child: Row(
          children: [ 
            DataCellWidget(value: report['id'] ?? '', flex: 1),
            DataCellWidget(value: report['zone_num'] ?? '', flex: 1),
            DataCellWidget(value: report['household_name'] ?? '', flex: 1),
            DataCellWidget(value: report['risk_type'] ?? '', flex: 1),
            DataCellWidget(value: report['num_of_pwd'] ?? '', flex: 1),
            DataCellWidget(value: report['num_of_senior'] ?? '', flex: 1),
            DataCellWidget(value: report['num_of_infant_toddler'] ?? '', flex: 1),
            DataCellWidget(value: report['num_of_flood_fatality'] ?? '', flex: 1),
            DataCellWidget(value: report['num_of_property_damage'] ?? '', flex: 1),
            DataCellWidget(value: report['risk_impact_level'] ?? '', flex: 1),
            DataCellWidget(value: report['risk_probability_level'] ?? '', flex: 1),
            DataCellWidget(value: report['risk_severity_level'] ?? '', flex: 1),
            DataCellWidget(value: report['option_action'] ?? '', flex: 1, center: true),
            // PopupMenuWidget must have flex 1 to match header column
            Expanded(
              flex: 1,
              child: Center(
                child: PopupMenuWidget(
                  onSelected: (value) {
                    if (value == 'View') {
                      _showRAForm(context, report, isViewMode: true);
                    } else if (value == 'Update') {
                      _showRAForm(context, report, isViewMode: false);
                    } else if (value == 'Delete') {
                      _deleteReport(report['id']);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

  void _showRAForm(BuildContext context, Map<String, dynamic>? existingData, {bool isViewMode = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: RAReportForm(
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

class RAReportForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave; 
  final Map<String, dynamic>? existingData; 
  bool isViewMode;
  final bool isUpdateMode;

  RAReportForm({
    required this.onSave, 
    this.existingData, 
    this.isViewMode = false,  
    this.isUpdateMode = false
  }); 

  @override
  _ReliefReportFormState createState() => _ReliefReportFormState();
}

class _ReliefReportFormState extends State<RAReportForm> {
  // Existing controllers
  final TextEditingController householdNameController = TextEditingController();
  final TextEditingController riskDescriptionController = TextEditingController();
  final TextEditingController numPerPWDController = TextEditingController();
  final TextEditingController numSeniorCitizenController = TextEditingController();
  final TextEditingController numInfantToddlerController = TextEditingController();
  final TextEditingController numFloodFatalityController = TextEditingController();
  final TextEditingController numPropertyDamageController = TextEditingController();
  final TextEditingController damageDescriptionController = TextEditingController();
  final TextEditingController impactedRemarksController = TextEditingController();
  final TextEditingController currentControlMeasuresController = TextEditingController();
  final TextEditingController actionRemarksController = TextEditingController();

  // Existing dropdown variables
  String? selectedZone;
  String? selectedRiskType;
  String? selectedImpactLevel;
  String? selectedProbabilityLevel;
  String? selectedRiskSeverityLevel;
  String? selectedAction;

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      // Populate the fields with existing data if available
      householdNameController.text = widget.existingData!['household_name'] ?? '';
      riskDescriptionController.text = widget.existingData!['risk_description'] ?? '';
      numPerPWDController.text = widget.existingData!['num_of_pwd'] ?? '';
      numSeniorCitizenController.text = widget.existingData!['num_of_senior'] ?? '';
      numInfantToddlerController.text = widget.existingData!['num_of_infant_toddler'] ?? '';
      numFloodFatalityController.text = widget.existingData!['num_of_flood_fatality'] ?? '';
      numPropertyDamageController.text = widget.existingData!['num_of_property_damage'] ?? '';
      damageDescriptionController.text = widget.existingData!['damage_description'] ?? '';
      impactedRemarksController.text = widget.existingData!['impacted_remarks'] ?? '';
      currentControlMeasuresController.text = widget.existingData!['current_control_measures'] ?? '';
      actionRemarksController.text = widget.existingData!['action_remarks'] ?? '';
      selectedZone = widget.existingData!['zone_num'];
      selectedRiskType = widget.existingData!['risk_type'];
      selectedImpactLevel = widget.existingData!['risk_impact_level'];
      selectedProbabilityLevel = widget.existingData!['risk_probability_level'];
      selectedRiskSeverityLevel = widget.existingData!['risk_severity_level'];
      selectedAction = widget.existingData!['option_action'];
    }
  }

  @override
Widget build(BuildContext context) {
  return SizedBox(
    width: 1000,
    height: 780,
    child: Stack(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(30, 25, 30, 60),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFCBCBCB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'RISK ASSESSMENT FORM',
                style: TextStyle(
                  color: Color(0xFF5576F5),
                  fontSize: 24,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              _buildForm({
                    'selectedZone': selectedZone,
                    'selectedRiskType': selectedRiskType,
                    'selectedImpactLevel': selectedImpactLevel,
                    'selectedProbabilityLevel': selectedProbabilityLevel,
                    'selectedRiskSeverityLevel': selectedRiskSeverityLevel,
                    'selectedAction': selectedAction,
                  }),
              
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

  Widget _buildForm(Map<String, String?> dropdownValues) {
    return Expanded(
      child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
                        'HOUSE RISK INFORMATION ',
                          style: TextStyle(
                          color: Color.fromARGB(255, 122, 122, 122),
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
          const SizedBox(height: 10),
          _buildRow([
            _buildDropdown('Zone*', 'selectedZone', zoneOptions, dropdownValues, isReadOnly: widget.isViewMode),
            FormHelper.buildTextField('Household Head*', householdNameController, isReadOnly: widget.isViewMode),
          ]),
          const SizedBox(height: 10),
          _buildRow([
            _buildDropdown('Type of Risk*', 'selectedRiskType', riskTypeOptions, dropdownValues, isReadOnly: widget.isViewMode),
            FormHelper.buildTextField('Risk Description*', riskDescriptionController, isReadOnly: widget.isViewMode, height: 150),
          ]),
          const SizedBox(height: 20),
          const Text(
                        'NUMBER OF PERSON(S) IMPACTED',
                          style: TextStyle(
                          color: Color.fromARGB(255, 122, 122, 122),
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
          const SizedBox(height:10),
          _buildRow([
            FormHelper.buildTextField('Person with Disability(s)', numPerPWDController, isReadOnly: widget.isViewMode),
            FormHelper.buildTextField('Senior Citizen(s)', numSeniorCitizenController, isReadOnly: widget.isViewMode),
            FormHelper.buildTextField('Infant(s) & Toddler(s)', numInfantToddlerController, isReadOnly: widget.isViewMode),
            FormHelper.buildTextField('Flood Fatality', numFloodFatalityController, isReadOnly: widget.isViewMode),
            FormHelper.buildTextField('Property Damage', numPropertyDamageController, isReadOnly: widget.isViewMode),
          ]),
          const SizedBox(height: 10),
          _buildRow([
            FormHelper.buildTextField('Damage Description', damageDescriptionController, isReadOnly: widget.isViewMode, height: 150),
            FormHelper.buildTextField('Remarks', impactedRemarksController, isReadOnly: widget.isViewMode, height: 150),
          ]),
          const SizedBox(height:20),
                      Row(
                      children: [
                      const Text(
                        'ASSESS RISK',
                          style: TextStyle(
                          color: Color.fromARGB(255, 122, 122, 122),
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
          const SizedBox(width: 5),
            GestureDetector(
              onTap: () {
                showDialog(
  context: context,
  builder: (BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        width: 1000,  // Adjust width as needed
        height: 300, // Adjust height as needed
        child: Image.asset(
          'assets/images/SL.png',
          fit: BoxFit.fill,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // Optional: controls the roundness
      ),
    );
  },
        );
      },
      child: Icon(
        Icons.help_outline, // Question mark icon
        size: 16,
        color: Color.fromARGB(255, 122, 122, 122),
      ),
    ),
  ],
),
const SizedBox(height: 10),
          
          _buildRow([
            _buildDropdown('Risk Impact*', 'selectedImpactLevel', riskImpactLevelOptions, dropdownValues, isReadOnly: widget.isViewMode),
            _buildDropdown('Risk Probability*', 'selectedProbabilityLevel', riskProbabilityLevelOptions, dropdownValues, isReadOnly: widget.isViewMode),
            _buildDropdown('Risk Severity Level*', 'selectedRiskSeverityLevel', riskSeverityLevelOptions, dropdownValues, isReadOnly: widget.isViewMode),
          ]),
          const SizedBox(height: 20),
                      const Text(
                        'IMPLEMENTATION',
                          style: TextStyle(
                          color: Color.fromARGB(255, 122, 122, 122),
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height:10),
          _buildRow([
            FormHelper.buildTextField('Current Control Measures*', currentControlMeasuresController, isReadOnly: widget.isViewMode, height: 150),
          ]),
           const SizedBox(height: 10),
          _buildRow([
            _buildDropdown('Further Action Needed?*', 'selectedAction', actionOptions, dropdownValues, isReadOnly: widget.isViewMode),
            FormHelper.buildTextField('Remarks', actionRemarksController, isReadOnly: widget.isViewMode, height: 150),
          ]),
        ],
      ),
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
            if (key == 'selectedZone') {
              selectedZone = newValue;
            } else if (key == 'selectedRiskType') {
              selectedRiskType = newValue;
            } else if (key == 'selectedImpactLevel') {
              selectedImpactLevel = newValue;
            } else if (key == 'selectedProbabilityLevel') {
              selectedProbabilityLevel = newValue;
            } else if (key == 'selectedRiskSeverityLevel') {
              selectedRiskSeverityLevel = newValue;
            } else if (key == 'selectedAction') {
              selectedAction = newValue;
            } 
          });
        },
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
  if (householdNameController.text.isNotEmpty &&
      riskDescriptionController.text.isNotEmpty &&
      currentControlMeasuresController.text.isNotEmpty &&
      selectedZone != null &&
      selectedRiskType != null &&
      selectedImpactLevel != null &&
      selectedProbabilityLevel != null &&
      selectedRiskSeverityLevel != null &&
      selectedAction != null) {
    try {
      final data = {
        'id': widget.existingData?['id'],
        'household_name': toCamelCase(householdNameController.text),
        'risk_description': riskDescriptionController.text,
        'num_of_pwd': numPerPWDController.text.isNotEmpty ? numPerPWDController.text : '0',
        'num_of_senior': numSeniorCitizenController.text.isNotEmpty ? numSeniorCitizenController.text : '0',
        'num_of_infant_toddler': numInfantToddlerController.text.isNotEmpty ? numInfantToddlerController.text : '0',
        'num_of_flood_fatality': numFloodFatalityController.text.isNotEmpty ? numFloodFatalityController.text : '0',
        'num_of_property_damage': numPropertyDamageController.text.isNotEmpty ? numPropertyDamageController.text : '0',
        'damage_description': damageDescriptionController.text,
        'impacted_remarks': impactedRemarksController.text,
        'current_control_measures': currentControlMeasuresController.text,
        'action_remarks': actionRemarksController.text,
        'zone_num': selectedZone,
        'risk_type': selectedRiskType,
        'risk_impact_level': selectedImpactLevel,
        'risk_probability_level': selectedProbabilityLevel,
        'risk_severity_level': selectedRiskSeverityLevel,
        'option_action': selectedAction,
      };

      var url = widget.isUpdateMode
          ? Uri.parse('http://localhost/bfeps/riskassessment_module/riskassessmentreport/update_report.php')
          : Uri.parse('http://localhost/bfeps/riskassessment_module/riskassessmentreport/save_report.php');

      var response = await http.post(url, body: json.encode(data), headers: {"Content-Type": "application/json"});

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      var responseBody = jsonDecode(response.body);
      if (response.statusCode == 200 && responseBody["success"] == true) {
        print('Data saved successfully');
        widget.onSave(data);

        setState(() {
          householdNameController.clear();
          riskDescriptionController.clear();
          numPerPWDController.clear();
          numSeniorCitizenController.clear();
          numInfantToddlerController.clear();
          numFloodFatalityController.clear();
          numPropertyDamageController.clear();
          damageDescriptionController.clear();
          impactedRemarksController.clear();
          currentControlMeasuresController.clear();
          actionRemarksController.clear();
          selectedZone = null;
          selectedRiskType = null;
          selectedImpactLevel = null;
          selectedProbabilityLevel = null;
          selectedRiskSeverityLevel = null;
          selectedAction = null;
        });

        ValidationDialog.showSuccessDialog(
          context,
          'Data saved successfully!',
          () {
            Navigator.pop(context);
            Navigator.pop(context);
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