import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:logger/logger.dart';
import 'package:path/path.dart' as Path;

class Storage {
  final firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;

  final Logger logger = Logger();

  Future<String> uploadPhoto(File file, String targetPath) async {
    try {
      firebase_storage.Reference ref = storage.ref().child('$targetPath/${Path.basename(file.path)}');
      firebase_storage.UploadTask uploadTask = ref.putFile(file);
      await uploadTask;
      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } on firebase_storage.FirebaseException catch (e) {
      // Log the error or use a more user-friendly message depending on the error
      logger.d("Firebase Storage error: ${e.code} - ${e.message}");
      throw Exception('Failed to upload photo: ${e.code}');
    } catch (e) {
      logger.e(e.toString());
      throw Exception('An unexpected error occurred');
    }
  }


  Future<List<String>> getImageUrls(String uri) async {
    firebase_storage.ListResult result = await storage.ref(uri).listAll();
    List<String> urls = [];

    for (var ref in result.items) {
      String downloadUrl = await ref.getDownloadURL();
      urls.add(downloadUrl);
    }

    return urls;
  }
}
