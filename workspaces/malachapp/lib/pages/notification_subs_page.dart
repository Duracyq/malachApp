import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:malachapp/services/notification_service.dart';
import 'package:malachapp/services/subscribe_to_noti.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Update NotificationsSubscriptionPage to include a debug button
class NotificationsSubscriptionPage extends StatefulWidget {
  @override
  _NotificationsSubscriptionPageState createState() => _NotificationsSubscriptionPageState();
}

class _NotificationsSubscriptionPageState extends State<NotificationsSubscriptionPage> {
  final SubscribeNotifications _subscribeNotifications = SubscribeNotifications();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications Subscription'),
      ),
      body: Column(
        children: [
          _buildSubscriptionTile('polls'),
          _buildSubscriptionTile('events'),
          _buildSubscriptionTile('posts'),
          const SizedBox(height: 50),
          //admin privliges
          
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
      trailing: !isSubscribed ? null : const Icon(Icons.check),
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
  // static const String _prefKey = 'notification_preferences';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

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
    Map<String, dynamic> savedPreferences = {
      'polls': await _secureStorage.read(key: 'subscribed_polls') == 'true',
      'events': await _secureStorage.read(key: 'subscribed_events') == 'true',
      'posts': await _secureStorage.read(key: 'subscribed_posts') == 'true',
      'all': await _secureStorage.read(key: 'all') == 'true',
    };

    _subscriptions = savedPreferences.cast<String, bool>();
    notifyListeners();
  }

  Future<void> _savePreferences() async {
    for (var entry in _subscriptions.entries) {
      await _secureStorage.write(key: entry.key, value: entry.value.toString());
    }
  }
}
