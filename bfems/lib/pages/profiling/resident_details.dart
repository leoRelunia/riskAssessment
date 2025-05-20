import 'package:bfems/widgets/buttons/update_button.dart';
import 'package:flutter/material.dart';
import 'package:bfems/widgets/buttons/save_button.dart';
import 'package:bfems/widgets/context/form.dart';

class ResidentDetailsDialog extends StatefulWidget {
  final Map<String, dynamic> residentData;
  bool isViewMode; 

  ResidentDetailsDialog({required this.residentData, this.isViewMode = false});

  @override
  _ResidentDetailsDialogState createState() => _ResidentDetailsDialogState();
}

class _ResidentDetailsDialogState extends State<ResidentDetailsDialog> {
  late TextEditingController profileController;
  late TextEditingController fnameController;
  late TextEditingController mnameController;
  late TextEditingController lnameController;
  late TextEditingController suffixController;
  late TextEditingController aliasController;
  late TextEditingController hhzoneController;
  late TextEditingController hhstreetController;
  late TextEditingController lotController;
  late TextEditingController cnumberController;
  late TextEditingController dbirthController;
  late TextEditingController ageController;
  late TextEditingController genderController;
  late TextEditingController cstatusController;
  late TextEditingController religionController;
  late TextEditingController educationController;
  late TextEditingController occupationController;
  late TextEditingController beneficiaryController;
  late TextEditingController pregnantController;
  late TextEditingController disabilityController;
  late TextEditingController hhtypeController;

  @override
  void initState() {
    super.initState();
    profileController = TextEditingController(text: widget.residentData['profilepicture']);
    fnameController = TextEditingController(text: widget.residentData['fname']);
    mnameController = TextEditingController(text: widget.residentData['mname'] ?? 'N/A');
    lnameController = TextEditingController(text: widget.residentData['lname']);
    suffixController = TextEditingController(text: widget.residentData['suffix'] ?? 'N/A');
    aliasController = TextEditingController(text: widget.residentData['alias'] ?? 'N/A');
    hhzoneController = TextEditingController(text: widget.residentData['hhzone']);
    hhstreetController = TextEditingController(text: widget.residentData['hhstreet']);
    lotController = TextEditingController(text: widget.residentData['lot'] ?? 'N/A');
    cnumberController = TextEditingController(text: widget.residentData['cnumber']);
    dbirthController = TextEditingController(text: widget.residentData['dbirth']);
    ageController = TextEditingController(text: widget.residentData['age'].toString());
    genderController = TextEditingController(text: widget.residentData['gender']);
    cstatusController = TextEditingController(text: widget.residentData['cstatus']);
    religionController = TextEditingController(text: widget.residentData['religion']);
    educationController = TextEditingController(text: widget.residentData['education']);
    occupationController = TextEditingController(text: widget.residentData['occupation']);
    beneficiaryController = TextEditingController(text: widget.residentData['beneficiary']);
    pregnantController = TextEditingController(text: widget.residentData['pregnant']);
    disabilityController = TextEditingController(text: widget.residentData['disability']);
    hhtypeController = TextEditingController(text: widget.residentData['hhtype']);
  }

  Widget _buildRow(List<Widget> children) {
    return Row(
      children: children
          .expand((widget) => [Expanded(child: widget), const SizedBox(width: 8)])
          .toList()
        ..removeLast(),
    );
  }

  Widget _buildProfileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfilePictureSection(profileController),
            Expanded(
              child: Column(
                children: [
                  _buildRow([
                    FormHelper.buildTextField('First Name', fnameController, isReadOnly: widget.isViewMode),
                    FormHelper.buildTextField('Middle Name', mnameController, isReadOnly: widget.isViewMode),
                    FormHelper.buildTextField('Last Name', lnameController, isReadOnly: widget.isViewMode),
                    FormHelper.buildTextField('Suffix', suffixController, isReadOnly: widget.isViewMode),
                    FormHelper.buildTextField('Alias', aliasController, isReadOnly: widget.isViewMode),
                  ]),
                  const SizedBox(height: 10),
                  _buildRow([
                    FormHelper.buildTextField('Zone', hhzoneController, isReadOnly: widget.isViewMode),
                    FormHelper.buildTextField('Street', hhstreetController, isReadOnly: widget.isViewMode),
                    FormHelper.buildTextField('Lot', lotController, isReadOnly: widget.isViewMode),
                    FormHelper.buildTextField('Contact Number', cnumberController, isReadOnly: widget.isViewMode),
                  ]),
                  const SizedBox(height: 10),
                  _buildRow([
                    FormHelper.buildDateField(context, dbirthController, 'Date of Birth', isReadOnly: widget.isViewMode),
                    FormHelper.buildTextField('Age', ageController, isReadOnly: widget.isViewMode),
                    FormHelper.buildTextField('Gender', genderController, isReadOnly: widget.isViewMode),
                  ]),
                  const SizedBox(height: 10),
                  _buildRow([
                    FormHelper.buildTextField('Civil Status', cstatusController, isReadOnly: widget.isViewMode),
                    FormHelper.buildTextField('Religion', religionController, isReadOnly: widget.isViewMode),
                  ]),
                  const SizedBox(height: 10),
                  _buildRow([
                    FormHelper.buildTextField('Education Attainment', educationController, isReadOnly: widget.isViewMode),
                    FormHelper.buildTextField('Occupation', occupationController, isReadOnly: widget.isViewMode),
                    FormHelper.buildTextField("4p's", beneficiaryController, isReadOnly: widget.isViewMode),
                  ]),
                  const SizedBox(height: 10),
                  _buildRow([
                    FormHelper.buildTextField('Pregnant', pregnantController, isReadOnly: widget.isViewMode),
                    FormHelper.buildTextField('Disability', disabilityController, isReadOnly: widget.isViewMode),
                    FormHelper.buildTextField('Household Member Type', hhtypeController, isReadOnly: widget.isViewMode),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormContainer() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCCCCCC), width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      height: 300,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildProfileSection(),
        ],
      ),
    );
  }

  Widget _buildProfilePictureSection(TextEditingController profilePictureController) {
    String imageUrl = profilePictureController.text.trim();
    String encodedUrl = Uri.encodeFull(imageUrl);

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
          if (!widget.isViewMode) // Only show the edit button if not in view mode
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
                    // Implement image picking functionality here
                    setState(() {});
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size; 
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), 
      ),
      child: Stack(
        children: [
          Container(
            width: screenSize.width * 0.6, 
            height: screenSize.height * 0.48, 
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
                  'INDIVIDUAL DATA FORM',
                  style: TextStyle(
                    color: Color(0xFF5576F5),
                    fontSize: 24,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                _buildFormContainer(),
                const SizedBox(height: 10),
                _buildButtonRow(),
              ],
            ),
          ),
          _buildCloseButton(), 
        ],
      ),
    );
  }

  Widget _buildButtonRow() {
    return Column(
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _buildViewHouseholdButton(),
            const SizedBox(width: 10),
            if (!widget.isViewMode) _buildSaveButton(),
            if (widget.isViewMode) _buildUpdateButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SaveButton(
      onPressed: () {
        _saveData();
      },
      label: 'Save',
    );
  }

  Widget _buildUpdateButton() {
    return UpdateButton(
      onPressed: () {
        setState(() {
          widget.isViewMode = false; // Toggle view mode to edit mode
        });
      },
      label: 'Edit', 
    );
  }

  Widget _buildViewHouseholdButton() {
    return TextButton(
      onPressed: () {
        // Implement the functionality to view the household
        // For example, navigate to the household details page
      },
      child: const Text(
        'View Household',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          fontFamily: 'Poppins',
          color: Color(0xFF878787),
          decoration: TextDecoration.underline,
        ),
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

  void _saveData() {
    // Prepare the data to be saved
    Map<String, dynamic> data = {
      'profilepicture': profileController.text,
      'fname': fnameController.text,
      'mname': mnameController.text,
      'lname': lnameController.text,
      'suffix': suffixController.text,
      'alias': aliasController.text,
      'hhzone': hhzoneController.text,
      'hhstreet': hhstreetController.text,
      'lot': lotController.text,
      'cnumber': cnumberController.text,
      'dbirth': dbirthController.text,
      'age': ageController.text,
      'gender': genderController.text,
      'cstatus': cstatusController.text,
      'religion': religionController.text,
      'education': educationController.text,
      'occupation': occupationController.text,
      'beneficiary': beneficiaryController.text,
      'pregnant': pregnantController.text,
      'disability': disabilityController.text,
      'hhtype': hhtypeController.text,
    };

    // Print the data being saved for debugging
    print("Data being saved: $data");

    // Here you would typically call your API to save the data
    // For example:
    // saveResidentData(data);
  }

  @override
  void dispose() {
    profileController.dispose();
    fnameController.dispose();
    mnameController.dispose();
    lnameController.dispose();
    suffixController.dispose();
    aliasController.dispose();
    hhzoneController.dispose();
    hhstreetController.dispose();
    lotController.dispose();
    cnumberController.dispose();
    dbirthController.dispose();
    ageController.dispose();
    genderController.dispose();
    cstatusController.dispose();
    religionController.dispose();
    educationController.dispose();
    occupationController.dispose();
    beneficiaryController.dispose();
    pregnantController.dispose();
    disabilityController.dispose();
    hhtypeController.dispose();
    super.dispose();
  }
}