// import 'package:flutter/material.dart';
// import 'package:malachapp/components/MyText.dart';

// class PollDesign1 extends StatelessWidget {
//   const PollDesign1({Key? key}) : super(key: key);

//   @override
//   _PollDesign1State createState() => _PollDesign1State();
// }

// class _PollDesign1State extends State<PollDesign1> {
//   final PageController _pageController = PageController();
//   int _currentPage = 0;

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('My App Bar'),
//       ),
//       body: Container(
//         height: screenHeight,
//         width: screenWidth,
//         child: Column(
//           children: [
//             Padding(
//                 padding: EdgeInsets.all(10.0),
//                 child: MyText(
//                   text: "Pytanie ${index + 1}/${3}",
//                   rozmiar: 20,
//                   waga: FontWeight.bold,
//                 )),
//             Expanded(
//               child: PageView.builder(
//                 itemCount: 3,
//                 itemBuilder: (context, index) {
//                   return Card(
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Pytanie ${index + 1}',
//                             style: Theme.of(context).textTheme.headline5,
//                           ),
//                           SizedBox(height: 16.0),
//                           Text('Odpowiedź 1'),
//                           Text('Odpowiedź 2'),
//                           Text('Odpowiedź 3'),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:malachapp/components/MyText.dart';

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
        title: const Text('My App Bar'),
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
                          const Text('Odpowiedź 1'),
                          const Text('Odpowiedź 2'),
                          const Text('Odpowiedź 3'),
                          AnswerBox(press: () {}, text: "ss", index: 1)
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

class _AnswerBoxState extends State<AnswerBox> {
  bool selected =
      false; // Zmienna do przechowywania informacji, czy odpowiedź została zaznaczona
  double borderWidth = 1.0; // Zmienna do przechowywania grubości obramowania

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.press();
        setState(() {
          selected = true;
          borderWidth =
              3.0; // Zmień grubość obramowania na 3.0, gdy odpowiedź zostanie zaznaczona
        });
      },
      child: Container(
        margin: EdgeInsets.only(top: 10),
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
          border: Border.all(
              color: Colors.black,
              width:
                  borderWidth), // Użyj zmiennej borderWidth jako grubości obramowania
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${widget.index + 1}. ${widget.text}",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            Container(
              height: 26,
              width: 26,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.black),
              ),
              child: null,
            )
          ],
        ),
      ),
    );
  }
}
