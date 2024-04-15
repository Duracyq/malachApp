import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:malachapp/auth/auth_service.dart';
import 'package:malachapp/components/MyText1.dart';
import 'package:malachapp/components/MyText2.dart';
import 'package:malachapp/components/my_button.dart';
import 'package:malachapp/components/reloadable_widget.dart';
import 'package:malachapp/pages/add_group_page.dart';
import 'package:malachapp/pages/notification_subs_page.dart';
import 'package:malachapp/services/group_service.dart';
import 'package:intl/intl.dart';
import 'package:malachapp/services/nickname_fetcher.dart';
import 'package:malachapp/services/notification_service.dart';
import 'package:malachapp/services/subscribe_to_noti.dart';
import 'package:malachapp/themes/dark_mode.dart';
import 'package:malachapp/themes/theme_provider.dart';
import 'package:provider/provider.dart';

class MessagingPage extends StatefulWidget {
  final String groupId;
  final String? groupTitle;
  final bool isGFC;

  const MessagingPage({super.key, required this.groupId, this.groupTitle, required this.isGFC});

  @override
  _MessagingPageState createState() => _MessagingPageState();
}

class _MessagingPageState extends State<MessagingPage> {
  final TextEditingController _messageController = TextEditingController();
  final GroupService _groupService = GroupService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  late SubscribeNotifications _subscribeNotifications;
  late bool isGFC;

  @override
  void initState() {
    super.initState();
    isGFC = widget.isGFC;
    _subscribeNotifications = SubscribeNotifications();
    isMemberSubscribed();
  }

  Future<bool> isAdminAsync() async {
    User? user = _auth.currentUser;
    if (user != null) {
      return await _authService.isAdmin();
    }
    return false;
  }

  Future<bool> isMemberSubscribed() async {
    User? user = _auth.currentUser;
    if (user != null) {
      return await _subscribeNotifications
          .isSubscribedToTopic('subscribed_${widget.groupId}');
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
            title: Text(widget.groupTitle ?? "Group Page"),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    Visibility(
                      visible: isAdmin && !isGFC,
                      child: IconButton(
                        icon: const Icon(Icons.person_add),
                        onPressed: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      AddMemberPage(groupID: widget.groupId),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
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
                    Consumer<UserNotificationPreferences>(
                      builder: (context, notificationPrefs, child) {
                        bool isSubscribed = notificationPrefs
                            .isTopicSubscribed('subscribed_${widget.groupId}');
                        return IconButton(
                          icon: isSubscribed
                              ? const Icon(Icons.notifications)
                              : const Icon(Icons.notifications_off),
                          onPressed: () async {
                            if (isSubscribed) {
                              await _subscribeNotifications
                                  .unsubscribeFromGroupTopic(widget.groupId);
                              notificationPrefs.updateSubscriptionStatus(
                                  'subscribed_${widget.groupId}', false);
                              debugPrint(
                                  'Unsubscribed from group topic: ${widget.groupId}');
                            } else {
                              await _subscribeNotifications
                                  .subscribeToGroupTopic(widget.groupId);
                              notificationPrefs.updateSubscriptionStatus(
                                  'subscribed_${widget.groupId}', true);
                              debugPrint(
                                  'Subscribed to group topic: ${widget.groupId}');
                            }
                          },
                        );
                      },
                    ),
                    // IconButton(onPressed: () => SubscribeNotifications().unsubscribeFromGroupTopic(widget.groupId), icon: Icon(Icons.cancel)),
                  ],
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
                                              ? "${message['sendersNickname'].split('@')[0]} (${message['sender'].split('@')[0]})"
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
                          String nicknameTemp = _messageController.text;
                          _messageController.clear();
                          String nickname = await NicknameFetcher().fetchNickname(_auth.currentUser!.uid).first;
                          await NotificationService().sendPersonalisedFCMMessage('$nickname: $nicknameTemp', widget.groupId, widget.groupTitle ?? 'Group Message');
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
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

  Stream<List<Map<String, dynamic>>> getCombinedStream() async* {
    // Fetch streams from Firestore collections
    var groupStream = _db.collection('groups').snapshots().map((snapshot) =>
      snapshot.docs.map((doc) => {
        ...doc.data(),
        'id': doc.id,
        'collection': 'groups',
      }).toList());

    // Check if user is an admin
    bool isAdmin = await AuthService().isAdmin();

    // If the user is an admin, include all groups from 'groupsForClass' without filtering
    Stream<List<Map<String, dynamic>>> groupForClassStream;
    if (isAdmin) {
      groupForClassStream = _db.collection('groupsForClass').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => {
          ...doc.data(),
          'id': doc.id,
          'collection': 'groupsForClass',
        }).toList());
    } else {
      // Fetch the user's class and year once
      var userDoc = await _db.collection('users').doc(_auth.currentUser!.uid).get();
      var userClass = userDoc.data()?['class'];
      var userYear = userDoc.data()?['year'];

      // Prepare the filtered stream for groupsForClass
      groupForClassStream = _db.collection('groupsForClass').snapshots().map((snapshot) =>
        snapshot.docs.where((doc) => doc.data()['class'] == userClass && doc.data()['year'] == userYear).map((doc) => {
          ...doc.data(),
          'id': doc.id,
          'collection': 'groupsForClass',
        }).toList());
    }

    // Combine the streams into a single list
    var combinedStream = StreamZip([groupStream, groupForClassStream])
        .map((List<List<Map<String, dynamic>>> combinedData) => combinedData.expand((x) => x).toList());

    // Process each group to include membership status
    await for (var combinedList in combinedStream) {
      for (var group in combinedList) {
        group['isMember'] = await isMember(group['id']);
      }
      yield combinedList;
    }
  }




  Future<bool> isMember(String groupId) async {
    try {
      var currentUserEmail = _auth.currentUser?.email;
      if (currentUserEmail == null) return false; // Early exit if no user is logged in

      // Adjusted to handle both groups and groupsForClass
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
                // child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Expanded(
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

                            // Safely handle the members list and check if the current user is a member
                            List<dynamic> members = data['members'] as List<dynamic>? ?? [];
                            bool isUserMember(String userEmail) {
                              return members.isNotEmpty && members.contains(userEmail);
                            }

                            // Add the ListTile
                            if (data['collection'] == 'groupsForClass' || isUserMember(_auth.currentUser?.email ?? '') || isAdmin) {
                              children.add(
                                Card(
                                  color: !(data['collection'] == 'groupsForClass' || isUserMember(_auth.currentUser?.email ?? ''))
                                    ? (Provider.of<ThemeProvider>(context, listen: false).themeData == darkMode ? Colors.black54 : Colors.grey)
                                    : (Provider.of<ThemeProvider>(context, listen: false).themeData == darkMode ? Colors.grey[700] : Colors.white), //isn't a member : is a member
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ListTile(
                                      title: Text('$prefix${data['groupTitle']}'),
                                      onTap: () async {
                                        if (data['collection'] == 'groupsForClass') {
                                          // If the group is from 'groupsForClass', get the group ID
                                          String groupId = data['id'];
                                          Navigator.of(context).push(MaterialPageRoute(
                                            builder: (context) => MessagingPage(groupId: groupId, groupTitle: data['groupTitle'], isGFC: true,)
                                          ));
                                          return;
                                        }
                                        if (isUserMember(_auth.currentUser?.email ?? '') || isAdmin) {
                                          String groupId = await _groupIDGetter(data['groupTitle']);
                                          Navigator.of(context).push(MaterialPageRoute(
                                            builder: (context) => MessagingPage(groupId: groupId, groupTitle: data['groupTitle'], isGFC: false,)
                                          ));
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Nie możesz zobaczyć zawartości!'))
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                )
                              );
                            }
                          
                            // Check if a Divider is needed
                            if (i < snapshot.data!.length - 1) {
                              if (data['collection'] != snapshot.data![i + 1]['collection']) {
                                children.add(Wrap(
                                  direction: Axis.horizontal,
                                  children: [
                                    const MyText2(text: 'Czaty Klasowe', rozmiar: 21),
                                    Divider(
                                      color: Provider.of<ThemeProvider>(context).themeData == darkMode
                                      ? Colors.white
                                      : Colors.black, thickness: 2),
                                  ]
                                ));
                              }
                            }
                          }

                          return Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: ListView(
                              children: [
                                ...children,
                                const SizedBox(height: 20), // Add a SizedBox with desired height
                              ],
                            ),
                          );
                        },
                      ),

                      ),
                    ],
                  )
                ),
              ),
              floatingActionButton: isAdmin
                ? FloatingActionButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: ((context) => const AddGroupPage())),
                    ),
                    child: const Icon(Icons.add),
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
