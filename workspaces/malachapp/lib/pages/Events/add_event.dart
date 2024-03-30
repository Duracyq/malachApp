import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:malachapp/components/MyText.dart';
import 'package:malachapp/components/my_button.dart';
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

  bool isEnrollAvailable = false; // Default value, can be changed via UI if needed

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
                        ? 'Wybierz datę i godzinę'
                        : 'Data wydarzenia: ${DateFormat('dd/MM/yyyy HH:mm').format(selectedDate!)}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _pickDateTime(),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(selectedPhoto != null ? 'URL zdjęcia: ${selectedPhoto!.path}' : 'URL zdjęcia'),
                  subtitle: const Text('Opcjonalne'),
                  trailing: const Icon(Icons.image),
                  onTap: () async {
                    final File? photo = await pickAndShrinkPhoto();
                    setState(() {
                      selectedPhoto = photo;
                    });
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Dostępne zapisy'),
                  trailing: Switch(
                      value: isEnrollAvailable,
                      onChanged: (value) {
                        setState(() {
                          isEnrollAvailable = value;
                        });
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                MyButton(
                  onTap: () {
                    if (formKey.currentState!.validate()) {
                      // Process the data and add the event
                      _addEvent();
                    }
                  },
                  text: 'Dodaj Wydarzenie',
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
      // Wyświetl błąd lub przypomnienie o wybraniu daty i godziny
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proszę wybrać datę i godzinę wydarzenia.')),
      );
      return;
    }
      // Zakładając, że masz zmienną globalną lub klasową `File? selectedPhoto;` ustawioną przez `pickAndShrinkPhoto`
    String photoUrl = '';
    if (selectedPhoto != null) {
      Storage storageService = Storage();
      // Zaktualizuj ścieżkę według potrzeb. Na przykład: 'event_photos/${eventNameController.text}'
      photoUrl = await storageService.uploadPhoto(selectedPhoto!, '/event_photos/');
    }

    // Konwertuj selectedDate na Timestamp dla Firestore
    final eventTimestamp = Timestamp.fromDate(selectedDate!);

    // Dodaj wydarzenie do Firestore
    await FirebaseFirestore.instance.collection('events').add({
      'eventName': eventNameController.text,
      'description': descriptionController.text,
      'date': eventTimestamp,
      'enrolledUsers': [],
      'isEnrollAvailable': isEnrollAvailable,
      'photoUrl': photoUrl,
    });

    // Wyczyść pola lub udziel informacji zwrotnej
    eventNameController.clear();
    descriptionController.clear();
    photoUrlController.clear();
    setState(() => selectedDate = null);

    // Wyświetl komunikat potwierdzający
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Wydarzenie dodane pomyślnie!')),
    );
    Navigator.of(context).pop();
  }
}
