import 'package:flutter/material.dart';
import 'package:malachapp/pages/adminPanel.dart';
import 'package:malachapp/pages/Messages/message_broadcast_page.dart';
import 'package:malachapp/services/notification_service.dart';

class AdminSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Settings'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Broadcast Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
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
              await NotificationService().requestNotificationPermission();
            },
            title: const Text('Request Notification Permission'),
          ),
          // MyButton(text: '(ADMIN_PANEL)', onTap: () => Navigator.of(context).push(
          //           MaterialPageRoute(builder: (context) => const AdminPanel()))
          //         ),
          ListTile(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AdminPanel()),
            ),
            title: const Text('Admin Panel'),
            trailing: const Icon(Icons.padding_rounded),
          ),
        ],
      ),
    );
  }
}
