
import 'package:flutter/material.dart';

class Dashboardpage extends StatelessWidget {
  const Dashboardpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            Center(
              child: Container(
                padding: const EdgeInsets.all(19),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/stats-bg2.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'BARANGAY FLOOD EVACUATION PLANNING SYSTEM',
                      style: _titleTextStyle,
                    ),
                    const Text(
                      'FOR THE BARANGAY DISASTER RISK REDUCTION MANAGEMENT COUNCIL IN BARANGAY BUENAVISTA, SAN FERNANDO, CAMARINES SUR.',
                      style: _subtitleTextStyle,
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 15,
                      runSpacing: 10,
                      children: [
                        _buildStatCard('400', 'POPULATION', 'assets/images/population-icon.png'),
                        _buildStatCard('200', 'FAMILIES', 'assets/images/families-icon.png'),
                        _buildStatCard('200', 'FEMALES', 'assets/images/female-icon.png'),
                        _buildStatCard('150', 'MALES', 'assets/images/male-icon.png'),
                        _buildStatCard('50', 'LGBTQIA+', 'assets/images/lgbtq-icon.png'),
                        _buildStatCard('80', 'UNDERAGED', 'assets/images/underaged-icon.png'),
                        _buildStatCard('30', 'SENIORS', 'assets/images/seniors-icon.png'),
                        _buildStatCard('18', 'PWDS', 'assets/images/pwd-icon.png'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildChartContainer('Flood History of Barangay Buenavista'),
                        const SizedBox(height: 25),
                        _buildChartContainer('Typhoon History of Barangay Buenavista'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 25),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 565,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Lorem Ipsum',
                            style: _sectionTitleTextStyle,
                          ),
                          const Text(
                            'Display any relevant information about the barangay/flood/ or ongoing typhoon etc/ or shortcut keys sa RA or EM',
                            style: _sectionSubtitleTextStyle,
                          ),
                          const SizedBox(height: 10),
                          const SizedBox(
                            height: 180,
                            child: Placeholder(color: Color(0xFF5576F5)),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            child: Divider(
                              color: Color(0xFFCBCBCB),
                              thickness: 1,
                            ),
                          ),
                          const Text(
                            'Evacuation Center Information Board',
                            style: _sectionTitleTextStyle,
                          ),
                          const Text(
                            'Bagyong Kristen',
                            style: _sectionSubtitleTextStyle,
                          ),
                          const SizedBox(height: 10),
                          const SizedBox(
                            height: 180,
                            child: Placeholder(color: Color(0xFF5576F5)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const TextStyle _titleTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    fontFamily: 'Poppins',
  );

  static const TextStyle _subtitleTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    fontFamily: 'Poppins',
  );

  static const TextStyle _sectionTitleTextStyle = TextStyle(
    color: Color(0xFF4B4B4B),
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle _sectionSubtitleTextStyle = TextStyle(
    color: Color(0xFF878787),
    fontSize: 12,
  );

  static Widget _buildStatCard(String value, String label, String imagePath) {
    return Container(
      width: 181,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(181, 255, 255, 255),
        border: Border.all(color: const Color.fromARGB(34, 255, 255, 255)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF4B4B4B),
              fontSize: 32,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Image.asset(imagePath, width: 30, height: 30),
              const SizedBox(width: 7),
              Text(
                label,
                style: const TextStyle(
                  color: Color.fromARGB(255, 121, 121, 121),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildChartContainer(String title) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF4B4B4B),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          const SizedBox(
            height: 200,
            child: Placeholder(color: Color(0xFF5576F5)),
          ),
        ],
      ),
    );
  }
}
