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

/// A stateful widget that represents a vote button for a poll option.
class PollCreatorPage extends StatefulWidget {
  PollCreatorPage({Key? key}) : super(key: key);

  @override
  State<PollCreatorPage> createState() => _PollCreatorPageState();
}

class _PollCreatorPageState extends State<PollCreatorPage> {
  final TextEditingController pollListTitleController = TextEditingController();
  late FirebaseFirestore db = FirebaseFirestore.instance;
  List<Question> questions = [];
  bool _oneTimeChoice = false; // State to keep track of single/multiple choice selection

  @override
  void initState() {
    super.initState();
    // Initialize with one question having one option
    questions.add(Question(
      questionController: TextEditingController(),
      optionControllers: [TextEditingController()],
    ));
  }

  // Add a new question
  void _addQuestion() {
    setState(() {
      questions.add(Question(
        questionController: TextEditingController(),
        optionControllers: [TextEditingController()], // Start with one option
      ));
    });
  }

  // Add a new option to a specific question
  void _addOptionToQuestion(int questionIndex) {
    setState(() {
      questions[questionIndex].optionControllers.add(TextEditingController());
    });
  }

  // Remove an option from a specific question
  void _removeOptionFromQuestion(int questionIndex) {
    if (questions[questionIndex].optionControllers.length > 1) {
      setState(() {
        questions[questionIndex].optionControllers.removeLast();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stwórz ankietę'), // Translate: Create a survey
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MyTextField(
                  hintText: 'Nazwa ankiety', // Translate: Survey name
                  controller: pollListTitleController,
                ),
              ),
              ...questions.map((question) => _buildQuestionSection(question, questions.indexOf(question))).toList(),
              ElevatedButton(
                onPressed: _addQuestion,
                child: const Text('Dodaj pytanie'), // Translate: Add question
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MyButton(
                  text: "Dodaj Ankietę", // Translate: Add Survey
                  onTap: () async {
                    await _submitPoll();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ankieta została dodana'), // Translate: Survey has been added
                    ));
                    NotificationService().sendPersonalisedFCMMessage('Niech Twój głos się liczy! 🗳️', 'polls', 'Nowa dostępna ankieta! 🎉'); 
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CheckboxListTile(
                  title: const Text(
                    'Pojedynczy wybór', // Translate: Single choice
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  value: _oneTimeChoice,
                  onChanged: (bool? value) {
                    setState(() {
                      _oneTimeChoice = value!;
                    });
                  },
                  activeColor: Colors.yellow,
                  checkColor: Colors.black,
                  tileColor: Colors.grey[200],
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionSection(Question question, int index) {
    return Column(
      children: [
        MyTextField(
          hintText: 'Pytanie', // Translate: Question
          controller: question.questionController,
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: question.optionControllers.length,
          itemBuilder: (context, optionIndex) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 5.0, 8.0, 5.0),
              child: MyTextField(
                hintText: 'Opcja #${optionIndex + 1}', // Translate: Option #
                controller: question.optionControllers[optionIndex],
              ),
            );
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => _addOptionToQuestion(index),
              child: const Icon(Icons.add),
            ),
            ElevatedButton(
              onPressed: () => _removeOptionFromQuestion(index),
              child: const Icon(Icons.remove),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _submitPoll() async {
    try {
      if (questions.any((question) => question.questionController.text.isNotEmpty && question.optionControllers.any((controller) => controller.text.isNotEmpty))) {
        String pollListId = db.collection('pollList').doc().id;

        await db.collection('pollList').doc(pollListId).set({
          'pollListTitle': pollListTitleController.text,
          'oneTimeChoice': _oneTimeChoice,
        });

        for (Question question in questions) {
          if (question.questionController.text.isNotEmpty && question.optionControllers.any((controller) => controller.text.isNotEmpty)) {
            List<Map<String, dynamic>> options = question.optionControllers
                .where((controller) => controller.text.isNotEmpty)
                .map((controller) => {'text': controller.text, 'voters': []})
                .toList();

            await db.collection('pollList').doc(pollListId).collection('polls').add({
              'pollTitle': question.questionController.text,
              'options': options,
            });
          }
        }
        NotificationService().sendPersonalisedFCMMessage('Twój głos się liczy! 🗳️', 'polls', 'Nowa ankieta właśnie dotarła! 🎉');        // Resetuj stan po pomyślnym przesłaniu
        pollListTitleController.clear();
        _oneTimeChoice = false; // Reset this if you want to clear the choice for the next use
        questions.clear(); // Clear the entire list of questions
        // Optionally, re-initialize the form to start with a single empty question
        // initState(); // Or a custom method to reinitialize the question form
      }
    } catch (e) {
      // Handle the error here
      print('Error submitting poll: $e');
    }
  }
}

class Question {
  TextEditingController questionController;
  List<TextEditingController> optionControllers;

  Question({required this.questionController, required this.optionControllers});
}
