// ignore_for_file: file_names
import 'resident_details.dart';
import 'package:flutter/material.dart';
import '/widgets/search_bar.dart' as custom;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bfems/widgets/context/table.dart';

class IndividualPage extends StatefulWidget {
  const IndividualPage({super.key});

  @override
  _IndividualPageState createState() => _IndividualPageState();
}

class _IndividualPageState extends State<IndividualPage> {

  int _currentPage = 0;
  final int _itemsPerPage = 15;
  List<Map<String, dynamic>> _allRecords = [];
  String _searchQuery = ""; 

  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  Future<void> _fetchRecords() async {
    try {
      final url = Uri.parse('http://localhost/BFEPS-BDRRMC/api/profiling/individual_record.php');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          _allRecords = List<Map<String, dynamic>>.from(data);
        });
      } else {
        throw Exception('Failed to load records');
      }
    } catch (e) {
      print('Error fetching records: $e');
    }
  }

  List<Map<String, dynamic>> _getPaginatedRecords() {
    // Normalize search query: trim, lowercase, and remove commas
    String normalizedQuery = _searchQuery.trim().toLowerCase().replaceAll(',', '');

    // Split search query into words
    List<String> queryWords = normalizedQuery.split(RegExp(r'\s+'));

    List<Map<String, dynamic>> filteredRecords = _allRecords.where((record) {
      // Normalize full name (remove commas)
      String fullName = "${record['lname']} ${record['fname']} ${record['mname'] ?? ''} ${record['suffix'] ?? ''}"
          .replaceAll(',', '') // Remove hardcoded commas
          .trim()
          .toLowerCase();

      // Normalize address (remove commas)
      String address = "${record['hhstreet']} ${record['hhzone']} ${record['lot'] ?? ''}"
          .replaceAll(',', '') // Remove hardcoded commas
          .trim()
          .toLowerCase();

      // Contact and age (no need to modify)
      String contact = record['cnumber'].toString().trim();
      String age = record['age'].toString().trim();

      // search works even if user enters commas or not
      bool nameMatches = queryWords.every((word) => fullName.contains(word));
      bool addressMatches = queryWords.every((word) => address.contains(word));

      return nameMatches || addressMatches || contact.contains(normalizedQuery) || age.contains(normalizedQuery);
    }).toList();

    int start = _currentPage * _itemsPerPage;
    int end = start + _itemsPerPage;
    if (end > filteredRecords.length) {
      end = filteredRecords.length;
    }

    return filteredRecords.sublist(start, end);
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
      _currentPage = 0; 
    });
  }

  void _goToNextPage() {
    int totalFilteredRecords = _allRecords
        .where((record) =>
            record['lname'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            record['fname'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            record['cnumber'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            record['hhstreet'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            record['hhzone'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            record['lot'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
            record['age'].toString().toLowerCase().contains(_searchQuery.toLowerCase()))
        .length;

    int maxPages = (totalFilteredRecords / _itemsPerPage).ceil();

    if (_currentPage + 1 < maxPages) {
      setState(() {
        _currentPage++;
      });
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }

  Widget _buildPagination() {
    
    int start = _currentPage * _itemsPerPage + 1;
    int end = start + _itemsPerPage - 1;

    if (end > _allRecords.length) {
      end = _allRecords.length;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '$start-$end of ${_allRecords.length}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: 'Poppins',
            color: Color(0xFF9E9E9E),
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: _currentPage > 0 ? _goToPreviousPage : null,
              style: ElevatedButton.styleFrom(
                foregroundColor: Color(0xFF4B4B4B),
                shape: const CircleBorder(
                  side: BorderSide(color: Color(0xFFCCCCCC), width: 1),
                ),
                backgroundColor: Color(0xFFFFFFFF),
                padding: const EdgeInsets.all(5),
                minimumSize: const Size(40, 40),
              ),
              child: const Icon(Icons.navigate_before_rounded, color: Color(0xFF4B4B4B), size: 22),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: (_currentPage + 1) * _itemsPerPage < _allRecords.length ? _goToNextPage : null,
              style: ElevatedButton.styleFrom(
                foregroundColor: Color(0xFF4B4B4B),
                shape: const CircleBorder(
                  side: BorderSide(color: Color(0xFFCCCCCC), width: 1),
                ),
                backgroundColor: Color(0xFFFFFFFF),
                padding: const EdgeInsets.all(5),
                minimumSize: const Size(40, 40),
              ),
              child: const Icon(Icons.navigate_next_rounded, color: Color(0xFF4B4B4B), size: 22),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 31),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
              custom.SearchBar(onSearch: _updateSearchQuery),
              ],
            ),
            const SizedBox(height: 21),
            _buildIndividualTable(),
            const SizedBox(height: 20),
            _buildPagination(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildIndividualTable() {
    return Container(
      width: double.infinity,
      height: 700,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFCCCCCC)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          Expanded(
            child: _getPaginatedRecords().isEmpty
                ? const Center(
                    child: Text(    
                      'No Records available.',
                      style: TextStyle(
                        color: Color(0xFFCBCBCB),
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  )
                : _buildTableRows(),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFCCCCCC))),
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      child: Row(
        children: [
          const HeaderCellWidget(label: 'Full Name', flex: 3),
          const HeaderCellWidget(label: 'Address', flex: 4),
          const HeaderCellWidget(label: 'Age', flex: 1, center: true),
          const HeaderCellWidget(label: 'Gender', flex: 2, center: true),
          const HeaderCellWidget(label: 'Contact Number', flex: 2, center: true),
          const HeaderCellWidget(label: 'Pregnant', flex: 1, center: true),
          const HeaderCellWidget(label: 'PWD\'s', flex: 1, center: true),
          const HeaderCellWidget(label: 'Senior', flex: 1, center: true),
          const HeaderCellWidget(label: 'Underaged', flex: 1, center: true),
          const HeaderCellWidget(label: 'Action', flex: 1, center: true),
        ],
      ),
    );
  }
  
  Widget _buildTableRows() {
    List<Map<String, dynamic>> paginatedRecords = _getPaginatedRecords();
    return ListView.builder(
      itemCount: paginatedRecords.length,
      itemBuilder: (context, index) {
        final record = paginatedRecords[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFCCCCCC))),
          ),
          child: Row(
            children: [
              DataCellWidget(value: '${record['lname']}, ${record['fname']} ${record['mname'] ?? ''} ${record['suffix'] ?? ''}', flex: 3),
              DataCellWidget(value: '${record['hhstreet']}, ${record['hhzone']}, ${record['lot'] ?? ''} Barangay Buenavista', flex: 4),
              DataCellWidget(value: record['age'], flex: 1, center: true),
              DataCellWidget(value: record['gender'], flex: 2, center: true),
              DataCellWidget(value: record['cnumber'], flex: 2, center: true),
              DataCellWidget(value: record['pregnantcheck'], showIcon: true, flex: 1, center: true),
              DataCellWidget(value: record['pwdcheck'], showIcon: true, flex: 1, center: true),
              DataCellWidget(value: record['seniorcheck'], showIcon: true, flex: 1, center: true),
              DataCellWidget(value: record['underagedcheck'], showIcon: true, flex: 1, center: true),
              Expanded(
                flex: 1,
                child: Center(
                  child: PopupMenuWidget(
                    onSelected: (value) {
                      if (value == 'View') {
                        showDialog(
                           barrierDismissible: false,
                          context: context,
                          builder: (context) => ResidentDetailsDialog(residentData: record),
                        );
                      } else if (value == "Delete") {

                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}




