import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: PreferredSize(
          preferredSize:
              const Size.fromHeight(100.0), // Ustaw preferowaną wysokość
          child: Center(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF8B4646),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                ),
              ),
              width: 110.0, // Ustaw szerokość kontenera
              height: 170.0, // Ustaw wysokość kontenera
              // Ustaw kolor tła kontenera
              child: Center(
                  child: Image.asset(
                'assets/herb1.png',
                width: 100,
                height: 90,
                alignment: Alignment.bottomCenter,
              )),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TopBarFb2(
                  title: "Szymon Kajak",
                  upperTitle: "Dzień dobry",
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: Color.fromARGB(255, 209, 210, 214),
                          borderRadius: BorderRadius.circular(20)),
                      width: 110.0, // Ustaw szerokość kontenera
                      height: 50.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text(
                            'Napis',
                            style: GoogleFonts.roboto(
                              // Ustawienie czcionki Open Sans
                              textStyle: const TextStyle(
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(0, 0, 0, 0.612),
                                fontSize: 20,
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded,
                              size: 36.0) // Ikona
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TopBarFb2 extends StatelessWidget {
  final String title;
  final String upperTitle;
  const TopBarFb2({required this.title, required this.upperTitle, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.normal)),
        Text(upperTitle,
            style: const TextStyle(
                color: Colors.black, fontSize: 26, fontWeight: FontWeight.bold))
      ],
    );
  }
}
