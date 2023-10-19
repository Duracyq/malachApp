import 'package:firebase_admin/firebase_admin.dart' as admin;
import 'package:firebase_admin/testing.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:malachapp/auth/auth_service.dart';

// nie działa reset !!

class AdminAuthService {
  Future<void> sendPasswordResetEmail({required email, required login}) async {
    try {
      var app = admin.FirebaseAdmin.instance.initializeApp();
      var link = await app.auth().generatePasswordResetLink(login)
        .then((value) => FirebaseAuth.instance.sendPasswordResetEmail(email:email));
      // print(link);
    } catch (e) {
      print("Error initializing Firebase Admin or generating the link: $e");
    }
    
  }
}