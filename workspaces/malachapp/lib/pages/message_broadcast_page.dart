// message_broadcast_page.dart
import 'package:flutter/material.dart';
import 'package:malachapp/services/notification_service.dart';

class MessageBroadcastPage extends StatefulWidget {
  @override
  _MessageBroadcastPageState createState() => _MessageBroadcastPageState();
}

class _MessageBroadcastPageState extends State<MessageBroadcastPage> {
  final TextEditingController _messageController = TextEditingController();
  final NotificationService _notificationService = NotificationService();

  void _broadcastMessage() async {
    final String message = _messageController.text.trim();

    if (message.isNotEmpty) {
      try {
        await _notificationService.sendFCMMessage(message);

        print('Message broadcast successful');
      } catch (error) {
        print('Failed to broadcast message: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Message Broadcast'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _messageController,
              decoration: InputDecoration(labelText: 'Enter your message'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _broadcastMessage,
              child: Text('Broadcast Message'),
            ),
          ],
        ),
      ),
    );
  }
}
