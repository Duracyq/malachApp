import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

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
        } else if (snapshot.hasError) {
          return Text('Error fetching nickname');
        } else {
          final nickname = snapshot.data ?? '';
          return Text(
            nickname,
            style: GoogleFonts.nunito(
              textStyle: const TextStyle(
                fontFamily: 'Nunito',
                fontStyle: FontStyle.normal,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }
      },
    );
  }
}
