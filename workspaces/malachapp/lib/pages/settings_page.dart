import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:malachapp/auth/auth_service.dart';
import 'package:malachapp/pages/message_broadcast_page.dart';
import 'package:malachapp/pages/notification_subs_page.dart';
import 'package:malachapp/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:malachapp/themes/theme_provider.dart';
import 'package:malachapp/themes/dark_mode.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AuthService _authService = AuthService();

  Future<bool> isAdmin() async {
    return await _authService.isAdmin(FirebaseAuth.instance.currentUser!);
  }
  
  Widget buildDivider(BuildContext context) {
    ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);
    return Column(
      children: [
        Divider(
          color: themeProvider.themeData == darkMode
              ? Colors.white
              : Colors.black,
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
        future: isAdmin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
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
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: ((context) => NotificationsSubscriptionPage()),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: isAdmin,
                    child: Column(
                      children: [
                        buildDivider(context),
                        // separator named Admin Privilages
                        Text('Admin Privilages',
                            style: GoogleFonts.roboto(
                              textStyle: const TextStyle(
                                fontStyle: FontStyle.normal,
                                fontSize: 18,
                              ),
                        )),
                        buildDivider(context),
                        ListTile(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MessageBroadcastPage(),
                            ),
                          ),
                          title: const Text("Send Message Page"),
                        ),
                        ListTile(
                          onTap: () async {
                            await NotificationService()
                                .requestNotificationPermission();
                          },
                          title: const Text('Request Notification Permission'),
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
