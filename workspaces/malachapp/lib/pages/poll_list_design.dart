import 'package:flutter/material.dart';
import 'package:malachapp/components/MyText.dart';
import 'package:malachapp/pages/test_chwilowy.dart';

import 'Poll.dart';

class PollDesign extends StatelessWidget {
  const PollDesign({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          title: Text('Poll Design'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: screenWidth,
              padding: const EdgeInsets.all(0),
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PollDesign1(),
                      ),
                    );
                  },
                  child: Stack(
                    children: [
                      Container(
                        // Dodany kontener zawierający pytanie i odpowiedzi
                        padding: EdgeInsets.all(10),
                        height: screenHeight * 0.1,
                        width: screenWidth * 0.9,
                        margin: EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                          color:
                              Colors.grey[200], // Zmieniono kolor na jasnoszary
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            // Dodano cień
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Center(
                          child: MyText(
                            text: "ddfffffty", //!nazwa calej ankiety
                            rozmiar: 22,
                            waga: FontWeight.w700,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 5,
                        top: 12,
                        child: Container(
                          width: 20,
                          height: 20,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onSecondary,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '9', //! liczba osob w czacie
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: screenWidth,
              padding: const EdgeInsets.all(0),
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SurveyScreen()),
                    );
                  },
                  child: Stack(
                    children: [
                      Container(
                        // Dodany kontener zawierający pytanie i odpowiedzi
                        padding: EdgeInsets.all(10),
                        height: screenHeight * 0.1,
                        width: screenWidth * 0.9,
                        margin: EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                          color:
                              Colors.grey[200], // Zmieniono kolor na jasnoszary
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            // Dodano cień
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Center(
                          child: MyText(
                            text: "ddfffffty", //!nazwa calej ankiety
                            rozmiar: 22,
                            waga: FontWeight.w700,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 5,
                        top: 12,
                        child: Container(
                          width: 20,
                          height: 20,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onSecondary,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '9', //! liczba osob w czacie
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: screenWidth,
              padding: const EdgeInsets.all(0),
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PollDesign(),
                      ),
                    );
                  },
                  child: Stack(
                    children: [
                      Container(
                        // Dodany kontener zawierający pytanie i odpowiedzi
                        padding: EdgeInsets.all(10),
                        height: screenHeight * 0.1,
                        width: screenWidth * 0.9,
                        margin: EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                          color:
                              Colors.grey[200], // Zmieniono kolor na jasnoszary
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            // Dodano cień
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Center(
                          child: MyText(
                            text: "ddfffffty", //!nazwa calej ankiety
                            rozmiar: 22,
                            waga: FontWeight.w700,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 5,
                        top: 12,
                        child: Container(
                          width: 20,
                          height: 20,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onSecondary,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '9', //! liczba osob w czacie
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
