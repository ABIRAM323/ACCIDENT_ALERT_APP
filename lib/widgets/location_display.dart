import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';

class LocationDisplay extends StatelessWidget {
  const LocationDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        final position = locationProvider.currentPosition;
        
        if (position == null) {
          return const SizedBox.shrink();
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03), // Precision 3%
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1.0, // Precision 1px
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.cyanAccent.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.cyanAccent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Your Current Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2), // Darker for high contrast
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      children: [
                        _buildCoordinateRow(
                          'Latitude',
                          position.latitude.toStringAsFixed(6),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Divider(color: Colors.white10, height: 1),
                        ),
                        _buildCoordinateRow(
                          'Longitude',
                          position.longitude.toStringAsFixed(6),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Divider(color: Colors.white10, height: 1),
                        ),
                        _buildCoordinateRow(
                          'Accuracy',
                          '±${position.accuracy.toStringAsFixed(1)} m',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        final coords = 
                            '${position.latitude}, ${position.longitude}';
                        Clipboard.setData(ClipboardData(text: coords));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF1E293B),
                            behavior: SnackBarBehavior.floating,
                            content: const Text(
                              'Coordinates copied to clipboard',
                              style: TextStyle(color: Colors.cyanAccent),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 16, color: Colors.cyanAccent),
                      label: const Text(
                        'Copy Coordinates',
                        style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCoordinateRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontFamily: 'monospace',
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
