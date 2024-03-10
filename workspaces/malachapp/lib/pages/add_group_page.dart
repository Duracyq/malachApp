import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:malachapp/auth/auth_service.dart';
import 'package:malachapp/components/text_field.dart';

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
        title: const Text('Add Group'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MyTextField(
              controller: groupTitleController,
              hintText: 'Group Title',
            ),
            ElevatedButton(
              onPressed: () async {
                // Check if the current user is an admin
                bool isAdmin = await _authService.isAdmin(_auth.currentUser!);

                if (isAdmin) {
                  await _db.collection('groups').add({
                    'groupTitle': groupTitleController.text,
                  });

                  // Show a success message or navigate back to the group page
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Group added successfully!'),
                    ),
                  );
                  Navigator.pop(context); // Navigate back to the previous screen
                } else {
                  // Show a message if the user is not an admin
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('You do not have permission to add groups.'),
                    ),
                  );
                }
              },
              child: const Text('Add Group'),
            ),
          ],
        ),
      ),
    );
  }
}



class AddMemberPage extends StatefulWidget {
  const AddMemberPage({super.key});

  @override
  State<AddMemberPage> createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<AddMemberPage> {
  TextEditingController memberEmailController = TextEditingController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Member'),
      ),
      body: Center(
        child: Column(
          children:[
            TextField(
              decoration: const InputDecoration(
                labelText: 'Enter member email',
              ),
              controller: memberEmailController,
            ),
            IconButton(
              onPressed: () {
                _db.collection('groups').doc('groupID').update({
                  'members': FieldValue.arrayUnion([memberEmailController.text]),
                });
              },
              icon: const Icon(Icons.add),
            ),
          ] 
        )
      ),
    );
  }
}