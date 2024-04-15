import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyText1 extends StatelessWidget {
  final String text;
  final double rozmiar;

  const MyText1({
    super.key,
    required this.text,
    required this.rozmiar,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.robotoCondensed(
        textStyle: TextStyle(
          fontStyle: FontStyle.normal,
          fontSize: rozmiar,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
