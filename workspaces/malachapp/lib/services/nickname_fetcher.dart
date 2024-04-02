import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:malachapp/components/MyText1.dart';

class NicknameFetcher {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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
          return Text('');
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
}
