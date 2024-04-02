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
    bool isCurrentlyEnrolled = (eventData.data()?['enrolledUsers'] as List<dynamic>?)?.contains(currentUserEmail) ?? false;

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
    bool result = await _db.collection('events').doc(eventID).get().then((v) => v.data()?['enrolledUsers'].contains(FirebaseAuth.instance.currentUser!.email));
    setState(() => isChecked = result);
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(eventName), actions: [
        Wrap(
          children: [
            for (var value in tags)
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.blue, borderRadius: BorderRadius.circular(30)),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Visibility(
                    visible: tags.isNotEmpty,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
            Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
          }
                  return Stack(
                    children: [
                     StreamBuilder<DocumentSnapshot<Map<String,dynamic>>>(
                      stream: _db.collection('events').doc(eventID).snapshots(),
                      builder: (context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        Timestamp timestamp = snapshot.data!['date'] as Timestamp;
                        DateTime dateTime = timestamp.toDate();
                        String formattedDate = DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
                        return Column(
                          children: [
                            SizedBox(
                              height: 140,
                              width: double.infinity,
                              child: FutureBuilder<String>(
                                future: Storage().getImageUrlFromDir('event_photos/$eventID/'), // Upewnij się, że $eventID jest poprawnie zdefiniowane
                                builder: (context, AsyncSnapshot<String> snapshot) => Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey,
                                    image: DecorationImage(
                                      image: snapshot.hasData
                                        ? NetworkImage(snapshot.data!) as ImageProvider // Jawne rzutowanie na ImageProvider
                                        : const AssetImage('assets/favicon.png') as ImageProvider, // Jawne rzutowanie na ImageProvider
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent, // zaczynamy od przezroczystego koloru
                                          Colors.grey.shade300, // kończymy na konkretnym kolorze
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // Expanded(
                                      //   child: GFShimmer(
                                      //     child: const MyText(
                                      //         text: "Nazwa wydarzenia",
                                      //         rozmiar: 24,
                                      //         waga: FontWeight.bold),
                                      //     showGradient: true,
                                      //     gradient: LinearGradient(
                                      //       begin: Alignment.bottomRight,
                                      //       end: Alignment.centerLeft,
                                      //       stops: const <double>[
                                      //         0,
                                      //         0.3,
                                      //         0.6,
                                      //         0.9,
                                      //         1,
                                      //       ],
                                      //       colors: [
                                      //         Colors.teal.withOpacity(0.1),
                                      //         Colors.teal.withOpacity(0.3),
                                      //         Colors.teal.withOpacity(0.5),
                                      //         Colors.teal.withOpacity(0.7),
                                      //         Colors.teal.withOpacity(0.9),
                                      //       ],
                                      //     ),
                                      //   ),
                                      // ),
                                      MyText1(
                                          text: snapshot.data!['eventName'] ?? "Nazwa wydarzenia",
                                          rozmiar: 24,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(30)),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4, horizontal: 8),
                                          child: Text(
                                            formattedDate, // zastąp datą wydarzenia
                                            style: const TextStyle(
                                                color: Colors.green,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 16),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    snapshot.data!['description'] ?? "Opis",
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  // const Row(
                                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  //   children: [
                                  //     Text(
                                  //       'Jakies dane',
                                  //       style: TextStyle(
                                  //         fontSize: 16,
                                  //       ),
                                  //     ),
                                  //     Text(
                                  //       'Jakies dane',
                                  //       style: TextStyle(
                                  //         fontSize: 16,
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
                                  // const SizedBox(height: 10),
                                  // const Row(
                                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  //   children: [
                                  //     Text(
                                  //       'Jakies dane',
                                  //       style: TextStyle(
                                  //         fontSize: 16,
                                  //       ),
                                  //     ),
                                  //     Text(
                                  //       'Jakies dane',
                                  //       style: TextStyle(
                                  //         fontSize: 16,
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                    ),
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
                              .then((value) => ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Zapisano na wydarzenie $eventName!'),
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
                              bottom: 16*6,
                              left: 16,
                              right: 16,
                              child: MyButton(
                                text: 'Zgłoszeni Użytkownicy',
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
