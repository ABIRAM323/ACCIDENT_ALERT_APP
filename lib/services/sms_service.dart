import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import '../models/hospital.dart';
import 'package:geolocator/geolocator.dart';
import 'package:twilio_flutter/twilio_flutter.dart';

class SmsService {
  late TwilioFlutter _twilioFlutter;

  SmsService() {
    // IMPORTANT: Replace these placeholders with your actual Twilio credentials
    _twilioFlutter = TwilioFlutter(
      accountSid: 'YOUR ACCOUNT SID', // e.g., 'AC...'
      authToken: 'YOUR AUTH TOKEN',   // e.g., '123...'
      twilioNumber: 'YOUR TWILLO NUMBER', // e.g., '+1234567890'
    );
  }

  /// Sends an instant SMS using Twilio API
  Future<void> sendTwilioSms({
    required String contactNumber,
    required String message,
  }) async {
    try {
      // Basic E.164 formatting if needed
      String formattedNumber = contactNumber.trim();
      
      // Auto-prepend +91 if it's a 10-digit number (common for India)
      if (formattedNumber.length == 10 && RegExp(r'^[0-9]+$').hasMatch(formattedNumber)) {
        formattedNumber = '+91$formattedNumber';
        debugPrint('Auto-prepended +91 to 10-digit number: $formattedNumber');
      } else if (!formattedNumber.startsWith('+')) {
        debugPrint('Warning: Contact number $formattedNumber does not start with +');
      }

      debugPrint('Twilio: Sending to $formattedNumber...');
      debugPrint('Twilio: Message body length: ${message.length}');
      
      final response = await _twilioFlutter.sendSMS(
        toNumber: formattedNumber,
        messageBody: message,
      );
      
      debugPrint('Twilio response: $response');
      
      // If the package returns a response object with a State/Code, check it
      if (response.toString().contains('ResponseState.FAILED') || 
          response.toString().contains('status: 400') ||
          response.toString().contains('code: 21211')) {
        debugPrint('Twilio API returned a failure response.');
        String errorMessage = 'Twilio SMS failed. Please ensure your emergency contact number starts with + and includes country code (e.g., +91).';
        if (response.toString().contains('21211') || response.toString().contains('Invalid \'To\' Phone Number')) {
          errorMessage = 'Invalid Phone Number format. Please use + prefix and country code (e.g., +91 for India).';
        }
        throw errorMessage;
      }
      
      debugPrint('Twilio SMS sent successfully!');
    } catch (e) {
      debugPrint('Twilio Error in sendTwilioSms: $e');
      rethrow;
    }
  }

  /// Prepares and launches an SMS to the emergency contact
  Future<void> sendEmergencySms({
    required String contactNumber,
    required Position position,
    Hospital? nearestHospital,
    required String name,
    bool useTwilio = true,
  }) async {
    final String locationUrl = 'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}';
    
    String message = 'EMERGENCY! $name has activated an SOS ALERT.\n\n';
    message += 'Current Location: $locationUrl\n\n';
    
    if (nearestHospital != null) {
      message += 'Nearest Hospital identified: ${nearestHospital.name}\n';
      message += 'Address: ${nearestHospital.address}\n';
      if (nearestHospital.phoneNumber != null) {
        message += 'Phone: ${nearestHospital.phoneNumber}\n';
      }
    }

    if (useTwilio) {
      try {
        await sendTwilioSms(contactNumber: contactNumber, message: message);
        return; // Success, no need to proceed to url_launcher
      } catch (e) {
        debugPrint('Twilio failed, falling back to manual SMS app.');
      }
    }
    
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: contactNumber,
      queryParameters: <String, String>{
        'body': message,
      },
    );

    if (await canLaunchUrl(smsUri)) {
      debugPrint('Launching SMS composer with URI: $smsUri');
      await launchUrl(smsUri);
    } else {
      // Fallback for some devices/platforms
      final String url = 'sms:$contactNumber?body=${Uri.encodeComponent(message)}';
      debugPrint('Primary SMS launch failed, trying fallback: $url');
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        debugPrint('Failed to launch SMS composer with both primary and fallback method.');
        throw 'Could not launch SMS composer';
      }
    }
  }
}
