import 'package:flutter/material.dart';
import 'package:malachapp/components/text_field.dart';

class CreatorPage extends StatefulWidget {
  const CreatorPage({super.key});

  @override
  State<CreatorPage> createState() => _CreatorPageState();
}

class _CreatorPageState extends State<CreatorPage> {
  late TextEditingController titleController = TextEditingController(); 

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const SizedBox(height: 25),
      IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back_ios_new_rounded), alignment: Alignment.topLeft),
        MyTextField(hintText: "Title", controller: titleController),
        IconButton(onPressed: () {}, icon: const Icon(Icons.send))
    ]);
  }
}