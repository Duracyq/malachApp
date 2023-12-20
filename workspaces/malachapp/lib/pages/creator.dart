import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:malachapp/components/my_button.dart';
import 'package:malachapp/components/text.dart';
import 'package:malachapp/components/text_field.dart';

class CreatorPage extends StatefulWidget {
  const CreatorPage({super.key});

  @override
  State<CreatorPage> createState() => _CreatorPageState();
}

class _CreatorPageState extends State<CreatorPage> {
  final Stream<QuerySnapshot> _postsStream = FirebaseFirestore.instance
      .collection('posts')
      .snapshots(includeMetadataChanges: true);

  late TextEditingController titleController = TextEditingController();
  late TextEditingController descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    alignment: Alignment.topLeft,
                  ),
                ),
              ],
            ),
          ),
          MyText(text: "Kreator posta", fontSize: 30),
          SizedBox(
            height: 100,
          ),
          //controllers
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 2),
            child: MyTextField(hintText: "Title", controller: titleController),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 2),
            child: MyTextField(hintText: "Desc", controller: descController),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 65,
              child: MyButton(
                myText: MyText(text: "Utwórz", fontSize: 16),
                onTap: () async {
                  // Check if both title and desc are not empty
                  if (titleController.text.isNotEmpty &&
                      descController.text.isNotEmpty) {
                    try {
                      await FirebaseFirestore.instance.collection('posts').add({
                        'title': titleController.text,
                        'desc': descController.text,
                      });

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
              ),
            ),
          ),
          //! poniżej jest poprzedni przycisk(jakby nie działał ci aktualny(powyższy) to użyj tego poniżej)
          /*
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                      // Tutaj możesz dostosować kolor w zależności od różnych stanów
                      if (states.contains(MaterialState.pressed)) {
                        return Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.5); // Przykład: kolor po wciśnięciu
                      }
                      // Zwróć domyślny kolor
                      return Theme.of(context).colorScheme.secondary;
                    },
                  ),
                ),
                onPressed: () async {
                  // Check if both title and desc are not empty
                  if (titleController.text.isNotEmpty &&
                      descController.text.isNotEmpty) {
                    try {
                      await FirebaseFirestore.instance.collection('posts').add({
                        'title': titleController.text,
                        'desc': descController.text,
                      });

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
                child: MyText(
                  text: "Utwórz",
                  fontSize: 18,
                )),
          )
          // SEND BUTTON
          */

          // show post contaiment
          StreamBuilder(
            stream: _postsStream,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                  Map<String, dynamic>? data =
                      document.data() as Map<String, dynamic>?;

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
