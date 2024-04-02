import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:malachapp/components/my_button.dart';
import 'package:malachapp/components/text_field.dart';
import 'package:malachapp/services/photo_from_gallery_picker.dart';

class PostCreator extends StatefulWidget {
    @override
    _PostCreatorState createState() => _PostCreatorState();
}

class _PostCreatorState extends State<PostCreator> {
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _descriptionController = TextEditingController();
    File? _mainImage;
    final List<File?> _sideImage = [];
    int _howManyImages = 1;

    @override
    void initState() {
      super.initState();
      setState(() {
        _howManyImages = 1;
      });;
    }

    void setHowManyImages(int value) {
      setState(() {
        _howManyImages = value;
      });
    }

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



      for (var image in _sideImage) {
        if (image != null) {
          // Generate a unique file name for the upload
          String fileName = DateTime.now().millisecondsSinceEpoch.toString();

          // Upload the image to Firebase Storage
          Reference ref = FirebaseStorage.instance.ref().child('posts/${postRef.id}/$fileName');
          UploadTask uploadTask = ref.putFile(image);

          // Wait for the upload to complete
          await uploadTask.whenComplete(() {});

          // Get the download URL and add it to the list
          String downloadUrl = await ref.getDownloadURL();
          sideImageUrls.add(downloadUrl);
        }
      }
      await postRef.update({
        'sideImages': sideImageUrls, // Store the list of image URLs in Firestore
      });

      FirebaseStorage.instance.ref().child('posts/${postRef.id}/mainImage/').putFile(_mainImage!, SettableMetadata(contentType: 'image/jpeg')).then((value) async {
        String downloadUrl = await value.ref.getDownloadURL();
        postRef.update({'mainImageUrl': downloadUrl});
      });

    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text('Post Creator'),
            ),
            body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                    children: [
                        MyTextField(hintText: 'Tytuł', controller: _titleController),
                        const SizedBox(height: 16),
                        MyTextField(hintText: 'Opis', controller: _descriptionController),
                        const SizedBox(height: 16),
                        ListTile(
                            title: Text(_mainImage?.path ?? 'Załącz zdjęcie'),
                            trailing: const Icon(Icons.camera_alt),
                            onTap: () {
                              pickAndShrinkPhoto().then((value) {
                                setState(() {
                                  _mainImage = value;
                                });
                              });
                            },
                        ),
                        ListView.builder(
                            shrinkWrap: true,
                            itemCount: _howManyImages,
                            itemBuilder: (context, index) {
                                return ListTile(
                                    title: Text('Załącz zdjęcie poboczne $index'),
                                    trailing: Row(
                                      children: [
                                        const Icon(Icons.camera_alt),
                                        const SizedBox(width: 16),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () {
                                            setState(() {
                                              if (_howManyImages > 0) _howManyImages--;
                                              _sideImage.removeAt(index);
                                            });
                                            debugPrint('Removed image at index $index');
                                          },
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      pickAndShrinkPhoto().then((value) {
                                        setState(() {
                                          _sideImage.add(value);
                                        });
                                      });
                                    },
                                );
                            },
                        ),
                        MyButton(text: 'Dodaj zdjęcie poboczne', onTap: () => setHowManyImages(_howManyImages++)),

                        const SizedBox(height: 16),                        
                        MyButton(text: 'Wyślij', onTap: () {
                            debugPrint(_titleController.text);
                            _sendPost();
                        }),
                    ],
                ),
            ),
        );
    }
}