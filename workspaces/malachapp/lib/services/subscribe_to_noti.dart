import 'package:firebase_messaging/firebase_messaging.dart';

class SubscribeNotifications {
  late FirebaseMessaging fm = FirebaseMessaging.instance;

  Future<void> subscribe(String topic) async {
    await fm.subscribeToTopic(topic);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data.containsKey(topic)) {
        print(topic);
      }
    });
  }

  Future<void> unsubscribe(String topic) async {
    fm.unsubscribeFromTopic(topic);
  }


  // Future<void> s_polls() async {
  //   fm.subscribeToTopic('polls');
  // }

  // Future<void> s_events() async {
  //   fm.subscribeToTopic('events');
  // }

  // Future<void> s_posts() async {
  //   fm.subscribeToTopic('posts');
  // }

  // Future<void> all() async {
  //   fm.subscribeToTopic('all');
  // }
}