import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:malachapp/auth/auth_service.dart';
import 'package:malachapp/components/MyText1.dart';
import 'package:malachapp/components/MyText2.dart';
import 'package:malachapp/components/my_button.dart';
import 'package:malachapp/components/text_field.dart';
import 'package:malachapp/services/nickname_fetcher.dart';
import 'package:malachapp/themes/dark_mode.dart';
import 'package:malachapp/themes/theme_provider.dart';
import 'package:provider/provider.dart';

class AddGroupPage extends StatefulWidget {
  const AddGroupPage({super.key});

  @override
  _AddGroupPageState createState() => _AddGroupPageState();
}

class _AddGroupPageState extends State<AddGroupPage> {
  String? selectedClass;
  String? selectedYear;
  final TextEditingController groupTitleController = TextEditingController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;


  @override
  void initState() {
    super.initState();
    fetchYears();
  }


  final List<String> classes = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
  List<String> years = [];
  Future<void> fetchYears() async {
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await _db.collection('academicYears').doc('exT9bo4N0RNOPXHTDxFL').get();
    if (documentSnapshot.exists) {
      final List<dynamic>? yearList = documentSnapshot.data()?['years'];
      if (yearList != null) {
        setState(() {
          years = List<String>.from(yearList);
        });
      } else {
        // Handle case where the 'years' field is null
        // You might want to provide a default value or show an error message
      }
    } else {
      // Handle case where the document doesn't exist
      // You might want to provide a default value or show an error message
    }
  }
  bool isForClass = false;

  void _setYearDropdown() {
  String? yearValue; // Make yearValue nullable

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Wybierz rok'),
        content: FutureBuilder<DocumentSnapshot>(
          future: _db.collection('academicYears').doc('exT9bo4N0RNOPXHTDxFL').get(),
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Błąd: ${snapshot.error}');
            } else if (snapshot.hasData && snapshot.data!.data() != null) {
              List<String> years =
                  List<String>.from((snapshot.data!.data() as Map<String, dynamic>)['years']);
              return StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return DropdownButton<String>(
                    value: yearValue,
                    onChanged: (String? newValue) {
                      setState(() {
                        yearValue = newValue; // Update yearValue
                      });
                    },
                    items: years.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: Provider.of<ThemeProvider>(context).themeData == darkMode
                              ? const TextStyle(color: Colors.white)
                              : const TextStyle(color: Colors.black),
                        ),
                      );
                    }).toList(),
                  );
                },
              );
            } else {
              return const Text('Brak dostępnych lat');
            }
          },
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Anuluj', style: TextStyle(color: Theme.of(context).textTheme.labelLarge?.color)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Zapisz', style: TextStyle(color: Theme.of(context).textTheme.labelLarge?.color)),
            onPressed: () {
              if (yearValue != null) {
                setState(() {
                  selectedYear = yearValue!; // Ensure selectedYear is properly assigned
                });
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}



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
            if (!isForClass)
              TextFormField(
                controller: groupTitleController,
                decoration: InputDecoration(
                  hintText: 'Group Title',
                ),
              ),
            if (isForClass) ...[
              DropdownButton<String>(
                onChanged: (String? newValue) {
                  setState(() {
                    selectedClass = newValue!;
                  });
                },
                items: classes.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                hint: Text(selectedClass ?? 'No Class Selected'),
              ),
              // DropdownButton<String>(
              //   value: selectedYear,
              //   onChanged: (String? newValue) {
              //     setState(() {
              //       selectedYear = newValue;
              //     });
              //   },
              //   items: years.map<DropdownMenuItem<String>>((String value) {
              //     return DropdownMenuItem<String>(
              //       value: value,
              //       child: Text(value),
              //     );
              //   }).toList(),
              //   hint: Text('Select Year'),
              // ),
              ListTile(
                title: Text(selectedYear ?? 'No Year Selected'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _setYearDropdown();
                  },
                ),
              )
            ],
            const SizedBox(height: 16),
            ListTile(
              title: const MyText2(text: 'For Class', rozmiar: 16),
              trailing: Switch(
                value: isForClass,
                onChanged: (value) {
                  setState(() {
                    isForClass = value;
                  });
                },
              ),
            ),
            MyButton(
              onTap: () async {
                // Check if the current user is an admin
                bool isAdmin = await _checkAdminPermission();

                if (isAdmin) {
                  _addGroup();
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
              text: 'Add Group',
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _checkAdminPermission() async {
    final authService = AuthService();
    return await authService.isAdmin();
  }

  void _addGroup() async {
    if(!isForClass) {
       await _db.collection('groups').add({
        'groupTitle': groupTitleController.text,
        'members': [_auth.currentUser!.email],
      }); 
    } else {
      await _db.collection('groupsForClass').add({
        'groupTitle': 'Klasa ${selectedClass!}_${selectedYear!}',
        'members': [_auth.currentUser!.email],
        'class': selectedClass,
        'year': selectedYear,
      });
    }

    // Show a success message or navigate back to the group page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Group added successfully!'),
      ),
    );
    Navigator.pop(context); // Navigate back to the previous screen
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

  

  Future<Widget> _buildNickname(BuildContext context, List members, int index) async {
    final NicknameFetcher nicknameFetcher = NicknameFetcher();
    String? userId = await nicknameFetcher.fetchUserIdByEmail(members[index]);
    if (userId == null || userId.isEmpty) {
      return Text(members[index]); // Handle case where no user ID could be fetched
    }
    return StreamBuilder<String>(
      stream: nicknameFetcher.fetchNickname(userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // Display errors if any
        }
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const CircularProgressIndicator(); // Waiting for data
          default:
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text(members[index]); // Handle case where no nickname is available
            } else {
              final String nickname = snapshot.data!;
              return Text('$nickname (${members[index].split('@').first})'); // Display nickname
            }
        }
      },
    );
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
                    memberEmailController.clear();
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
                    return FutureBuilder(
                      future: _buildNickname(context, members, index),
                      builder: (context, snapshot) {
                        return ListTile(
                          title: snapshot.data,
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
                      }
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
