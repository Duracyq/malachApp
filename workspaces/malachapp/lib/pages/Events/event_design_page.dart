import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:malachapp/components/MyText1.dart';
import 'package:malachapp/auth/auth_service.dart';
import 'package:malachapp/components/my_button.dart';
import 'package:malachapp/pages/Events/enrolled_users_page.dart';
import 'package:malachapp/pages/Events/event_design.dart';
import 'package:malachapp/services/storage_service.dart';
import 'package:malachapp/themes/theme_provider.dart';
import 'package:provider/provider.dart';

class EventDesignPage extends StatefulWidget {
  final String eventID;
  final String eventName;
  final Iterable<dynamic> tags;
  const EventDesignPage({
    Key? key,
    required this.eventID,
    required this.eventName,
    required this.tags,
  }) : super(key: key);

  @override
  State<EventDesignPage> createState() => _EventDesignPageState();
}

class _EventDesignPageState extends State<EventDesignPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late String eventID;
  late String eventName;
  late Iterable<dynamic> tags;
  bool isChecked = false;

  // late bool isChecked;
  @override
  void initState() {
    eventID = widget.eventID;
    eventName = widget.eventName;
    tags = widget.tags;
    // isChecked = _db.collection('events').doc(eventID).get().then((value) => value.data()?['enrolledUsers'].contains(FirebaseAuth.instance.currentUser!.email)) as bool;
    super.initState();
    _toggleIsChecked();
  }

  void toggleEnrollment(DocumentSnapshot<Map<String, dynamic>> eventData) {
    final currentUserEmail = FirebaseAuth.instance.currentUser!.email;
    bool isCurrentlyEnrolled =
        (eventData.data()?['enrolledUsers'] as List<dynamic>?)
                ?.contains(currentUserEmail) ??
            false;

    if (isCurrentlyEnrolled) {
      // Logic for unenrolling the user
      // Ensure this method removes the currentUserEmail from 'enrolledUsers'
      EventList().enrollEvent(widget.eventID);
    } else {
      // Logic for enrolling the user
      // Ensure this method adds the currentUserEmail to 'enrolledUsers'
      EventList().enrollEvent(widget.eventID);
    }
  }

  void _toggleIsChecked() async {
    bool result = await _db.collection('events').doc(eventID).get().then((v) =>
        v
            .data()?['enrolledUsers']
            .contains(FirebaseAuth.instance.currentUser!.email));
    setState(() => isChecked = result);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Ustal kolory na podstawie motywu
    final color = themeProvider.currentThemeKey == 'light'
        ? Colors.grey.shade300
        : Colors.grey.shade900;
    final color2 = themeProvider.currentThemeKey == 'light'
        ? Color.fromARGB(255, 133, 196, 255)
        : Colors.grey.shade900;

    final isDarkMode = themeProvider.currentThemeKey == 'dark';
    return Scaffold(
      appBar: AppBar(title: Text(eventName), actions: [
        Wrap(
          children: [
            for (var value in tags)
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: Visibility(
                      visible: tags.isNotEmpty,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 4),
                        child: Wrap(
                          children: [
                            Text(
                              value,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ]),
      body: FutureBuilder(
        future: _db.collection('events').doc(eventID).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
          }
          return Stack(
            children: [
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: _db.collection('events').doc(eventID).snapshots(),
                  builder: (context,
                      AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                          snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    Timestamp timestamp = snapshot.data!['date'] as Timestamp;
                    DateTime dateTime = timestamp.toDate();
                    String formattedDate =
                        DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
                    return Column(
                      children: [
                        SizedBox(
                          height: 140,
                          width: double.infinity,
                          child: FutureBuilder<String>(
                            future: Storage().getImageUrlFromDir(
                                'event_photos/$eventID/'), // Ensure $eventID is correctly defined
                            builder:
                                (context, AsyncSnapshot<String> snapshot) =>
                                    Container(
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                image: DecorationImage(
                                  image: snapshot.hasData
                                      ? NetworkImage(snapshot.data!)
                                          as ImageProvider // Explicitly casting to ImageProvider
                                      : const AssetImage('assets/favicon.png')
                                          as ImageProvider, // Explicitly casting to ImageProvider
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors
                                          .transparent, // start with transparent color
                                      color, // end with a specific color
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              Center(
                                child: MyText1(
                                  text: snapshot.data!['eventName'] ??
                                      "Event Name",
                                  rozmiar: 24,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.2),
                                    borderRadius:
                                        BorderRadius.circular(10)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 8),
                                  child: Text(
                                    formattedDate, // replace with the event date
                                    style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  snapshot.data!['description'] ?? "Description",
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Visibility(
                  visible: snapshot.data!['isEnrollAvailable'] == true,
                  child: MyButton(
                    text: !isChecked ? 'Zapisz się!' : 'Wypisz się!',
                    onTap: () => EventList()
                        .enrollEvent(eventID)
                        .then((value) =>
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Zapisano na wydarzenie $eventName!'),
                                duration: const Duration(seconds: 2),
                              ),
                            ))
                        .then((value) => setState(() {
                              isChecked = !isChecked;
                            })),
                  ),
                ),
              ),
              FutureBuilder(
                future: AuthService().isAdmin(),
                builder: (context, snapshot) {
                  return Visibility(
                    visible: snapshot.data == true,
                    child: Positioned(
                      bottom: 16 * 6,
                      left: 16,
                      right: 16,
                      child: MyButton(
                        text: 'Enrolled Users',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EnrolledUsersPage(eventID: eventID),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),

      // floatingActionButton: Stack(children: [
      //   Positioned(
      //         bottom: 16,
      //         left: 16,
      //         right: 16,
      //         child: MyButton(
      //           text: 'Zapisz się!',
      //           onTap: () => EventList().enrollEvent(eventID),
      //         ),
      //       ),
      // ],),
    );
  }
  // https://fastly.picsum.photos/id/90/3000/1992.jpg?hmac=v_xO0GFiGn3zpcKzWIsZ3WoSoxJuAEXukrYJUdo2S6g
}
