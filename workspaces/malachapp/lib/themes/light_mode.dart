import "package:flutter/material.dart";

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
      inversePrimary: Colors.grey.shade300,
      primary: Colors.grey.shade200,
      secondary: Colors.grey.shade400,
      background: Colors.grey.shade300),
  textTheme: ThemeData.light()
      .textTheme
      .apply(bodyColor: Colors.grey[800], displayColor: Colors.black),
);
