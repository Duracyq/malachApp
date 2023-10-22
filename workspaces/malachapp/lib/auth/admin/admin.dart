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

late String loginName;
late String email;
const int shift = 934892347;


class AuthCreateUser {

  AuthCreateUser() {
    loginName = '0000';
  }
  String formatLoginName(int index) {
    return index.toString().padLeft(4, '0');
  }

  String passwDecryption(String text) {
    late String decText = '';
    String charAtIndex3 = text[3];

    if (charAtIndex3.isNotEmpty && RegExp(r'[0-9]').hasMatch(charAtIndex3)) {
      try {
        String decTextTemp = CaesarCiph().deCaesarCipher(text);
        decText =  RailCyph().railFenceEncrypt(decTextTemp, 7);
        print(decText);
      } catch (e) {
        print(e);
      }
      return decText;
    } else {
      return 'Invalid input at position 3';
    }
  }

  String createPasswForUsers(text) {
    late String createdPasw = '';
    late var tempShift = shift + text[3].codeUnitAt(0)*43751;
    try {
      createdPasw = CaesarCiph().caesarCipher(text, tempShift.toInt());
      createdPasw = RailCyph().railFenceEncrypt(createdPasw, 7);
    } catch(e) {
      print(e);
    }
    return createdPasw;
  } 

  final auth = FirebaseAuth.instance;
  Future<void> createUsers() async {
    for (int index = 1; index <= 10; index++) {
      loginName = formatLoginName(index);
      email = '$loginName@malach.com';
      
      try {
        final userCredentials = await auth.createUserWithEmailAndPassword(
          email: email,
          password: createPasswForUsers(email)
        );
        print('User created: $email');
      } on FirebaseAuthException catch (e) {
        print('Error creating user: $email - $e');
      }
    }
  }
}
class RailCyph {
  // przestawienny szyfr
  String railFenceEncrypt(String text, int rails) {
  List<String> railFence = List.generate(rails, (i) => '', growable: false);
  int currentRail = 0;
  bool directionDown = true;

  for (int i = 0; i < text.length; i++) {
    railFence[currentRail] += text[i];
    if (directionDown) {
      currentRail++;
      if (currentRail == rails - 1) {
        directionDown = false;
      }
    } else {
      currentRail--;
      if (currentRail == 0) {
        directionDown = true;
      }
    }
  }

  return railFence.join();
}

String railFenceDecrypt(String text, int rails) {
  List<List<String>> railFence = List.generate(rails, (i) => [], growable: false);
  List<int> railLengths = List.generate(rails, (i) => 0, growable: false);

  int currentRail = 0;
  bool directionDown = true;

  for (int i = 0; i < text.length; i++) {
    railFence[currentRail].add('');
    if (directionDown) {
      currentRail++;
      if (currentRail == rails - 1) {
        directionDown = false;
      }
    } else {
      currentRail--;
      if (currentRail == 0) {
        directionDown = true;
      }
    }
  }

  int currentIndex = 0;
  for (int i = 0; i < rails; i++) {
    for (int j = 0; j < railFence[i].length; j++) {
      railFence[i][j] = text[currentIndex];
      currentIndex++;
    }
  }

  // Reset currentRail and directionDown for decryption
  currentRail = 0;
  directionDown = true;
  
  currentIndex = 0;
  String decryptedText = '';

  for (int i = 0; i < text.length; i++) {
    decryptedText += railFence[currentRail][currentIndex];
    currentIndex++;

    if (directionDown) {
      currentRail++;
      if (currentRail == rails - 1) {
        directionDown = false;
      }
    } else {
      currentRail--;
      if (currentRail == 0) {
        directionDown = true;
      }
    }
  }

  return decryptedText;
}
// koniec przestawiennego
}

class CaesarCiph {
  //! najbezpieczniejsza wersja CESARA
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
    late String loginNameTemp = text[0] + text[1] + text[2] + text[3];
    late var tempShift = shift + loginNameTemp[3].codeUnitAt(0)*43751;
    print(shift);
    print(loginNameTemp);
    print(tempShift);
    // caesarCipher(text, shift);
    return caesarCipher(text, tempShift);
  }
  //koniec Cezara
}