import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import '../providers/user_provider.dart';

class StatusIndicator extends StatelessWidget {
  const StatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        if (locationProvider.statusMessage.isEmpty) {
          return const SizedBox.shrink();
        }

        Color accentColor;
        IconData icon;

        if (locationProvider.statusMessage.contains('Error') ||
            locationProvider.statusMessage.contains('denied') ||
            locationProvider.statusMessage.contains('Unable')) {
          accentColor = const Color(0xFFFF1744); // Neon Crimson
          icon = Icons.error_outline;
        } else if (locationProvider.statusMessage.contains('Found') ||
            locationProvider.statusMessage.contains('obtained')) {
          accentColor = const Color(0xFF00E676); // Emerald Green
          icon = Icons.check_circle_outline;
        } else {
          accentColor = const Color(0xFF00E5FF); // Electric Cyan
          icon = Icons.info_outline;
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: accentColor.withOpacity(0.3),
                  width: 1.0,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        icon,
                        color: accentColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          locationProvider.statusMessage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (locationProvider.nearbyHospitals.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Consumer<UserProvider>(
                      builder: (context, userProvider, child) {
                        return ElevatedButton.icon(
                          onPressed: () {
                            if (userProvider.userProfile != null) {
                              locationProvider.triggerEmergencySms(userProvider.userProfile!);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please complete your profile first')),
                              );
                            }
                          },
                          icon: const Icon(Icons.send_rounded, size: 20),
                          label: const Text(
                            'NOTIFY EMERGENCY CONTACT',
                            style: TextStyle(
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.1),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            elevation: 0,
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
