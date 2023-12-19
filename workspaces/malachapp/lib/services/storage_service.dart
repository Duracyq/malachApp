import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class Storage {
  firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;

  Future<List<String>> getImageUrls(var uri) async {
    firebase_storage.ListResult result = await storage.ref(uri).listAll();
    List<String> urls = [];

    await Future.forEach(result.items, (firebase_storage.Reference ref) async {
      String downloadUrl = await ref.getDownloadURL();
      urls.add(downloadUrl);
    });

    return urls;
  }
}