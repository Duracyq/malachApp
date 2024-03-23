import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:malachapp/auth/auth_service.dart';
import 'package:malachapp/components/my_button.dart';
import 'package:malachapp/components/text_field.dart';
import 'package:malachapp/themes/dark_mode.dart';
import 'package:malachapp/themes/theme_provider.dart';
import 'package:provider/provider.dart';

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
                bool isAdmin = await _authService.isAdmin();

                if (isAdmin) {
                  await _db.collection('groups').add({
                    'groupTitle': groupTitleController.text,
                    'members': [_auth.currentUser!.email],
                  });

                  // Show a success message or navigate back to the group page
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Group added successfully!'),
                    ),
                  );
                  Navigator.pop(
                      context); // Navigate back to the previous screen
                } else {
                  // Show a message if the user is not an admin
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('You do not have permission to add groups.'),
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
  final String groupID;

  const AddMemberPage({
    super.key,
    required this.groupID,
    });

  @override
  State<AddMemberPage> createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<AddMemberPage> {
  // TextEditingController memberCodeController = TextEditingController();
  TextEditingController memberEmailController = TextEditingController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late String groupID;
  @override
  void initState() {
    super.initState();
    groupID = widget.groupID;
  }

  bool isChecked = false;

  void toggleIsChecked() {
    setState(() {
      isChecked = !isChecked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Member'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
                child: Column(children: [
                  Text('Group ID: $groupID'),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MyTextField(
                    hintText: isChecked ? 'Enter member email' : 'Enter member code',
                    controller: memberEmailController,
                    keyboardType: isChecked ? null : TextInputType.number,
                ), 
              ),
              CheckboxListTile(
                title: const Text('Different domain email'),
                value: isChecked,
                onChanged: (bool? value) {
                  toggleIsChecked();
                },
                activeColor: Provider.of<ThemeProvider>(context).themeData == darkMode
                    ? Colors.black
                    : Colors.white
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MyButton(
                  text: "Dodaj",
                  onTap: () {
                    if(isChecked) {
                      _db.collection('groups').doc(groupID).update({
                        'members': FieldValue.arrayUnion([memberEmailController.text]),
                      });
                    } else {
                      _db.collection('groups').doc(groupID).update({
                        'members': FieldValue.arrayUnion(['${memberEmailController.text}@malach.com']),
                      });
                    }
                  },
                ),
              ),
            ])),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _db.collection('groups').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                final data = snapshot.requireData;
                final groupData = data.docs.firstWhere((doc) => doc.id == groupID);
                final members = (groupData.data() as Map<String, dynamic>)['members'] as List;
                return ListView.builder(
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(members[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          final _auth = FirebaseAuth.instance;
                          if (members[index] != _auth.currentUser!.email) {
                            _db.collection('groups').doc(groupID).update({
                            'members': FieldValue.arrayRemove([members[index]]),
                          });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('You cannot remove yourself from the group'),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                );
              },
                // ListTile(
                //   title: const Text('Member 1'),
                //   trailing: IconButton(
                //     icon: const Icon(Icons.delete),
                //     onPressed: () {
                //       _db.collection('groups').doc(groupID).update({
                //         'members': FieldValue.arrayRemove(['']),
                //       });
                //     },
                //   ),
                // ),
                // ListTile(
                //   title: const Text('Member 2'),
                //   trailing: IconButton(
                //     icon: const Icon(Icons.delete),
                //     onPressed: () {
                //       _db.collection('groups').doc(groupID).update({
                //         'members': FieldValue.arrayRemove(['']),
                //       });
                //     },
                //   ),
                // ),
            ),
          )
        ],
      ),
    );
  }
}
