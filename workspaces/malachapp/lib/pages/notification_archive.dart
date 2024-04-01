import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:malachapp/components/reloadable_widget.dart';
import 'package:malachapp/pages/messaging_page.dart';
import 'package:malachapp/themes/dark_mode.dart';
import 'package:malachapp/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationArchive extends StatefulWidget {
  const NotificationArchive({Key? key}) : super(key: key);

  @override
  _NotificationArchiveState createState() => _NotificationArchiveState();
}

class _NotificationArchiveState extends State<NotificationArchive> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late SharedPreferences _prefs;
  List<Map<String, dynamic>> notifications = [];
  final Logger logger = Logger();


  String? _currentToken;
  bool _savingNotification = false;

  @override
  void initState() {
    super.initState();
    _initFirebase();
    _initSharedPreferences();
    migrateDataIfNeeded();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    // final bool? hasAcceptedTerms = prefs.getBool('accepted_terms');
    // if (hasAcceptedTerms == null || !hasAcceptedTerms) {
    //   await prefs.setBool('accepted_terms', true);
    // }
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
      print("Received message: ${message.data}");
      final topic = message.data['topic'] ?? 'Unknown';
      logger.d("Topic: $topic");
      if (message.notification != null && message.from != _currentToken) {
        logger.d("Received message: ${message.notification!.body}");
        if (!await _isNotificationAlreadyStored(message.notification!.title!, message.notification!.body!, topic)) {
          _storeNotification(message.notification!.title!, message.notification!.body!, topic);
        }
      }
    });

    _retrieveNotifications();
  }

  // String extractTopicFromNotification() {

  //   String topic = messagePayload['message']['topic'] as String;
  //   return topic;
  // }


  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    final topic = message.data['topic'] ?? 'Unknown';
    if (message.notification != null && message.from != _currentToken) {
      logger.d("Received message: ${message.notification!.body}");
      if (!await _isNotificationAlreadyStored(message.notification!.title!, message.notification!.body!, topic)) {
        _storeNotification(message.notification!.title!, message.notification!.body!, topic);
      }
      debugPrint("Handling a background message: ${message.messageId}");
    }
  }

  Future<void> _storeNotification(String title, String notification, String topic) async {
    if (_savingNotification) return;
    _savingNotification = true;

    // Generate a unique key based on the notification's content, including a timestamp for sorting
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
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
    await _prefs.setString(uniqueKey, valueToStore);

    _retrieveNotifications();
    _savingNotification = false;
  }


  // Helper method to generate a unique key (this is a simple version, consider a hash for more complexity)
  String _generateUniqueKey(String title, String notification, String topic, String formattedDate) {
    return "$title-$notification-$topic-$formattedDate";
  }

  // Check if a unique key already exists in the storage
  Future<bool> _uniqueKeyExists(String uniqueKey) async {
    return _prefs.containsKey(uniqueKey);
  }

  Future<bool> _isNotificationAlreadyStored(String title, String notification, String topic) async {
    for (var key in _prefs.getKeys()) {
      try {
        Map<String, dynamic> storedData = jsonDecode(_prefs.getString(key)!);
        if (storedData['title'] == title && storedData['notification'] == notification && storedData['topic'] == topic) {
          return true;
        }
      } catch (e) {
        logger.e("Error decoding or processing stored data: $e");
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
    List<Map<String, dynamic>> parsedNotifications = [];

    for (var key in _prefs.getKeys()) {
      try {
        final dynamic decodedData = jsonDecode(_prefs.getString(key)!);
        if (decodedData is Map<String, dynamic>) {
          parsedNotifications.add(decodedData);
        } else {
          logger.d("Unexpected data format for key $key: Expected a Map but got ${decodedData.runtimeType}");
        }
      } catch (e) {
        logger.e("Error decoding data for key $key: $e");
      }
    }

    parsedNotifications.sort((a, b) {
      // Assuming 'timestamp' is stored as a String in ISO 8601 format
      var dateA = DateTime.tryParse(a['timestamp'] ?? '') ?? DateTime.now();
      var dateB = DateTime.tryParse(b['timestamp'] ?? '') ?? DateTime.now();
      return dateB.compareTo(dateA); // Sort in descending order
    });


    if (mounted) {
      setState(() {
        notifications = parsedNotifications;
      });
    }
  }

  Future<void> migrateDataIfNeeded() async {
    for (var key in _prefs.getKeys()) {
      final dynamic decodedData = jsonDecode(_prefs.getString(key)!);
      if (decodedData is! Map<String, dynamic>) {
        if (decodedData is bool) {
          final Map<String, dynamic> newData = {'isEnabled': decodedData};
          await _prefs.setString(key, jsonEncode(newData));
        }
      }
    }
  }

  void _deleteNotification(int index) async {
    String key = notifications[index]['key']!;
    await _prefs.remove(key);
    _retrieveNotifications();
  }

  Future<void> _refresh() async {
    await _retrieveNotifications();
  }

  // String _formatTimestamp(String timestamp) {
  //   var dateTime = DateTime.fromMillisecondsSinceEpoch(int.tryParse(timestamp) ?? 0);
  //   var formatter = DateFormat('yyyy-MM-dd HH:mm');
  //   return formatter.format(dateTime);
  // }

  Widget _buildNotificationDescription(BuildContext context, String notification) {
    if (notification.length > 200) {
      return Text('${notification.substring(0, 100)}...');
    } else {
      return Text(notification);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Provider.of<ThemeProvider>(context).themeData == darkMode ? Colors.white : Colors.black;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Archive'),
      ),
      body: Center(
        child: notifications.isEmpty
            ? const Text('No notifications saved.')
            : ReloadableWidget(
              onRefresh: _refresh,
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  // Ensure key is never null
                  final String itemKey = notification['key'] ?? 'item_$index';
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(6.0, 2.0, 6.0, 0),
                    child: Card(
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
                                _buildNotificationDescription(context, notification['notification']), 
                                const SizedBox(height: 4),
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
                              if(notification['notification'].toString().split('').length >= 100) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text(notification['title'] ?? 'No Title'),
                                      content: SingleChildScrollView(
                                        child: Text(notification['notification'] ?? 'No Details'),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('Zamknij', style: TextStyle(color: themeColor),),
                                        ),
                                        Visibility(
                                          visible: notification['topic'] != {'all', 'polls', 'posts', 'events'},
                                          child: TextButton(
                                            onPressed: () => Navigator.of(context).push(
                                              MaterialPageRoute(builder: ((context) => MessagingPage(groupId: notification['topic'] ?? '')))
                                            ),
                                            child: Text('Otwórz czat', style: TextStyle(color: themeColor)),
                                          ),
                                        )
                                      ],
                                    );
                                  },
                                );
                              }
                              if(notification['topic'] != {'all', 'polls', 'posts', 'events'}) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: ((context) => MessagingPage(groupId: notification['topic'] ?? '')))
                                );
                              }
                            },
                          ),
                        ),
                      ),
                  );
                  },
                ),
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
        tooltip: 'Clear all notifications',
        child: const Icon(Icons.delete_sweep),
      ),
    );
  }
}
