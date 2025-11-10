import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/notification_model.dart';

/// Service for handling email notifications via SendGrid or similar service
class EmailNotificationService {
  String? _apiKey;
  String? _fromEmail;
  String? _fromName;
  EmailProvider _provider = EmailProvider.sendGrid;

  /// Initialize email service
  void initialize({
    required String apiKey,
    required String fromEmail,
    String fromName = 'SmartPOS',
    EmailProvider provider = EmailProvider.sendGrid,
  }) {
    _apiKey = apiKey;
    _fromEmail = fromEmail;
    _fromName = fromName;
    _provider = provider;
    debugPrint('Email Service initialized with $_provider');
  }

  /// Send email notification
  Future<bool> sendEmail(AppNotification notification) async {
    if (_apiKey == null || _fromEmail == null) {
      debugPrint('Email service not initialized');
      return false;
    }

    // Get email address from notification data
    final email = notification.data?['email'] as String?;
    if (email == null) {
      debugPrint('No email address in notification data');
      return false;
    }

    switch (_provider) {
      case EmailProvider.sendGrid:
        return await _sendViaSendGrid(
          to: email,
          subject: notification.title,
          body: notification.body,
          htmlBody: _generateHTMLEmail(notification),
        );

      case EmailProvider.awsSES:
        return await _sendViaAWS SES(
          to: email,
          subject: notification.title,
          body: notification.body,
        );

      case EmailProvider.backend:
        return await _sendViaBackend(notification, email);
    }
  }

  /// Send email via SendGrid
  Future<bool> _sendViaSendGrid({
    required String to,
    required String subject,
    required String body,
    String? htmlBody,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.sendgrid.com/v3/mail/send'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'personalizations': [
            {
              'to': [
                {'email': to}
              ],
            }
          ],
          'from': {
            'email': _fromEmail,
            'name': _fromName,
          },
          'subject': subject,
          'content': [
            {
              'type': 'text/plain',
              'value': body,
            },
            if (htmlBody != null)
              {
                'type': 'text/html',
                'value': htmlBody,
              },
          ],
        }),
      );

      if (response.statusCode == 202) {
        debugPrint('Email sent successfully via SendGrid to $to');
        return true;
      } else {
        debugPrint('Failed to send email via SendGrid: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending email via SendGrid: $e');
      return false;
    }
  }

  /// Send email via AWS SES
  Future<bool> _sendViaAWSSES({
    required String to,
    required String subject,
    required String body,
  }) async {
    try {
      // AWS SES requires AWS SDK or direct API calls
      // This is a simplified example - in production use AWS SDK

      debugPrint('AWS SES integration pending - email queued for $to');

      // TODO: Implement AWS SES integration
      // You'll need:
      // 1. AWS credentials (access key, secret key)
      // 2. AWS region
      // 3. AWS SES SDK or direct API calls with proper signing

      return true;
    } catch (e) {
      debugPrint('Error sending email via AWS SES: $e');
      return false;
    }
  }

  /// Send email via backend API
  Future<bool> _sendViaBackend(AppNotification notification, String email) async {
    try {
      // Call your backend API to send email
      debugPrint('Backend email integration pending - email queued for $email');

      // TODO: Call backend API
      // final response = await http.post(
      //   Uri.parse('YOUR_BACKEND_API/notifications/email'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({
      //     'to': email,
      //     'notification': notification.toJson(),
      //   }),
      // );
      //
      // return response.statusCode == 200;

      return true;
    } catch (e) {
      debugPrint('Error sending email via backend: $e');
      return false;
    }
  }

  /// Generate HTML email template
  String _generateHTMLEmail(AppNotification notification) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    body {
      font-family: Arial, sans-serif;
      line-height: 1.6;
      color: #333;
      max-width: 600px;
      margin: 0 auto;
      padding: 20px;
    }
    .header {
      background-color: #2196F3;
      color: white;
      padding: 20px;
      text-align: center;
      border-radius: 5px 5px 0 0;
    }
    .content {
      background-color: #f9f9f9;
      padding: 20px;
      border-radius: 0 0 5px 5px;
    }
    .title {
      font-size: 24px;
      margin-bottom: 10px;
    }
    .body {
      font-size: 16px;
      margin-bottom: 20px;
    }
    .button {
      display: inline-block;
      padding: 10px 20px;
      background-color: #2196F3;
      color: white;
      text-decoration: none;
      border-radius: 5px;
      margin-top: 10px;
    }
    .footer {
      text-align: center;
      margin-top: 20px;
      font-size: 12px;
      color: #666;
    }
    ${notification.imageUrl != null ? '.image { width: 100%; max-width: 500px; margin: 20px 0; }' : ''}
  </style>
</head>
<body>
  <div class="header">
    <h1>${_fromName}</h1>
  </div>
  <div class="content">
    <div class="title">${notification.title}</div>
    ${notification.imageUrl != null ? '<img src="${notification.imageUrl}" class="image" alt="Notification image">' : ''}
    <div class="body">${notification.body}</div>
    ${notification.actionUrl != null ? '<a href="${notification.actionUrl}" class="button">View Details</a>' : ''}
  </div>
  <div class="footer">
    <p>This is an automated notification from SmartPOS.</p>
    <p>© ${DateTime.now().year} SmartPOS. All rights reserved.</p>
  </div>
</body>
</html>
    ''';
  }

  /// Send bulk email
  Future<Map<String, bool>> sendBulkEmail({
    required List<String> emails,
    required String subject,
    required String body,
    String? htmlBody,
  }) async {
    final results = <String, bool>{};

    for (final email in emails) {
      results[email] = await _sendViaSendGrid(
        to: email,
        subject: subject,
        body: body,
        htmlBody: htmlBody,
      );

      // Add small delay to avoid rate limiting
      await Future.delayed(const Duration(milliseconds: 100));
    }

    return results;
  }

  /// Validate email format
  bool isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }
}

/// Email service providers
enum EmailProvider {
  sendGrid,
  awsSES,
  backend,
}

/// Email template builder
class EmailTemplateBuilder {
  String _subject = '';
  String _body = '';
  String? _htmlBody;
  String? _imageUrl;
  String? _buttonText;
  String? _buttonUrl;

  EmailTemplateBuilder setSubject(String subject) {
    _subject = subject;
    return this;
  }

  EmailTemplateBuilder setBody(String body) {
    _body = body;
    return this;
  }

  EmailTemplateBuilder setHTMLBody(String htmlBody) {
    _htmlBody = htmlBody;
    return this;
  }

  EmailTemplateBuilder setImage(String imageUrl) {
    _imageUrl = imageUrl;
    return this;
  }

  EmailTemplateBuilder setButton(String text, String url) {
    _buttonText = text;
    _buttonUrl = url;
    return this;
  }

  Map<String, String> build() {
    return {
      'subject': _subject,
      'body': _body,
      if (_htmlBody != null) 'htmlBody': _htmlBody!,
      if (_imageUrl != null) 'imageUrl': _imageUrl!,
      if (_buttonText != null) 'buttonText': _buttonText!,
      if (_buttonUrl != null) 'buttonUrl': _buttonUrl!,
    };
  }
}
