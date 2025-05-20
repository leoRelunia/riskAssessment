import 'package:flutter/material.dart';

class FormHelper {
  static InputDecoration inputDecoration(String label, {bool alignLabel = false}) {
    return InputDecoration(
      labelText: label,
      alignLabelWithHint: alignLabel,
      labelStyle: const TextStyle(
        color: Color(0xFFCBCBCB),
        fontFamily: 'Poppins',
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      border: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFCBCBCB))),
      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF4076F5), width: 2.0)),
      enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFCBCBCB), width: 1.5)),
      floatingLabelStyle: const TextStyle(color: Color(0xFF4076F5), fontFamily: 'Poppins'),
    );
  }

  static Widget buildTextField(String label, TextEditingController controller, {required bool isReadOnly, double height = 35}) {
    return SizedBox(
      height: height,
      child: TextField(
        controller: controller,
        readOnly: isReadOnly,
        maxLines: height > 35 ? (height ~/ 20) : 1, 
        decoration: inputDecoration(label, alignLabel: height > 35),
      ),
    );
  }

  static Widget buildTextBigField(String label, TextEditingController controller, {required bool isReadOnly, double height = 35}) {
  return SizedBox(
    child: TextField(
      controller: controller,
      readOnly: isReadOnly,
      maxLines: height > 35 ? (height ~/ 20) : 5, 
      keyboardType: TextInputType.multiline,
      decoration: inputDecoration(label),
    ),
  );
}
    
  static Widget buildDropdownField(String label, List<String> items, ValueChanged<String?> onChanged, {String? initialValue}) {
    return SizedBox(
      height: 35,
      child: DropdownButtonFormField<String>(
        decoration: inputDecoration(label, alignLabel: true),
        dropdownColor: Colors.white,
        value: null,
        items: items.map((value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Color(0xFF4B4B4B),
                fontWeight: FontWeight.w400,
              ),
            ),
          );
        }).toList(),
        menuMaxHeight: 200.0,
        isDense: true,
        onChanged: onChanged,
      ),
    );
  }
  
  static Widget buildDateField(BuildContext context, TextEditingController dbirthController, String label, {required bool isReadOnly}) {
    return GestureDetector(
      onTap: isReadOnly ? null : () async { 
        DateTime? picked = await showDatePicker(
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
        if (picked != null) {
          dbirthController.text = '${picked.toLocal()}'.split(' ')[0];
        }
      },
      child: AbsorbPointer(
        child: SizedBox(
          height: 35,
          child: TextField(
            controller: dbirthController,
            decoration: inputDecoration(label, alignLabel: true),
          ),
        ),
      ),
    );
  }
}
