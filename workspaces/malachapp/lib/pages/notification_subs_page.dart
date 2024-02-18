import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:malachapp/services/notification_service.dart';
import 'package:malachapp/services/subscribe_to_noti.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsSubscriptionPage extends StatefulWidget {
  @override
  _NotificationsSubscriptionPageState createState() =>
      _NotificationsSubscriptionPageState();
}

class _NotificationsSubscriptionPageState
    extends State<NotificationsSubscriptionPage> {
  final SubscribeNotifications _subscribeNotifications =
      SubscribeNotifications();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications Subscription'),
      ),
      body: Column(
        children: [
          _buildSubscriptionTile('polls'),
          _buildSubscriptionTile('events'),
          _buildSubscriptionTile('posts'),
          _buildSubscriptionTile('all'),
          SizedBox(height: 50),
          ListTile(
            title: Text('Send Notification to polls'),
            onTap: () {
              NotificationService().sendFCMMessage('polls');
            },
          )
        ],
      ),
    );
  }

  Widget _buildSubscriptionTile(String topic) {
    bool isSubscribed =
        Provider.of<UserNotificationPreferences>(context).isTopicSubscribed(topic);

    return ListTile(
      title: Text('Subscribe to $topic'),
      onTap: () => _toggleSubscription(topic, !isSubscribed),
      trailing: isSubscribed ? Icon(Icons.check) : null,
    );
  }

  void _toggleSubscription(String topic, bool subscribe) async {
    try {
      if (subscribe) {
        await _subscribeNotifications.subscribe(topic);
      } else {
        await _subscribeNotifications.unsubscribe(topic);
      }

      // Update the user's notification preferences locally
      Provider.of<UserNotificationPreferences>(context, listen: false)
          .updateSubscriptionStatus(topic, subscribe);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${subscribe ? 'Subscribed to' : 'Unsubscribed from'} $topic notifications'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Failed to ${subscribe ? 'subscribe to' : 'unsubscribe from'} $topic notifications'),
        ),
      );
    }
  }
}

class UserNotificationPreferences with ChangeNotifier {
  static const String _prefKey = 'notification_preferences';

  // Store user's notification preferences locally
  Map<String, bool> _subscriptions = {'polls': false, 'events': false, 'posts': false, 'all': false};

  UserNotificationPreferences() {
    _loadPreferences();
  }

  bool get isSubscribed {
    // Check if the user is subscribed to at least one topic
    return _subscriptions.containsValue(true);
  }

  bool isTopicSubscribed(String topic) {
    return _subscriptions[topic] ?? false;
  }

  void updateSubscriptionStatus(String topic, bool subscribe) {
    _subscriptions[topic] = subscribe;
    _savePreferences();
    notifyListeners();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> savedPreferences = {
      'polls': prefs.getBool('polls') ?? false,
      'events': prefs.getBool('events') ?? false,
      'posts': prefs.getBool('posts') ?? false,
      'all': prefs.getBool('all') ?? false,
    };

    _subscriptions = savedPreferences.cast<String, bool>();
    notifyListeners();
  }

  Future<void> _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    SharedPreferencesHelper.setNotificationPreferences(_subscriptions.values.toList(), _prefKey);
  }
}

class SharedPreferencesHelper {
  static Future<List<bool>> getNotificationPreferences(String _prefKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = prefs.getString(_prefKey) ?? '[]';

    List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((value) => value as bool).toList();
  }

  static Future<void> setNotificationPreferences(List<bool> preferences, String _prefKey) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = json.encode(preferences);
    prefs.setString(_prefKey, jsonString);
  }
}
