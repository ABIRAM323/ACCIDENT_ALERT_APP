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

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.my_location,
                      color: Colors.blue.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Your Current Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _buildCoordinateRow(
                        'Latitude',
                        position.latitude.toStringAsFixed(6),
                      ),
                      const SizedBox(height: 8),
                      _buildCoordinateRow(
                        'Longitude',
                        position.longitude.toStringAsFixed(6),
                      ),
                      const SizedBox(height: 8),
                      _buildCoordinateRow(
                        'Accuracy',
                        '±${position.accuracy.toStringAsFixed(1)} m',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        final coords = 
                            '${position.latitude}, ${position.longitude}';
                        Clipboard.setData(ClipboardData(text: coords));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Coordinates copied to clipboard'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy Coordinates'),
                    ),
                  ],
                ),
              ],
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
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
