import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VoteButton extends StatefulWidget {
  final String pollId;
  final int optionIndex; // Change the type to int
  final String optionText;
  final List<dynamic> voters;

  const VoteButton({
    Key? key,
    required this.pollId,
    required this.optionIndex,
    required this.optionText,
    required this.voters,
  }) : super(key: key);

  @override
  _VoteButtonState createState() => _VoteButtonState();
}

class _VoteButtonState extends State<VoteButton> {
  /// Checks if the current user has voted for this option.
  bool get userVoted {
    final user = FirebaseAuth.instance.currentUser;
    return user != null &&
        widget.voters != null &&
        widget.voters!.any((voter) => voter['id'] == user.uid);
  }

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
                widget.optionText,
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