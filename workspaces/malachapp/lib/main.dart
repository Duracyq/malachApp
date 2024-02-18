import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:malachapp/auth/admin/firebase_api.dart';
import 'package:malachapp/auth/auth_page.dart';
import 'package:malachapp/firebase_options.dart';
import 'package:malachapp/pages/event_page.dart';
import 'package:malachapp/pages/poll_page.dart';
import 'package:malachapp/services/fcm/chat_view_model.dart';
// import 'package:malachapp/services/notification_service.dart';
import 'package:malachapp/themes/dark_mode.dart';
import 'package:malachapp/themes/light_mode.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

final navKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate();
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => ChatViewModel()),
    ], child: const MyApp(),)
  );
  await FirebaseApi().initNotifications();
  FirebaseMessaging.instance.subscribeToTopic('all'); //this provides the app with global broadcast notifications
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // final NotificationService _notificationService = NotificationService();
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      darkTheme: darkMode,
      home: const FirebaseAuthPage(),
      navigatorKey: navKey,
      routes: ({
        '/event':(context) => const EventListPage(),
        '/polls':(context) => const PollList(),
      }),
    );
  }
}
