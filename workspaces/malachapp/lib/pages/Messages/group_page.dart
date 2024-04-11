import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:malachapp/auth/auth_service.dart';
import 'package:malachapp/components/MyText1.dart';
import 'package:malachapp/components/reloadable_widget.dart';
import 'package:malachapp/pages/Messages/messaging_page.dart';
import 'package:malachapp/pages/add_group_page.dart';
import 'package:malachapp/pages/notification_subs_page.dart';
import 'package:malachapp/services/group_service.dart';
import 'package:intl/intl.dart';
import 'package:malachapp/services/nickname_fetcher.dart';
import 'package:malachapp/services/notification_service.dart';
import 'package:malachapp/services/subscribe_to_noti.dart';
import 'package:provider/provider.dart';

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
                            // color: Colors.white,
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
                                title: MyText1(
                                  text: doc['groupTitle'],
                                  rozmiar: 18,
                                ),
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
                                      builder: (context) => MessagingPage(
                                            groupId: groupId,
                                            groupTitle: doc['groupTitle'],
                                          )));
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
