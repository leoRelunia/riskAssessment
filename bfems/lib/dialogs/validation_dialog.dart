import 'package:flutter/material.dart';

class ValidationDialog {
  static void _showDialog({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onConfirm,
    IconData? icon,
    Color iconColor = const Color(0xFF5576F5),
    String confirmText = 'Ok',
    Color confirmTextColor = const Color(0xFF5576F5),
    Color confirmBgColor = Colors.transparent,
    Color confirmBorderColor = const Color(0xFF5576F5),
    VoidCallback? onCancel,
    String? cancelText,
    Color? cancelTextColor,
    Color? cancelBorderColor,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            if (icon != null) Icon(icon, color: iconColor, size: 28),
            if (icon != null) const SizedBox(width: 5),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: RichText(
          text: _highlightAsterisk(message),
        ),
        actions: [
          if (cancelText != null)
            TextButton(
              onPressed: onCancel ?? () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                side: BorderSide(color: cancelBorderColor ?? const Color(0xFFF55555)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                foregroundColor: cancelTextColor ?? const Color(0xFFF55555),
                textStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              child: Text(cancelText),
            ),
          TextButton(
            onPressed: onConfirm ?? () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: confirmBgColor,
              side: BorderSide(color: confirmBorderColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              foregroundColor: confirmTextColor,
              textStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  static void showSuccessDialog(BuildContext context, String message, VoidCallback onConfirm) {
    _showDialog(
      context: context,
      title: 'Success',
      message: message,
      onConfirm: onConfirm,
      icon: Icons.check_circle_outline,
      iconColor: const Color(0xFF5576F5),
    );
  }

  static void showErrorDialog(BuildContext context, String message) {
    _showDialog(
      context: context,
      title: 'Error!',
      message: message,
      icon: Icons.error_outline,
      iconColor: const Color(0xFF5576F5),
    );
  }

  static void showDeleteDialog({
    required BuildContext context,
    required String message,
    required VoidCallback onConfirm,
  }) {
    _showDialog(
      context: context,
      title: 'Confirm Deletion',
      message: message,
      onConfirm: onConfirm,
      icon: Icons.highlight_remove_rounded,
      iconColor: const Color(0xFFF55555),
      confirmText: 'Delete',
      confirmTextColor: Colors.white,
      confirmBgColor: const Color(0xFFF55555),
      confirmBorderColor: const Color(0xFFF55555),
      cancelText: 'Cancel',
      cancelTextColor: const Color(0xFFF55555),
      cancelBorderColor: const Color(0xFFF55555),
    );
  }

  static TextSpan _highlightAsterisk(String message) {
    return TextSpan(
      children: message.split('').map((char) {
        return TextSpan(
          text: char,
          style: TextStyle(
            fontSize: char == '*' ? 20 : 14,
            fontWeight: char == '*' ? FontWeight.w500 : FontWeight.normal,
            color: char == '*' ? const Color(0xFF5576F5) : const Color(0xFF9E9E9E),
          ),
        );
      }).toList(),
    );
  }

  static void showDiscardChangesDialog({required BuildContext context, required Null Function() onDiscard}) {}
}