import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:malachapp/components/text_field.dart';
import 'package:malachapp/services/notification_service.dart';

class CreatorPage extends StatefulWidget {
  const CreatorPage({super.key});

  @override
  State<CreatorPage> createState() => _CreatorPageState();
}

class _CreatorPageState extends State<CreatorPage> {
  final Stream<QuerySnapshot> _postsStream = FirebaseFirestore.instance.collection('posts').snapshots(includeMetadataChanges: true);

  late TextEditingController titleController = TextEditingController(); 
  late TextEditingController descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 25),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            alignment: Alignment.topLeft,
          ),

          //controllers
          MyTextField(hintText: "Title", controller: titleController),
          MyTextField(hintText: "Desc", controller: descController),

          // SEND BUTTON
          IconButton(
            onPressed: () async {
              // Check if both title and desc are not empty
              if (titleController.text.isNotEmpty && descController.text.isNotEmpty) {
                try {
                  await FirebaseFirestore.instance.collection('posts').add({
                    'title': titleController.text,
                    'desc': descController.text,
                  });
                  // send notification
                  await NotificationService().sendPersonalisedFCMMessage('Go check it out!', 'posts', 'New Post has just arrived!');
                  // Clear the text fields after adding data
                  titleController.clear();
                  descController.clear();

                  // Optionally, show a success message or perform other actions
                } catch (e) {
                  // Handle any errors that may occur during data addition
                  print('Error adding data to Firestore: $e');
                  // Optionally, show an error message or perform other error handling
                }
              } else {
                // Handle the case where either title or desc is empty
                print('Both title and desc must be provided');
                // Optionally, show a message to the user about the missing information
              }
            },
            icon: const Icon(Icons.send),
          ),

          // show post contaiment 
        StreamBuilder(
          stream: _postsStream,
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Loading");
            }

            if (snapshot.data!.docs.isEmpty) {
              return const Text("No data available");
            }

            print("Number of documents: ${snapshot.data!.docs.length}");

            return Column(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;

                if (data == null) {
                  return const SizedBox.shrink();
                }

                print("Document data: $data");

                String title = data['title'] ?? 'No title';
                String desc = data['desc'] ?? 'No description';
                print("Title: $title, Desc: $desc");

                return ListTile(
                  title: Text(title),
                  subtitle: Text(desc),
                );
              }).toList(),
            );
          },
        ),

        ],
      ),
    );
  }
}
