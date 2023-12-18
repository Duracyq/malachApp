import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventCreatorPage extends StatefulWidget {
  const EventCreatorPage({super.key});

  @override
  _EventCreatorPageState createState() => _EventCreatorPageState();
}

class _EventCreatorPageState extends State<EventCreatorPage> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController monthController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  bool isEnrollAvailable = false;

  Future<void> _addEvent() async {
    await FirebaseFirestore.instance.collection('events').add({
      'date': dateController.text,
      'month': monthController.text,
      'year': yearController.text,
      'description': descriptionController.text,
      'isEnrollAvailable': isEnrollAvailable,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Creator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: dateController,
              decoration: const InputDecoration(labelText: 'Date'),
            ),
            TextField(
              controller: monthController,
              decoration: const InputDecoration(labelText: 'Month'),
            ),
            TextField(
              controller: yearController,
              decoration: const InputDecoration(labelText: 'Year'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            Row(
              children: [
                const Text('Is Enroll Available'),
                Checkbox(
                  value: isEnrollAvailable,
                  onChanged: (value) {
                    setState(() {
                      isEnrollAvailable = value!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _addEvent();
                Navigator.pop(context); // Go back to the previous screen after adding the event
              },
              child: const Text('Create Event'),
            ),
          ],
        ),
      ),
    );
  }
}
