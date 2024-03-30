import 'package:cached_network_image/cached_network_image.dart';
import 'package:logger/logger.dart'; 
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:getwidget/getwidget.dart';
import 'package:malachapp/pages/Events/add_event.dart';
import 'package:malachapp/pages/Events/event_design_page.dart';
import 'package:malachapp/services/storage_service.dart';

class EventList extends StatefulWidget {
  const EventList({Key? key}) : super(key: key);

  @override
  _EventListState createState() => _EventListState();
}

class _EventListState extends State<EventList> {
  // late bool isChecked = false; // add this line
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    // if(_db.collection('events').doc().get().asStream().contains('isEnrollAvailable') == true) {
    //   setState(() {
    //     isChecked = true;
    //   });
    // }
  }
  Future<void> _enrollEvent(String eventId) async {
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


  Widget _buildEventCard(BuildContext context, int i, DocumentSnapshot snapshot) {
    var data = snapshot.data() as Map<String, dynamic>;
    late bool isChecked = false;
    Future<void> _isChecked() async {
      if(snapshot['enrolledUsers'].containsKey(_auth.currentUser!.uid)) {
        setState(() {
          isChecked = true;
        });
      }
    }

    final DateTime eventDate = snapshot['date'].toDate();
    final String formattedDate = DateFormat('dd.MM.yyyy').format(eventDate);
    var logger = Logger();

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
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(30)),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              child: Text(
                                'Tag', // replace with the event category
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(30)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              child: Text(
                                formattedDate, // replace with the formatted event date
                                style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 10),
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
                          ? snapshot['eventName']
                          : snapshot['description'], // replace with the event name
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        snapshot['description'], // replace with the event description
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
                  visible: data['isEnrollAvailable'] == true, // show the button only if isChecked is false
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isChecked = !isChecked; // toggle isChecked when the button is pressed
                        });
                        _enrollEvent(snapshot.id); // call the function to enroll the user in the event
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.pressed) || isChecked) {
                              return Colors.transparent; // the color when button is pressed or isChecked is true
                            }
                            return Colors.blue; // the default color
                          },
                        ),
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
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => const AddEvent(),
                  ),
                );
              },
              icon: const Icon(CupertinoIcons.add)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(4.0),
        child: StreamBuilder(
          stream: _db.collection('events').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final events = snapshot.data!.docs;
              final currentDate = DateTime.now();

              final upcomingEvents = events
                  .where((event) => event['date'].toDate().isAfter(currentDate))
                  .toList();

              return GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // number of columns
                  crossAxisSpacing: 10, // spacing between the columns
                  mainAxisSpacing: 10, // spacing between the rows
                  childAspectRatio: 0.6,
                ),
                itemCount: upcomingEvents.length, // replace with the number of upcoming events
                itemBuilder: (context, int i) {
                  return _buildEventCard(context, i, upcomingEvents[i]);
                },
              );
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
