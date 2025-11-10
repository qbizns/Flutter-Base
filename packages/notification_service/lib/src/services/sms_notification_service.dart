import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/notification_model.dart';

/// Service for handling SMS notifications via Twilio
class SMSNotificationService {
  // Twilio configuration (should be stored in environment variables)
  String? _accountSid;
  String? _authToken;
  String? _fromNumber;
  String? _apiUrl;

  /// Initialize SMS service with Twilio credentials
  void initialize({
    required String accountSid,
    required String authToken,
    required String fromNumber,
  }) {
    _accountSid = accountSid;
    _authToken = authToken;
    _fromNumber = fromNumber;
    _apiUrl = 'https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json';
    debugPrint('SMS Service initialized with Twilio');
  }

  /// Send SMS notification
  Future<bool> sendSMS(AppNotification notification) async {
    if (_accountSid == null || _authToken == null) {
      debugPrint('SMS service not initialized');
      return false;
    }

    // Get phone number from notification data
    final phoneNumber = notification.data?['phoneNumber'] as String?;
    if (phoneNumber == null) {
      debugPrint('No phone number in notification data');
      return false;
    }

    return await _sendSMSMessage(
      to: phoneNumber,
      body: '${notification.title}\n${notification.body}',
    );
  }

  /// Send SMS message via Twilio
  Future<bool> _sendSMSMessage({
    required String to,
    required String body,
  }) async {
    if (_apiUrl == null || _fromNumber == null) {
      debugPrint('SMS service not properly configured');
      return false;
    }

    try {
      final credentials = base64Encode(utf8.encode('$_accountSid:$_authToken'));

      final response = await http.post(
        Uri.parse(_apiUrl!),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'From': _fromNumber!,
          'To': to,
          'Body': body,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('SMS sent successfully to $to');
        return true;
      } else {
        debugPrint('Failed to send SMS: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending SMS: $e');
      return false;
    }
  }

  /// Send SMS to multiple recipients
  Future<Map<String, bool>> sendBulkSMS({
    required List<String> phoneNumbers,
    required String body,
  }) async {
    final results = <String, bool>{};

    for (final phoneNumber in phoneNumbers) {
      results[phoneNumber] = await _sendSMSMessage(
        to: phoneNumber,
        body: body,
      );

      // Add small delay to avoid rate limiting
      await Future.delayed(const Duration(milliseconds: 100));
    }

    return results;
  }

  /// Validate phone number format
  bool isValidPhoneNumber(String phoneNumber) {
    // Basic validation for E.164 format (+1234567890)
    final regex = RegExp(r'^\+[1-9]\d{1,14}$');
    return regex.hasMatch(phoneNumber);
  }

  /// Format phone number to E.164
  String formatPhoneNumber(String phoneNumber, {String defaultCountryCode = '+1'}) {
    // Remove all non-digit characters
    String cleaned = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Add country code if not present
    if (!cleaned.startsWith('+')) {
      if (cleaned.length == 10) {
        // US number without country code
        cleaned = '$defaultCountryCode$cleaned';
      } else {
        cleaned = '+$cleaned';
      }
    }

    return cleaned;
  }
}

/// Alternative: SMS service using backend API
class BackendSMSService {
  final String _apiBaseUrl;

  BackendSMSService({required String apiBaseUrl}) : _apiBaseUrl = apiBaseUrl;

  /// Send SMS via backend API
  Future<bool> sendSMS(AppNotification notification) async {
    try {
      final phoneNumber = notification.data?['phoneNumber'] as String?;
      if (phoneNumber == null) {
        debugPrint('No phone number in notification data');
        return false;
      }

      final response = await http.post(
        Uri.parse('$_apiBaseUrl/api/notifications/sms'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'to': phoneNumber,
          'title': notification.title,
          'body': notification.body,
          'data': notification.data,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('SMS sent successfully via backend');
        return true;
      } else {
        debugPrint('Failed to send SMS via backend: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending SMS via backend: $e');
      return false;
    }
  }

  /// Send bulk SMS via backend
  Future<bool> sendBulkSMS({
    required List<String> phoneNumbers,
    required String title,
    required String body,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/api/notifications/sms/bulk'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumbers': phoneNumbers,
          'title': title,
          'body': body,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error sending bulk SMS: $e');
      return false;
    }
  }
}
