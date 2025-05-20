import 'package:flutter/material.dart';
import 'package:bfems/pages/risk_assessment/flood_updates.dart';
import 'package:bfems/pages/risk_assessment/ra_report_page.dart';
import 'package:google_fonts/google_fonts.dart';

class FloodRiskReports extends StatelessWidget {
  final void Function(String, Widget) onMenuSelect; // Declare the onMenuSelect function

  const FloodRiskReports({super.key, required this.onMenuSelect}); // Update constructor to accept onMenuSelect

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(50),
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/images/stats-bg2.png'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: SizedBox(
                        height: 90,
                        child: ElevatedButton(
                           onPressed: () {
                            // Call onMenuSelect with the appropriate parameters
                            onMenuSelect('FLood Updates', const FloodUpdatesPage());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(1),
                            foregroundColor: Color.fromARGB(255, 54, 124, 177),
                            side: const BorderSide(color: Color.fromARGB(255, 28, 80, 201)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text('Record of Flood', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: SizedBox(
                        height: 90,
                        child: ElevatedButton(
                          onPressed: () {
                            // Call onMenuSelect with the appropriate parameters
                            onMenuSelect('Risk Assessment Report', const RaReportPage());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(1),
                            foregroundColor: Color.fromARGB(255, 54, 124, 177),
                            side: const BorderSide(color: Color.fromARGB(255, 28, 80, 201)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Risk Assessment Report',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Calamities:',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 0.8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SizedBox(
                      height: 200,
                      child: ListView.builder(
                        itemCount: 0, // Update this with your actual data count
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text('Calamity #$index', style: GoogleFonts.poppins()),
                          );
                        },
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
}