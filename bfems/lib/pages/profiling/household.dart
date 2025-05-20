// ignore_for_file: must_be_immutable
import 'package:bfems/widgets/buttons/save_button.dart';
import 'package:bfems/widgets/buttons/update_button.dart';
import 'package:bfems/widgets/buttons/add_button.dart';
import 'package:bfems/widgets/context/form.dart';
import 'package:bfems/widgets/context/table.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:bfems/constants/dropdown_options.dart';
import 'package:bfems/dialogs/validation_dialog.dart';
import '/widgets/search_bar.dart' as custom;

class HouseholdPage extends StatefulWidget {
  const HouseholdPage({super.key});

  @override
  _HouseholdPageState createState() => _HouseholdPageState();
}

class _HouseholdPageState extends State<HouseholdPage> {
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
        final url = Uri.parse('http://localhost/BFEPS-BDRRMC/api/profiling/get_hhdata.php');
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
  
  void _deleteHouseholdRecord(String householdId) async {
    ValidationDialog.showDeleteDialog(
      context: context, 
      message: 'Are you sure you want to delete this record?',
      onConfirm: () async {
        Navigator.of(context).pop(); 
        try {
          final url = Uri.parse('http://localhost/BFEPS-BDRRMC/api/profiling/delete_hhdata.php');
          final response = await http.post(url, body: {'household_id': householdId});
          if (response.statusCode == 200) {
            var responseData = json.decode(response.body);
            if (responseData['success'] == true) {
              // Refresh reports
              await _fetchRecords();
              print('Record deleted successfully');
            } else {
              print('Failed to delete record: ${responseData['message']}');
            }
          } else {
            print('Failed to connect to the server');
          }
        } catch (e) {
          print('Error deleting record: $e');
        }
      },
    );
  }


  List<Map<String, dynamic>> _getPaginatedRecords() {
    // Normalize search query: trim, lowercase, and remove commas
    String normalizedQuery = _searchQuery.trim().toLowerCase().replaceAll(',', '');

    // Split search query into words
    List<String> queryWords = normalizedQuery.split(RegExp(r'\s+'));

    List<Map<String, dynamic>> filteredRecords = _allRecords.where((record) {
        // Normalize full name (remove commas)
        String fullName = "${record['residents'][0]['lname']} ${record['residents'][0]['fname']} ${record['residents'][0]['mname'] ?? ''} ${record['residents'][0]['suffix'] ?? ''}"
            .replaceAll(',', '') // Remove hardcoded commas
            .trim()
            .toLowerCase();

        // Normalize address (remove commas)
        String address = "${record['hhstreet']} ${record['hhzone']} ${record['lot'] ?? ''}"
            .replaceAll(',', '') // Remove hardcoded commas
            .trim()
            .toLowerCase();

        // Normalize contact number and age
        String contact = record['residents'][0]['cnumber'].toString().trim();
        String age = record['residents'][0]['age'].toString().trim();

        // Check if any of the fields match the search query
        bool nameMatches = queryWords.any((word) => fullName.contains(word));
        bool addressMatches = queryWords.any((word) => address.contains(word));
        bool contactMatches = queryWords.any((word) => contact.contains(word));
        bool ageMatches = queryWords.any((word) => age.contains(word));

        return nameMatches || addressMatches || contactMatches || ageMatches;
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
        .where((record) =>
            record['lname'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            record['fname'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            record['cnumber'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            record['hhstreet'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            record['hhzone'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            record['lot'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            record['age'].toString().toLowerCase().contains(_searchQuery.toLowerCase()))
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
                  label: 'Add Record',
                  onPressed: () {
                    _showOverlayForm(context,  null, isViewMode: false);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildHouseholdTable(),
            const SizedBox(height: 20), 
            _buildPagination(),
          ],
        ),
      ),
    );
  }

  Widget _buildHouseholdTable() {
    return Container(
      width: double.infinity,
      height: 700,
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
          const HeaderCellWidget(label: 'Household Head', flex: 3),
          const HeaderCellWidget(label: 'Address', flex: 4),
          const HeaderCellWidget(label: 'Age', flex: 1, center: true),
          const HeaderCellWidget(label: 'Gender', flex: 2, center: true),
          const HeaderCellWidget(label: 'Contact Number', flex: 2, center: true),
          const HeaderCellWidget(label: 'Pregnant', flex: 1, center: true),
          const HeaderCellWidget(label: 'PWD\'s', flex: 1, center: true),
          const HeaderCellWidget(label: 'Senior', flex: 1, center: true),
          const HeaderCellWidget(label: 'Underaged', flex: 1, center: true),
          const HeaderCellWidget(label: 'Members', flex: 1, center: true),
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
        final record = paginatedRecords[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFCCCCCC))),
          ),
          child: Row(
            children: [
              DataCellWidget(value: '${record['residents'][0]['lname']}, ${record['residents'][0]['fname']} ${record['residents'][0]['mname'] ?? ''} ${record['residents'][0]['suffix'] ?? ''}', flex: 3),
              DataCellWidget(value: '${record['hhstreet']}, ${record['hhzone']}, ${record['lot'] ?? ''} Barangay Buenavista', flex: 4),
              DataCellWidget(value: '${record['residents'][0]['age']}', flex: 1, center: true),
              DataCellWidget(value: '${record['residents'][0]['gender']}', flex: 2, center: true),
              DataCellWidget(value: '${record['residents'][0]['cnumber']}', flex: 2, center: true),
              DataCellWidget(value: record['PregnantCount'] ?? '0', flex: 1, center: true),
              DataCellWidget(value: record['PWDCount'] ?? '0', flex: 1, center: true),
              DataCellWidget(value: record['SeniorCount'] ?? '0', flex: 1, center: true),
              DataCellWidget(value: record['UnderagedCount'] ?? '0', flex: 1, center: true),
              DataCellWidget(value: record['HouseholdMembersCount'] ?? '0', flex: 1, center: true),
              Expanded(
                flex: 1,
                child: Center(
                  child: PopupMenuWidget(
                    onSelected: (value) {
                      if (value == 'View') {
                        _showOverlayForm(context, record, isViewMode: true);
                      } else if (value == 'Update') {
                        _showOverlayForm(context, record, isViewMode: false);
                      } else if (value == 'Delete') {
                        _deleteHouseholdRecord(record['household_id']);
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

  void _showOverlayForm(BuildContext context, Map<String, dynamic>? existingData, {bool isViewMode = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: PersonalInfoForm(
            onSave: (newRecord) {
              print("Received data from form: $newRecord"); // Print the received data
              setState(() {
                // Update the existing record in _allRecords without refreshing counts
                if (existingData != null) {
                  int index = _allRecords.indexWhere((record) => record['household_id'] == existingData['household_id']);
                  if (index != -1) {
                    _allRecords[index] = newRecord; // Update the existing record
                  }
                } else {
                  _allRecords.add(newRecord); // Add new record if existingData is null
                }
              });
              _fetchRecords(); // Fetch updated records
            },
            existingData: existingData,
            isViewMode: isViewMode,
            isUpdateMode: existingData != null, // Set update mode if existing data is provided
          ),
        );
      },
    );
  }
}

class PersonalInfoForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave; 
  final Map<String, dynamic>? existingData; 
  bool isViewMode; 
  final bool isUpdateMode;

  PersonalInfoForm({
    required this.onSave, 
    this.existingData, 
    this.isViewMode = false, 
    this.isUpdateMode = false,
  });

  @override
  _PersonalInfoFormState createState() => _PersonalInfoFormState();
}

class _PersonalInfoFormState extends State<PersonalInfoForm> {

  final Map<String, TextEditingController> controllers = {
    'profilepicture': TextEditingController(),
    'fname': TextEditingController(),
    'mname': TextEditingController(),
    'lname': TextEditingController(),
    'suffix': TextEditingController(),
    'alias': TextEditingController(),
    'hhstreet': TextEditingController(),
    'lot': TextEditingController(),
    'cnumber': TextEditingController(),
    'dbirth': TextEditingController(),
    'age': TextEditingController(),
  };

  final Map<String, String?> dropdownValues = {
    'hhzone': null,
    'cstatus': null,
    'religion': null,
    'gender': null,
    'education': null,
    'occupation': null,
    'beneficiary': null,  
    'pregnant': null,
    'disability': null,
    'hhtype': null,
    'materialused': null,
    'toiletfacility': null,
    'meansofcommunication': null,
    'sourceofwater': null,
    'electricity': null,
    'hhwith': null,
    'familyincome': null,
  };
  
  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
        // Initialize variables to hold household head and members
        Map<String, dynamic>? householdHead;
        List<Map<String, dynamic>> members = [];

        // Loop through residents to find the household head
        for (var member in widget.existingData!['residents']) {
            if (member['hhtype'] == 'Head of the Household') {
                householdHead = member; // Store household head
            } else {
                members.add(member); // Store other members
            }
        }

        // Populate the fields with household head data if available
        if (householdHead != null) {
            controllers['profilepicture']!.text = householdHead['profilepicture'] ?? '';
            controllers['fname']!.text = householdHead['fname'] ?? '';
            controllers['mname']!.text = householdHead['mname'] ?? '';
            controllers['lname']!.text = householdHead['lname'] ?? '';
            controllers['suffix']!.text = householdHead['suffix'] ?? '';
            controllers['alias']!.text = householdHead['alias'] ?? '';
            controllers['hhstreet']!.text = widget.existingData!['hhstreet'] ?? '';
            controllers['lot']!.text = widget.existingData!['lot'] ?? '';
            controllers['cnumber']!.text = householdHead['cnumber'] ?? '';
            controllers['dbirth']!.text = householdHead['dbirth'] ?? '';
            controllers['age']!.text = householdHead['age'] ?? '';

            // Populate dropdown values for household head
            dropdownValues['hhzone'] = widget.existingData!['hhzone'] as String?;
            dropdownValues['cstatus'] = householdHead['cstatus'] as String?;
            dropdownValues['religion'] = householdHead['religion'] as String?;
            dropdownValues['gender'] = householdHead['gender'] as String?;
            dropdownValues['education'] = householdHead['education'] as String?;
            dropdownValues['occupation'] = householdHead['occupation'] as String?;
            dropdownValues['beneficiary'] = householdHead['beneficiary'] as String?;
            dropdownValues['pregnant'] = householdHead['pregnant'] as String?;
            dropdownValues['disability'] = householdHead['disability'] as String?;
            dropdownValues['hhtype'] = householdHead['hhtype'] as String?;
            dropdownValues['materialused'] = widget.existingData!['materialused'] as String?;
            dropdownValues['toiletfacility'] = widget.existingData!['toiletfacility'] as String?;
            dropdownValues['meansofcommunication'] = widget.existingData!['meansofcommunication'] as String?;
            dropdownValues['sourceofwater'] = widget.existingData!['sourceofwater'] as String?;
            dropdownValues['electricity'] = widget.existingData!['electricity'] as String?;
            dropdownValues['hhwith'] = widget.existingData!['hhwith'] as String?;
            dropdownValues['familyincome'] = widget.existingData!['familyincome'] as String?;
        }

        // Populate household members if available
        for (var member in members) {
            householdMembers.add({
                'resident_id': member['resident_id'], 
                'controllers': {
                    'profilepicture': TextEditingController(text: member['profilepicture'] ?? ''),
                    'fname': TextEditingController(text: member['fname'] ?? ''),
                    'mname': TextEditingController(text: member['mname'] ?? ''),
                    'lname': TextEditingController(text: member['lname'] ?? ''),
                    'suffix': TextEditingController(text: member['suffix'] ?? ''),
                    'alias': TextEditingController(text: member['alias'] ?? ''),
                    'cnumber': TextEditingController(text: member['cnumber'] ?? ''),
                    'dbirth': TextEditingController(text: member['dbirth'] ?? ''),
                    'age': TextEditingController(text: member['age'] ?? ''),
                },
                'dropdownValues': {
                    'cstatus': member['cstatus'] as String?,
                    'religion': member['religion'] as String?,
                    'gender': member['gender'] as String?,
                    'education': member['education'] as String?,
                    'occupation': member['occupation'] as String?,
                    'beneficiary': member['beneficiary'] as String?,
                    'pregnant': member['pregnant'] as String?,
                    'disability': member['disability'] as String?,
                    'hhtype': member['hhtype'] as String?,
                },
            });
        }
    }
  }

  // For additional household members
  List<Map<String, dynamic>> householdMembers = [];

  void _addHouseholdMember() {
    setState(() {
      // Generate a temporary ID for the new member
      String tempId = DateTime.now().millisecondsSinceEpoch.toString(); // Used timestamp as a temporary ID
      householdMembers.add({
        'resident_id': tempId, // Assign the temporary ID
        'controllers': {
          'profilepicture': TextEditingController(),
          'fname': TextEditingController(),
          'mname': TextEditingController(),
          'lname': TextEditingController(),
          'suffix': TextEditingController(),
          'alias': TextEditingController(),
          'cnumber': TextEditingController(),
          'dbirth': TextEditingController(),
          'age': TextEditingController(),
        },
        'dropdownValues': {
          'hhzone': '',
          'cstatus': '',
          'religion': '',
          'gender': '',
          'education': '',
          'occupation': '',
          'beneficiary': '',
          'pregnant': '',
          'disability': '',
          'hhtype': '',
        },
      });
    });
  }

  void _deleteHouseholdMember(int index) {
    String memberId = householdMembers[index]['resident_id'];

    ValidationDialog.showDeleteDialog(
      context: context,
      message: 'Are you sure you want to delete this profile?',
      onConfirm: () async {
        Navigator.of(context).pop(); 

        if (memberId.startsWith('temp_')) {
          setState(() {
            householdMembers.removeAt(index);
          });
        } else {
          try {
            final url = Uri.parse('http://localhost/BFEPS-BDRRMC/api/profiling/delete_member.php');
            final response = await http.post(url, body: {'resident_id': memberId});

            if (response.statusCode == 200) {
              var responseData = json.decode(response.body);
              if (responseData['success'] == true) {
                setState(() {
                  householdMembers.removeAt(index);
                });
                print('Member deleted successfully');
              } else {
                print('Failed to delete member: ${responseData['message']}');
              }
            } else {
              print('Failed to connect to the server');
            }
          } catch (e) {
            print('Error deleting member: $e');
          }
        }
      },
    );
  }


  @override //dispose also the dropdowns
  void dispose() {
    controllers.values.forEach((controller) => controller.dispose());
    for (var member in householdMembers) {
      member['controllers']
          .values
          .forEach((controller) => controller.dispose());
    }
    super.dispose();
  }


  Future<void> _pickImage(TextEditingController profilePictureController) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      Uint8List? webImage;
      File? image;

      if (kIsWeb) {
        webImage = result.files.first.bytes;
      } else {
        image = File(result.files.single.path!);
      }

      String? imageUrl = await _uploadImage(
        file: image,
        webBytes: webImage,
        fileName: result.files.first.name,
      );

      if (imageUrl != null) {
        setState(() {
          profilePictureController.text = imageUrl;  // Set the image URL in the controller
        });
      }
    }
  }

  Future<String?> _uploadImage({File? file, Uint8List? webBytes, required String fileName}) async {

    var request = http.MultipartRequest('POST', Uri.parse('http://localhost/BFEPS-BDRRMC/api/profiling/upload_image.php'));

    if (kIsWeb && webBytes != null) {
      request.files.add(http.MultipartFile.fromBytes('profilepicture', webBytes, filename: fileName));
    } else if (file != null) {
      request.files.add(await http.MultipartFile.fromPath('profilepicture', file.path));
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonData = json.decode(responseData);

      if (jsonData is Map<String, dynamic> && jsonData['success'] == true) {
        print("Image uploaded successfully: ${jsonData['filepath']}"); // Log success

        return jsonData['filepath']; 
      }
    }
    return null;
  }

  Widget _buildProfilePictureSection(TextEditingController profilePictureController) {
    String imageUrl = profilePictureController.text.trim();
    String encodedUrl = Uri.encodeFull(imageUrl); 

    print("Encoded Profile Picture URL: $encodedUrl"); 

    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Stack(
        children: [
          CircleAvatar(
            radius: 90,
            backgroundColor: Colors.white,
            backgroundImage: imageUrl.isNotEmpty
                ? NetworkImage(encodedUrl) as ImageProvider
                : const AssetImage('assets/images/profile-placeholder.png'),
            onBackgroundImageError: (error, stackTrace) {
              print("Image loading error: $error");
            },
          ),
           if (!widget.isViewMode) Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFF1F1F1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: IconButton(
                icon: Icon(
                  imageUrl.isNotEmpty ? Icons.edit : Icons.camera_alt,
                  color: Color(0xFF9E9E9E),
                  size: 25,
                ),
                onPressed: () async {
                  await _pickImage(profilePictureController);
                  setState(() {}); 
                },
              ),
            ),
          ),
        ],
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
        onChanged: isReadOnly ? null :  (newValue) {
          setState(() {
            dropdownValues[key] = newValue ?? ''; 
            print("Updated $key to $newValue, dropdownValues: $dropdownValues");
          });
        },
      ),
    );
  }
  
  Widget _buildProfileSection(Map<String, TextEditingController> controllers, Map<String, String?> dropdownValues, {VoidCallback? onDelete, bool isHouseholdHead = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfilePictureSection(controllers['profilepicture']!),
            Expanded(
              child: Column(
                children: [
                  _buildRow([
                    FormHelper.buildTextField('Firstname*', controllers['fname']!, isReadOnly: widget.isViewMode),
                    FormHelper.buildTextField('Middlename', controllers['mname']!, isReadOnly: widget.isViewMode),
                    FormHelper.buildTextField('Lastname*', controllers['lname']!, isReadOnly: widget.isViewMode),
                    FormHelper.buildTextField('Suffix', controllers['suffix']!, isReadOnly: widget.isViewMode),
                    FormHelper.buildTextField('Alias', controllers['alias']!, isReadOnly: widget.isViewMode),
                  ]),
                  const SizedBox(height: 10),
                  if (isHouseholdHead) ...[
                    _buildRow([
                      FormHelper.buildTextField('Street*', controllers['hhstreet']!, isReadOnly: widget.isViewMode),
                      _buildDropdown('Zone*', 'hhzone', zoneOptions, dropdownValues, isReadOnly: widget.isViewMode),
                      FormHelper.buildTextField('Lot No*', controllers['lot']!, isReadOnly: widget.isViewMode),
                      FormHelper.buildTextField('Contact Number', controllers['cnumber']!, isReadOnly: widget.isViewMode),
                    ]),
                  ] else ...[
                    FormHelper.buildTextField('Contact Number', controllers['cnumber']!, isReadOnly: widget.isViewMode),
                  ],
                  const SizedBox(height: 10),
                  _buildRow([
                    FormHelper.buildDateField(context, controllers['dbirth']!, 'Date of Birth*', isReadOnly: widget.isViewMode),
                    FormHelper.buildTextField('Age*', controllers['age']!, isReadOnly: widget.isViewMode),
                    _buildDropdown('Gender*', 'gender', genderOptions, dropdownValues, isReadOnly: widget.isViewMode),
                  ]),
                  const SizedBox(height: 10),
                  _buildRow([
                    _buildDropdown('Civil Status*', 'cstatus', civilStatusOptions, dropdownValues, isReadOnly: widget.isViewMode),
                    _buildDropdown('Religion*', 'religion', religionOptions, dropdownValues, isReadOnly: widget.isViewMode),
                  ]),
                  const SizedBox(height: 10),
                  _buildRow([
                    _buildDropdown('Education Attainment*', 'education', educationOptions, dropdownValues, isReadOnly: widget.isViewMode),
                    _buildDropdown('Occupation*', 'occupation', occupationOptions, dropdownValues, isReadOnly: widget.isViewMode),
                    _buildDropdown("4p's Beneficiary*", 'beneficiary', beneficiaryOptions, dropdownValues, isReadOnly: widget.isViewMode),
                  ]),
                  const SizedBox(height: 10),
                  _buildRow([
                    _buildDropdown('Pregnant*', 'pregnant', pregnantOptions, dropdownValues, isReadOnly: widget.isViewMode),
                    _buildDropdown('Disability*', 'disability', disabilityOptions, dropdownValues, isReadOnly: widget.isViewMode),
                    _buildDropdown('Household Member Type*', 'hhtype', householdMemberTypeOptions, dropdownValues, isReadOnly: widget.isViewMode),
                  ]),
                ],
              ),
            ),
            if (!widget.isViewMode) if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete, color: Color(0xFFF55555)),
                onPressed: onDelete,
              ),
          ],
        ),
        const SizedBox(height: 10),
        const Divider(thickness: 1.8, color: Color(0xFFCBCBCB)),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1400,
      height: 840,
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
                  'HOUSEHOLD DATA FORM',
                  style: TextStyle(
                    color: Color(0xFF5576F5),
                    fontSize: 24,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                _buildFormContainer(),
                const SizedBox(height: 15), 
                _buildHouseholdDetailsSection(dropdownValues),
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
      bottom: 24,
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

  Widget _buildFormContainer() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCCCCCC), width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      height: 600,
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: Column(
          children: [
            // Household Head
            _buildProfileSection(controllers, dropdownValues, isHouseholdHead: true),
            // Household Members
            ...householdMembers.asMap().entries.map((entry) =>
              _buildProfileSection(
                entry.value['controllers'],
                entry.value['dropdownValues'],
                onDelete: () => _deleteHouseholdMember(entry.key),
                isHouseholdHead: false, 
              ),
            ),
             if (!widget.isViewMode) Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.add, color: Color(0xFF9E9E9E)),
                onPressed: _addHouseholdMember,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimestamp(String label, String? timestamp) {
    if (timestamp == null) return SizedBox.shrink();
    return Text(
      '$label $timestamp',
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 12,
        color: Color(0xFFCBCBCB),
        fontWeight: FontWeight.w400,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildHouseholdDetailsSection(Map<String, String?> dropdownValues) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRow([
          _buildDropdown('Construction Materials Used*', 'materialused', constructionMaterialOptions, dropdownValues, isReadOnly: widget.isViewMode),
          _buildDropdown('Toilet Facility*', 'toiletfacility', toiletFacilityOptions, dropdownValues, isReadOnly: widget.isViewMode),
          _buildDropdown('Means of Communication*', 'meansofcommunication', meansOfCommunicationOptions, dropdownValues, isReadOnly: widget.isViewMode),
          _buildDropdown('Source of Water*', 'sourceofwater', sourceOfWaterOptions, dropdownValues, isReadOnly: widget.isViewMode),
        ]),
        const SizedBox(height: 10),
        _buildRow([
          _buildDropdown('Electricity*', 'electricity', electricityOptions, dropdownValues, isReadOnly: widget.isViewMode),
          _buildDropdown('HH with..*', 'hhwith', hhWithOptions, dropdownValues, isReadOnly: widget.isViewMode),
          _buildDropdown('Family Income*', 'familyincome', familyIncomeOptions, dropdownValues, isReadOnly: widget.isViewMode),
        ]),
        const SizedBox(height: 10),
        if (widget.existingData != null)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTimestamp('Created At:', widget.existingData!['household_created_at']),
                _buildTimestamp('Updated At:', widget.existingData!['household_updated_at']),
              ],
            ),
          ),
      ],
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
      bottom: 24,
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
    // Required fields for validation
    List<String> requiredControllers = ['fname', 'lname', 'dbirth', 'age'];
    List<String> requiredDropdowns = [
        'cstatus', 'religion', 'gender', 'education', 
        'occupation', 'beneficiary', 'pregnant', 
        'disability', 'hhtype'
    ];
    List<String> requiredHouseholdFields = [
        'hhstreet', 'hhzone', 'lot', 'materialused', 
        'toiletfacility', 'meansofcommunication', 
        'sourceofwater', 'electricity', 'hhwith', 'familyincome'
    ];

    bool hasError = false;
    String errorMessage = "";

    // Validation logic
    for (var field in requiredHouseholdFields) {
        if (controllers.containsKey(field) && controllers[field]!.text.trim().isEmpty) {
            hasError = true;
            errorMessage = "Please fill in all required household details.";
            break;
        }
        if (dropdownValues.containsKey(field) && (dropdownValues[field] == null || dropdownValues[field].toString().trim().isEmpty)) {
            hasError = true;
            errorMessage = "Please select all required household options.";
            break;
        }
    }

    for (var field in requiredControllers) {
        if (controllers[field]!.text.trim().isEmpty) {
            hasError = true;
            errorMessage = "Please fill in all fields marked with an asterisk *";
            break;
        }
    }

    for (var field in requiredDropdowns) {
        if (dropdownValues[field] == null || dropdownValues[field].toString().trim().isEmpty) {
            hasError = true;
            errorMessage = "Please select all required personal details.";
            break;
        }
    }

    for (var member in householdMembers) {
        for (var field in requiredControllers) {
            if (member['controllers'][field]!.text.trim().isEmpty) {
                hasError = true;
                errorMessage = "Please fill in all required details for household members.";
                break;
            }
        }
        for (var field in requiredDropdowns) {
            if (member['dropdownValues'][field] == null || member['dropdownValues'][field].toString().trim().isEmpty) {
                hasError = true;
                errorMessage = "Please select all required options for household members.";
                break;
            }
        }
    }

    if (hasError) {
        ValidationDialog.showErrorDialog(context, errorMessage);
        return;
    }

    // Prepare the data for saving
    var data = {
      'household_id': widget.existingData?['household_id'], 
      'hhstreet': toCamelCase(controllers['hhstreet']!.text),
      'hhzone': dropdownValues['hhzone'],
      'lot': controllers['lot']!.text,
      'materialused': dropdownValues['materialused'],
      'toiletfacility': dropdownValues['toiletfacility'],
      'meansofcommunication': dropdownValues['meansofcommunication'],
      'sourceofwater': dropdownValues['sourceofwater'],
      'electricity': dropdownValues['electricity'],
      'hhwith': dropdownValues['hhwith'],
      'familyincome': dropdownValues['familyincome'],
      'residents': [
        // Household head
        {
          'id': widget.existingData?['residents'][0]['resident_id'], 
          'profilepicture': controllers['profilepicture']!.text,
          'fname': toCamelCase(controllers['fname']!.text),
          'mname': toCamelCase(controllers['mname']!.text),
          'lname': toCamelCase(controllers['lname']!.text),
          'suffix': toCamelCase(controllers['suffix']!.text),
          'alias': toCamelCase(controllers['alias']!.text),
          'cnumber': controllers['cnumber']!.text,
          'cstatus': dropdownValues['cstatus'],
          'religion': dropdownValues['religion'],
          'dbirth': controllers['dbirth']!.text,
          'age': controllers['age']!.text, 
          'gender': dropdownValues['gender'],
          'education': dropdownValues['education'],
          'occupation': dropdownValues['occupation'],
          'beneficiary': dropdownValues['beneficiary'],
          'pregnant': dropdownValues['pregnant'],
          'disability': dropdownValues['disability'],
          'hhtype': dropdownValues['hhtype'],
        },
        // Household Members
        ...householdMembers.map((member) {    
            return {
              'id': member['resident_id'], // Ensure resident_id is included for each member
              'profilepicture': member['controllers']['profilepicture']!.text,
              'fname': toCamelCase(member['controllers']['fname']!.text),
              'mname': toCamelCase(member['controllers']['mname']!.text),
              'lname': toCamelCase(member['controllers']['lname']!.text),
              'suffix': toCamelCase(member['controllers']['suffix']!.text),
              'alias': toCamelCase(member['controllers']['alias']!.text),
              'cnumber': member['controllers']['cnumber']!.text,
              'cstatus': member['dropdownValues']['cstatus'],
              'religion': member['dropdownValues']['religion'],
              'dbirth': member['controllers']['dbirth']!.text,
              'age': member['controllers']['age']!.text,
              'gender': member['dropdownValues']['gender'],
              'education': member['dropdownValues']['education'],
              'occupation': member['dropdownValues']['occupation'],
              'beneficiary': member['dropdownValues']['beneficiary'],
              'pregnant': member['dropdownValues']['pregnant'],
              'disability': member['dropdownValues']['disability'],
              'hhtype': member['dropdownValues']['hhtype'],
            };
        }).toList(),
      ]
    };

    // Log the state of the input fields before the API call
    print("Input Field States:");
    controllers.forEach((key, controller) {
        print("$key: ${controller.text}");
    });
    dropdownValues.forEach((key, value) {
        print("$key: $value");
    });
    print("Household Members: $householdMembers");
    
    // Print the data being sent to the API
    print("Data being sent to the API: ${json.encode(data)}");

    // Determine the URL based on whether it's an update or a new record
    var url = widget.isUpdateMode 
        ? Uri.parse('http://localhost/BFEPS-BDRRMC/api/profiling/update_hhdata.php') // Update URL
        : Uri.parse('http://localhost/BFEPS-BDRRMC/api/profiling/save_hhdata.php'); // Save URL

    var response = await http.post(url, body: json.encode(data), headers: {"Content-Type": "application/json"});

    if (response.statusCode == 200) {
        var responseData = json.decode(response.body);        
        if (responseData['success'] == true) {
            // Clear the controllers and dropdown values
            controllers.forEach((key, controller) => controller.clear());
            dropdownValues.forEach((key, value) => dropdownValues[key] = null);
            householdMembers.clear();

            print('Data saved successfully');

            // Call the onSave callback to refresh records
            widget.onSave(data); // Call the callback here
        
            // Show success dialog
            ValidationDialog.showSuccessDialog(
                context,
                "Data saved successfully!",
                () {
                    Navigator.pop(context); // Close the dialog
                    Navigator.pop(context); // Close the form dialog
                }
            );
            // Debugging: Check if the state is updated
              print("State updated with new data: $data");
        } else {
            // Handle the case where the response indicates failure
            ValidationDialog.showErrorDialog(context, "Error: ${responseData['message']}");
        }
    } else {
        ValidationDialog.showErrorDialog(context, "Failed to connect to the server");
    }
  }
}
