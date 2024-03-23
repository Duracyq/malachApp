/// notification_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter/services.dart' show rootBundle;

const String project_id = 'malachapp';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  // Add a variable to store the FCM server key
  final String _serverKey =
      'AAAA8jXsXOg:APA91bG0D8EQZxoTEFSJNOc2nzMjgh7IVTG4jMaQUNSGvctwQcvkoeZ23jkX_95Lrr1xfYZKE9QshjCSJ3C9LbMZL_Nj_eJeXFxVlIZWAALZjZ3Vl_bQwHP8TVVTVN_r5YcrR91mGZUi';

  Future<String> getOAuth2Token() async {
    var jsonStr = await rootBundle.loadString('lib/auth/admin/malachapp-firebase-adminsdk-9a5ko-d405b11463.json');
    var accountCredentials = ServiceAccountCredentials.fromJson(jsonDecode(jsonStr));
    var scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    var client = http.Client();
    try {
      var authClient = await clientViaServiceAccount(accountCredentials, scopes, baseClient: client);
      return authClient.credentials.accessToken.data;
    } finally {
      client.close();
    }
  }

  Future<void> sendFCMMessage(String message) async {
    try {
      final Map<String, dynamic> fcmPayload = {
        'message': {
          'notification': {
            'title': 'UWAGA!',
            'body': message,
          },
          'topic': 'all',
        },
      };

      final String accessToken = await getOAuth2Token(); // Correctly obtaining the OAuth2 token

      final http.Response response = await http.post(
        Uri.parse('https://fcm.googleapis.com/v1/projects/$project_id/messages:send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken', // Using the OAuth2 token for authentication
        },
        body: jsonEncode(fcmPayload), // Correctly encoding the FCM payload as JSON
      );

      if (response.statusCode == 200) {
        print('FCM message sent successfully: $message');
      } else {
        print('Failed to send FCM message. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error sending FCM message: $error');
      throw error;
    }
  }


  Future<void> sendPersonalisedFCMMessage(
      String message, String topic, String title) async {
    try {
      final Map<String, dynamic> fcmPayload = {
        'message': {
          'notification': {
            'title': title,
            'body': message,
          },
          'topic': topic,
        },
      };

      final String jsonPayload = jsonEncode(fcmPayload);

      final String accessToken = await getOAuth2Token();

      try {
        final http.Response response = await http.post(
          Uri.parse('https://fcm.googleapis.com/v1/projects/$project_id/messages:send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonPayload,
        );

        if (response.statusCode == 200) {
          print('FCM message sent successfully: $message');
        } else {
          print(
              'Failed to send FCM message. Status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Error sending personalised FCM message $e');
        rethrow;
      }
    } catch (e) {
      print('Error sending personalised FCM message $e');
      rethrow;
    }
  }

  Future<void> requestNotificationPermission() async {
    PermissionStatus status = await Permission.notification.status;

    if (status.isDenied) {
      // Permission is denied
      PermissionStatus result = await Permission.notification.request();

      if (result.isGranted) {
        // Permission granted
        print('Notification permission granted');
      } else {
        // Permission denied
        print('Notification permission denied');
        // You may want to show a dialog or redirect the user to app settings
        // to enable notifications for a better user experience.
        // For example:
        // showNotificationPermissionDeniedDialog();
      }
    } else {
      // Permission is already granted
      print('Notification permission already granted');
    }
  }
}
