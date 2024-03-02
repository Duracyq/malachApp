import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:malachapp/auth/auth_service.dart';

class AddGroupPage extends StatefulWidget {
  const AddGroupPage({super.key});

  @override
  _AddGroupPageState createState() => _AddGroupPageState();
}

class _AddGroupPageState extends State<AddGroupPage> {
  final TextEditingController groupTitleController = TextEditingController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Group'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: groupTitleController,
              decoration: InputDecoration(labelText: 'Group Title'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Check if the current user is an admin
                bool isAdmin = await _authService.isAdmin(_auth.currentUser!);

                if (isAdmin) {
                  // Logic to add the group to the database
                  // Use _questionController.text, _optionController1.text, _optionController2.text
                  // to get the values entered by the admin and add them to the database

                  // Example:
                  // await _db.collection('groups').add({
                  //   'question': _questionController.text,
                  //   'options': [
                  //     _optionController1.text,
                  //     _optionController2.text,
                  //   ],
                  // });

                  await _db.collection('groups').add({
                    'groupTitle': groupTitleController.text,
                  });

                  // Show a success message or navigate back to the group page
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Group added successfully!'),
                    ),
                  );
                  Navigator.pop(context); // Navigate back to the previous screen
                } else {
                  // Show a message if the user is not an admin
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('You do not have permission to add groups.'),
                    ),
                  );
                }
              },
              child: Text('Add Group'),
            ),
          ],
        ),
      ),
    );
  }
}
