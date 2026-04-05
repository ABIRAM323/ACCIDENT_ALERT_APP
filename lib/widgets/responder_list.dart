import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../providers/location_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ResponderList extends StatelessWidget {
  const ResponderList({super.key});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      debugPrint('Could not launch phone app');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        if (!locationProvider.isAlertActivated || locationProvider.nearbyResponders.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              child: Text(
                'Responders',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: locationProvider.nearbyResponders.length,
              itemBuilder: (context, index) {
                final responder = locationProvider.nearbyResponders[index];
                
                IconData roleIcon;
                Color roleColor;

                // Determine if it's an official national helpline
                final isHelpline = responder.id.startsWith('helpline_');
                
                if (isHelpline) {
                  roleIcon = Icons.emergency;
                  roleColor = Colors.redAccent;
                } else {
                  switch (responder.role) {
                    case 'Doctor':
                      roleIcon = Icons.medical_services;
                      roleColor = Colors.blueAccent;
                      break;
                    case 'Nurse':
                      roleIcon = Icons.healing;
                      roleColor = Colors.cyanAccent;
                      break;
                    case 'Ambulance Driver':
                      roleIcon = Icons.airport_shuttle;
                      roleColor = Colors.orangeAccent;
                      break;
                    default:
                      roleIcon = Icons.person;
                      roleColor = Colors.white70;
                  }
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03), // Precision 3%
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.0), // Precision 1px
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _makePhoneCall(responder.phoneNumber),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: roleColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: roleColor.withOpacity(0.2),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Icon(roleIcon, color: roleColor, size: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      responder.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.badge, size: 14, color: Colors.white54),
                                        const SizedBox(width: 4),
                                        Flexible(
                                          child: Text(
                                            responder.role,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.white70,
                                              fontWeight: FontWeight.w500,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Icon(Icons.directions_run, size: 14, color: roleColor),
                                        const SizedBox(width: 4),
                                        Text(
                                          isHelpline 
                                              ? 'National' 
                                              : '${responder.distance} km',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: roleColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.phone, size: 14, color: Colors.white54),
                                        const SizedBox(width: 4),
                                        Text(
                                          responder.phoneNumber,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent.withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.call, color: Colors.greenAccent),
                                  onPressed: () => _makePhoneCall(responder.phoneNumber),
                                  tooltip: 'Call Responder',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
