import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({super.key});

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return _buildSearchBar();
  }

  Widget _buildSearchBar() {
    return Container(
      width: 300,
      height: 40,
      padding: const EdgeInsets.only(left: 13, right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFCCCCCC)),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                border: InputBorder.none,
                hintStyle: const TextStyle(
                  color: Color(0xFFCCCCCC),
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          MouseRegion(
            onEnter: (_) => setState(() => _isHovering = true),
            onExit: (_) => setState(() => _isHovering = false),
            child: GestureDetector(
              onTap: () {
                // add search logic 
              },
              child: Icon(
                Icons.search,
                color: _isHovering ? Color(0xFF5576F5) : const Color(0xFF979797),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
