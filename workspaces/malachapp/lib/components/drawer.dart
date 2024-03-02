import 'package:flutter/material.dart';
import 'package:malachapp/auth/auth_service.dart';
import 'package:malachapp/components/herb.dart';
import 'package:malachapp/components/herb_topbar.dart';
import 'package:malachapp/components/topbar.dart';
import 'package:malachapp/pages/messaging_page.dart';
import 'package:malachapp/pages/notification_subs_page.dart';
import 'package:malachapp/pages/settings_page.dart';


class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      //margin: const EdgeInsets.fromLTRB(0, 3.5, 0, 3.5),
      child: Drawer(
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
                  MaterialPageRoute(builder: (context) => GroupPage())
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
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.of(context).push(
               //   MaterialPageRoute(builder: (context) => NotificationsSubscriptionPage())
               // );
                    MaterialPageRoute(builder: ((context) => const SettingsPage())));
              },
            ),
            const SizedBox(height: 50),
            IconButton(
                onPressed: () => AuthService().signOut(),
                icon: const Icon(Icons.power_settings_new_rounded))
          ],
        ),
      ),
    );
  }
}
