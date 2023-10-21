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

class AuthCreateUser {
  late String loginName;
  late String email;
  final int shift = 934892347;

  AuthCreateUser() {
    loginName = '0000';
  }

  String formatLoginName(int index) {
    return index.toString().padLeft(4, '0');
  }

  //! najbezpieczniejsza wersja
  String caesarCipher(String text, int shift) {
    StringBuffer result = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      String char = text[i];
      if (char.contains(RegExp(r'[a-zA-Z0-9]'))) {
        bool isUpperCase = char == char.toUpperCase();
        char = char.toLowerCase();
        int charCode = char.codeUnitAt(0);
        charCode = (charCode - 'a'.codeUnitAt(0) + shift) % 26 + 'a'.codeUnitAt(0);
        char = String.fromCharCode(charCode);
        if (isUpperCase) {
          char = char.toUpperCase();
        }
      } else {
        int charCode = char.codeUnitAt(0);
        charCode = (charCode - '!'.codeUnitAt(0) + shift) % 33 + '!'.codeUnitAt(0);
        char = String.fromCharCode(charCode);
      }
      result.write(char);
    }
    return result.toString();
  }

  String deCaesarCipher(String text) {
    return caesarCipher(text, shift);
  }
  
  final auth = FirebaseAuth.instance;
  Future<void> createUsers() async {
    for (int index = 1; index <= 10; index++) {
      loginName = formatLoginName(index);
      email = '$loginName@malach.com';
      
      try {
        final userCredentials = await auth.createUserWithEmailAndPassword(
          email: email,
          password: caesarCipher(email, shift),
        );
        print('User created: $email');
      } on FirebaseAuthException catch (e) {
        print('Error creating user: $email - $e');
      }
    }
  }
}