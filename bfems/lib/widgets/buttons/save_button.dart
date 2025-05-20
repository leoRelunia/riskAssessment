import 'package:flutter/material.dart';

class SaveButton extends StatelessWidget {
  final VoidCallback onPressed; 
  final String label;
  final Color backgroundColor;

  const SaveButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.backgroundColor = const Color(0xFF5076F5), 
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed, 
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: backgroundColor,
      ),
      child: Text(
        label, 
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          fontFamily: 'Poppins',
          color: Colors.white,
        ),
      ),
    );
  }
}
