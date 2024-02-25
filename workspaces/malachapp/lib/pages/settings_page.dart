import 'package:flutter/material.dart';
import 'package:malachapp/components/my_button.dart';
import 'package:malachapp/pages/message_broadcast_page.dart';
import 'package:malachapp/pages/notification_subs_page.dart';
import 'package:provider/provider.dart';
import 'package:malachapp/themes/theme_provider.dart';
import 'package:malachapp/themes/dark_mode.dart';
import 'package:malachapp/themes/light_mode.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:malachapp/services/notification_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ustawienia'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Switch(
                    value: Provider.of<ThemeProvider>(context).themeData ==
                        darkMode,
                    activeColor: const Color.fromARGB(255, 139, 139, 139),
                    onChanged: (value) {
                      Provider.of<ThemeProvider>(context, listen: false)
                          .toggleTheme();
                    },
                  ),
                ),
                Text(
                  'Motyw',
                  style: GoogleFonts.cinzel(
                    textStyle: TextStyle(
                      fontStyle: FontStyle.normal,
                      // color: Color.fromRGBO(131, 116, 116, 1.0),
                      fontSize: 18,
                    ),
                  ),
                )
              ],
            ),
// <<<<<<< zabka_nie_umie_w_gita
//             //
//             TextButton(
//                 onPressed: () => Navigator.of(context).push(MaterialPageRoute(
//                     builder: (context) => MessageBroadcastPage())),
//                 child: const Text("Send Message Page")),
//             // Example usage in a Flutter widget
//             TextButton(
//               onPressed: () async {
//                 await NotificationService().requestNotificationPermission();
//               },
//               child: Text('Request Notification Permission'),
//             ),
// =======
            ListTile(
              title: Text('Notifications'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: ((context) => NotificationsSubscriptionPage()))
              ),
            )
          ],
        ),
      ),
    );
  }
}
