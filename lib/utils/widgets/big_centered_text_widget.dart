import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BigCenteredText extends StatelessWidget {
  final String text;

  const BigCenteredText({
    super.key,
    required this.text
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: Text(
          text,
          style: GoogleFonts.oswald(
            fontSize: 35,
          ),
        ),
      ),
    );
  }
}