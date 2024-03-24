import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart' show Uint8List;
import 'package:googleapis_auth/auth_io.dart';

const String project_id = 'malachapp';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  Future<String> getOAuth2TokenFromFirebaseStorage() async {
    try {
      // Path to the secret in Firebase Storage
      const String secretPath = 'secret/malachapp-firebase-adminsdk-9a5ko-7e05d828f3.json';

      // Retrieve the secret file's content from Firebase Storage
      final ref = FirebaseStorage.instance.ref().child(secretPath);
      final Uint8List? fileData = await ref.getData();

      // Ensure we got data
      if (fileData == null) throw Exception('Failed to download secret file.');

      // Decode the content to string and parse it as JSON
      final jsonStr = utf8.decode(fileData);
      final accountCredentials = ServiceAccountCredentials.fromJson(jsonDecode(jsonStr));

      // Define the scopes for your OAuth2 token
      var scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

      // Generate the OAuth2 token
      var client = http.Client();
      try {
        var authClient = await clientViaServiceAccount(accountCredentials, scopes, baseClient: client);
        return authClient.credentials.accessToken.data;
      } finally {
        client.close();
      }
    } catch (error) {
      print('Error getting OAuth2 token from Firebase Storage: $error');
      rethrow;
    }
  }

  Future<void> sendFCMMessage(String message) async {
    final Map<String, dynamic> messagePayload = {
      'message': {
        'topic': 'all',
        'notification': {
          'title': 'UWAGA!',
          'body': message,
        },
        'data': {
          'message': message,
          'topic': 'all',
        },
      },
    };

    await _sendMessageToFCM(messagePayload);
  }

  Future<void> sendPersonalisedFCMMessage(String message, String topic, String title) async {
    final Map<String, dynamic> messagePayload = {
      'message': {
        'topic': topic,
        'notification': {
          'title': title,
          'body': message,
        },
        'data': {
          'message': message,
          'topic': topic,
        },
      },
    };

    await _sendMessageToFCM(messagePayload);
  }

  Future<void> _sendMessageToFCM(Map<String, dynamic> messagePayload) async {
    try {
      final String jsonPayload = jsonEncode(messagePayload);
      final String accessToken = await getOAuth2TokenFromFirebaseStorage();

      final http.Response response = await http.post(
        Uri.parse('https://fcm.googleapis.com/v1/projects/$project_id/messages:send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonPayload,
      );

      if (response.statusCode == 200) {
        print('FCM message sent successfully');
      } else {
        print('Failed to send FCM message. Status code: ${response.statusCode}, Response: ${response.body}');
      }
    } catch (e) {
      print('Error sending FCM message $e');
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

