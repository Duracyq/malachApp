import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VoteButton extends StatefulWidget {
  final String pollId;
  final String pollListId;
  final int? optionIndex; // Change the type to int
  final String? optionText;
  final List<dynamic>? voters;

  const VoteButton({
    super.key,
    required this.pollId,
    required this.pollListId,
    this.optionIndex,
    this.optionText,
    this.voters,
  });

  bool get userVoted {
    final user = FirebaseAuth.instance.currentUser;
    return user != null &&
        voters != null &&
        voters!.any((voter) => voter['id'] == user.uid);
  }

  Future<void> handleVote({
    required String pollId,
    required int optionIndex,
    required String optionText,
    required String pollListId,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final pollReference = FirebaseFirestore.instance.collection('pollList').doc(pollListId).collection('polls').doc(pollId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final docSnapshot = await transaction.get(pollReference);
      if (!docSnapshot.exists) {
        debugPrint('Document does not exist: $pollListId');
        return; // Document does not exist, handle accordingly
      }

      final data = docSnapshot.data();
      if (!data!.containsKey('options')) {
        debugPrint('Options field does not exist in the document');
        return; // Handle the case where the 'options' field is missing
      }

      final options = data['options'] as List<dynamic>;
      final updatedOptions = List<Map<String, dynamic>>.from(options);

      // Find the option by text
      int optionIndex = -1;
      for (int i = 0; i < updatedOptions.length; i++) {
        if (updatedOptions[i]['text'] == optionText) {
          optionIndex = i;
          break;
        }
      }

      if (optionIndex != -1) {
        // Check if the user has already voted
        final userVoted = updatedOptions[optionIndex]['voters']?.contains(user?.uid) ?? false;

        // If the user has not voted, add their vote; otherwise, remove it
        if (!userVoted) {
          updatedOptions[optionIndex]['voters'] = [
            ...updatedOptions[optionIndex]['voters'],
            user?.uid,
          ];
          debugPrint('Vote added');
        } else {
          updatedOptions[optionIndex]['voters'] = List<String>.from(
            updatedOptions[optionIndex]['voters'],
          )..remove(user?.uid);
          debugPrint('Vote removed');
        }

        transaction.update(pollReference, {'options': updatedOptions});
      } else {
        // Handle the case where the option is not found
        debugPrint('Option not found: $optionText');
      }
    });
  }

  

    
  @override
  _VoteButtonState createState() => _VoteButtonState();
}

class _VoteButtonState extends State<VoteButton> {
  bool get userVoted => false;

  /// Checks if the current user has voted for this option.

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      width: 160,
      padding: EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                if (!userVoted) {
                  // Update the document to include the user's vote
                  final user = FirebaseAuth.instance.currentUser;
                  final pollReference = FirebaseFirestore.instance
                      .collection('polls')
                      .doc(widget.pollId);

                  await FirebaseFirestore.instance
                      .runTransaction((transaction) async {
                    final docSnapshot = await transaction.get(pollReference);
                    if (!docSnapshot.exists) {
                      return; // Document does not exist, handle accordingly
                    }

                    final options = docSnapshot['options'] as List<dynamic>;
                    final updatedOptions =
                        List<Map<String, dynamic>>.from(options);

                    // Find the option by text
                    int optionIndex = -1;
                    for (int i = 0; i < updatedOptions.length; i++) {
                      if (updatedOptions[i]['text'] == widget.optionText) {
                        optionIndex = i;
                        break;
                      }
                    }

                    if (optionIndex != -1) {
                      updatedOptions[optionIndex]['voters'] = [
                        ...updatedOptions[optionIndex]['voters'],
                        {'id': user?.uid},
                      ];

                      transaction
                          .update(pollReference, {'options': updatedOptions});
                    } else {
                      // Handle the case where the option is not found
                      debugPrint('Option not found: ${widget.optionText}');
                    }
                  });
                } else {
                  // Remove the user's vote from the document
                  final user = FirebaseAuth.instance.currentUser;
                  final pollReference = FirebaseFirestore.instance
                      .collection('polls')
                      .doc(widget.pollId);

                  await FirebaseFirestore.instance
                      .runTransaction((transaction) async {
                    final docSnapshot = await transaction.get(pollReference);
                    if (!docSnapshot.exists) {
                      return; // Document does not exist, handle accordingly
                    }

                    final options = docSnapshot['options'] as List<dynamic>;
                    final updatedOptions =
                        List<Map<String, dynamic>>.from(options);

                    // Find the option by text
                    int optionIndex = -1;
                    for (int i = 0; i < updatedOptions.length; i++) {
                      if (updatedOptions[i]['text'] == widget.optionText) {
                        optionIndex = i;
                        break;
                      }
                    }

                    if (optionIndex != -1) {
                      updatedOptions[optionIndex]
                          ['voters'] = List<Map<String, dynamic>>.from(
                        updatedOptions[optionIndex]['voters'],
                      )..removeWhere((voter) => voter['id'] == user?.uid);

                      transaction
                          .update(pollReference, {'options': updatedOptions});
                    } else {
                      // Handle the case where the option is not found
                      debugPrint('Option not found: ${widget.optionText}');
                    }
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: userVoted ? Colors.green : null,
              ),
              child: Text(
                widget.optionText!,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color, // Set text color to black
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}