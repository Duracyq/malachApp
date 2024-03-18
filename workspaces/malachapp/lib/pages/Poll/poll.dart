import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:malachapp/components/MyText.dart';
import 'package:malachapp/components/my_button.dart';
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
  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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
              text: "${_currentPage + 1}/${widget.pollCount}",
              rozmiar: 20,
              waga: FontWeight.bold,
            ),
          ),
        ],
      ),
      body: FutureBuilder(
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
                                child: Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: snapshot.data!.docs.map<Widget>((doc) {
                                      final List<dynamic> options = doc['options'];
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: options.map<Widget>((option) {
                                          return AnswerBox(
                                            press: () {},
                                            text: option['text'],
                                            index: options.indexOf(option) + 1,
                                          );
                                        }).toList(),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                            if (index == widget.pollCount-1)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: MyButton(
                                  text: "Wyślij",
                                  onTap: () {
                                    final doc = snapshot.data!.docs.first;
                                    final List<dynamic> options = doc['options'];
                                    final int selectedIndex = _currentPage * options.length + index;
                                    VoteButton(pollId: doc.id, pollListId: widget.pollListId).handleVote(
                                      pollId: doc.id,
                                      optionIndex: selectedIndex,
                                      // voters: [],
                                      optionText: options[selectedIndex]['text'],
                                      pollListId: widget.pollListId,
                                      // pollTitle: doc['pollTitle'],
                                    );
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
    );
  }
}

class _AnswerBoxState extends State<AnswerBox> {
  bool selected = false;

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
                  color:
                      Provider.of<ThemeProvider>(context).themeData == darkMode
                          ? Colors.white ?? Colors.grey
                          : Colors.black,
                  width: selected ? 3.0 : 1.0),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(
                  color:
                      Provider.of<ThemeProvider>(context).themeData == darkMode
                          ? Colors.white ?? Colors.grey
                          : Colors.black,
                  width: 1.0),
              borderRadius: BorderRadius.circular(15),
            ),
            //! srodek
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //! text
                Expanded(
                  child: Text(
                    widget.text,
                    style: TextStyle(
                        color: Provider.of<ThemeProvider>(context).themeData ==
                                darkMode
                            ? Colors.white ?? Colors.grey
                            : Colors.black,
                        fontSize: 16),
                  ),
                ),
                //! kolko
                Container(
                  height: 28,
                  width: 26,
                  decoration: BoxDecoration(
                    color: selected
                        ? (Provider.of<ThemeProvider>(context).themeData ==
                                darkMode
                            ? Colors.white
                            : Colors.black)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: Provider.of<ThemeProvider>(context).themeData ==
                              darkMode
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AnswerBox extends StatefulWidget {
  final Function press;
  final String text;
  final int index;

  const AnswerBox(
      {Key? key, required this.press, required this.text, required this.index})
      : super(key: key);

  @override
  _AnswerBoxState createState() => _AnswerBoxState();
}
