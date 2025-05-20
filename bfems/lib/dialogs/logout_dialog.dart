import 'package:flutter/material.dart';

class LogoutDialog extends StatelessWidget {
  final VoidCallback onLogoutConfirmed;

  const LogoutDialog({super.key, required this.onLogoutConfirmed});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), 
      ),
      title: Center(
        child: const Text(
          'Logging Out',
          style: TextStyle(
            fontFamily: 'Poppins', 
            fontSize: 18, 
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min, 
        children: [
          Center(
            child: const Text(
              'Are you sure \n you want to log out?',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Poppins', 
                  fontSize: 14, 
                  fontWeight: FontWeight.w300,
                  color: Color(0xFF9E9E9E)),
            ),
          ),
          const SizedBox(height: 10), 
          SizedBox(
            width: 200, 
            child: const Divider(
              color: Color.fromARGB(255, 112, 112, 112), 
              thickness: 0.5, 
            ),
          ),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            SizedBox(
              width: 100, 
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); 
                },
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
                child: const Text('No'),
              ),
            ),
            const SizedBox(width: 20), 
            SizedBox(
              width: 100, 
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); 
                  onLogoutConfirmed();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF5576F5), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5), 
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Poppins', 
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                child: const Text('Yes'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
