import "package:flutter/material.dart";

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
      inversePrimary: Colors.grey.shade300,
      primary: Colors.grey.shade800,
      secondary: Colors.grey.shade700,
      background: Colors.grey.shade900),
  textTheme: ThemeData.dark()
      .textTheme
      .apply(bodyColor: Colors.grey[300], displayColor: Colors.white),
);
