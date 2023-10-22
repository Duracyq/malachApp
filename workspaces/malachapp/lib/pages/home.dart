import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:malachapp/auth/auth_service.dart';
import 'package:malachapp/components/topbar.dart';
import 'package:malachapp/pages/home_home.dart';
import 'package:malachapp/themes/dark_mode.dart';
import 'package:malachapp/themes/light_mode.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService auth = AuthService();
  //! S T R O N Y
  int _currentIndex = 0;

  final tabs = [
    HomeHome(),
    Container(),
    Container(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      darkTheme: darkMode,
      home: Scaffold(
        appBar: CustomAppBar(),
        body: tabs[_currentIndex],
        bottomNavigationBar: CurvedNavigationBar(
          buttonBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
          animationDuration: const Duration(milliseconds: 200),
          color: const Color.fromRGBO(251, 133, 0, 1),
          backgroundColor: const Color.fromRGBO(255, 183, 3, 1),
          height: 49,
          items: const [
            Icon(Icons.list_outlined),
            Icon(Icons.list_outlined),
            Icon(Icons.list_outlined),
          ],
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
