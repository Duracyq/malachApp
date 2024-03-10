import "package:flutter/material.dart";

ThemeData darkMode = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      inversePrimary: Colors.grey.shade300,
      primary: Colors.grey.shade800,
      secondary: Colors.grey.shade700,
      background: Colors.grey.shade900,
      onPrimary: Colors.white,
      onSecondary: Colors.grey.shade700,
      onSurface: Colors.white,
      onBackground: Colors.white,
      onSecondaryContainer: Colors.white,
    ),
    textTheme: ThemeData.dark()
        .textTheme
        .apply(bodyColor: Colors.grey[300], displayColor: Colors.white));
