import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import '../widgets/emergency_button.dart';
import '../widgets/status_indicator.dart';
import '../widgets/hospital_list.dart';
import '../widgets/location_display.dart';
import 'map_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.emergency,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Accident Alert',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Emergency Response System',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 2,
      ),
      body: SafeArea(
        child: Consumer<LocationProvider>(
          builder: (context, locationProvider, child) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Emergency Information Card
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 40,
                              color: Colors.blue,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Emergency Quick Response',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Press the emergency button below to:\n'
                              '• Get your current location\n'
                              '• Find nearby hospitals\n'
                              '• Navigate to the nearest facility',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Emergency Button
                    const EmergencyButton(),
                    
                    const SizedBox(height: 16),
                    
                    // Status Indicator
                    if (locationProvider.statusMessage.isNotEmpty)
                      const StatusIndicator(),
                    
                    const SizedBox(height: 16),
                    
                    // Location Display
                    if (locationProvider.currentPosition != null)
                      const LocationDisplay(),
                    
                    const SizedBox(height: 16),
                    
                    // View Map Button
                    if (locationProvider.currentPosition != null &&
                        locationProvider.nearbyHospitals.isNotEmpty)
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MapScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.map),
                        label: const Text('View Map'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 16),
                    
                    // Hospital List
                    if (locationProvider.nearbyHospitals.isNotEmpty)
                      const HospitalList(),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
