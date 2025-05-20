import 'package:flutter/material.dart';
import '/dialogs/logout_dialog.dart'; 
import '/login.dart';

class HeaderBar extends StatefulWidget {
  final VoidCallback onBurgerMenuTap;

  const HeaderBar({super.key, required this.onBurgerMenuTap});

  @override
  _HeaderBarState createState() => _HeaderBarState();
}

class _HeaderBarState extends State<HeaderBar> {
  bool _isHovered = false; 

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFC0C0C0)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              MouseRegion(
                onEnter: (_) => _onHover(true), 
                onExit: (_) => _onHover(false), 
                child: GestureDetector(
                  onTap: widget.onBurgerMenuTap,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isHovered
                          ? Color(0xFFE1E1E1)
                          : Colors.transparent, 
                    ),
                    padding: const EdgeInsets.all(10), 
                    child: Image.asset(
                      'assets/images/burger-icon.png',
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
              ),
              Image.asset(
                'assets/images/bfeps-logo.png',
                width: 150,
                height: 40,
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.only(right: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: const Color(0xFFB6B6B6)),
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/profile-picture.png',
                  width: 45,
                  height: 45,
                ),
                const Text(
                  'Secretary',
                  style: TextStyle(
                    color: Color(0xFF878787),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(width: 50),
                GestureDetector(
                  onTap: () {
                    _showLogoutDialog(context);
                  },
                  child: Image.asset(
                    'assets/images/logout-button.png',
                    width: 35,
                    height: 35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onHover(bool isHovering) {
    setState(() {
      _isHovered = isHovering;
    });
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext context) {
        return LogoutDialog(
          onLogoutConfirmed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Login()),
            );
          },
        );
      },
    );
  }
}
