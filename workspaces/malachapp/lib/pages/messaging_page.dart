import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:malachapp/auth/auth_service.dart';
import 'package:malachapp/components/reloadable_widget.dart';
import 'package:malachapp/pages/add_group_page.dart';
import 'package:malachapp/services/group_service.dart';

class MessagingPage extends StatefulWidget {
  final String groupId;

  MessagingPage({Key? key, required this.groupId}) : super(key: key);

  @override
  _MessagingPageState createState() => _MessagingPageState();
}

class _MessagingPageState extends State<MessagingPage> {
  final TextEditingController _messageController = TextEditingController();
  final GroupService _groupService = GroupService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();

  Future<bool> isAdminAsync() async {
    User? user = _auth.currentUser;
    if(user != null) {
      return await _authService.isAdmin(user);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: isAdminAsync(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        bool isAdmin = snapshot.data ?? false;
      
        return Scaffold(
          appBar: AppBar(
            title: const Text("Group Messaging"),
          ),
          body: Column(
            children: <Widget>[
              Expanded(
                child: StreamBuilder(
                  // Use StreamBuilder to listen for real-time updates
                  stream: _db
                      .collection('groups')
                      .doc(widget.groupId)
                      .collection('messages')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    return ListView(
                      children: snapshot.data!.docs.map((message) {
                        return ListTile(
                          title: Text(message['text']),
                          subtitle: Text(message['sender']),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    labelText: "Send a message...",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () async {
                        if (_messageController.text.isNotEmpty) {
                          await _groupService.sendMessage(
                            widget.groupId,
                            _messageController.text,
                            _auth.currentUser!.email!,
                          );
                          _messageController.clear();
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: Visibility(
            visible: isAdmin,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AddMemberPage()),
                );
              },
              child: const Icon(Icons.add),
            ),
          )
        );
      }
    );
  }
}

class GroupPage extends StatefulWidget {
  const GroupPage({Key? key}) : super(key: key);

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<String> _groupIDGetter(String groupTitle) async {
    try {
      QuerySnapshot querySnapshot = await _db.collection('groups')
        .where('groupTitle', isEqualTo: groupTitle)
        .limit(1)
        .get();

      if(querySnapshot.docs.isNotEmpty) {
        String groupId = querySnapshot.docs.first.id;
        return groupId;
      }
    }catch(e){
      print(e);
    }
    return '';
  }

  Future<bool> isAdminAsync() async {
    User? user = _auth.currentUser;
    if(user != null) {
      return await _authService.isAdmin(user);
    }
    return false;
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isAdminAsync(),
      builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      bool isAdmin = snapshot.data ?? false; 
      
      return Scaffold(
        appBar: AppBar(
          title: const Text('Group Page'),
        ),
        body: Container(
          child: ReloadableWidget(
            onRefresh: () async {
              setState(() {
                // Refresh logic here
              });
            },
            child: StreamBuilder<QuerySnapshot>(
              stream: _db.collection('groups').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                final groups = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return {...data, 'groupTitle': data['groupTitle'] ?? 'No title'};
                }).toList();
      
                if (groups.isEmpty) {
                  return const Center(child: Text('No groups available...'));
                }
      
                return ListView.builder(
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final doc = groups[index];
      
                    return Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text(
                              doc['groupTitle'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            onTap: () async {
                              String groupId = await _groupIDGetter(doc['groupTitle']);
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => MessagingPage(groupId: groupId))
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
        floatingActionButton:  isAdmin
            ? FloatingActionButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: ((context) => const AddGroupPage())),
                ),
              )
            : null,
      );
      }
    );
  }

}
