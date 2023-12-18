import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:malachapp/pages/event_creator.dart';

class EventListPage extends StatelessWidget {
  const EventListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event List'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Text('No events found');
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var event = snapshot.data!.docs[index];
              return ListTile(
                title: Text(event['description']),
                onTap: () {
                  // Navigate to EventPage with eventId
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventPage(eventId: event.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const EventCreatorPage())
            );
          }, child: const Icon(Icons.post_add_rounded),),
    );
  }
}

class EventPage extends StatelessWidget {
  final String eventId;

  EventPage({required this.eventId});

  Future<Map<String, dynamic>> _fetchEventData() async {
    DocumentSnapshot eventDoc = await FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .get();

    return eventDoc.data() as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchEventData(),
      builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Text('Event not found');
        }

        var data = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Event Details'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${data['date']} ${data['month']} ${data['year']}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Description: ${data['description']}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                if (data['isEnrollAvailable'])
                  ElevatedButton(
                    onPressed: () {
                      // Implement your enrollment logic here
                      // e.g., navigate to enrollment page
                    },
                    child: const Text('Enroll'),
                  ),
              ],
            ),
          ),
          
        );
      },
    );
  }
}
