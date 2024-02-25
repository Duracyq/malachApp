import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:malachapp/auth/admin/firebase_api.dart';
import 'package:malachapp/auth/auth_page.dart';
import 'package:malachapp/firebase_options.dart';
import 'package:malachapp/pages/event_page.dart';
import 'package:malachapp/pages/notification_subs_page.dart';
import 'package:malachapp/pages/poll_page.dart';
import 'package:malachapp/themes/dark_mode.dart';
import 'package:malachapp/themes/light_mode.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:malachapp/themes/theme_provider.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate();
  runApp(ChangeNotifierProvider(
      create: (context) => ThemeProvider(), child: const MyApp()));
  await FirebaseApi().initNotifications();
  FirebaseMessaging.instance.subscribeToTopic(
      'all'); //this provides the app with global broadcast notifications
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return ChangeNotifierProvider<UserNotificationPreferences>(
      create: (context) => UserNotificationPreferences(),
      child: MaterialApp(
        navigatorKey: navKey,
        scaffoldMessengerKey: scaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        theme: Provider.of<ThemeProvider>(context).themeData,
        darkTheme: darkMode,
        home: const FirebaseAuthPage(),
        routes: {
          '/event': (context) => const EventListPage(),
          '/polls': (context) => const PollList(),
          '/notifications': (context) => NotificationsSubscriptionPage(),
        },
      ),
    );
  }
}
