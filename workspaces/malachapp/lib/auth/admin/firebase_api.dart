import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:malachapp/main.dart';

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  // init notification
  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
  
    if (fCMToken != null) {
      print('Token: $fCMToken');
    } else {
      print('Unable to get FCM token');
    }
  }

  // handling notification
  void handleMessage(RemoteMessage? message) async {
    if(message == null) return;

    navKey.currentState?.pushNamed(
      '/event',
      arguments: message
    );
  }

  Future initPushNotification() async {
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);

    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }
}