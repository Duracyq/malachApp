import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:malachapp/components/my_button.dart';
import 'package:malachapp/components/text_field.dart';
import 'package:malachapp/services/notification_service.dart';
import 'package:malachapp/services/photo_from_gallery_picker.dart';

class PostCreator extends StatefulWidget {
  const PostCreator({Key? key}) : super(key: key);

  @override
  _PostCreatorState createState() => _PostCreatorState();
}

class _PostCreatorState extends State<PostCreator> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _mainImage;
  final List<File?> _sideImages = [];
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> _sendPost() async {
    List<String> sideImageUrls = [];
    DocumentReference postRef = await _db.collection('posts').add({
      'title': _titleController.text,
      'description': _descriptionController.text,
      'createdAt': DateTime.now(),
      'mainImageUrl': '',
      'sideImageUrls': [],
    });

    int index = 0; // Initialize a counter for side images
    for (var image in _sideImages) {
      if (image != null) {
        // Extract filename and extension more robustly
        String originalName = Uri.file(image.path).pathSegments.last; // Using Uri to handle file paths
        String fileExtension = originalName.contains('.') ? originalName.split('.').last : 'jpg'; // Default to jpg if no extension found
        String baseFileName = originalName.contains('.') ? originalName.substring(0, originalName.lastIndexOf('.')) : originalName;
        String sanitizedFileName = baseFileName.replaceAll(RegExp('[^A-Za-z0-9]'), '_'); // Sanitize file name

        String fileName = '${sanitizedFileName}_${index}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension'; // Construct the new filename

        Reference ref = FirebaseStorage.instance.ref('posts/${postRef.id}/$fileName');
        TaskSnapshot uploadTaskSnapshot = await ref.putFile(image);
        String downloadUrl = await uploadTaskSnapshot.ref.getDownloadURL();
        sideImageUrls.add(downloadUrl);
        index++; // Increment the index for each side image
      }
    }
    await postRef.update({'sideImageUrls': sideImageUrls});

    if (_mainImage != null) {
      String mainFileName = 'mainImage_${DateTime.now().millisecondsSinceEpoch}.jpg'; // Similar naming convention for main image
      Reference mainImageRef = FirebaseStorage.instance.ref('posts/${postRef.id}/$mainFileName');
      TaskSnapshot mainImageUploadTask = await mainImageRef.putFile(_mainImage!, SettableMetadata(contentType: 'image/jpeg'));
      String mainImageUrl = await mainImageUploadTask.ref.getDownloadURL();
      await postRef.update({'mainImageUrl': mainImageUrl});
    }
    NotificationService().sendPersonalisedFCMMessage('Sprawdź teraz!', 'posts', 'Nowy post! 🎉');
    Navigator.of(context).pop();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kreator Postów'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            MyTextField(hintText: 'Tytuł', controller: _titleController),
            const SizedBox(height: 16),
            MyTextField(hintText: 'Opis', controller: _descriptionController),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                title: Text(_mainImage?.path ?? 'Dołącz główne zdjęcie'),
                trailing: const Icon(Icons.camera_alt),
                onTap: () async {
                  File? image = await pickAndShrinkPhoto();
                  setState(() {
                    _mainImage = image;
                  });
                },
              ),
            ),
            const SizedBox(height: 10,),
            const Divider(),  
            const SizedBox(height: 10,),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _sideImages.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(_sideImages[index]?.path ?? 'Dodatkowe zdjęcie ${index + 1}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _sideImages.removeAt(index);
                        });
                      },
                    ),
                    onTap: () async {
                      File? image = await pickAndShrinkPhoto();
                      if (image != null) {
                        setState(() {
                          _sideImages[index] = image;
                        });
                      }
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 10,),
            MyButton(
              text: 'Dodaj dodatkowe zdjęcie',
              onTap: () {
                setState(() {
                  _sideImages.add(null); // Add a placeholder to be replaced
                });
              },
            ),
            const SizedBox(height: 16),
            MyButton(text: 'Wyślij Post', onTap: _sendPost),
          ],
        ),
      ),
    );
  }
}
