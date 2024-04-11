import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:malachapp/auth/admin_settings_page.dart';
import 'package:malachapp/auth/auth_service.dart';
import 'package:malachapp/pages/Messages/message_broadcast_page.dart';
import 'package:malachapp/pages/notification_subs_page.dart';
import 'package:malachapp/pages/profile_page.dart';
import 'package:malachapp/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:malachapp/themes/theme_provider.dart';
import 'package:malachapp/themes/dark_mode.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthService _authService = AuthService();
  Widget buildDivider(BuildContext context) {
    ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);
    return Column(
      children: [
        Divider(
          color:
              themeProvider.themeData == darkMode ? Colors.white : Colors.black,
          height: 20,
          thickness: 2,
          indent: 20,
          endIndent: 20,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ustawienia'),
      ),
      body: FutureBuilder<bool>(
        future: _authService.isAdmin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            bool isAdmin = snapshot.data!;
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: const Text('Notifications Settings'),
                    leading: const Icon(Icons.notifications),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: ((context) => NotificationsSubscriptionPage()),
                      ),
                    ),
                  ),
                  ListTile(
                    title: const Text('Profile Settings'),
                    leading: const Icon(Icons.person),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProfilePageSettings(),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: isAdmin,
                    child: Column(
                      children: [
                        buildDivider(context),
                        ListTile(
                          title: const Text('Admin Settings'),
                          leading: const Icon(Icons.admin_panel_settings),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AdminSettingsPage(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
