import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as Path;

class Storage {
  final firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;

  Future<String> uploadPhoto(File file, String targetPath) async {
    try {
      // Create a reference to the location you want to upload to in Firebase Storage
      firebase_storage.Reference ref = storage.ref().child(targetPath + '/' + Path.basename(file.path));

      // Upload the file
      firebase_storage.UploadTask uploadTask = ref.putFile(file);

      // Wait for the upload to complete
      await uploadTask.whenComplete(() => {});

      // Get and return the URL of the uploaded file
      String downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      // Handle errors, for example, by returning an empty string or rethrowing
      print(e);
      return '';
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
