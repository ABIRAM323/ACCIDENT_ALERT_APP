import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import '../widgets/emergency_button.dart';
import '../widgets/status_indicator.dart';
import '../widgets/hospital_list.dart';
import '../widgets/location_display.dart';
import '../widgets/responder_list.dart';
import '../widgets/brand_logo.dart';
import 'map_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 0 for Hospitals, 1 for Responders
  int _selectedView = 0;

  @override
  void initState() {
    super.initState();
    // Fetch nearby data immediately on launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LocationProvider>(context, listen: false).fetchNearbyDataOnly();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: BrandLogo(size: 32),
        ),
        title: const Text(
          'EMERGENCY ALERT',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.cyanAccent),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
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
                    // SOS Hub Header - Clean Glassmorphism
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 20,
                              left: 0,
                              right: 0,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const BrandLogo(size: 40, showBackground: true),
                                  const SizedBox(height: 10),
                                  Text(
                                    'SOS EMERGENCY HUB',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white.withOpacity(0.9),
                                      letterSpacing: 4.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Emergency SOS Button
                    const EmergencyButton(),
                    
                    const SizedBox(height: 24),
                    
                    // Status Indicator
                    if (locationProvider.statusMessage.isNotEmpty)
                      const StatusIndicator(),
                    
                    const SizedBox(height: 16),
                    
                    // Removed LocationDisplay from here - Moved to Profile
                    
                    // View Map Button
                    if (locationProvider.currentPosition != null &&
                        (locationProvider.nearbyHospitals.isNotEmpty ||
                         locationProvider.nearbyResponders.isNotEmpty))
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MapScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.map, color: Colors.cyanAccent),
                        label: const Text(
                          'VIEW REAL-TIME MAP',
                          style: TextStyle(
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.cyanAccent, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 16),
                    
                    // Custom Glass Row Toggle
                    if (locationProvider.nearbyHospitals.isNotEmpty || locationProvider.nearbyResponders.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.0),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final tabWidth = constraints.maxWidth / 2;
                            return Stack(
                              children: [
                                // Animated Background Pill
                                AnimatedPositioned(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOutCubic,
                                  top: 0,
                                  bottom: 0,
                                  left: _selectedView == 0 ? 0 : tabWidth,
                                  width: tabWidth,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _selectedView == 0 
                                          ? Colors.cyanAccent.withOpacity(0.2)
                                          : Colors.greenAccent.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(28),
                                      border: Border.all(
                                        color: _selectedView == 0
                                            ? Colors.cyanAccent.withOpacity(0.5)
                                            : Colors.greenAccent.withOpacity(0.5),
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                                // Text and Icons Layer
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () => setState(() => _selectedView = 0),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.local_hospital,
                                                  size: 18,
                                                  color: _selectedView == 0 ? Colors.cyanAccent : Colors.white54),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Hospitals',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: _selectedView == 0 ? Colors.cyanAccent : Colors.white54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () => setState(() => _selectedView = 1),
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.medical_services,
                                                  size: 18,
                                                  color: _selectedView == 1 ? Colors.greenAccent : Colors.white54),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Responders',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: _selectedView == 1 ? Colors.greenAccent : Colors.white54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      if (_selectedView == 0 && locationProvider.nearbyHospitals.isNotEmpty)
                        const HospitalList()
                      else if (_selectedView == 0 && locationProvider.nearbyHospitals.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('No hospitals found nearby.', textAlign: TextAlign.center),
                        )
                      else if (_selectedView == 1 && locationProvider.nearbyResponders.isNotEmpty)
                        const ResponderList()
                      else if (_selectedView == 1 && locationProvider.nearbyResponders.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('No responders found nearby.', textAlign: TextAlign.center),
                        ),
                    ],
                    
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
