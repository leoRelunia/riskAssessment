import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:bfems/constants/dropdown_options.dart';
import 'package:bfems/dialogs/validation_dialog.dart';
import 'package:bfems/widgets/context/form.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bfems/widgets/buttons/add_button.dart';
import 'package:bfems/widgets/buttons/save_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class FloodUpdatesPage extends StatefulWidget {
  const FloodUpdatesPage({super.key});

  @override
  _FloodUpdatesPageState createState() => _FloodUpdatesPageState();
}

class _FloodUpdatesPageState extends State<FloodUpdatesPage> {
  List<Map<String, dynamic>> _allRecords = [];

  @override
  void initState() {
    super.initState();
    _fetchRecords();
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
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AddButton(
                  label: 'Add Update',
                  onPressed: () {
                    _showUpdateForm(context, null, isViewMode: false); 
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildBlank(context),
          ],
        ),
    ),
    );
  }

Future<void> _fetchRecords() async {
    try {
      final url = Uri.parse('http://localhost/bfeps/riskassessment_module/floodupdate/get_update.php'); 
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          _allRecords = List<Map<String, dynamic>>.from(data);
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
          final url = Uri.parse('http://localhost/BFEPS/riskassessment_module/floodupdate/delete_report.php');
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

Widget _buildBlank(BuildContext context) {
  if (_allRecords.isEmpty) {
    return _buildEmpty();
  } else {
    return _buildListWithData(context, _allRecords);
  }
}

Widget _buildEmpty() {
  return Container(
    width: double.infinity,
    height: 700,
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFCCCCCC)),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Center(
            child: Text(
              'No Update(s) available.',
              style: TextStyle(
                color: Color(0xFFCBCBCB),
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
  void _showUpdateForm(BuildContext context, Map<String, dynamic>? existingData, {bool isViewMode = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: FloodUpdateForm(
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
          ),
        );
      },
    );
  }

Widget _buildListWithData(BuildContext context, List<Map<String, dynamic>> reports) {
  double screenWidth = MediaQuery.of(context).size.width; // Get screen width

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
    child: Column(
      children: [
        const SizedBox(height: 20),
        SizedBox(
          height: 500, // Adjust height as needed
          child: reports.isEmpty
              ? const Center(child: Text("No updates available."))
              : GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: screenWidth < 600
                        ? 1
                        : screenWidth < 900
                            ? 2
                            : screenWidth < 1200
                                ? 3
                                : 4, // Adjust number of columns based on screen width
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    return _buildUpdateCard(report, screenWidth); // Pass screenWidth
                  },
                ),
        ),
      ],
    ),
  );
}

Widget _buildUpdateCard(Map<String, dynamic> reports, double screenWidth) {
  double cardWidth = screenWidth / 4 - 24; // Maximum 4 columns
  if (screenWidth < 600) {
    cardWidth = screenWidth - 24; // Single column for small screens
  } else if (screenWidth < 900) {
    cardWidth = screenWidth / 2 - 24; // Two columns for medium screens
  } else if (screenWidth < 1200) {
    cardWidth = screenWidth / 3 - 24; // Three columns for larger screens
  }

  return Container(
    width: cardWidth,
    child: Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                color: const Color.fromARGB(255, 67, 132, 228),
                child: Text(
                  reports['created_at'] ?? "Unknown Time",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${reports['zone_num']}",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 23,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Flood Level: ${reports['flood_level']}",
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Flood Depth: ${reports['flood_depth']} ft",
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Notes: ${reports['notes']}",
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (reports['file_path'] != null && reports['file_path'].toString().isNotEmpty)
  Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        reports['file_path'],
        width: double.infinity,
        height: 180,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 180,
            color: Colors.grey[300],
            child: Center(
              child: Icon(Icons.broken_image, size: 40, color: Colors.grey[700]),
            ),
          );
        },
      ),
    ),
  ),
                      
                      
 /* if (reports['image_path'] != null && reports['image_path'].toString().isNotEmpty)
  Expanded(  // This makes the image take available space
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        'http://127.0.0.1/riskassessment_module/${reports['image_path']}',
        width: double.infinity,  // Take full width
        height: double.infinity, // Take full height (optional)
        fit: BoxFit.cover, // Ensure it fills the area properly
        errorBuilder: (context, error, stackTrace) => Icon( 
          Icons.broken_image, 
          size: 150, 
          color: const Color.fromARGB(255, 69, 102, 250), 
          ),
      ),
    ),
  ),*/
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 8,
            right: 8,
            child: PopupMenuButton<String>(
              color: Colors.white,
              onSelected: (value) {
                if (value == 'View') {
                  _showUpdateForm(context, reports, isViewMode: true);
                } else if (value == 'Delete') {
                  _deleteReport(reports['id']);
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem(
                    value: 'View',
                    child: Text(
                      'View',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'Delete',
                    child: Text(
                      'Delete',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ];
              },
              child: const Icon(Icons.more_vert),
            ),
          ),
        ],
      ),
    ),
  );
}


}


class FloodUpdateForm extends StatefulWidget{
  final Function(Map<String, dynamic>) onSave; 
  final Map<String, dynamic>? existingData; 
  final bool isViewMode;

  FloodUpdateForm({
    required this.onSave, 
    this.existingData, 
    this.isViewMode = false
  });

  @override
  _FloodUpdateFormState createState() => _FloodUpdateFormState();
}

class _FloodUpdateFormState extends State<FloodUpdateForm>{
  final TextEditingController floodDepthController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController imageController = TextEditingController();

  String? selectedZone;
  String? selectedFloodLevel;

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null){
      // Populate the fields with existing data if available
    imageController.text = widget.existingData!['image_cover'] ?? '';
    floodDepthController.text = widget.existingData!['flood_depth'] ?? '';
    notesController.text = widget.existingData!['notes'] ?? '';
    selectedZone = widget.existingData!['zone_num'];
    selectedFloodLevel = widget.existingData!['flood_level'];
    }
  }

 Future<void> _pickImage(TextEditingController imageController) async {
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
          imageController.text = imageUrl;  // Set the image URL in the controller
        });
      }
    }
  }

  Future<String?> _uploadImage({File? file, Uint8List? webBytes, required String fileName}) async {
    var request = http.MultipartRequest('POST', Uri.parse('http://localhost/bfeps/riskassessment_module/floodupdate/upload_image.php'));

    if (kIsWeb && webBytes != null) {
        request.files.add(http.MultipartFile.fromBytes('image_cover', webBytes, filename: fileName));
    } else if (file != null) {
        request.files.add(await http.MultipartFile.fromPath('image_cover', file.path));
    }

    try {
        var response = await request.send();
        if (response.statusCode == 200) {
            var responseData = await response.stream.bytesToString();
            var jsonData = json.decode(responseData);

            if (jsonData is Map<String, dynamic> && jsonData['success'] == true) {
                print("Image uploaded successfully: ${jsonData['filepath']}");
                return jsonData['filepath'];
            } else {
                print("Image upload failed: ${jsonData['error']}");
            }
        } else {
            print("Server error: ${response.statusCode}");
        }
    } catch (e) {
        print("Error uploading image: $e");
    }
    return null;
}

  Widget _buildImageCover(TextEditingController imageController) {
  String imageUrl = imageController.text.trim();
  String encodedUrl = Uri.encodeFull(imageUrl);

  print("Encoded Image URL: $encodedUrl");

  return Padding(
  padding: const EdgeInsets.only(right: 20),
  child: Row( // or Column, depending on layout
    children: [
      Expanded(
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 180,
                color: Colors.white,
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        encodedUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print("Image loading error: $error");
                          return Image.asset(
                            'assets/images/placeholder.png',
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Image.asset(
                        'assets/images/placeholder.png',
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            if (!widget.isViewMode)
              Positioned(
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
                      await _pickImage(imageController);
                      setState(() {});
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    ],
  ),
);
  }


/* Future<void> _pickImage() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    withData: true,
  );
  if (result != null) {
    setState(() {
      _selectedImageBytes = result.files.first.bytes;
      _selectedImageName = result.files.first.name;
    });
    print('Image Selected: $_selectedImageName, Bytes: ${_selectedImageBytes?.length}');
  } else {
    print('No image selected'); // Debugging
  }
}*/

  @override 
    Widget build(BuildContext context) {
      return SizedBox(
        width: 450,
        height: 680,
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color:const Color(0xFFCBCBCB))
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FLOOD UPDATE FORM',
                    style: TextStyle(
                      color: Color(0xFF5576F5),
                    fontSize: 24,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildForm({
                    'selectedZone' : selectedZone,
                    'selectedFloodLevel' : selectedFloodLevel,
                  }),
                ],
              ),
            ),
            _buildCloseButton(),
            if (!widget.isViewMode) _buildSaveButton(),
          ],
        ),
      );
    }
      Widget _buildForm(Map<String, String?> dropdownValues) {
  return Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        // Upload Image Section
        _buildImageCover(imageController),
    
    const SizedBox(height: 8),
   /*  Row(
  children: [
    Expanded(
      child: Center(
        child: Text(
          _selectedImageBytes != null
              ? 'Image Selected: $_selectedImageName'
              : 'No Image Selected',
          style: TextStyle(
            color: _selectedImageBytes != null
                ? const Color(0xFF5576F5)
                : Colors.black,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ),
  ],
),*/


        const SizedBox(height: 10),

        // Zone Dropdown
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                'Zone*',
                'selectedZone',
                zoneOptions,
                dropdownValues,
                isReadOnly: widget.isViewMode,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Flood Level + Help Icon
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                'Flood Level*',
                'selectedFloodLevel',
                floodLevelOptions,
                dropdownValues,
                isReadOnly: widget.isViewMode,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.help_outline, size: 20, color: Color(0xFF7A7A7A)),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: Image.asset(
                        'assets/images/floodlevel.png',
                        fit: BoxFit.fill,
                      ),
                    );
                  },
                );
              },
            ),
             Expanded(
              child: FormHelper.buildTextField(
                'Flood Depth*',
                floodDepthController,
                isReadOnly: widget.isViewMode,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'ft',
              style: TextStyle(
                color: Color(0xFF7A7A7A),
                fontSize: 12,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Notes Text Area
        Row(
          children: [
            Expanded(
              child: FormHelper.buildTextField(
                'Notes*',
                notesController,
                isReadOnly: widget.isViewMode,
                height: 250,
              ),
            ),
          ],
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
        onChanged: isReadOnly ? null : (newValue) {
          setState(() {
            if (key == 'selectedZone') {
              selectedZone = newValue;
            } else if (key == 'selectedFloodLevel') {
              selectedFloodLevel = newValue;
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
/* Widget _buildDateField(BuildContext context) {
  return GestureDetector(
    onTap: () async {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF4076F5),
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Color(0xFF4B4B4B),
              ),
              dialogBackgroundColor: Colors.white,
            ),
            child: child!,
          );
        },
      );

       if (pickedDate != null) {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                          builder: (BuildContext context, Widget? child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: const Color(0xFF5576F5),
                                  onPrimary: Colors.white,
                                  onSurface: Colors.black,
                                ),
                                dialogBackgroundColor: Colors.white,
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (pickedTime != null) {
                          final dateTime = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                          dateTimeController.text =
                              DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
                        }
                      }
                    },
                    
      child: AbsorbPointer(
        child: SizedBox(
          height: 35,
          child: TextField(
            controller: dateTimeController,
            decoration: _inputDecoration('Date/Time'),
          ),
        ),
      ),
    );
  }
*/
Future<void> _saveData(BuildContext context) async {
  if (imageController.text.isNotEmpty &&
      floodDepthController.text.isNotEmpty &&
      notesController.text.isNotEmpty &&
      selectedFloodLevel != null &&
      selectedZone != null) {
    
    try {
      // Convert image bytes to Base64 string

      final data = {
        'image_cover': imageController.text,
        'flood_depth': floodDepthController.text,
        'notes': notesController.text,
        'flood_level': selectedFloodLevel,
        'zone_num': selectedZone,
      };

       var url = Uri.parse('http://localhost/bfeps/riskassessment_module/floodupdate/save_update.php');

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
            floodDepthController.clear();
            notesController.clear();
            selectedZone = null;
            selectedFloodLevel = null;
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
