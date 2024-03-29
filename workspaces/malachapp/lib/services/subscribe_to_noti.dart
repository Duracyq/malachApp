import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SubscribeNotifications {
  late FirebaseMessaging fm = FirebaseMessaging.instance;
  final _secureStorage = const FlutterSecureStorage();

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
    await fm.subscribeToTopic(groupId);
  }

  Future<void> unsubscribeFromGroupTopic(String groupId) async {
    await fm.unsubscribeFromTopic(groupId);
  } 


  Future<void> subscribe(String topic) async {
    await fm.subscribeToTopic(topic);
    await _secureStorage.write(key: 'subscribed_$topic', value: 'true');
  }

  Future<void> unsubscribe(String topic) async {
    await fm.unsubscribeFromTopic(topic);
    await _secureStorage.delete(key: 'subscribed_$topic');
  }

  Future<bool> isSubscribedToTopic(String topic) async {
    String? value = await _secureStorage.read(key: 'subscribed_$topic');
    return value == 'true';
  }
}
