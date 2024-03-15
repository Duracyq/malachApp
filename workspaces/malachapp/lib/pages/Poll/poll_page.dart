// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:malachapp/components/MyText.dart';
import 'package:malachapp/components/my_button.dart';
import 'package:malachapp/components/reloadable_widget.dart';
import 'package:malachapp/components/text_field.dart';
import 'package:malachapp/services/notification_service.dart';
import 'package:malachapp/themes/theme_provider.dart';
import 'package:provider/provider.dart';

/// FILEPATH: /home/dr3x_0/Projects/malachApp/workspaces/malachapp/lib/pages/poll_page.dart
/// A page widget that displays a list of polls.
class PollPage extends StatelessWidget {
  const PollPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Ankiety'),
        ),
        body: const PollList(),
        floatingActionButton: FirebaseAuth.instance.currentUser?.email ==
                "00011@malach.com"
            ? FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PollCreatorPage()),
                  );
                },
                child: const Icon(Icons.add),
              )
            : null);
  }
}

/// A stateful widget that represents a list of polls.
class PollList extends StatefulWidget {
  const PollList({super.key});

  @override
  State<PollList> createState() => _PollListState();
}

class _PollListState extends State<PollList> {
  /// Refreshes the list of polls.
  Future<void> _refresh() async {
    setState(() {
      FirebaseFirestore.instance.collection('polls').snapshots();
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Building PollList widget');
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.black12,
      alignment: Alignment.bottomCenter,
      child: ReloadableWidget(
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
              padding: const EdgeInsets.all(5),
              itemCount: polls.length,
              itemBuilder: (context, index) {
                final doc = polls[index];
                final question = doc['question'] ??
                    ''; // Default to an empty string if 'question' is null
                final options = doc['options'] ?? [];
                final docId = doc['id'] ??
                    ''; // Default to an empty string if 'id' is null

                final optionWidgets =
                    (options as List<dynamic>).map<Widget>((option) {
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

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PollAnswering(),
                      ),
                    );
                  },
                  child: Container(
                    // Dodany kontener zawierający pytanie i odpowiedzi
                    padding: EdgeInsets.all(10),
                    height: screenHeight * 0.1,
                    margin: EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: MyText(
                        text:
                            question + "(nazwaAnkiety)", //!nazwa calej ankiety
                        rozmiar: 22,
                        waga: FontWeight.w700,
                      ),
                    ),
// =======
//                 return Container(
//                   // Dodany kontener zawierający pytanie i odpowiedzi
//                   padding: const EdgeInsets.all(10),
//                   margin: const EdgeInsets.symmetric(vertical: 7),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Center(
//                         child: Text(
//                           question,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 40),
//                       Container(
//                         height: 80,
//                         width: screenWidth - 40, // dowolna wartość wysokości
//                         child: ListView(
//                             itemExtent: 120,
//                             scrollDirection: Axis.horizontal,
//                             children: optionWidgets),
//                       )
//                     ],
// >>>>>>> main
                  ),
                );
              },
            );
          },
        ),
      ),
    );

    ///*/
  }
}

class PollAnswering extends StatefulWidget {
  @override
  _PollAnsweringState createState() => _PollAnsweringState();
}

class _PollAnsweringState extends State<PollAnswering> {
  final List<Widget> pollQuestions = [
    createPollQuestion('Pytanie 1', 'pollId1'),
    createPollQuestion('Pytanie 2', 'pollId2'),
    createPollQuestion('Pytanie 3', 'pollId3'),
    // Dodaj więcej pytań tutaj
  ];

  static Widget createPollQuestion(String questionText, String pollId) {
    return Container(
      child: Column(
        children: [
          MyText(
            text: questionText,
            rozmiar: 22,
            waga: FontWeight.w700,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: VoteButton(
              pollId: pollId,
              optionIndex: 0,
              optionText: 'Odpowiedź 1',
              voters: [],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: VoteButton(
              pollId: pollId,
              optionIndex: 1,
              optionText: 'Odpowiedź 2',
              voters: [],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: VoteButton(
              pollId: pollId,
              optionIndex: 2,
              optionText: 'Odpowiedź 3',
              voters: [],
            ),
          ),
          // Dodaj więcej odpowiedzi tutaj
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tytul ankiety'),
      ),
      body: Center(
        child: ListView(
          children: pollQuestions,
        ),
      ),
    );
  }
}

// onPressed: () {
//                       Navigator.of(context).push(
//                         PageRouteBuilder(
//                           pageBuilder:
//                               (context, animation, secondaryAnimation) =>
//                                   const AddMemberPage(),
//                           transitionsBuilder:
//                               (context, animation, secondaryAnimation, child) {
//                             var begin = const Offset(1.0, 0.0);
//                             var end = Offset.zero;
//                             var curve = Curves.ease;

//                             var tween = Tween(begin: begin, end: end)
//                                 .chain(CurveTween(curve: curve));

//                             return SlideTransition(
//                               position: animation.drive(tween),
//                               child: child,
//                             );
//                           },
//                         ),
//                       );
//                     },

/// A stateful widget that represents a vote button for a poll option.
class VoteButton extends StatefulWidget {
  final String pollId;
  final int optionIndex; // Change the type to int
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
  /// Checks if the current user has voted for this option.
  bool get userVoted {
    final user = FirebaseAuth.instance.currentUser;
    return user != null &&
        widget.voters != null &&
        widget.voters!.any((voter) => voter['id'] == user.uid);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      width: 160,
      padding: const EdgeInsets.all(0),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                if (!userVoted) {
                  // Update the document to include the user's vote
                  final user = FirebaseAuth.instance.currentUser;
                  final pollReference = FirebaseFirestore.instance
                      .collection('polls')
                      .doc(widget.pollId);

                  await FirebaseFirestore.instance
                      .runTransaction((transaction) async {
                    final docSnapshot = await transaction.get(pollReference);
                    if (!docSnapshot.exists) {
                      return; // Document does not exist, handle accordingly
                    }

                    final options = docSnapshot['options'] as List<dynamic>;
                    final updatedOptions =
                        List<Map<String, dynamic>>.from(options);

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

                      transaction
                          .update(pollReference, {'options': updatedOptions});
                    } else {
                      // Handle the case where the option is not found
                      print('Option not found: ${widget.optionText}');
                    }
                  });
                } else {
                  // Remove the user's vote from the document
                  final user = FirebaseAuth.instance.currentUser;
                  final pollReference = FirebaseFirestore.instance
                      .collection('polls')
                      .doc(widget.pollId);

                  await FirebaseFirestore.instance
                      .runTransaction((transaction) async {
                    final docSnapshot = await transaction.get(pollReference);
                    if (!docSnapshot.exists) {
                      return; // Document does not exist, handle accordingly
                    }

                    final options = docSnapshot['options'] as List<dynamic>;
                    final updatedOptions =
                        List<Map<String, dynamic>>.from(options);

                    // Find the option by text
                    int optionIndex = -1;
                    for (int i = 0; i < updatedOptions.length; i++) {
                      if (updatedOptions[i]['text'] == widget.optionText) {
                        optionIndex = i;
                        break;
                      }
                    }

                    if (optionIndex != -1) {
                      updatedOptions[optionIndex]
                          ['voters'] = List<Map<String, dynamic>>.from(
                        updatedOptions[optionIndex]['voters'],
                      )..removeWhere((voter) => voter['id'] == user?.uid);

                      transaction
                          .update(pollReference, {'options': updatedOptions});
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
              child: Text(
                widget.optionText,
                style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.color, // Set text color to black
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
//* Kreator Ankiet

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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                child: MyTextField(
                    hintText: 'Question', controller: questionController),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _howManyOptions,
                  itemBuilder: (context, index) {
                    return MyTextField(
                      hintText: 'Option ${index + 1}',
                      controller: optionControllers[index],
                    );
                  },
                ),
              ),
              Column(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            Theme.of(context).colorScheme.primary),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                        padding: MaterialStateProperty.all(EdgeInsets
                            .zero), // Dodajemy to, aby usunąć domyślne marginesy
                      ),
                      onPressed: () async {
                        setState(() {
                          _howManyOptions++;
                          // Add a new controller for the new option
                          optionControllers.add(TextEditingController());
                        });
                      },
                      child: const Icon(
                        Icons.add,
                        color: Colors.black,
                      ),
                    ),
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MyButton(
                  text: "Dodaj Ankietę",
                  onTap: () async {
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

                        await NotificationService().sendPersonalisedFCMMessage(
                            'Go and make your vote count!',
                            'polls',
                            'New Poll has just arrived');
                      } catch (e) {
                        print(e);
                      }
                    }
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.only(right: 140.0),
                  child: Theme(
                    data: ThemeData(
                      unselectedWidgetColor: Colors
                          .red, // Kolor checkboxa, gdy nie jest zaznaczony
                      hintColor: Colors
                          .blue, // Replace 'accentColor' with an existing named parameter or define a named parameter with the name 'accentColor'
                      // Kolor checkboxa, gdy jest zaznaczony
                    ),
                    child: CheckboxListTile(
                      title: const Text(
                        'Jednokrotny wybór',
                        style: TextStyle(
                          // Kolor tekstu
                          fontWeight: FontWeight.bold, // Grubość czcionki
                        ),
                      ),
                      value: false,
                      onChanged: (bool? value) {},
                      activeColor: Colors
                          .yellow, // Kolor tła, gdy checkbox jest zaznaczony
                      checkColor: Colors.black, // Kolor znaku zaznaczenia
                      tileColor: Colors.grey[200], // Kolor tła elementu listy
                      controlAffinity: ListTileControlAffinity
                          .leading, // Umieszczenie checkboxa przed tekstem
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
