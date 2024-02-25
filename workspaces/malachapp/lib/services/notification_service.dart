/// notification_service.dart
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Add a variable to store the FCM registration token
  String? _fcmToken;

  // Getter method to retrieve the FCM registration token
  String? get fcmToken => _fcmToken;

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Retrieve the FCM registration token when the app starts
    _fcmToken = await _firebaseMessaging.getToken();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data.isNotEmpty) {
        print('Message data payload: ${message.data}');
      }

      showNotification(
        title: message.notification?.title ?? '',
        body: message.notification?.body ?? '',
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification tapped!');
    });
    FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);
  }

  Future<void> backgroundMessageHandler(RemoteMessage message) async {
    print('Handling a background message: ${message.messageId}');
    // Implement your logic to handle the FCM message when the app is in the background
    // For example, you can schedule a local notification here
    showNotification(
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
    );
  }

  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  Future<void> sendFCMMessage(String message) async {
    try {
      final Map<String, dynamic> fcmPayload = {
        'notification': {
          'title': 'UWAGA!',
          'body': message,
        },
        'data': {
          'message': message,
        },
        'priority': 'high',
        'to': '/topics/all',
      };

      final String jsonPayload = jsonEncode(fcmPayload);

      try {
        const String serverKey =
            'AAAA8jXsXOg:APA91bG0D8EQZxoTEFSJNOc2nzMjgh7IVTG4jMaQUNSGvctwQcvkoeZ23jkX_95Lrr1xfYZKE9QshjCSJ3C9LbMZL_Nj_eJeXFxVlIZWAALZjZ3Vl_bQwHP8TVVTVN_r5YcrR91mGZUi'; // Replace with your FCM server key

        final http.Response response = await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $serverKey',
          },
          body: jsonPayload,
        );

        if (response.statusCode == 200) {
          print('FCM message sent successfully: $message');
        } else {
          print(
              'Failed to send FCM message. Status code: ${response.statusCode}');
        }
      } catch (error) {
        print('Error getting or sending FCM server key: $error');
        throw error;
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
        'notification': {
          'title': title,
          'body': message,
        },
        'data': {
          'message': message,
        },
        'priority': 'high',
        'to': '/topics/$topic',
      };

      final String jsonPayload = jsonEncode(fcmPayload);

      try {
        const String serverKey = 'AAAA8jXsXOg:APA91bG0D8EQZxoTEFSJNOc2nzMjgh7IVTG4jMaQUNSGvctwQcvkoeZ23jkX_95Lrr1xfYZKE9QshjCSJ3C9LbMZL_Nj_eJeXFxVlIZWAALZjZ3Vl_bQwHP8TVVTVN_r5YcrR91mGZUi'; // Replace with your FCM server key
        
        final http.Response response =
            await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
                headers: <String, String>{
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer $serverKey',
                },
                body: jsonPayload);

        if (response.statusCode == 200) {
          print('FCM message sent successfully: $message');
        } else {
          print(
              'Failed to send FCM message. Status code: ${response.statusCode}');
        }
      } catch (e) {
        print('Error getting or sending FCM server key $e');
        rethrow;
      }
    } catch (e) {
      print('Error sending personalised FCM message $e');
      rethrow;
    }
  }

// Future<String> getServerKey() async {
//   // Initialize Firebase Admin with your credentials
//   const String path = 'lib/auth/admin/9a5ko-35eeb1e303.json';
//   final admin = FirebaseAdmin.instance;
//   final app = await admin.initializeApp(
//     AppOptions(
//       credential: admin.certFromPath(path),
//     ),
//   );
//   print('Current working directory: ${Directory.current}');

//   // Retrieve the FCM server key from the service account credentials
//   final Map<String, dynamic>? credentials =
//       app.options.credential as Map<String, dynamic>?;

//   if (credentials != null && credentials.containsKey('private_key')) {
//     final String privateKey = credentials['private_key'] as String;
//     // You may need to format the privateKey if it includes line breaks or other characters
//     return privateKey;
//   } else {
//     throw Exception('Failed to retrieve FCM server key');
//   }
// }

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
