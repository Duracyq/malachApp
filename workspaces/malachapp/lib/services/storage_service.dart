import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' as f_storage;

class Storage {
  f_storage.FirebaseStorage storage = f_storage.FirebaseStorage.instance;

  Future<f_storage.ListResult> listFiles() async {
    f_storage.ListResult results = await storage.ref('test').listAll();

    results.items.forEach((f_storage.Reference ref) { print('Found File $ref'); });
    return results;

  }
}