// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:malachapp/components/reloadable_widget.dart';
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
class PollList extends StatefulWidget {
  const PollList({super.key});

  @override
  State<PollList> createState() => _PollListState();
}

class _PollListState extends State<PollList> {
  Future<void> _refresh() async {
    setState(() {
      FirebaseFirestore.instance.collection('polls').snapshots();
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Building PollList widget');

    return ReloadableWidget(
      onRefresh: _refresh,
      child: StreamBuilder<QuerySnapshot>(
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
            return {...data, 'id': doc.id};
          }).toList();
      
          print('Number of polls: ${polls.length}');
      
          if (polls.isEmpty) {
            print('No polls available');
            return const Center(
              child: Text('No polls available.'),
            );
          }
      
          return ListView.builder(
            itemCount: polls.length,
            itemBuilder: (context, index) {
              final doc = polls[index];
              final question = doc['question'] ?? ''; // Default to an empty string if 'question' is null
              final options = doc['options'] ?? [];
              final docId = doc['id'] ?? ''; // Default to an empty string if 'id' is null
      
              final optionWidgets = (options as List<dynamic>).map<Widget>((option) {
              final optionData = option as Map<String, dynamic>;
              final optionText = optionData['text'] ?? '';
              final voters = optionData['voters'] as List<dynamic>?;
      
              return VoteButton(
                pollId: docId,
                optionIndex: options.indexOf(option),
                optionText: optionText,
                voters: voters ?? [], // Ensure 'voters' is a list
              );
            }).toList();
      
      
              return ListTile(
                title: Text(question),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: optionWidgets,
                ),
              );
            },
          );
        },
      ),
    );
  }
}


class VoteButton extends StatefulWidget {
  final String pollId;
  final int optionIndex;  // Change the type to int
  final String optionText;
  final List<dynamic> voters;

  const VoteButton({
    super.key,
    required this.pollId,
    required this.optionIndex,
    required this.optionText,
    required this.voters,
  });

  @override
  _VoteButtonState createState() => _VoteButtonState();
}

class _VoteButtonState extends State<VoteButton> {
  bool get userVoted {
    final user = FirebaseAuth.instance.currentUser;
    return user != null &&
        widget.voters != null &&
        widget.voters!.any((voter) => voter['id'] == user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () async {
            if (!userVoted) {
              // Update the document to include the user's vote
              final user = FirebaseAuth.instance.currentUser;
              final pollReference = FirebaseFirestore.instance.collection('polls').doc(widget.pollId);

              await FirebaseFirestore.instance.runTransaction((transaction) async {
                final docSnapshot = await transaction.get(pollReference);
                if (!docSnapshot.exists) {
                  return; // Document does not exist, handle accordingly
                }

                final options = docSnapshot['options'] as List<dynamic>;
                final updatedOptions = List<Map<String, dynamic>>.from(options);

                // Find the option by text
                int optionIndex = -1;
                for (int i = 0; i < updatedOptions.length; i++) {
                  if (updatedOptions[i]['text'] == widget.optionText) {
                    optionIndex = i;
                    break;
                  }
                }

                if (optionIndex != -1) {
                  updatedOptions[optionIndex]['voters'] = [
                    ...updatedOptions[optionIndex]['voters'],
                    {'id': user?.uid},
                  ];

                  transaction.update(pollReference, {'options': updatedOptions});
                } else {
                  // Handle the case where the option is not found
                  print('Option not found: ${widget.optionText}');
                }
              });
            } else {
              // Remove the user's vote from the document
              final user = FirebaseAuth.instance.currentUser;
              final pollReference = FirebaseFirestore.instance.collection('polls').doc(widget.pollId);

              await FirebaseFirestore.instance.runTransaction((transaction) async {
                final docSnapshot = await transaction.get(pollReference);
                if (!docSnapshot.exists) {
                  return; // Document does not exist, handle accordingly
                }

                final options = docSnapshot['options'] as List<dynamic>;
                final updatedOptions = List<Map<String, dynamic>>.from(options);

                // Find the option by text
                int optionIndex = -1;
                for (int i = 0; i < updatedOptions.length; i++) {
                  if (updatedOptions[i]['text'] == widget.optionText) {
                    optionIndex = i;
                    break;
                  }
                }

                if (optionIndex != -1) {
                  updatedOptions[optionIndex]['voters'] = List<Map<String, dynamic>>.from(
                    updatedOptions[optionIndex]['voters'],
                  )..removeWhere((voter) => voter['id'] == user?.uid);

                  transaction.update(pollReference, {'options': updatedOptions});
                } else {
                  // Handle the case where the option is not found
                  print('Option not found: ${widget.optionText}');
                }
              });
            }

          },
          style: ElevatedButton.styleFrom(
            backgroundColor: userVoted ? Colors.green : null,
          ),
          child: Text(widget.optionText),
        ),
      ],
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
            Row(
              children: [
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
                // remove
                IconButton(
                  onPressed: () async {
                    setState(() {
                      if (_howManyOptions > 0) {
                        _howManyOptions--;
                      }
                      optionControllers.removeLast();
                    });
                  },
                  icon: const Icon(Icons.remove),
                ),
              ],
            ),
            IconButton(
              onPressed: () async {
                if (questionController.text.isNotEmpty) {
                  try {
                    // Create a list to store options
                    List<Map<String, dynamic>> options = [];

                    // Add options to the list
                    for (int i = 0; i < _howManyOptions; i++) {
                      options.add({
                        'text': optionControllers[i].text,
                        'voters': [], // Initialize an empty list of voters
                      });
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