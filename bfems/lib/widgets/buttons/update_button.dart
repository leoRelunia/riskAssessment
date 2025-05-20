import 'package:flutter/material.dart';

class UpdateButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const UpdateButton({
    super.key,
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(
            color: Color(0xFF5076F5),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF5076F5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Icon(
              Icons.edit,
              color: Color(0xFF5076F5),
              size: 16,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              fontFamily: 'Poppins',
              color: Color(0xFF5076F5),
            ),
          ),
        ],
      ),
    );
  }
}