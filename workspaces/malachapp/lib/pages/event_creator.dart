import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventCreatorPage extends StatefulWidget {
  const EventCreatorPage({Key? key}) : super(key: key);

  @override
  _EventCreatorPageState createState() => _EventCreatorPageState();
}

class _EventCreatorPageState extends State<EventCreatorPage> {
  DateTime? selectedDate;

  final TextEditingController descriptionController = TextEditingController();
  bool isEnrollAvailable = false;

  Future<void> _addEvent() async {
    await FirebaseFirestore.instance.collection('events').add({
      'date': selectedDate?.day,
      'month': selectedDate?.month,
      'year': selectedDate?.year,
      'description': descriptionController.text,
      'isEnrollAvailable': isEnrollAvailable,
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
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
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text(selectedDate != null
                  ? 'Selected Date: ${selectedDate!.toLocal()}'
                  : 'Select Date'),
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
