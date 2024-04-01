import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyText2 extends StatelessWidget {
  final String text;
  final double rozmiar;

  const MyText2({
    super.key,
    required this.text,
    required this.rozmiar,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.openSans(
        textStyle: TextStyle(
          fontSize: rozmiar,
        ),
      ),
    );
  }
}
