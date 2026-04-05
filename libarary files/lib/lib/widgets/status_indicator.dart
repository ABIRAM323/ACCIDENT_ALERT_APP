import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';

class StatusIndicator extends StatelessWidget {
  const StatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        if (locationProvider.statusMessage.isEmpty) {
          return const SizedBox.shrink();
        }

        Color backgroundColor;
        Color textColor;
        IconData icon;

        if (locationProvider.statusMessage.contains('Error') ||
            locationProvider.statusMessage.contains('denied') ||
            locationProvider.statusMessage.contains('Unable')) {
          backgroundColor = Colors.red.shade50;
          textColor = Colors.red.shade900;
          icon = Icons.error_outline;
        } else if (locationProvider.statusMessage.contains('Found') ||
            locationProvider.statusMessage.contains('obtained')) {
          backgroundColor = Colors.green.shade50;
          textColor = Colors.green.shade900;
          icon = Icons.check_circle_outline;
        } else {
          backgroundColor = Colors.blue.shade50;
          textColor = Colors.blue.shade900;
          icon = Icons.info_outline;
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: textColor.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: textColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  locationProvider.statusMessage,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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
