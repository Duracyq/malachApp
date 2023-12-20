import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:malachapp/themes/dark_mode.dart';
import 'package:malachapp/themes/light_mode.dart';

class MyText extends StatelessWidget {
  final String text;
  final Color?
      textColor; // Zmieniono na Color? aby można było przyjąć null, jeśli nie dostarczono koloru.
  final bool underline;
  final double fontSize;

  MyText({
    required this.text,
    required this.fontSize,
    this.textColor, // Zmieniono na Color? aby można było przyjąć null, jeśli nie dostarczono koloru.
    this.underline = false,
  });

  @override
  Widget build(BuildContext context) {
    Color finalTextColor = textColor ?? Theme.of(context).colorScheme.onPrimary;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: GoogleFonts.cinzel(
          textStyle: TextStyle(
            color: finalTextColor,
            decoration:
                underline ? TextDecoration.underline : TextDecoration.none,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }
}
