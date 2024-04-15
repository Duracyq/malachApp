import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:malachapp/components/MyText1.dart';

class NicknameFetcher {
  Stream<String> fetchNickname(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) => snapshot.data()?['nickname'] as String? ?? '');
  }

  Widget buildNickname(BuildContext context, String userId) {
    return StreamBuilder<String>(
      stream: fetchNickname(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.data == null) {
          return const Text('');
        } else {
          final nickname = snapshot.data ?? '';
          return MyText1(
            text: nickname,
            rozmiar: 26,
          );
        }
      },
    );
  }

  Future<String?> fetchUserIdByEmail(String email) async {
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('getUserIdByEmail');
    try {
      final result = await callable.call(<String, dynamic>{
        'email': email,
      });
      return result.data['userId'];
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }
}
