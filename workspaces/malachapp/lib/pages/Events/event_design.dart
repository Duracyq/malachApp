import 'package:cached_network_image/cached_network_image.dart';
import 'package:logger/logger.dart'; 
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:getwidget/getwidget.dart';
import 'package:malachapp/auth/auth_service.dart';
import 'package:malachapp/components/reloadable_widget.dart';
import 'package:malachapp/pages/Events/add_event.dart';
import 'package:malachapp/pages/Events/event_design_page.dart';
import 'package:malachapp/services/storage_service.dart';

class EventList extends StatefulWidget {
  EventList({Key? key}) : super(key: key);
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String eventId;
  Future<void> enrollEvent(String eventId) async {
    _db.runTransaction((transaction){
      return transaction.get(_db.collection('events').doc(eventId)).then((event){
        if(event.exists){
          var data = event.data() as Map<String, dynamic>;
          if(data.containsKey('enrolledUsers')){
            var enrolledUsers = data['enrolledUsers'] as List<dynamic>;
            if(enrolledUsers.contains(_auth.currentUser!.email)) {
              enrolledUsers.remove(_auth.currentUser!.email);
              transaction.update(_db.collection('events').doc(eventId), {'enrolledUsers': enrolledUsers});
            } else {
              enrolledUsers.add(_auth.currentUser!.email);
              transaction.update(_db.collection('events').doc(eventId), {'enrolledUsers': enrolledUsers});
            }
          } else {
            transaction.update(_db.collection('events').doc(eventId), {'enrolledUsers': [_auth.currentUser!.email]});
          }
        }
      });
    });
  }

  @override
  _EventListState createState() => _EventListState();
}

class _EventListState extends State<EventList> {
  // late bool isChecked = false; // add this line
  late bool isChecked = false;

  @override
  void initState() {
    super.initState();
    // if(_db.collection('events').doc().get().asStream().contains('isEnrollAvailable') == true) {
    //   setState(() {
    //     isChecked = true;
    //   });
    // }
    // checkUserEnrollment();
  }

  Future<void> checkUserEnrollment(String? eventId) async {
    try {
      DocumentSnapshot eventDoc = await widget._db.collection('events').doc(eventId).get();
      if (eventDoc.exists) {
        Map<String, dynamic> data = eventDoc.data() as Map<String, dynamic>;
        List<dynamic> enrolledUsers = data['enrolledUsers'] ?? [];
        setState(() {
          isChecked = enrolledUsers.contains(widget._auth.currentUser!.uid);
        });
      }
    } catch (e) {
      print("Error checking user enrollment: $e");
    }
  }

  Widget _buildEventCard(BuildContext context, DocumentSnapshot snapshot, bool? past) {
    var data = snapshot.data() as Map<String, dynamic>;

    final DateTime eventDate = snapshot['date'].toDate();
    final String formattedDate = DateFormat('dd.MM.yyyy').format(eventDate);

    final currentUserEmail = widget._auth.currentUser!.email;
    // bool isUserEnrolled = data.containsKey('enrolledUsers') && data['enrolledUsers'].contains(currentUserEmail);
    bool isUserEnrolled = (snapshot.data() as Map<String, dynamic>)['enrolledUsers']?.contains(currentUserEmail) ?? false;
    Iterable<dynamic> tags = data['tags'] ?? [];


    return Material(
          elevation: 3,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => EventDesignPage(
                    eventID: snapshot.id,
                    eventName: snapshot['eventName'],
                    tags: tags,
                  ),
                ),
              );
              print("Event ${snapshot.id} tapped");
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      child: FutureBuilder<String>(
                        future: Storage().getImageUrlFromDir('event_photos/${snapshot.id}/'), // Adjust with your image's name and extension
                        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            // Show a loader while waiting for the future to complete
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            // If the future completes with an error, show a constant fallback image
                            return const AspectRatio(aspectRatio: 16 / 9,child: Image(image: AssetImage('assets/favicon.png'), fit: BoxFit.cover));
                          } else {
                            // If the future completes successfully, show the CachedNetworkImage
                            return AspectRatio(
                              aspectRatio: 16 / 9,
                              child: CachedNetworkImage(
                                imageUrl: snapshot.data!,
                                placeholder: (context, url) => const CircularProgressIndicator(),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                                fit: BoxFit.cover,
                              ),
                            );
                          }
                          //  else {
                          //   return Center(child: Text('No image found'));
                          // }
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Column(
                        children: [
                          Wrap(
                            direction: Axis.horizontal,
                            spacing: 3,
                            children: [
                              if(tags.length <= 3)
                              for (var value in tags)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Visibility(
                                  visible: data['tags'] != null && data.containsKey('tags') && data['tags'].isNotEmpty,
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
                              if(tags.length > 3)
                              for (var value in tags.take(3))
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Visibility(
                                  visible: data['tags'] != null && data.containsKey('tags') && data['tags'].isNotEmpty,
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
                              if(tags.length > 3)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Visibility(
                                  visible: data['tags'] != null && data.containsKey('tags') && data['tags'].isNotEmpty,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                    child: Wrap(
                                      children: [
                                        Text(
                                          '+${tags.length - 3}',
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

                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(30)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              child: Wrap(
                                children:[
                                  const Icon(
                                    Icons.calendar_today,
                                    color: Colors.green,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    formattedDate, // replace with the formatted event date
                                    style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 10),
                                  ),
                                ] 
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        (snapshot.data() != null && data.containsKey('eventName'))
                          ? (snapshot['eventName'].length <= 20)
                            ? snapshot['eventName']
                            : "${snapshot['eventName'].substring(0,20)}..." // replace with the event name
                          : (snapshot['description'].length <= 20)
                            ? snapshot['description']
                            : "${snapshot['description'].substring(0,20)}...", // replace with the event name
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if(snapshot['isEnrollAvailable'] == false)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        (snapshot['description'].length <= 70)
                          ? snapshot['description']
                          : "${snapshot['description'].substring(0,70)}...", // replace with the event description
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  ],
                ),

                //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     GFCheckbox(
                //       activeBgColor: const Color.fromRGBO(16, 220, 96, 1),
                //       size: GFSize.SMALL,
                //       type: GFCheckboxType.circle,
                //       onChanged: (value) {
                //         setState(() {
                //           isChecked = value;
                //         });
                //       },
                //       value: isChecked,
                //       inactiveIcon: null,
                //     ),
                //     SizedBox(
                //       width: 3,
                //     ),
                //     Text(
                //       "Zapisz się!", // replace with the event price
                //       style: TextStyle(
                //           fontSize: 16,
                //           color: Colors.black,
                //           fontWeight: FontWeight.w700),
                //     ),
                //   ],
                // ),
                // SizedBox(
                //   height: 0,
                // )
                Visibility(
                  visible: data['isEnrollAvailable'] == true && !past!, // show the button only if isEnrollAvailable is true
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isChecked = !isChecked; // toggle isChecked when the button is pressed
                        });
                        EventList().enrollEvent(snapshot.id); // call the function to enroll the user in the event
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            // MaterialStateProperty.resolveWith<Color>(
                            //   (Set<MaterialState> states) {
                            //     if (states.contains(MaterialState.pressed) || isChecked || isUserEnrolled) {
                            //       return Colors.transparent; // the color when button is pressed or isChecked is true
                            //     }
                            //     return Colors.blue; // the default color
                            //   },
                            // ),
                            isUserEnrolled
                                ? MaterialStateProperty.all<Color>(Colors.transparent)
                                : MaterialStateProperty.all<Color>(Colors.blue),
                        fixedSize: MaterialStateProperty.all<Size>(
                          const Size(118, 25),
                        ),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13.0), // round the corners
                          ),
                        ),
                      ),
                      child: const Text(
                        "Zapisz się!",
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 3)
              ],
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Events"),
        actions: [
          FutureBuilder(
            future: AuthService().isAdmin(),
            builder: (context, snapshot) {
              return Visibility(
                visible: snapshot.hasData && snapshot.data == true,
                child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (BuildContext context) => const AddEvent(),
                        ),
                      );
                    },
                    icon: const Icon(CupertinoIcons.add)),
              );
            }
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: StreamBuilder(
                stream: EventList()._db.collection('events').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const CircularProgressIndicator();
                  final events = snapshot.data!.docs;
                  final currentDate = DateTime.now();
                  
                  final upcomingEvents = events
                      .where((event) => event['date'].toDate().isAfter(currentDate))
                      .toList();
        
                  final pastEvents = events
                      .where((event) => event['date'].toDate().isBefore(currentDate))
                      .toList();
                  
                  return Column(
                    children: [
                      GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.6,
                          ),
                          itemCount: upcomingEvents.length,
                          // Important: Wrap itemBuilder with Builder or similar to avoid context issues
                          itemBuilder: (context, int i) => _buildEventCard(context, upcomingEvents[i], false),
                          // Disable scrolling since it's in a scrollable view
                          physics: const NeverScrollableScrollPhysics(),
                          // Never grow since it's already constrained
                          shrinkWrap: true,
                      ),
                      const Column(
                        children: [
                          SizedBox(
                            height: 25,
                          ),
                           Divider(
                            color: Colors.grey,
                            thickness: 2,
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "Archiwum Wydarzeń",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ]
                      ),
                      GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.6,
                          ),
                          itemCount: pastEvents.length,
                          itemBuilder: (context, int i) => _buildEventCard(context, pastEvents[i], true),
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}