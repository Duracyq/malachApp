import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyText extends StatelessWidget {
  final String text;
  final double rozmiar;
  final FontWeight waga;

  const MyText(
      {super.key,
      required this.text,
      required this.rozmiar,
      required this.waga});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.nunito(
        textStyle: TextStyle(
            fontStyle: FontStyle.normal, fontSize: rozmiar, fontWeight: waga),
      ),
    );
  }
}
