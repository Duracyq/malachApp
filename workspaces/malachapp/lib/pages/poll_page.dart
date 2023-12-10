import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PollPage extends StatelessWidget {
  const PollPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upcoming Polls'),
      ),
      body: PollList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PollCreatorPage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class PollList extends StatelessWidget {
  const PollList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Building PollList widget'); // Debugging line

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('polls').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final polls = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data.containsKey('question') ? data['question'] : '';
        }).toList();

        print('Number of polls: ${polls.length}'); // Debugging line

        if (polls.isEmpty) {
          print('No polls available'); // Debugging line
          return Center(
            child: Text('No polls available.'),
          );
        }

        return ListView.builder(
          itemCount: polls.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(polls[index]),
            );
          },
        );
      },
    );

  }
}

class PollCreatorPage extends StatelessWidget {
  const PollCreatorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Poll'),
      ),
      body: Center(
        child: Text('Create your poll here'),
      ),
    );
  }
}
