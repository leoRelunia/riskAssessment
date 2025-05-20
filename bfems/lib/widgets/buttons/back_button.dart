import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback onPressed; 
  final String label;
  final Color backgroundColor;

  const CustomBackButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.backgroundColor = const Color.fromARGB(255, 82, 84, 91), 
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
