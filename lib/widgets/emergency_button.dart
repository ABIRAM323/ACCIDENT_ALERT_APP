import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../providers/location_provider.dart';
import 'brand_logo.dart';

class EmergencyButton extends StatefulWidget {
  const EmergencyButton({super.key});

  @override
  State<EmergencyButton> createState() => _EmergencyButtonState();
}

class _EmergencyButtonState extends State<EmergencyButton> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: false);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        final isActivated = locationProvider.isAlertActivated;
        final isCountingDown = locationProvider.isCountingDown;
        final isLoading = locationProvider.isLoading;
        
        final activeColor = const Color(0xFF00E676); // Vibrant Emerald Green
        final inactiveColor = const Color(0xFFFF1744); // Neon Crimson
        final countingColor = Colors.cyanAccent;
        
        Color baseColor = inactiveColor;
        if (isActivated) {
          baseColor = activeColor;
        } else if (isCountingDown) {
          baseColor = countingColor;
        }
        
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
          child: Center(
            child: SizedBox(
              width: 240, // Increased size for 'massive' feel
              height: 240,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Layer 2: The Animated Expanding 'Breathing' Ring
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Opacity(
                          opacity: (1.0 - _pulseController.value) * 0.5,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: baseColor.withOpacity(0.8),
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: baseColor.withOpacity(0.6),
                                  blurRadius: 30,
                                  spreadRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  // Layer 1: The Core Button with 3D Effect
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        // Massive outer glow
                        BoxShadow(
                          color: baseColor.withOpacity(0.4),
                          blurRadius: 50,
                          spreadRadius: 10,
                        ),
                        // 3D Rim Highlight
                        BoxShadow(
                          color: Colors.white.withOpacity(0.15),
                          blurRadius: 1,
                          spreadRadius: 1,
                          offset: const Offset(0, -2),
                        ),
                        // Bottom Depth Shadow
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 15,
                          spreadRadius: 2,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: baseColor.withOpacity(0.2),
                            border: Border.all(
                              color: baseColor.withOpacity(0.6),
                              width: 2,
                            ),
                            gradient: RadialGradient(
                              colors: [
                                baseColor.withOpacity(0.4),
                                baseColor.withOpacity(0.1),
                              ],
                              stops: const [0.0, 1.0],
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: isLoading
                                  ? null
                                  : () {
                                      if (isCountingDown) {
                                        locationProvider.cancelCountdown();
                                      } else if (isActivated) {
                                        locationProvider.deactivateAlert();
                                      } else {
                                        locationProvider.activateEmergencyAlert();
                                      }
                                    },
                              child: Center(
                                child: isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 4,
                                      )
                                    : Text(
                                        isCountingDown 
                                            ? 'CANCEL\n(${locationProvider.countdownSeconds}s)'
                                            : (isActivated ? 'SOS ACTIVE' : 'SOS'),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isCountingDown ? 24 : 32,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: isCountingDown ? 1.0 : 4.0,
                                          shadows: const [
                                            Shadow(
                                              color: Colors.black45,
                                              offset: Offset(0, 2),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
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
}
