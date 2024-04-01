import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:malachapp/components/MyText.dart';
import 'package:malachapp/components/my_button.dart';
import 'package:malachapp/components/vote_button.dart';
import 'package:malachapp/pages/Poll/poll_list_design.dart';
import 'package:malachapp/themes/dark_mode.dart';
import 'package:malachapp/themes/theme_provider.dart';

class PollDesign1 extends StatefulWidget {
  final String pollListTitle;
  final int pollCount;
  final String pollListId;

  const PollDesign1({
    Key? key,
    required this.pollListTitle,
    required this.pollCount,
    required this.pollListId,
  }) : super(key: key);

  @override
  _PollDesign1State createState() => _PollDesign1State();
}

class _PollDesign1State extends State<PollDesign1> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<int> _selectedIndexTemp = [];

  Map<String, Set<int>> _selectedOptionsPerPoll = {};

  void _handleOptionTap(String pollId, int optionIndex) {
    setState(() {
      if (_selectedOptionsPerPoll[pollId] == null) {
        _selectedOptionsPerPoll[pollId] = {optionIndex};
      } else {
        if (_selectedOptionsPerPoll[pollId]!.contains(optionIndex)) {
          _selectedOptionsPerPoll[pollId]!.remove(optionIndex);
        } else {
          _selectedOptionsPerPoll[pollId]!.add(optionIndex);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pollListTitle),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: MyText(
              text: "Ilość pytań: ${widget.pollCount}",
              rozmiar: 20,
              waga: FontWeight.bold,
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
  stream: _db
      .collection('pollList')
      .doc(widget.pollListId)
      .collection('polls')
      .snapshots(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    } else if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    } else {
      return SizedBox(
        height: screenHeight,
        width: screenWidth,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: snapshot.data!.docs.length, // Count of polls/documents
                itemBuilder: (context, pollIndex) {
                  final DocumentSnapshot pollDoc = snapshot.data!.docs[pollIndex];
                  final String pollTitle = pollDoc['pollTitle'];
                  final List<dynamic> options = pollDoc['options'];
                  final String pollId = pollDoc.id;

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: MyText(
                          text: "${pollIndex + 1}.$pollTitle", // Updated to show poll number and title
                          rozmiar: 26,
                          waga: FontWeight.bold,
                        ),
                      ),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List<Widget>.generate(options.length, (optionIndex) {
                              bool isSelected = _selectedOptionsPerPoll[pollId]?.contains(optionIndex) ?? false;
                              return AnswerBox(
                                press: () {
                                  _handleOptionTap(pollId, optionIndex);
                                },
                                text: options[optionIndex]['text'],
                                index: optionIndex,
                                pollId: pollId,
                                pollListId: widget.pollListId,
                                isSelected: isSelected,
                              );
                            }),
                          ),
                        ),
                      ),
                          if (pollIndex == widget.pollCount - 1)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: MyButton(
                                text: "Wyślij",
                                onTap: () {
                                  _selectedOptionsPerPoll.forEach((pollId, selectedOptions) {
                                    // Fetch the correct DocumentSnapshot based on pollId
                                    final DocumentSnapshot correctPollDoc = snapshot.data!.docs.firstWhere(
                                      (doc) => doc.id == pollId,
                                      orElse: () => throw Exception('Poll not found'),
                                    );

                                    // Now, we can safely assume we have the correct options list
                                    final List<dynamic> currentOptions = correctPollDoc['options'];

                                    for (int optionIndex in selectedOptions) {
                                      final String optionText = currentOptions[optionIndex]['text'];

                                      VoteButton(pollId: pollId, pollListId: widget.pollListId)
                                        .handleVote(
                                          pollId: pollId,
                                          optionIndex: optionIndex,
                                          optionText: optionText,
                                          pollListId: widget.pollListId,
                                        );
                                    }
                                  });
                                  // Assuming you want to navigate away after voting on the last poll
                                  Navigator.of(context).pop();
                                },
                              ),
                            )
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}



class AnswerBox extends StatelessWidget {
  final Function press;
  final String text;
  final int index;
  final String pollId;
  final String pollListId;
  final bool isSelected;

  const AnswerBox({
    Key? key,
    required this.press,
    required this.text,
    required this.index,
    required this.pollId,
    required this.pollListId,
    required this.isSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        press();
      },
      child: Stack(
        children: [
          Container(
            height: 50,
            margin: EdgeInsets.only(top: 10),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(
                color: Provider.of<ThemeProvider>(context).themeData == darkMode
                    ? Colors.white ?? Colors.grey
                    : Colors.black,
                width: isSelected ? 3.0 : 1.0,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(
                color: Provider.of<ThemeProvider>(context).themeData == darkMode
                    ? Colors.white ?? Colors.grey
                    : Colors.black,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            //! srodek
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //! text
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: Provider.of<ThemeProvider>(context).themeData == darkMode
                          ? Colors.white ?? Colors.grey
                          : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
                //! kolko
                Container(
                  height: 28,
                  width: 26,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (Provider.of<ThemeProvider>(context).themeData == darkMode
                            ? Colors.white
                            : Colors.black)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: Provider.of<ThemeProvider>(context).themeData == darkMode
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}