import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/location_provider.dart';
import '../models/hospital.dart';
import 'dart:io' show Platform;

class HospitalList extends StatelessWidget {
  const HospitalList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        final hospitals = locationProvider.nearbyHospitals;

        if (hospitals.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_hospital,
                  color: Colors.red.shade700,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Nearest Hospitals',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: hospitals.length,
              itemBuilder: (context, index) {
                return HospitalCard(
                  hospital: hospitals[index],
                  isNearest: index == 0,
                  userPosition: locationProvider.currentPosition!,
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class HospitalCard extends StatelessWidget {
  final Hospital hospital;
  final bool isNearest;
  final dynamic userPosition;

  const HospitalCard({
    super.key,
    required this.hospital,
    required this.isNearest,
    required this.userPosition,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isNearest ? 4 : 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isNearest ? Colors.green.shade300 : Colors.grey.shade200,
          width: isNearest ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showHospitalDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (isNearest)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'NEAREST',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (isNearest) const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hospital.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      hospital.address,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.directions_car,
                    size: 16,
                    color: Colors.blue.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${hospital.distanceText} away',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '~${hospital.estimatedDriveTime} min drive',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              if (hospital.rating != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.amber.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      hospital.rating!.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showNavigationOptions(context),
                      icon: const Icon(Icons.navigation, size: 18),
                      label: const Text('Navigate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (hospital.phoneNumber != null)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _callHospital(),
                        icon: const Icon(Icons.phone, size: 18),
                        label: const Text('Call'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNavigationOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Navigate with:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Google Maps option
            ListTile(
              leading: const Icon(Icons.map, color: Colors.blue),
              title: const Text('Google Maps'),
              subtitle: const Text('Open in Google Maps app or browser'),
              onTap: () {
                Navigator.pop(context);
                _launchGoogleMaps();
              },
            ),
            
            // Apple Maps option (iOS only)
            if (Platform.isIOS)
              ListTile(
                leading: const Icon(Icons.map, color: Colors.grey),
                title: const Text('Apple Maps'),
                subtitle: const Text('Open in Apple Maps'),
                onTap: () {
                  Navigator.pop(context);
                  _launchAppleMaps();
                },
              ),
            
            // Waze option
            ListTile(
              leading: const Icon(Icons.navigation, color: Colors.cyan),
              title: const Text('Waze'),
              subtitle: const Text('Open in Waze app'),
              onTap: () {
                Navigator.pop(context);
                _launchWaze();
              },
            ),
            
            // OpenStreetMap
            ListTile(
              leading: const Icon(Icons.map_outlined, color: Colors.green),
              title: const Text('OpenStreetMap'),
              subtitle: const Text('Open in browser'),
              onTap: () {
                Navigator.pop(context);
                _launchOSM();
              },
            ),
            
            // Generic geo: link (opens default map app)
            ListTile(
              leading: const Icon(Icons.smartphone, color: Colors.orange),
              title: const Text('Default Map App'),
              subtitle: const Text('Open in your device\'s default map app'),
              onTap: () {
                Navigator.pop(context);
                _launchDefaultMap();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchGoogleMaps() async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&origin=${userPosition.latitude},${userPosition.longitude}'
      '&destination=${hospital.latitude},${hospital.longitude}'
      '&travelmode=driving',
    );
    
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      print('Error launching Google Maps: $e');
    }
  }

  Future<void> _launchAppleMaps() async {
    final url = Uri.parse(
      'https://maps.apple.com/?saddr=${userPosition.latitude},${userPosition.longitude}'
      '&daddr=${hospital.latitude},${hospital.longitude}'
      '&dirflg=d',
    );
    
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      print('Error launching Apple Maps: $e');
    }
  }

  Future<void> _launchWaze() async {
    final url = Uri.parse(
      'https://waze.com/ul?ll=${hospital.latitude},${hospital.longitude}&navigate=yes',
    );
    
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      print('Error launching Waze: $e');
    }
  }

  Future<void> _launchOSM() async {
    final url = Uri.parse(
      'https://www.openstreetmap.org/directions?'
      'from=${userPosition.latitude},${userPosition.longitude}'
      '&to=${hospital.latitude},${hospital.longitude}'
      '&engine=fossgis_osrm_car',
    );
    
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      print('Error launching OSM: $e');
    }
  }

  Future<void> _launchDefaultMap() async {
    final url = Uri.parse(
      'geo:${hospital.latitude},${hospital.longitude}?q=${hospital.latitude},${hospital.longitude}(${Uri.encodeComponent(hospital.name)})',
    );
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to Google Maps if geo: doesn't work
        await _launchGoogleMaps();
      }
    } catch (e) {
      print('Error launching default map: $e');
      // Fallback to Google Maps
      await _launchGoogleMaps();
    }
  }

  void _callHospital() async {
    if (hospital.phoneNumber == null) return;

    final url = Uri.parse('tel:${hospital.phoneNumber}');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    } catch (e) {
      print('Error making phone call: $e');
    }
  }

  void _showHospitalDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              hospital.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.location_on, hospital.address),
            const SizedBox(height: 8),
            _buildDetailRow(
              Icons.directions_car,
              '${hospital.distanceText} away (${hospital.estimatedDriveTime} min drive)',
            ),
            if (hospital.phoneNumber != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow(Icons.phone, hospital.phoneNumber!),
            ],
            if (hospital.rating != null) ...[
              const SizedBox(height: 8),
              _buildDetailRow(
                Icons.star,
                'Rating: ${hospital.rating!.toStringAsFixed(1)}/5.0',
              ),
            ],
            const SizedBox(height: 8),
            _buildDetailRow(
              hospital.isOpen ? Icons.check_circle : Icons.cancel,
              hospital.isOpen ? 'Open Now' : 'Closed',
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showNavigationOptions(context);
                },
                icon: const Icon(Icons.navigation),
                label: const Text('Start Navigation'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
