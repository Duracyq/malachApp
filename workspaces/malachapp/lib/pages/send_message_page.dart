import 'package:flutter/material.dart';
import 'package:malachapp/services/fcm/chat_view_model.dart';
import 'package:provider/provider.dart';

class SendMessagePage extends StatelessWidget {
  const SendMessagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatViewModel>(
      builder: (context, viewModel, _) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                onChanged: (text) {
                  viewModel.onMessageChange(text);
                },
                decoration: InputDecoration(labelText: 'Enter Message'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  viewModel.sendMessage(false);
                },
                child: Text('Send Message to Remote Token'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  viewModel.sendMessage(true);
                  Navigator.of(context).pop();
                },
                child: Text('Broadcast Message'),
              ),
            ],
          ),
        );
      },
    );
  }
}