import 'package:flutter/material.dart';

class SurveyScreen extends StatelessWidget {
  final List<Question> questions = [
    Question(
        question: "Pytanie 1",
        options: ["Odpowiedź 1", "Odpowiedź 2", "Odpowiedź 3"]),
    Question(
        question: "Pytanie 2",
        options: ["Odpowiedź 1", "Odpowiedź 2", "Odpowiedź 3"]),
    Question(
        question: "Pytanie 3",
        options: ["Odpowiedź 1", "Odpowiedź 2", "Odpowiedź 3"]),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ankieta")),
      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          return QuestionCard(question: questions[index]);
        },
      ),
    );
  }
}

class Question {
  final String question;
  final List<String> options;

  Question({required this.question, required this.options});
}

class QuestionCard extends StatelessWidget {
  final Question question;

  QuestionCard({required this.question});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20.0),
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          Text(
            question.question,
            // style: Theme.of(context).textTheme.,
          ),
          SizedBox(height: 20),
          ...question.options
              .map((option) => AnswerButton(answer: option))
              .toList(),
        ],
      ),
    );
  }
}

class AnswerButton extends StatelessWidget {
  final String answer;

  AnswerButton({required this.answer});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: ElevatedButton(
        child: Text(answer),
        onPressed: () {},
      ),
    );
  }
}
