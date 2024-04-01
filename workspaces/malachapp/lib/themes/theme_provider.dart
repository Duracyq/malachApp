// import 'package:flutter/material.dart';
// import 'package:malachapp/themes/dark_mode.dart';
// import 'package:malachapp/themes/light_mode.dart';

// class ThemeProvider with ChangeNotifier {
//   ThemeData _themeData = lightMode;

//   ThemeData get themeData => _themeData;

//   set themeData(ThemeData themeData) {
//     _themeData = themeData;
//     notifyListeners();
//   }

//   void toggleTheme() {
//     if (_themeData == lightMode) {
//       themeData = darkMode;
//     } else {
//       themeData = lightMode;
//     }
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ThemeProvider extends ChangeNotifier {
//   String currentTheme = 'system';

//   ThemeMode get themeMode {
//     if (currentTheme == 'light') {
//       return ThemeMode.light;
//     } else if (currentTheme == 'dark') {
//       return ThemeMode.dark;
//     } else {
//       return ThemeMode.system;
//     }
//   }

//   changeTheme(String theme) async {
//     final SharedPreferences _prefs = await SharedPreferences.getInstance();

//     await _prefs.setString('theme', theme);

//     currentTheme = theme;
//     notifyListeners();
//   }

//   initialize() async {
//     final SharedPreferences _prefs = await SharedPreferences.getInstance();

//     currentTheme = _prefs.getString('theme') ?? 'system';
//     notifyListeners();
//   }
// }
import 'package:flutter/material.dart';
import 'package:malachapp/themes/light_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:malachapp/themes/dark_mode.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData currentThemeData = lightMode;
  String currentThemeKey = 'light';

  ThemeMode get themeMode {
    if (currentThemeKey == 'light') {
      return ThemeMode.light;
    } else if (currentThemeKey == 'dark') {
      return ThemeMode.dark;
    } else {
      return ThemeMode.system;
    }
  }

  ThemeData get themeData {
    return currentThemeData;
  }

  changeTheme(String themeKey, ThemeData themeData) async {
    final SharedPreferences _prefs = await SharedPreferences.getInstance();

    await _prefs.setString('theme', themeKey);

    currentThemeKey = themeKey;
    currentThemeData = themeData;
    notifyListeners();
  }

  toggleTheme() async {
    final SharedPreferences _prefs = await SharedPreferences.getInstance();
    if (currentThemeKey == 'light') {
      changeTheme('dark', darkMode);
      await _prefs.setString('theme', 'dark');
    } else {
      changeTheme('light', lightMode);
      await _prefs.setString('theme', 'light');
    }
  }

  initialize() async {
    final SharedPreferences _prefs = await SharedPreferences.getInstance();

    currentThemeKey = _prefs.getString('theme') ?? 'system';

    if (currentThemeKey == 'light') {
      currentThemeData = lightMode;
    } else if (currentThemeKey == 'dark') {
      currentThemeData = darkMode;
    } else {
      // Ustaw domyślny motyw systemowy
      currentThemeData = ThemeData.fallback();
    }

    notifyListeners();
  }
}
