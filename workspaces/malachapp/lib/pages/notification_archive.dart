import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:logger/logger.dart';

class NotificationArchive extends StatefulWidget {
  const NotificationArchive({Key? key}) : super(key: key);

  @override
  _NotificationArchiveState createState() => _NotificationArchiveState();
}

class _NotificationArchiveState extends State<NotificationArchive> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  List<Map<String, String>> notifications = [];
  final Logger logger = Logger();

  String? _currentToken;
  bool _savingNotification = false;

  @override
  void initState() {
    super.initState();
    // Initialize Firebase
    Firebase.initializeApp();

    // Configure Firebase messaging
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    _firebaseMessaging.getToken().then((token) {
      setState(() {
        _currentToken = token;
      });
      if (token != null) {
        logger.d("Firebase Token: $token");
      }
    });

    // Listen for incoming messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.notification != null && message.from != null && message.from != _currentToken) {
        logger.d("Received message: ${message.notification!.body}");
        // Check if the notification is already stored
        if (!await _isNotificationAlreadyStored(message.notification!.title!, message.notification!.body!)) {
          // Store received notification locally
          _storeNotification(message.notification!.title!, message.notification!.body!);
        }
      }
    });

    // Retrieve stored notifications
    _retrieveNotifications();
  }

  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    if (message.notification != null && message.from != _currentToken) {
      logger.d("Handling a background message: ${message.notification!.body}");
      // Check if the notification is already stored
      if (!await _isNotificationAlreadyStored(message.notification!.title!, message.notification!.body!)) {
        // Store received notification locally
        final storage = const FlutterSecureStorage();
        await storage.write(
            key: 'notification_${DateTime.now().millisecondsSinceEpoch}',
            value: '${message.notification!.title!}|${message.notification!.body!}');
        // Update the list of notifications
        _retrieveNotifications();
      }
    }
  }

  // Store notification locally
  void _storeNotification(String title, String notification) async {
    if (_savingNotification) return; // Check if notification is already being saved
    _savingNotification = true; // Set flag to true to indicate notification saving process
    bool isAlreadyStored = await _isNotificationAlreadyStored(title, notification);
    if (!isAlreadyStored) {
      final key = 'notification_${DateTime.now().millisecondsSinceEpoch}'; // Unique key
      await _secureStorage.write(key: key, value: '$title|$notification');
      // Update the list of notifications
      _retrieveNotifications();
    }

    _savingNotification = false; // Reset flag after saving is complete
  }

  // Retrieve stored notifications
  void _retrieveNotifications() async {
    Map<String, String> allValues = await _secureStorage.readAll();
    List<Map<String, String>> parsedNotifications = [];
    allValues.forEach((key, value) {
      List<String> parts = value.split('|');
      if (parts.length >= 2) {
        // Extract timestamp from the key
        int timestamp = int.tryParse(key.substring(key.lastIndexOf('_') + 1)) ?? 0;
        parsedNotifications.add({'key': key, 'title': parts[0], 'notification': parts[1], 'timestamp': timestamp.toString()});
      }
    });

    // Sort notifications from latest to oldest based on timestamp
    parsedNotifications.sort((a, b) => int.parse(b['timestamp']!).compareTo(int.parse(a['timestamp']!)));

    setState(() {
      notifications = parsedNotifications;
    });
  }

  // Delete notification from archive
  void _deleteNotification(int index) async {
    String key = notifications[index]['key']!;
    await _secureStorage.delete(key: key);
    // Update the list of notifications
    _retrieveNotifications();
  }

  // Check if the notification is already stored
  Future<bool> _isNotificationAlreadyStored(String title, String notification) async {
    Map<String, String> allValues = await _secureStorage.readAll();
    for (var value in allValues.values) {
      List<String> parts = value.split('|');
      if (parts.length >= 2 && parts[0] == title && parts[1] == notification) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Archive'),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            return Dismissible(
              key: Key(notifications[index]['key']!),
              onDismissed: (direction) {
                setState(() {
                  _deleteNotification(index);
                  notifications.removeAt(index);
                });
              },
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16.0),
                child: const Icon(Icons.delete),
              ),
              child: ListTile(
                title: Text(notifications[index]['title']!),
                subtitle: Text(notifications[index]['notification']!),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _secureStorage.deleteAll();
          // Update the list of notifications
          _retrieveNotifications();
        },
        child: const Icon(Icons.delete),
      ),
    );
  }
}
