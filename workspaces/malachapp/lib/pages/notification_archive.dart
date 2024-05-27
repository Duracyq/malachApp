import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:malachapp/components/reloadable_widget.dart';
import 'package:malachapp/pages/Messages/messaging_page.dart';
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
  late SharedPreferences _prefs;
  List<Map<String, dynamic>> notifications = [];
  final Logger logger = Logger();

  String? _currentToken;
  bool _savingNotification = false;

  @override
  void initState() {
    super.initState();
    initializeApp();
  }

  Future<void> initializeApp() async {
    await _initFirebase();
    await _initSharedPreferences();
    await migrateDataIfNeeded();
    await _retrieveNotifications();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> _setHasNotifications(bool value) async {
    await _prefs.setBool('hasNotifications', value);
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
          _setHasNotifications(true);
        }
      }
      _retrieveNotifications();
    });

    _retrieveNotifications();
  }

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

    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    final String formattedDate = formatter.format(now);
    final String uniqueKey = _generateUniqueKey(title, notification, topic, formattedDate);

    logger.d("Attempting to store notification with key: $uniqueKey");

    final Map<String, dynamic> notificationData = {
      "title": title,
      "notification": notification,
      "topic": topic,
      "timestamp": formattedDate,
    };

    logger.d("Storing notification with key: $uniqueKey and data: $notificationData");
    await _prefs.setString(uniqueKey, jsonEncode(notificationData));
    _savingNotification = false;
    _retrieveNotifications();
  }

  String _generateUniqueKey(String title, String notification, String topic, String formattedDate) {
    return "$title-$notification-$topic-$formattedDate";
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

  Future<void> _retrieveNotifications() async {
    final List<Map<String, dynamic>> parsedNotifications = [];
    for (var key in _prefs.getKeys()) {
      final String? value = _prefs.getString(key);
      if (value != null) {
        try {
          final Map<String, dynamic> decodedData = jsonDecode(value);
          if (decodedData.containsKey('title') && decodedData.containsKey('notification') && decodedData.containsKey('topic') && decodedData.containsKey('timestamp')) {
            parsedNotifications.add(decodedData);
          }
        } catch (e) {
          logger.e("Error decoding notification data for key $key: $e");
        }
      }
    }

    parsedNotifications.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
    logger.d("Retrieved ${parsedNotifications.length} notifications");

    if (mounted) {
      _setHasNotifications(parsedNotifications.isNotEmpty);
      setState(() {
        notifications = parsedNotifications;
      });
    }
  }

  Future<void> migrateDataIfNeeded() async {
    for (var key in _prefs.getKeys()) {
      final value = _prefs.getString(key);
      if (value != null) {
        try {
          final dynamic decodedData = jsonDecode(value);
          if (decodedData is! Map<String, dynamic>) {
            if (decodedData is bool) {
              final Map<String, dynamic> newData = {'isEnabled': decodedData};
              await _prefs.setString(key, jsonEncode(newData));
            }
          }
        } catch (e) {
          logger.e("Error during migration for key $key: $e");
        }
      }
    }
  }

  void _deleteNotification(int index) async {
    String key = notifications[index]['key']!;
    await _prefs.remove(key);
    _retrieveNotifications();
    _setHasNotifications(notifications.isNotEmpty);
  }

  Future<void> _refresh() async {
    await _retrieveNotifications();
  }

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
                              notification['title'] ?? 'No Title',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildNotificationDescription(context, notification['notification']),
                                const SizedBox(height: 4),
                                Text(
                                  'Saved at: ${notification['timestamp']}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                Text(
                                  'Topic: ${notification['topic'] ?? ''}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                            onTap: () {
                              if (notification['notification'].toString().length >= 100) {
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
                                          child: Text('Close', style: TextStyle(color: themeColor)),
                                        ),
                                        Visibility(
                                          visible: !['all', 'polls', 'posts', 'events'].contains(notification['topic']),
                                          child: TextButton(
                                            onPressed: () => Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: ((context) => MessagingPage(
                                                      groupTitle: notification['title'],
                                                      groupId: notification['topic'] ?? '',
                                                      isGFC: false,
                                                    )),
                                              ),
                                            ),
                                            child: Text('Open Chat', style: TextStyle(color: themeColor)),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else if (!['all', 'polls', 'posts', 'events'].contains(notification['topic'])) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: ((context) => MessagingPage(
                                          groupTitle: notification['title'],
                                          groupId: notification['topic'] ?? '',
                                          isGFC: false,
                                        )),
                                  ),
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
          _prefs.clear().then((_) {
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
