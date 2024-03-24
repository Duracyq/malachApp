import 'dart:async';
import 'dart:convert'; // Import JSON codec
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class NotificationArchive extends StatefulWidget {
  const NotificationArchive({Key? key}) : super(key: key);

  @override
  _NotificationArchiveState createState() => _NotificationArchiveState();
}

class _NotificationArchiveState extends State<NotificationArchive> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  List<Map<String, dynamic>> notifications = []; // Changed to dynamic to handle JSON
  final Logger logger = Logger();

  String? _currentToken;
  bool _savingNotification = false;

  @override
  void initState() {
    super.initState();
    _initFirebase();
  }

  Future<void> _initFirebase() async {
    await Firebase.initializeApp();

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    _firebaseMessaging.getToken().then((token) {
      setState(() {
        _currentToken = token;
      });
      if (token != null) {
        logger.d("Firebase Token: $token");
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final topic = message.data['topic'] ?? 'Unknown';
      if (message.notification != null && message.from != _currentToken) {
        logger.d("Received message: ${message.notification!.body}");
        if (!await _isNotificationAlreadyStored(message.notification!.title!, message.notification!.body!, topic)) {
          _storeNotification(message.notification!.title!, message.notification!.body!, topic);
        }
      }
    });

    _retrieveNotifications();
  }

  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    final topic = message.data['topic'] ?? 'Unknown';
    if (message.notification != null && message.from != _currentToken) {
      logger.d("Handling a background message: ${message.notification!.body}");
      if (!await _isNotificationAlreadyStored(message.notification!.title!, message.notification!.body!, topic)) {
        _storeNotification(message.notification!.title!, message.notification!.body!, topic);
      }
    }
  }

  void _storeNotification(String title, String notification, String topic) async {
    if (_savingNotification) return;
    _savingNotification = true;

    final key = 'notification_${DateTime.now().millisecondsSinceEpoch}';
    final String valueToStore = jsonEncode({
      "title": title,
      "notification": notification,
      "topic": topic,
    });
    await _secureStorage.write(key: key, value: valueToStore);
    _retrieveNotifications();

    _savingNotification = false;
  }

  Future<bool> _isNotificationAlreadyStored(String title, String notification, String topic) async {
    Map<String, String> allValues = await _secureStorage.readAll();
    for (var value in allValues.values) {
      Map<String, dynamic> storedData = jsonDecode(value);
      if (storedData['title'] == title && storedData['notification'] == notification && storedData['topic'] == topic) {
        return true;
      }
    }
    return false;
  }

  void _retrieveNotifications() async {
    Map<String, String> allValues = await _secureStorage.readAll();
    List<Map<String, dynamic>> parsedNotifications = [];
    allValues.forEach((key, value) {
      Map<String, dynamic> storedData = jsonDecode(value);
      int timestamp = int.tryParse(key.substring(key.lastIndexOf('_') + 1)) ?? 0;
      storedData['timestamp'] = timestamp.toString();
      parsedNotifications.add(storedData);
    });

    parsedNotifications.sort((a, b) => int.parse(b['timestamp']).compareTo(int.parse(a['timestamp'])));

    setState(() {
      notifications = parsedNotifications;
    });
  }

  void _deleteNotification(int index) async {
    String key = notifications[index]['key']!;
    await _secureStorage.delete(key: key);
    _retrieveNotifications();
  }

  String _formatTimestamp(int timestamp) {
    var dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    var formatter = DateFormat('yyyy-MM-dd HH:mm');
    return formatter.format(dateTime);
  }

  // Check if the notification is already stored
  // Future<bool> _isNotificationAlreadyStored(String title, String notification) async {
  //   Map<String, String> allValues = await _secureStorage.readAll();
  //   for (var value in allValues.values) {
  //     List<String> parts = value.split('|');
  //     if (parts.length >= 3 && parts[0] == title && parts[1] == notification) {
  //       return true;
  //     }
  //   }
  //   return false;
  // }

  @override
  Widget build(BuildContext context) {
        return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Archive'),
      ),
      body: Center(
        child: notifications.isEmpty
            ? Text('No notifications saved.')
            : ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return Card(
                    child: Dismissible(
                      key: Key(notification['key']),
                      onDismissed: (direction) {
                        _deleteNotification(index);
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16.0),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: ListTile(
                        title: Text(
                          notification['title'] != null ? notification['title']! : 'No Title',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),

                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notification['notification'] ?? 'No Details'), // Fallback for null notification
                            SizedBox(height: 4),
                            Text(
                              'Topic: ${notification['topic'] ?? 'Unknown'}', // Already correctly handled
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Saved at: ${_formatTimestamp(int.tryParse(notification['timestamp'].toString()) ?? 0)}', // Safe parsing with fallback
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),

                        onTap: () {
                          // Here you can add actions for when the user taps a notification
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // This button deletes all notifications
          _secureStorage.deleteAll().then((_) {
            setState(() {
              notifications.clear();
            });
          });
        },
        child: const Icon(Icons.delete_sweep),
        tooltip: 'Clear all notifications',
      ),
    );
  }
}
