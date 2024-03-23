import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:malachapp/components/MyText.dart';
import 'package:malachapp/pages/add_group_page.dart';
import 'package:malachapp/services/nickname_fetcher.dart';

class HomeHomeWidget extends StatefulWidget {
  const HomeHomeWidget({Key? key}) : super(key: key);

  @override
  State<HomeHomeWidget> createState() => _HomeHomeWidgetState();
}

class _HomeHomeWidgetState extends State<HomeHomeWidget> {
  // Posty
  List<String> items = ["", "Wydarzenia", "Posty", "Cos"];
  // List<IconData> icons = [
  //   Icons.home,
  //   Icons.explore,
  // ];
  int current = 0;
  PageController pageController = PageController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      width: screenWidth,
      height: double.infinity,
      child: Column(children: [
        //! WITAJ AMELKA

        //* https://www.youtube.com/watch?v=mEPm9w5QlJM 4:13:18
        //! Posty
        SizedBox(
          width: screenWidth,
          height: screenHeight - 134,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            scrollDirection: Axis.vertical,
            // Ustawienie odstępu między elementami na 10 pikseli

            itemBuilder: (context, index) {
              List<String> tytul = [
                'Rada nauczycielska',
                'Dni otwarte',
                'Studniówka 2024'
              ];
              List<String> imagePaths = [
                'assets/zd1.jpg', // Ścieżka do pierwszego obrazka
                'assets/zd2.jpg', // Ścieżka do drugiego obrazka
                'assets/zd3.jpg', // Ścieżka do trzeciego obrazka
              ]; // Ścieżka do trzeciego obrazka
              List<String> opis = [
                'Już 19 lutego odbędzie sie Rada Nauczycieli więc uczniowie kończą zajęcia o 13.30',
                'Chodzą pogłoski że dni otwarte w Małachiwance będą 22 czerwca',
                "Zobacz już teraz zdjęcia ze studniówki"
              ];
              double itemHeight = index == 0 ? 100 : 300;

              if (index == 0) {
                // Jeśli jest to pierwszy element, zwracamy kontener "Witaj, admin"
                return Container(
                  height: itemHeight,
                  width: screenWidth * 0.2,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSecondary,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(
                          10), // Ustawienie promienia zaokrąglenia tylko dla lewego dolnego rogu
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  // padding: const EdgeInsets.all(3),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      width: screenWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const MyText(
                              text: "Dołącz do naszej szkolnej społeczności!",
                              rozmiar: 16,
                              waga: FontWeight.w400),
                          Row(
                            children: [
                              const MyText(
                                  text: "Witaj ",
                                  rozmiar: 26,
                                  waga: FontWeight.w700),
                              // Text(
                              //   nickname ?? '',
                              //   style: GoogleFonts.nunito(
                              //     textStyle: const TextStyle(
                              //         fontFamily: 'Nunito',
                              //         fontStyle: FontStyle.normal,
                              //         fontSize: 26,
                              //         fontWeight: FontWeight.w700),
                              //   ),
                              // ),
                              NicknameFetcher().buildNickname(context, userId),
                              Text(
                                "!",
                                style: GoogleFonts.nunito(
                                  textStyle: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontStyle: FontStyle.normal,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    height: itemHeight,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(imagePaths[index - 1]),
                          fit: BoxFit.cover),

                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(
                          20), // Ustawienie promienia zaokrąglenia na 10
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5), // Kolor cienia
                          spreadRadius: 2, // Rozprzestrzenianie cienia
                          blurRadius: 5, // Rozmycie cienia
                          offset: const Offset(
                              0, 3), // Przesunięcie cienia w osi x i y
                        ),
                      ],
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        stops: [0.3, 0.9],
                        colors: [
                          Colors.black.withOpacity(.9),
                          Colors.black.withOpacity(.7)
                        ],
                      ),
                    ),
                    width: screenWidth,
                    child: Stack(
                      children: [
                        // Obrazek
                        // Positioned.fill(
                        //   child: Image.asset(
                        //     imagePaths[
                        //         index], // Wybieramy odpowiedni obrazek na podstawie indeksu
                        //     fit: BoxFit.cover,
                        //   ),
                        // ),
                        // // Tekst na dole
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Opacity(
                            opacity: 0.7,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(20),
                                      bottomRight: Radius.circular(20))),
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                tytul[index -
                                    1], // Dodajemy indeks + 1, ponieważ indeksowanie zaczyna się od 0
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ]),
    );
  }
}
