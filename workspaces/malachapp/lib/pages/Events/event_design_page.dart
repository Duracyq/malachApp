import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:malachapp/components/MyText.dart';
import 'package:malachapp/services/storage_service.dart';

class EventDesignPage extends StatefulWidget {
  final String eventID;
  final String eventName;
  const EventDesignPage({
    Key? key,
    required this.eventID,
    required this.eventName,
  }) : super(key: key);

  @override
  State<EventDesignPage> createState() => _EventDesignPageState();
}

class _EventDesignPageState extends State<EventDesignPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late String eventID;
  late String eventName;

  @override
  void initState() {
    eventID = widget.eventID;
    eventName = widget.eventName;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(eventName), actions: [
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.blue, borderRadius: BorderRadius.circular(30)),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Text(
                "Tag", // replace with the event category
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
            ),
          ),
        ),
      ]),
      body: StreamBuilder(
        stream: _db.collection('events').doc(eventID).snapshots(),
        builder: (context, snapshot) {
          return Container(
            child: Column(
              children: [
                SizedBox(
                  height: 140,
                  width: double.infinity,
                  child: FutureBuilder<String>(
                    future: Storage().getImageUrlFromDir('event_photos/$eventID/'), // Ensure $eventID is correctly defined
                    builder: (context, AsyncSnapshot<String> snapshot) => Container(
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        image: DecorationImage(
                          image: snapshot.hasData
                            ? NetworkImage(snapshot.data!) as ImageProvider // Explicitly casting to ImageProvider
                            : const AssetImage('assets/favicon.png') as ImageProvider, // Explicitly casting to ImageProvider
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent, // start with transparent color
                              Colors.grey.shade300, // end with a specific color
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
                          //         text: "Event Name",
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
                          MyText(
                              text: snapshot.data!['eventName'] ?? "Event Name",
                              rozmiar: 24,
                              waga: FontWeight.bold),
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(30)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 8),
                              child: Text(
                                Text(
                                  DateFormat('dd.MM.yyyy HH:mm').format(snapshot.data!['date']), // replace with the event date
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ) as String,
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
                      const Text(
                        'Event DescriptionEvent DescriptionE vent Desc riptio nEvent De scriptionEvent Descript ionEvent Descri ption Event Descr iptionEvent DescriptionEv ent Descriptio nEvent Description',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Jakies dane',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Jakies dane',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Jakies dane',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Jakies dane',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
  // https://fastly.picsum.photos/id/90/3000/1992.jpg?hmac=v_xO0GFiGn3zpcKzWIsZ3WoSoxJuAEXukrYJUdo2S6g
}
