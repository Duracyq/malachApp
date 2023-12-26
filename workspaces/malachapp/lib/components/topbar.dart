import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:malachapp/components/herb.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  CustomAppBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return PreferredSize(
      preferredSize: Size.fromHeight(300),
      child: AppBar(
        title: Container(
          height: 50,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
            child: Container(
              // color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,

                // Ustawienie drugiego elementu na skraju
                children: <Widget>[
                  // Pierwszy element (na środku)
                  SizedBox(width: 60),
                  Container(
                    width: 200, // Dostosuj szerokość według potrzeb
                    height: 100, // Dostosuj wysokość według potrzeb

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Herb(),
                          height: 30,
                        ),
                        Text(
                          'M A L A C H  A P P',
                          style: GoogleFonts.openSans(
                            // Ustawienie czcionki Open Sans
                            textStyle: TextStyle(
                              fontStyle: FontStyle.normal,
                              fontSize: 20,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  // Drugi element (maksymalnie na prawo)
                  // IconButton(
                  //   onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  //   icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  //   alignment: Alignment.topLeft,
                  // )
                  //Image.asset('assets/herb1.png'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ustawienia'),
      ),
      body: Center(
        child: Text('Strona ustawień'),
      ),
    );
  }
}
