import 'dart:ffi';
import 'package:getwidget/getwidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:malachapp/components/MyText1.dart';
import 'package:malachapp/components/MyText2.dart';
import 'package:malachapp/pages/add_group_page.dart';
import 'package:malachapp/services/nickname_fetcher.dart';
import 'package:malachapp/themes/theme_provider.dart';
import 'package:provider/provider.dart';

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
  // final FirebaseFirestore _db = FirebaseFirestore.instance;
  // final FirebaseAuth auth = FirebaseAuth.instance;
  // String userId = FirebaseAuth.instance.currentUser!.uid;
  List<String> tytul = ['Rada nauczycielska', 'Dni otwarte', 'Studniówka 2024'];
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Ustal kolory na podstawie motywu
    final color = themeProvider.currentThemeKey == 'light'
        ? Color.fromARGB(255, 133, 196, 255)
        : Colors.blueGrey;

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
              double itemHeight = index == 0 ? 120 : 300;

              if (index == 0) {
                // Jeśli jest to pierwszy element, zwracamy karuzelę
                return Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: GFCarousel(
                    items: [
                      // Tutaj dodaj swoje karty
                      Container(
                        width: screenWidth,
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          color: color,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: SizedBox(
                              width: screenWidth,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const MyText2(
                                    text:
                                        "Dołącz do naszej szkolnej społeczności!",
                                    rozmiar: 16,
                                  ),
                                  Row(
                                    children: [
                                      const MyText1(
                                        text: "Witaj ",
                                        rozmiar: 26,
                                      ),
                                      MyText1(
                                        text: "Szymon",
                                        rozmiar: 26,
                                      ),
                                      // NicknameFetcher()
                                      //     .buildNickname(context, userId),
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
                        ),
                      ),
                      Container(
                        width: screenWidth,
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          color: color,
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Center(
                              child: Text(
                                "... krew człowieka wykonuje pełny obieg w układzie krążenia w ciągu około minuty",
                                style: GoogleFonts.merriweather(
                                    fontSize: 16, fontWeight: FontWeight.w400),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Card(
                      //   child: Text('Karta 2'),
                      // ),
                      Container(
                        width: screenWidth,
                        child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            color: color,
                            child: Column(
                              children: [
                                Text(
                                  'Hello, world!',
                                  style: GoogleFonts.robotoCondensed(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'This is a description.',
                                  style: GoogleFonts.openSans(
                                    fontSize: 24,
                                  ),
                                ),
                              ],
                            )),
                      ),

                      Container(
                        width: screenWidth,
                        child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            color: color,
                            child: Column(
                              children: [
                                Text(
                                  'Hello, world!',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'This is a description.',
                                  style: GoogleFonts.lato(
                                    fontSize: 24,
                                  ),
                                ),
                              ],
                            )),
                      ),
                    ],
                    pauseAutoPlayOnTouch: Duration(seconds: 1),
                    height: itemHeight,
                    aspectRatio: 16 / 9,
                    viewportFraction: 0.9,
                    autoPlay: true,
                    autoPlayInterval: Duration(seconds: 8),
                    autoPlayAnimationDuration: Duration(seconds: 1),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enlargeMainPage: true,
                    hasPagination: true,
                    initialPage: 0,
                    enableInfiniteScroll: true,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (index) {
                      // Zrób coś, gdy strona się zmieni
                    },
                  ),
                );
              }
              if (index != 0) {
                //! kazdy inny element
                return GestureDetector(
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => AddPost(),
                    //   ),
                    // );
                  },
                  child: Card(
                    margin: EdgeInsets.only(top: 5, left: 8, right: 8),
                    borderOnForeground: true,
                    elevation: 1,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Ink.image(
                              image: NetworkImage(
                                  "https://fastly.picsum.photos/id/90/3000/1992.jpg?hmac=v_xO0GFiGn3zpcKzWIsZ3WoSoxJuAEXukrYJUdo2S6g"),
                              child: InkWell(
                                onTap: () {
                                  print('tapped');
                                },
                              ),
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                            Center(
                              child: Text(
                                "Co tam",
                                style: TextStyle(
                                    fontSize: 30,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 100,
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
