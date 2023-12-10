import 'package:firebase_admin/firebase_admin.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:malachapp/components/text_field.dart';

class PollPage extends StatelessWidget {
  const PollPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Polls'),
      ),
      body: const PollList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PollCreatorPage()),
          );
        },
        child: const Icon(Icons.add),
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
          return const Center(
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
          return const Center(
            child: Text('No polls available.'),
          );
        }

        return ListView.builder(
          itemCount: polls.length,
          itemBuilder: (context, index) {
            final data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            final options = data.containsKey('options') ? data['options'] : <String, dynamic>{};

            // Convert options to a list of widgets
            final optionWidgets = options.entries.map<Widget>((entry) {
              return Text('${entry.key}: ${entry.value}');
            }).toList();

            return ListTile(
              title: Text(polls[index]),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: optionWidgets,
              ),
            );
          },
        );
      },
    );
  }
}


class PollCreatorPage extends StatefulWidget {
  PollCreatorPage({Key? key}) : super(key: key);


  @override
  State<PollCreatorPage> createState() => _PollCreatorPageState();
}

class _PollCreatorPageState extends State<PollCreatorPage> {
  final TextEditingController questionController = TextEditingController();
  late FirebaseFirestore db = FirebaseFirestore.instance;
  var _howManyOptions = 1;
  List<TextEditingController> optionControllers = [];
  @override
  void initState() {
    super.initState();

    // Initialize option controllers with empty controllers
    for (int i = 0; i < _howManyOptions; i++) {
      optionControllers.add(TextEditingController());
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Poll'),
      ),
      body: Center(
        child: Column(
          children: [
            MyTextField(hintText: 'Question', controller: questionController),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _howManyOptions,
              itemBuilder: (context, index) {
                return MyTextField(
                  hintText: 'Option ${index + 1}',
                  controller: optionControllers[index],
                );
              },
            ),

            Row(children: [
              IconButton(
                onPressed: () async {
                  setState(() {
                    _howManyOptions++;
                    // Add a new controller for the new option
                    optionControllers.add(TextEditingController());
                  });
                },
                icon: const Icon(Icons.add),
              ),
              //remove
              IconButton(
                onPressed: () async {
                  setState(() {
                    if(_howManyOptions>0) {
                      _howManyOptions--;
                    }
                    optionControllers.remove(TextEditingController());
                  });
                },
                icon: const Icon(Icons.remove),
              ),
            ],),

            IconButton(
              onPressed: () async {
                if (questionController.text.isNotEmpty) {
                  try {
                    // Create a map to store options
                    Map<String, dynamic> options = {};

                    // Add options to the map
                    for (int i = 0; i < _howManyOptions; i++) {
                      options['option${i + 1}'] = optionControllers[i].text;
                    }

                    // Add data to Firestore
                    await db.collection('polls').add({
                      'question': questionController.text,
                      'options': options,
                    });

                    questionController.clear();

                    // Clear option controllers
                    for (var controller in optionControllers) {
                      controller.clear();
                    }
                  } catch (e) {
                    print(e);
                  }
                }
              },
              icon: const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
