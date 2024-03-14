import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:malachapp/auth/auth_service.dart';
import 'package:malachapp/components/MyText.dart';
import 'package:malachapp/components/reloadable_widget.dart';
import 'package:malachapp/pages/add_group_page.dart';
import 'package:malachapp/services/group_service.dart';
import 'package:intl/intl.dart';

class MessagingPage extends StatefulWidget {
  final String groupId;

  const MessagingPage({super.key, required this.groupId});

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
    if (user != null) {
      return await _authService.isAdmin();
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
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Visibility(
                  visible: isAdmin,
                  child: IconButton(
                    icon: const Icon(Icons.person_add),
                    onPressed: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  AddMemberPage(groupID: widget.groupId),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            var begin = const Offset(1.0, 0.0);
                            var end = Offset.zero;
                            var curve = Curves.ease;

                            var tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));

                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              )
            ],
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
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ListView(
                      children: snapshot.data!.docs.map((message) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment
                                .start, // aligns the children at the start
                            children: [
                              const CircleAvatar(
                                child: Icon(Icons.person),
                              ),
                              const SizedBox(
                                  width:
                                      10), // add some space between the avatar and the text
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment
                                      .start, // aligns the text to the start
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                            message['sendersNickname'] != null
                                                ? "${message['sendersNickname']
                                                    .split('@')[0]} (${message['sender']
                                                    .split('@')[0]})"
                                                : message['sender'],
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors
                                                  .grey), // smaller, grey text
                                        ),
                                        const Spacer(),
                                        Text(
                                          message['timestamp'] != null
                                              ? formatMessageTime(
                                                  message['timestamp'])
                                              : '...',
                                          style: const TextStyle(
                                              fontSize: 12, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                    Text(message['text']),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                        child: GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                      },
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: "Send a message...",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 20),
                        ),
                      ),
                    )),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.blue),
                      onPressed: () async {
                        if (_messageController.text.isNotEmpty) {
                          await _groupService.sendMessage(
                            widget.groupId,
                            _messageController.text,
                            _auth.currentUser!.email!
                          );
                          _messageController.clear();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<String> _groupIDGetter(String groupTitle) async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection('groups')
          .where('groupTitle', isEqualTo: groupTitle)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String groupId = querySnapshot.docs.first.id;
        return groupId;
      }
    } catch (e) {
      print(e);
    }
    return '';
  }

  Future<bool> isAdminAsync() async {
    User? user = _auth.currentUser;
    if (user != null) {
      return await _authService.isAdmin();
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
              padding: const EdgeInsets.fromLTRB(
                  12.0, 20.0, 12.0, 0.0), // Dodaj odstęp od góry
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
                      return {
                        ...data,
                        'groupTitle': data['groupTitle'] ?? 'No title'
                      };
                    }).toList();

                    if (groups.isEmpty) {
                      return const Center(
                          child: Text('No groups available...'));
                    }
                    return ListView.builder(
                      itemCount: groups.length,
                      itemBuilder: (context, index) {
                        final doc = groups[index];

                        return Container(
                          padding:
                              const EdgeInsets.all(10), // Zwiększ padding do 10
                          margin: const EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 10), // Dodaj margines poziomy
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                                15), // Zwiększ promień zaokrąglenia
                            boxShadow: [
                              // Dodaj cień
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                title: MyText(
                                    text: doc['groupTitle'],
                                    rozmiar: 18,
                                    waga: FontWeight.bold),
                                // title: Text(
                                //   ,
                                //   style: const TextStyle(
                                //     fontWeight: FontWeight.bold,
                                //     fontSize: 18,
                                //   ),
                                // ),
                                onTap: () async {
                                  String groupId =
                                      await _groupIDGetter(doc['groupTitle']);
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          MessagingPage(groupId: groupId)));
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
            floatingActionButton: isAdmin
                ? FloatingActionButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: ((context) => const AddGroupPage())),
                    ),
                  )
                : null,
          );
        });
  }
}

String formatMessageTime(Timestamp timestamp) {
  DateTime messageTime = timestamp.toDate();
  DateTime now = DateTime.now();

  if (now.difference(messageTime).inHours < 24) {
    // If the message was sent within the last 24 hours, display only the time
    return DateFormat('HH:mm').format(messageTime);
  } else {
    // If the message was sent more than 24 hours ago, display the full date and time
    return DateFormat('yyyy-MM-dd HH:mm').format(messageTime);
  }
}
