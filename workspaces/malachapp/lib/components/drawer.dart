import 'package:flutter/material.dart';
import 'package:malachapp/auth/auth_service.dart';
import 'package:malachapp/components/herb.dart';
import 'package:malachapp/pages/messaging_page.dart';
import 'package:malachapp/pages/profile_page.dart';
import 'package:malachapp/pages/settings_page.dart';
import 'package:malachapp/themes/dark_mode.dart';
import 'package:malachapp/themes/theme_provider.dart';
import 'package:provider/provider.dart';


class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

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
              Provider.of<ThemeProvider>(context, listen: false)
                  .toggleTheme();
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
              Navigator.of(context).push(
                  MaterialPageRoute(builder: ((context) => ProfilePage()))
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: ((context) => const SettingsPage())));
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
