import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:malachapp/components/MyText.dart';
import 'package:malachapp/components/my_button.dart';
import 'package:malachapp/components/reloadable_widget.dart';
import 'package:malachapp/components/vote_button.dart';
import 'package:malachapp/pages/Poll/poll_list_design.dart';
import 'package:malachapp/themes/dark_mode.dart';
import 'package:malachapp/themes/theme_provider.dart';
import 'package:provider/provider.dart';

class PollDesign1 extends StatefulWidget {
  final String pollListTitle;
  final int pollCount;
  final String pollListId;
  const PollDesign1({
    super.key,
    required this.pollListTitle,
    required this.pollCount,
    required this.pollListId,
  });

  @override
  _PollDesign1State createState() => _PollDesign1State();
}

class _PollDesign1State extends State<PollDesign1> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late List<int> selectedIndex;

  Stream<bool> _isVoted(String currentUserId, String pollListId, String pollId) {
    // Reference to the poll document
    DocumentReference pollRef = FirebaseFirestore.instance
        .collection('pollList')
        .doc(pollListId)
        .collection('polls')
        .doc(pollId); // Replace 'yourPollId' with the actual poll ID
    
    // Check if the user has voted
    return pollRef.snapshots().map((snapshot) {
      if (snapshot.exists) {
        // Get the votes array from the document data
        List<dynamic> votes = (snapshot.data() as Map<String, dynamic>)['votes'] ?? [];
        // Check if the current user's ID is in the votes array
        return votes.contains(currentUserId) ? true : false;
      } else {
        // Handle case when the document doesn't exist
        return false;
      }
    });
  }


  @override
  void initState() {
    super.initState();
    selectedIndex = [];
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
        selectedIndex = [];
      });
    });
  }
  void setSelectedIndex(List<int> indexList) {
    setState(() {
      selectedIndex = indexList;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  Future<void> _refresh() async {
    setState(() {
      FirebaseFirestore.instance.collection('pollList').doc(widget.pollListId).collection('polls').get();
    });    
  }



  final FirebaseFirestore _db = FirebaseFirestore.instance;
  @override 
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    List<int> _selectedIndexTemp = [];
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pollListTitle),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: MyText(
              text: "${_currentPage + 1}/${widget.pollCount}",
              rozmiar: 20,
              waga: FontWeight.bold,
            ),
          ),
        ],
      ),
      body: ReloadableWidget(
        onRefresh: _refresh,
        child: FutureBuilder(
          future: _db.collection('pollList').doc(widget.pollListId).collection('polls').get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final DocumentSnapshot firstDocument = snapshot.data!.docs.first;
              final String pollTitle = firstDocument['pollTitle'];
              return SizedBox(
                height: screenHeight,
                width: screenWidth,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: MyText(
                        text: "${_currentPage + 1}.$pollTitle",
                        rozmiar: 26,
                        waga: FontWeight.bold,
                      ),
                    ),
                    Flexible(
                      fit: FlexFit.loose,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: widget.pollCount,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: snapshot.data!.docs.map<Widget>((doc) {
                                        final List<dynamic> options = doc['options'];
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: options.map<Widget>((option) {
                                            return AnswerBox(
                                              press: () {
                                                if(selectedIndex.contains(options.indexOf(option))) {
                                                  _selectedIndexTemp.remove(options.indexOf(option));
                                                }
                                                else {
                                                  _selectedIndexTemp.add(options.indexOf(option));
                                                }
                                              },
                                              text: option['text'],
                                              index: options.indexOf(option) + 1,
                                              pollId: doc.id,
                                              pollListId: widget.pollListId,
                                            );
                                          }).toList(),
                                        );
                                      }).toList(),
                                    ),
                                ),
                              ),
                              if (index == widget.pollCount-1)
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: MyButton(
                                    text: "Wyślij",
                                    onTap: () {
                                      setSelectedIndex(_selectedIndexTemp);
                                      final doc = snapshot.data!.docs.first;
                                      final List<dynamic> options = doc['options'];
                                      for (var v = 0; v < selectedIndex.length; ++v) {
                                        VoteButton(pollId: doc.id, pollListId: widget.pollListId).handleVote(
                                          pollId: doc.id,
                                          optionIndex: selectedIndex[v],
                                          optionText: options[selectedIndex[v]]['text'],
                                          pollListId: widget.pollListId,
                                        );
                                      }
                                      // Clear the selected index list
                                      selectedIndex = [];
                                      _selectedIndexTemp = [];
                                      // Go back to the previous page
                                      Navigator.pop(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const PollDesign(),
                                        ),
                                      );
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
      ),
    );
  }
}
class AnswerBox extends StatefulWidget {
  final VoidCallback press;
  final String text;
  final int index;
  final String pollListId;
  final String pollId;

  const AnswerBox({
    super.key,
    required this.press, 
    required this.text, 
    required this.index,
    required this.pollId,
    required this.pollListId,
  });

  @override
  _AnswerBoxState createState() => _AnswerBoxState();
}

class _AnswerBoxState extends State<AnswerBox> {
  bool selected = false;

  @override
  void initState() {
    super.initState();
    checkIfVoted();
  }

// TODO: implement this to code so user is informed if they have already voted
  void checkIfVoted() async {
    bool result = await isVoted(
      FirebaseAuth.instance.currentUser!.uid,
      widget.pollListId,
      widget.pollId,
    );
    if (mounted) {
      setState(() {
        selected = result;
      });
    }
  }

  Future<bool> isVoted(String currentUserId, String pollListId, String pollId) async {
    // Reference to the poll document
    DocumentReference pollRef = FirebaseFirestore.instance
        .collection('pollList')
        .doc(pollListId)
        .collection('polls')
        .doc(pollId);

    // Fetch the document and check if the user has voted
    var snapshot = await pollRef.get();
    if (snapshot.exists) {
      List<dynamic> votes = (snapshot.data() as Map<String, dynamic>)['votes'] ?? [];
      return votes.contains(currentUserId);
    }
    return false;
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.press();
        setState(() {
          selected = !selected;
        });
      },
      child: Stack(
        children: [
          Container(
            height: 50,
            margin: EdgeInsets.only(top: 10),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(
                color: selected
                    ? (Provider.of<ThemeProvider>(context).themeData == darkMode
                        ? Colors.white ?? Colors.grey
                        : Colors.black)
                    : Colors.transparent,
                width: selected ? 3.0 : 1.0,
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.text,
                    style: TextStyle(
                      color: Provider.of<ThemeProvider>(context).themeData == darkMode
                          ? Colors.white ?? Colors.grey
                          : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  height: 28,
                  width: 26,
                  decoration: BoxDecoration(
                    color: selected
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

