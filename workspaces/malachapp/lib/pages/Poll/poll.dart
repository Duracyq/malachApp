import 'package:flutter/material.dart';
import 'package:malachapp/components/MyText.dart';
import 'package:malachapp/themes/dark_mode.dart';
import 'package:malachapp/themes/theme_provider.dart';
import 'package:provider/provider.dart';

class PollDesign1 extends StatefulWidget {
  const PollDesign1({Key? key}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nazwa Ankiety'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: MyText(
              text: "${_currentPage + 1}/3",
              rozmiar: 20,
              waga: FontWeight.bold,
            ),
          ),
        ],
      ),
      body: SizedBox(
        height: screenHeight,
        width: screenWidth,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: MyText(
                text: "${_currentPage + 1}.Treść pytania",
                rozmiar: 26,
                waga: FontWeight.bold,
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16.0),
                          AnswerBox(press: () {}, text: "Odp 1", index: 1),
                          AnswerBox(press: () {}, text: "Odp 2", index: 1),
                          AnswerBox(press: () {}, text: "Odp 3", index: 1),
                          AnswerBox(press: () {}, text: "Odp 4", index: 1),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
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
