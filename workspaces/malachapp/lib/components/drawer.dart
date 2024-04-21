import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:malachapp/auth/auth_service.dart';
import 'package:malachapp/components/herb.dart';
import 'package:malachapp/pages/Messages/group_page.dart';
import 'package:malachapp/pages/Messages/messaging_page.dart';
import 'package:malachapp/pages/founders_page.dart';
import 'package:malachapp/pages/notification_archive.dart';
import 'package:malachapp/pages/profile_page.dart';
import 'package:malachapp/pages/settings_page.dart';
import 'package:malachapp/themes/dark_mode.dart';
import 'package:malachapp/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  late SharedPreferences _prefs;

  void initApp() async {
    await initPrefs();
  }

  Future<void> initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Stream<bool> getPref() {
    return Stream.fromFuture(initPrefs())
        .map((_) => _prefs.getBool('hasNotifications') ?? false);
  }

  Widget buildtheme(BuildContext context) {
    return IconButton(
      icon: Icon(
        Provider.of<ThemeProvider>(context).themeData == darkMode
            ? Icons.nights_stay
            : Icons.wb_sunny,
        size: 30,
        color: Provider.of<ThemeProvider>(context).themeData == darkMode
            ? Colors.white
            : Colors.black,
      ),
      onPressed: () {
        Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
              decoration: const BoxDecoration(shape: BoxShape.circle
                  //color: Colors.brown[300],

                  ),
              child: Container(
                height: 30,
                child: const Herb(),
              )
              // child: const Text(
              //   'Drawer Header',
              //   style: TextStyle(
              //     //color: Colors.white,
              //     fontSize: 24,
              //   ),
              // ),
              ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.message),
            title: const Text('Messages'),
            onTap: () {
              Navigator.of(context).push(
                //BrHkbwqGH0Fzp1zPbIgc
                // MessagingPage(groupId: 'EHi1zf3LgyvIQdHACwmw')
                MaterialPageRoute(builder: (context) => const GroupPage())
              );
              // Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Profile'),
            onTap: () {
              // Update the state of the app
              // Then close the drawer
              Navigator.of(context).push(
                  MaterialPageRoute(builder: ((context) => ProfilePage())));
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: ((context) => const SettingsPage())));
            },
          ),
          StreamBuilder(
            stream: getPref(),
            builder: (context, snapshot) => ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('Notifications Archive'),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: ((context) => NotificationArchive()))
                );
              },
              trailing: snapshot.data == true ? const Icon(Icons.notification_important) : null,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.terminal_rounded),
            title: const Text('Founders '),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: ((context) => FoundersPage())));
            },
          ),
          const SizedBox(height: 60),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildtheme(context),
                const SizedBox(height: 5),
                IconButton(
                  onPressed: () => AuthService().signOut(),
                  icon: const Icon(Icons.power_settings_new_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
