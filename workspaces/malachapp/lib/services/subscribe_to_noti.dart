import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscribeNotifications {
  late FirebaseMessaging fm = FirebaseMessaging.instance;
  SubscribeNotifications() {
    // Set up listener once in the constructor
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Assuming you have a way to determine the relevant topics
      // for the incoming message, you could check them here.
      // This example just prints out the message data for demonstration.
      print("Message received: ${message.data}");
    });
  }

   Future<void> subscribeToGroupTopic(String groupId) async {
    await fm.subscribeToTopic('subscribed_$groupId');
  }

  Future<void> unsubscribeFromGroupTopic(String groupId) async {
    await fm.unsubscribeFromTopic('subscribed_$groupId');
  } 


  Future<void> subscribe(String topic) async {
    await fm.subscribeToTopic(topic);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('subscribed_$topic', true);
  }

  Future<void> unsubscribe(String topic) async {
    await fm.unsubscribeFromTopic(topic);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('subscribed_$topic');
  }

  Future<bool> isSubscribedToTopic(String topic) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? value = prefs.getBool('subscribed_$topic');
    return value ?? false;
  }
}
