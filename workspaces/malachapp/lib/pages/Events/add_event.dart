import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:malachapp/components/MyText.dart';
import 'package:malachapp/components/text_field.dart';
import 'package:malachapp/pages/Events/event_design_page.dart';

class AddEvent extends StatefulWidget {
  const AddEvent({super.key});

  @override
  State<AddEvent> createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Name'),
      ),
      body: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  // Add logic to handle image selection and upload
                },
                child: Text('Add Image'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child:
                  MyTextField(hintText: 'Event name', controller: controller2),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child:
                  MyTextField(hintText: 'Description', controller: controller1),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: MyTextField(hintText: 'date', controller: controller2),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: MyTextField(hintText: 'category', controller: controller1),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child:
                  MyTextField(hintText: 'other data', controller: controller2),
            ),
          ],
        ),
      ),
    );
  }
}
