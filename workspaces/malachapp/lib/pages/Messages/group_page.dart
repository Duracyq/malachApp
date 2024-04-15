import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:malachapp/auth/auth_service.dart';
import 'package:malachapp/components/MyText2.dart';
import 'package:malachapp/components/reloadable_widget.dart';
import 'package:malachapp/pages/Messages/messaging_page.dart';
import 'package:malachapp/pages/add_group_page.dart';
import 'package:provider/provider.dart';
import 'package:malachapp/themes/dark_mode.dart';
import 'package:malachapp/themes/theme_provider.dart';

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
        return querySnapshot.docs.first.id;
      }
    } catch (e) {
      print(e);
    }
    return '';
  }

  Future<bool> isAdminAsync() async {
    User? user = _auth.currentUser;
    return user != null && await _authService.isAdmin();
  }

  Stream<List<Map<String, dynamic>>> getCombinedStream() async* {
    var groupStream = _db.collection('groups').snapshots().map((snapshot) =>
      snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id, 'collection': 'groups'}).toList());

    bool isAdmin = await isAdminAsync();

    Stream<List<Map<String, dynamic>>> groupForClassStream;
    if (isAdmin) {
      groupForClassStream = _db.collection('groupsForClass').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id, 'collection': 'groupsForClass'}).toList());
    } else {
      var userDoc = await _db.collection('users').doc(_auth.currentUser!.uid).get();
      var userClass = userDoc.data()?['class'];
      var userYear = userDoc.data()?['year'];
      groupForClassStream = _db.collection('groupsForClass').snapshots().map((snapshot) =>
        snapshot.docs.where((doc) => doc.data()['class'] == userClass && doc.data()['year'] == userYear).map((doc) => {...doc.data(), 'id': doc.id, 'collection': 'groupsForClass'}).toList());
    }

    var combinedStream = StreamZip([groupStream, groupForClassStream])
        .map((List<List<Map<String, dynamic>>> combinedData) => combinedData.expand((x) => x).toList());

    await for (var combinedList in combinedStream) {
      for (var group in combinedList) {
        bool isMember = await this.isMember(group['id']);
        group['isMember'] = isMember;
      }
      yield combinedList;
    }
  }

  Future<bool> isMember(String groupId) async {
    try {
      var currentUserEmail = _auth.currentUser?.email;
      if (currentUserEmail == null) return false;

      DocumentSnapshot groupDoc = await _db.collection('groups').doc(groupId).get();
      if (!groupDoc.exists) {
        groupDoc = await _db.collection('groupsForClass').doc(groupId).get();
        if (!groupDoc.exists) return false;
      }

      Map<String, dynamic>? groupData = groupDoc.data() as Map<String, dynamic>?;
      List<dynamic> members = groupData?['members'] as List<dynamic>? ?? [];
      return members.contains(currentUserEmail);
    } catch (e) {
      print("Error checking membership: $e");
      return false;
    }
  }

  @override
Widget build(BuildContext context) {
  return FutureBuilder<bool>(
    future: isAdminAsync(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      bool isAdmin = snapshot.data ?? false;

      return Scaffold(
        appBar: AppBar(title: const Text('Group Page')),
        body: Container(
          padding: const EdgeInsets.fromLTRB(12.0, 20.0, 12.0, 0.0),
          child: ReloadableWidget(
            onRefresh: () async {
              setState(() {});
            },
            child: SingleChildScrollView(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: getCombinedStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(child: Text('No groups available...'));
                  }

                  List<Widget> children = [];
                  for (int i = 0; i < snapshot.data!.length; i++) {
                    final data = snapshot.data![i];
                    String prefix = data['collection'] == 'groupsForClass' ? '' : '';
                    List<dynamic> members = data['members'] as List<dynamic>? ?? [];
                    bool isUserMember(String userEmail) {
                      return members.isNotEmpty && members.contains(userEmail);
                    }

                    if (data['collection'] == 'groupsForClass' || isUserMember(_auth.currentUser?.email ?? '') || isAdmin) {
                      children.add(
                        Card(
                          color: !(data['collection'] == 'groupsForClass' || isUserMember(_auth.currentUser?.email ?? ''))
                            ? (Provider.of<ThemeProvider>(context, listen: false).themeData == darkMode ? Colors.black54 : Colors.grey)
                            : (Provider.of<ThemeProvider>(context, listen: false).themeData == darkMode ? Colors.grey[700] : Colors.white),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text('$prefix${data['groupTitle']}'),
                              onTap: () async {
                                if (data['collection'] == 'groupsForClass') {
                                  String groupId = data['id'];
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => MessagingPage(groupId: groupId, groupTitle: data['groupTitle'], isGFC: true)));
                                } else {
                                  if (isUserMember(_auth.currentUser?.email ?? '') || isAdmin) {
                                    String groupId = await _groupIDGetter(data['groupTitle']);
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => MessagingPage(groupId: groupId, groupTitle: data['groupTitle'], isGFC: false)));
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You do not have access to view this group!')));
                                  }
                                }
                              },
                            ),
                          ),
                        )
                      );
                    }

                    if (i < snapshot.data!.length - 1) {
                      if (data['collection'] != snapshot.data![i + 1]['collection']) {
                        children.add(Wrap(
                          direction: Axis.horizontal,
                          children: [
                            const MyText2(text: 'Class Chats', rozmiar: 21),
                            Divider(color: Provider.of<ThemeProvider>(context).themeData == darkMode ? Colors.white : Colors.black, thickness: 2),
                          ]
                        ));
                      }
                    }
                  }

                  return ListView(
                    primary: false,  // Make sure the ListView does not scroll
                    shrinkWrap: true,  // Let ListView size itself according to the incoming content
                    children: [...children, const SizedBox(height: 20)],
                  );
                },
              ),
            ),
          ),
        ),
        floatingActionButton: isAdmin ? FloatingActionButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: ((context) => const AddGroupPage()))), child: const Icon(Icons.add)) : null,
      );
    },
  );
}

}

String formatMessageTime(Timestamp timestamp) {
  DateTime messageTime = timestamp.toDate();
  DateTime now = DateTime.now();
  if (now.difference(messageTime).inHours < 24) {
    return DateFormat('HH:mm').format(messageTime);  // Display only the time for recent messages
  } else {
    return DateFormat('yyyy-MM-dd HH:mm').format(messageTime);  // Display the full date for older messages
  }
}
