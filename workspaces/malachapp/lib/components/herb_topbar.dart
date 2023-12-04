import 'package:flutter/material.dart';
import 'package:malachapp/themes/dark_mode.dart';
import 'package:malachapp/themes/light_mode.dart';

class Herb1 extends StatelessWidget {
  const Herb1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    ThemeData themeData = isDarkMode ? darkMode : lightMode;
    String herbFile = isDarkMode ? 'assets/herb2.png' : 'assets/herb1.png';

    return Image(
      image: AssetImage(herbFile),
      height: 100,
    );
  }
}
