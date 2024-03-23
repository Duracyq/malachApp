import "package:flutter/material.dart";

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    inversePrimary: Colors.grey.shade300,
    primary: Colors.grey.shade200,
    secondary: Colors.grey.shade400,
    background: Colors.grey.shade300,
    onPrimary: Colors.black,
    onSecondary: Colors.grey.shade400,
    onSurface: Colors.black,
    onBackground: Colors.black,
  ),
  textTheme: ThemeData.light()
      .textTheme
      .apply(bodyColor: Colors.grey[800], displayColor: Colors.black)
      .copyWith(
        labelLarge: TextStyle(color: Colors.black),
      ),
);


// Theme.of(context).colorScheme.onSecondary,

// Provider.of<ThemeProvider>(context).themeData == darkMode
//             ? Colors.red[400]
//             : Colors.red[700],

