import 'dart:async';
import 'dart:convert';
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
  List<Map<String, dynamic>> notifications = [];
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

  Future<void> _storeNotification(String title, String notification, String topic) async {
    if (_savingNotification) return;
    _savingNotification = true;

    // Generate a unique key based on the notification's content, including a timestamp for sorting
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
    final String formattedDate = formatter.format(now);
    final uniqueKey = _generateUniqueKey(title, notification, topic, formattedDate);

    // Check if this unique key already exists
    if (await _uniqueKeyExists(uniqueKey)) {
      logger.d("Notification already stored, skipping...");
      _savingNotification = false;
      return;
    }

    // Prepare the notification data with the formatted date
    final Map<String, dynamic> notificationData = {
      "title": title,
      "notification": notification,
      "topic": topic,
      "timestamp": formattedDate, // Save the formatted date
    };

    final String valueToStore = jsonEncode(notificationData);
    await _secureStorage.write(key: uniqueKey, value: valueToStore); // Use the uniqueKey as the storage key

    _retrieveNotifications();
    _savingNotification = false;
  }


  // Helper method to generate a unique key (this is a simple version, consider a hash for more complexity)
  String _generateUniqueKey(String title, String notification, String topic, String formattedDate) {
    return "$title-$notification-$topic-$formattedDate";
  }

  // Check if a unique key already exists in the storage
  Future<bool> _uniqueKeyExists(String uniqueKey) async {
    final allKeys = await _secureStorage.readAll();
    return allKeys.containsKey(uniqueKey);
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

  // Future<void> _retrieveNotifications() async {
  //   Map<String, String> allValues = await _secureStorage.readAll();
  //   List<Map<String, dynamic>> parsedNotifications = [];
  //   allValues.forEach((key, value) {
  //     Map<String, dynamic> storedData = jsonDecode(value);
  //     int timestamp = int.tryParse(key.substring(key.lastIndexOf('_') + 1)) ?? 0;
  //     storedData['timestamp'] = timestamp.toString();
  //     parsedNotifications.add(storedData);
  //   });

  //   parsedNotifications.sort((a, b) => int.parse(b['timestamp']).compareTo(int.parse(a['timestamp'])));

  //   setState(() {
  //     notifications = parsedNotifications;
  //   });
  // }

  Future<void> _retrieveNotifications() async {
    Map<String, String> allValues = await _secureStorage.readAll();
    List<Map<String, dynamic>> parsedNotifications = [];
    allValues.forEach((key, value) {
      Map<String, dynamic> storedData = jsonDecode(value);
      // Use the 'timestamp' directly from storedData, assuming it's stored in the correct format
      parsedNotifications.add(storedData);
    });

    // Sort based on the 'timestamp' string; consider converting to DateTime for accurate sorting if necessary
    parsedNotifications.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

    setState(() {
      notifications = parsedNotifications;
    });
  }


  void _deleteNotification(int index) async {
    String key = notifications[index]['key']!;
    await _secureStorage.delete(key: key);
    _retrieveNotifications();
  }

  // String _formatTimestamp(String timestamp) {
  //   var dateTime = DateTime.fromMillisecondsSinceEpoch(int.tryParse(timestamp) ?? 0);
  //   var formatter = DateFormat('yyyy-MM-dd HH:mm');
  //   return formatter.format(dateTime);
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
                // Ensure key is never null
                final String itemKey = notification['key'] ?? 'item_$index';
                return Card(
                  child: Dismissible(
                    key: Key(itemKey),
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
                        notification['title'] ?? 'No Title', // Use ?? to provide a fallback
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notification['notification'] ?? 'No Details'), // Fallback for null notification
                            SizedBox(height: 4),
                            // Text(
                            //   'Topic: ${notification['topic'] ?? 'Unknown'}', // Already correctly handled
                            //   style: const TextStyle(fontSize: 12, color: Colors.grey),
                            // ),
                            // SizedBox(height: 4),
                            Text(
                              'Saved at: ${notification['timestamp']}', // Safe parsing with fallback
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            Text(
                              'Topic: ${notification['topic'] ?? ''}', // Already correctly handled
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
