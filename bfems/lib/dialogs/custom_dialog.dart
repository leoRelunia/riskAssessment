import 'package:flutter/material.dart';

class CustomDialog {
  static void showSuccessDialog(
      BuildContext context, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: Colors.white,
        title: DefaultTextStyle(
          style: TextStyle(
              fontSize: 18, fontFamily: 'Poppins', fontWeight: FontWeight.w600),
          child: const Text('Success'),
        ),
        content: DefaultTextStyle(
          style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
          child: Text(message),
        ),
        actions: [
          TextButton(
            onPressed: onConfirm,
            style: TextButton.styleFrom(
              side: const BorderSide(color: Color(0xFF5576F5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              foregroundColor: const Color(0xFF5576F5),
              textStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }

  // 'Please fill in all fields marked with \'*\' '

  static void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: Colors.white,
        title: DefaultTextStyle(
          style: TextStyle(fontSize: 18, fontFamily: 'Poppins', fontWeight: FontWeight.w600),
          child: const Text('Error!'),
        ),
        content: DefaultTextStyle(
          style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
          child: Text(message),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              side: const BorderSide(color: Color(0xFF5576F5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              foregroundColor: const Color(0xFF5576F5),
              textStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }
}
