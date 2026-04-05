import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';

class EmergencyButton extends StatelessWidget {
  const EmergencyButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        final isActivated = locationProvider.isAlertActivated;
        final isLoading = locationProvider.isLoading;

        return GestureDetector(
          onTap: isLoading
              ? null
              : () {
                  if (isActivated) {
                    locationProvider.deactivateAlert();
                  } else {
                    locationProvider.activateEmergencyAlert();
                  }
                },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isActivated
                    ? [Colors.green.shade400, Colors.green.shade700]
                    : [Colors.red.shade400, Colors.red.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (isActivated ? Colors.green : Colors.red)
                      .withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: isLoading
                    ? null
                    : () {
                        if (isActivated) {
                          locationProvider.deactivateAlert();
                        } else {
                          locationProvider.activateEmergencyAlert();
                        }
                      },
                child: Center(
                  child: isLoading
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Processing...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isActivated
                                  ? Icons.check_circle
                                  : Icons.emergency,
                              color: Colors.white,
                              size: 40,
                            ),
                            const SizedBox(width: 16),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isActivated
                                      ? 'ALERT ACTIVATED'
                                      : 'TAP FOR EMERGENCY',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isActivated
                                      ? 'Tap to deactivate'
                                      : 'One tap emergency response',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
