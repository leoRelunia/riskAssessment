import 'package:bfems/pages/dashboard_page.dart';
import 'package:bfems/components/header_bar.dart';
import 'package:bfems/components/side_bar.dart';
import 'package:flutter/material.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BFEPS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF6F7F9),
        textSelectionTheme: const TextSelectionThemeData(
          selectionColor: Color.fromARGB(255, 199, 210, 255),
          cursorColor: Color(0xFF5576F5),
          selectionHandleColor: Color(0xFF5576F5),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const DashboardLayout(),
    );
  }
}

class DashboardLayout extends StatefulWidget {
  const DashboardLayout({super.key});

  @override
  State<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends State<DashboardLayout> {
  Widget _currentPage = const Dashboardpage();
  bool _isSidebarVisible = true;
  bool _isProfilingExpanded = false;
  bool _isRaReportExpanded = false;
  String _selectedMenu = 'Dashboard';

  void _selectPage(String menu, Widget page) {
    setState(() {
      _selectedMenu = menu;
      _currentPage = page;
    });
  }

  void _toggleSidebarVisibility() {
    setState(() {
      _isSidebarVisible = !_isSidebarVisible;
    });
  }

  void _toggleProfilingExpansion() {
    setState(() {
      _isProfilingExpanded = !_isProfilingExpanded;
    });
  }
  void _toggleRaReportExpansion() {
    setState(() {
      _isRaReportExpanded = !_isRaReportExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ResponsiveLayout(
        isSidebarVisible: _isSidebarVisible,
        isProfilingExpanded: _isProfilingExpanded,
        isRaReportExpanded: _isRaReportExpanded,
        selectedMenu: _selectedMenu,
        currentPage: _currentPage,
        onMenuSelect: _selectPage,
        onToggleSidebar: _toggleSidebarVisibility,
        onToggleProfiling: _toggleProfilingExpansion,
        onToggleRaReport: _toggleRaReportExpansion,
      ),
    );
  }
}

class ResponsiveLayout extends StatelessWidget {
  final bool isSidebarVisible;
  final bool isProfilingExpanded;
  final bool isRaReportExpanded;
  final String selectedMenu;
  final Widget currentPage;
  final Function(String, Widget) onMenuSelect;
  final VoidCallback onToggleSidebar;
  final VoidCallback onToggleProfiling;
  final VoidCallback onToggleRaReport;

  const ResponsiveLayout({
    required this.isSidebarVisible,
    required this.isProfilingExpanded,
    required this.isRaReportExpanded,
    required this.selectedMenu,
    required this.currentPage,
    required this.onMenuSelect,
    required this.onToggleSidebar,
    required this.onToggleProfiling,
    required this.onToggleRaReport,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isTabletOrMobile = constraints.maxWidth <= 1230;
        return Stack(
          children: [
            Row(
              children: [
                if (isSidebarVisible && !isTabletOrMobile)
                  SideBar(
                    isProfilingExpanded: isProfilingExpanded,
                    //isCalamityExpanded: isRaReportExpanded,
                    selectedMenu: selectedMenu,
                    onMenuSelect: onMenuSelect,
                    toggleProfiling: onToggleProfiling,
                    //toggleCalamity: onToggleRaReport,
                  ),
                Expanded(
                  child: Column(
                    children: [
                      HeaderBar(
                        onBurgerMenuTap: onToggleSidebar,
                      ),
                      Expanded(
                        child: currentPage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isSidebarVisible && isTabletOrMobile)
              GestureDetector(
                onTap: onToggleSidebar,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            if (isSidebarVisible && isTabletOrMobile)
              Align(
                alignment: Alignment.centerLeft,
                child: SideBar(
                  isProfilingExpanded: isProfilingExpanded,
                  //isCalamityExpanded: isRaReportExpanded,
                  selectedMenu: selectedMenu,
                  onMenuSelect: (menu, page) {
                    onMenuSelect(menu, page);
                    onToggleSidebar();
                  },
                  toggleProfiling: onToggleProfiling,
                  //toggleCalamity: onToggleRaReport,
                ),
              ),
          ],
        );
      },
    );
  }
}
