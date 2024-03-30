import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:malachapp/components/MyText.dart';
import 'package:malachapp/components/text_field.dart';
import 'package:malachapp/pages/Events/event_design_page.dart';
import 'package:intl/intl.dart';
import 'package:malachapp/services/photo_from_gallery_picker.dart';
import 'package:malachapp/services/storage_service.dart';

class AddEvent extends StatefulWidget {
  const AddEvent({super.key});

  @override
  State<AddEvent> createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  final formKey = GlobalKey<FormState>();
  TextEditingController eventNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  DateTime? selectedDate;
  TextEditingController photoUrlController = TextEditingController();
  File? selectedPhoto;

  bool isEnrollAvailable = true; // Default value, can be changed via UI if needed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kreator Wydarzeń'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                MyTextField(
                  hintText: 'Nazwa wydarzenia',
                  controller: eventNameController,
                ),
                const SizedBox(height: 16),
                MyTextField(
                  hintText: 'Opis',
                  controller: descriptionController,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(
                    selectedDate == null
                        ? 'Pick Date and Time'
                        : 'Event Date: ${DateFormat('dd/MM/yyyy HH:mm').format(selectedDate!)}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _pickDateTime(),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Photo URL'),
                  subtitle: const Text('Optional'),
                  trailing: const Icon(Icons.image),
                  onTap: () {
                    selectedPhoto = pickAndShrinkPhoto() as File?;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      // Process the data and add the event
                      _addEvent();
                    }
                  },
                  child: const Text('Dodaj Wydarzenie'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
    
    Future<void> _pickDateTime() async {
      final date = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (date == null) return; // User tapped on cancel

      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDate ?? DateTime.now()),
      );
      if (time == null) return; // User tapped on cancel

      setState(() {
        selectedDate = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      });
    }


  void _addEvent() async {
    if (selectedDate == null) {
      // Show an error or a reminder to pick a date and time
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick a date and time for the event.')),
      );
      return;
    }
      // Assuming you have a global or class-level variable `File? selectedPhoto;` set by `pickAndShrinkPhoto`
    String photoUrl = '';
    if (selectedPhoto != null) {
      Storage storageService = Storage();
      // Update the path as needed. For example: 'event_photos/${eventNameController.text}'
      photoUrl = await storageService.uploadPhoto(selectedPhoto!, 'path/to/upload');
    }

    // Convert selectedDate to Timestamp for Firestore
    final eventTimestamp = Timestamp.fromDate(selectedDate!);

    // Add the event to Firestore
    await FirebaseFirestore.instance.collection('events').add({
      'eventName': eventNameController.text,
      'description': descriptionController.text,
      'date': eventTimestamp,
      'enrolledUsers': [],
      'isEnrollAvailable': isEnrollAvailable,
      'photoUrl': photoUrl,
    });

    // Clear the inputs or give feedback
    eventNameController.clear();
    descriptionController.clear();
    photoUrlController.clear();
    setState(() => selectedDate = null);

    // Show a confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event added successfully!')),
    );
  }
}

