// ignore_for_file: avoid_debugPrint

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:malachapp/auth/auth_service.dart';
import 'package:malachapp/components/MyText.dart';
import 'package:malachapp/components/my_button.dart';
import 'package:malachapp/components/reloadable_widget.dart';
import 'package:malachapp/components/text_field.dart';
import 'package:malachapp/components/vote_button.dart';
import 'package:malachapp/services/notification_service.dart';
import 'package:malachapp/themes/theme_provider.dart';
import 'package:provider/provider.dart';

/// FILEPATH: /home/dr3x_0/Projects/malachApp/workspaces/malachapp/lib/pages/poll_page.dart
/// A page widget that displays a list of polls.
// ontext,
//                     MaterialPageRoute(builder: (context) => PollCreatorPage()),
//                   );
//                 },
//                 child: const Icon(Icons.add),
//               )
//             : null);
//   }
// }

// /// A stateful widget that represents a list of polls.
// class PollList extends StatefulWidget {
//   const PollList({super.key});

//   @override
//   State<PollList> createState() => _PollListState();
// }

// class _PollListState extends State<PollList> {
//   /// Refreshes the list of polls.
//   Future<void> _refresh() async {
//     setState(() {
//       FirebaseFirestore.instance.collection('polls').snapshots();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     debugPrint('Building PollList widget');
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;
//     return Container(
//       padding: const EdgeInsets.all(10),
//       color: Colors.black12,
//       alignment: Aligclass PollPage extends StatelessWidget {
//   const PollPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(nment.bottomCenter,
//       child: ReloadableWidget(
//         onRefresh: _refresh,
//         child: StreamBuilder<QuerySnapshot>(
//           stream: FirebaseFirestore.instance.collection('polls').snapshots(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(
//                 child: CircularProgressIndicator(),
//               );
//             }
//             if (snapshot.hasError) {
//               return Center(
//                 child: Text('Error: ${snapshot.error}'),
//               );
//             }

//             final polls = snapshot.data!.docs.map((doc) {
//               final data = doc.data() as Map<String, dynamic>;
//               return {...data, 'id': doc.id};
//             }).toList();

//             debugPrint('Number of polls: ${polls.length}');

//             if (polls.isEmpty) {
//               debugPrint('No polls available');
//               return const Center(
//                 child: Text('No polls available.'),
//               );
//             }

//             return ListView.builder(
//               padding: const EdgeInsets.all(5),
//               itemCount: polls.length,
//               itemBuilder: (context, index) {
//                 final doc = polls[index];
//                 final question = doc['question'] ??
//                     ''; // Default to an empty string if 'question' is null
//                 final options = doc['options'] ?? [];
//                 final docId = doc['id'] ??
//                     ''; // Default to an empty string if 'id' is null

//                 final optionWidgets =
//                     (options as List<dynamic>).map<Widget>((option) {
//                   final optionData = option as Map<String, dynamic>;
//                   final optionText = optionData['text'] ?? '';
//                   final voters = optionData['voters'] as List<dynamic>?;

//                   return VoteButton(
//                     pollId: docId,
//                     optionIndex: options.indexOf(option),
//                     optionText: optionText,
//                     voters: voters ?? [], // Ensure 'voters' is a list
//                   );
//                 }).toList();

//                 return GestureDetector(
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => PollAnswering(),
//                       ),
//                     );
//                   },
//                   child: Container(
//                     // Dodany kontener zawierający pytanie i odpowiedzi
//                     padding: EdgeInsets.all(10),
//                     height: screenHeight * 0.1,
//                     margin: EdgeInsets.symmetric(vertical: 7),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Center(
//                       child: MyText(
//                         text:
//                             question + "(nazwaAnkiety)", //!nazwa calej ankiety
//                         rozmiar: 22,
//                         waga: FontWeight.w700,
//                       ),
//                     ),
// // =======
// //                 return Container(
// //                   // Dodany kontener zawierający pytanie i odpowiedzi
// //                   padding: const EdgeInsets.all(10),
// //                   margin: const EdgeInsets.symmetric(vertical: 7),
// //                   decoration: BoxDecoration(
// //                     color: Colors.white,
// //                     borderRadius: BorderRadius.circular(10),
// //                   ),
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Center(
// //                         child: Text(
// //                           'Pytanie',
// //                           style: const TextStyle(
// //                             fontWeight: FontWeight.bold,
// //                             fontSize: 18,
// //                           ),
// //                         ),
// //                       ),
// //                       const SizedBox(height: 40),
// //                       Container(
// //                         height: 80,
// //                         width: screenWidth - 40, // dowolna wartość wysokości
// //                         child: ListView(
// //                             itemExtent: 120,
// //                             scrollDirection: Axis.horizontal,
// //                             children: optionWidgets),
// //                       )
// //                     ],
// // >>>>>>> main
//                   ),
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );

//     ///*/
//   }
// }

// class PollAnswering extends StatefulWidget {
//   @override
//   _PollAnsweringState createState() => _PollAnsweringState();
// }

// class _PollAnsweringState extends State<PollAnswering> {
//   final List<Widget> pollQuestions = [
//     createPollQuestion('Pytanie 1', 'pollId1'),
//     createPollQuestion('Pytanie 2', 'pollId2'),
//     createPollQuestion('Pytanie 3', 'pollId3'),
//     // Dodaj więcej pytań tutaj
//   ];

//   static Widget createPollQuestion(String questionText, String pollId) {
//     return Container(
//       child: Column(
//         children: [
//           MyText(
//             text: questionText,
//             rozmiar: 22,
//             waga: FontWeight.w700,
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: VoteButton(
//               pollId: pollId,
//               optionIndex: 0,
//               optionText: 'Odpowiedź 1',
//               voters: [],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: VoteButton(
//               pollId: pollId,
//               optionIndex: 1,
//               optionText: 'Odpowiedź 2',
//               voters: [],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: VoteButton(
//               pollId: pollId,
//               optionIndex: 2,
//               optionText: 'Odpowiedź 3',
//               voters: [],
//             ),
//           ),
//           // Dodaj więcej odpowiedzi tutaj
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Tytul ankiety'),
//       ),
//       body: Center(
//         child: ListView(
//           children: pollQuestions,
//         ),
//       ),
//     );
//   }
// }

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
//* Kreator Ankiet


class PollCreatorPage extends StatefulWidget {
  const PollCreatorPage({Key? key}) : super(key: key);

  @override
  State<PollCreatorPage> createState() => _PollCreatorPageState();
}

class _PollCreatorPageState extends State<PollCreatorPage> {
  final TextEditingController pollListTitleController = TextEditingController();
  late FirebaseFirestore db = FirebaseFirestore.instance;
  List<PollData> pollsData = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Add this line

  final TextEditingController questionController = TextEditingController(); // Add this line
  final List<TextEditingController> optionControllers = []; // Add this line
  final DocumentReference pollListRef = FirebaseFirestore.instance.collection('polls').doc(); // Add this line

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Poll'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MyTextField(
                  hintText: 'Poll List Title',
                  controller: pollListTitleController,
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), // Add the 'const' keyword
                itemCount: pollsData.length,
                itemBuilder: (context, index) {
                  return PollWidget(
                    pollData: pollsData[index],
                    onRemove: () {
                      setState(() {
                        pollsData.removeAt(index);
                      });
                    },
                  );
                },
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    pollsData.add(PollData());
                  });
                },
                child: const Text('Add Question'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (pollsData.isNotEmpty) {
                    try {
                      // Create a new poll list document
                      DocumentReference pollListRef = await db.collection('pollList').add({
                        'pollListTitle': pollListTitleController.text,
                        'oneTimeChoice': false,
                      });

                      for (var pollData in pollsData) {
                        String question = pollData.questionController.text;
                        List<String> options = pollData.optionControllers.map((controller) => controller.text).toList();

                        if (question.isEmpty) {
                          throw Exception('Question cannot be empty');
                        }

                        if (options.any((option) => option.isEmpty)) {
                          throw Exception('Options cannot be empty');
                        }

                        // Create a list of options with voters
                        List<Map<String, dynamic>> optionsWithVoters = options.map((option) => {
                          'pollTitle': option,
                          'voters': [],
                        }).toList();

                        // Add the question as a document in the polls subcollection
                        await pollListRef.collection('polls').add({
                          'question': question,
                          'options': optionsWithVoters,
                        });
                        Navigator.of(context).pop();
                      }
                    } catch (e) {
                      // Handle the error
                      print(e);
                    }
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PollData {
  late String question;
  late List<String> options;
  late TextEditingController questionController;
  late List<TextEditingController> optionControllers;

  PollData() {
    question = '';
    options = [];
    questionController = TextEditingController(text: question);
    optionControllers = options.map((option) => TextEditingController(text: option)).toList();
  }

  Future<DocumentReference> addToDatabase(String pollListId) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference pollRef = await db.collection('pollList').doc(pollListId).collection('polls').add({
      'pollTitle': questionController.text,
      'options': optionControllers.map((controller) => controller.text).toList(),
    });
    return pollRef;
  }
}

class PollWidget extends StatefulWidget {
  final PollData pollData;
  final VoidCallback onRemove;

  const PollWidget({Key? key, required this.pollData, required this.onRemove}) : super(key: key);

  @override
  _PollWidgetState createState() => _PollWidgetState();
}

class _PollWidgetState extends State<PollWidget> {
  @override
  void initState() {
    super.initState();
    widget.pollData.questionController = TextEditingController(text: widget.pollData.question);
    widget.pollData.optionControllers = widget.pollData.options.map((option) => TextEditingController(text: option)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyTextField(
            hintText: 'Question',
            controller: widget.pollData.questionController,
            onChanged: (value) {
              widget.pollData.question = value;
            },
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: widget.pollData.optionControllers.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: MyTextField(
                        hintText: 'Option ${index + 1}',
                        controller: widget.pollData.optionControllers[index],
                        onChanged: (value) {
                          widget.pollData.options[index] = value;
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          widget.pollData.optionControllers.removeAt(index);
                          widget.pollData.options.removeAt(index);
                        });
                      },
                      icon: Icon(Icons.remove),
                    ),
                  ],
                ),
              );
            },
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                widget.pollData.optionControllers.add(TextEditingController());
                widget.pollData.options.add('');
              });
            },
            child: const Text('Add Option'),
          ),
          IconButton(
            onPressed: widget.onRemove,
            icon: Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}