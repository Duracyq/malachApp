import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<bool> setUser() async {
  try {
    final FirebaseAuth auth = FirebaseAuth.instance;
    
    // if (auth.currentUser == null) {
    //   print('User is not authenticated');
    //   return;
    // }

    final FirebaseFirestore db = FirebaseFirestore.instance;
    final userId = auth.currentUser!.uid;
    final currentUserRef = db.collection('users').doc(userId);

    final currentUserSnapshot = await currentUserRef.get();

    if (!currentUserSnapshot.exists) {
      await currentUserRef.set({
        'nickname': auth.currentUser!.email,
        'email': auth.currentUser!.email,
      });

      print('User document created');
      return true;
    } else {
      print('User document already exists');
      return false;
    }
  } catch (e) {
    print('Error in setUser: $e');
  }
  return false;
}