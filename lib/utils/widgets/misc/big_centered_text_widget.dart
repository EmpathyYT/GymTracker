import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/utils/widgets/misc/absolute_centered_widget.dart';

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
          textAlign: TextAlign.center,
          text,
          style: GoogleFonts.oswald(
            fontSize: 35,
          ),
        ),
      ),
    );
  }
}


class BigAbsoluteCenteredText extends StatelessWidget {
  final String text;

  const BigAbsoluteCenteredText({
    super.key,
    required this.text
  });

  @override
  Widget build(BuildContext context) {
    final internalKey = GlobalKey();

    return AbsoluteCenteredWidget(
      widgetKey: internalKey,
      child: Text(
        key: internalKey,
        textAlign: TextAlign.center,
        text,
        style: GoogleFonts.oswald(
          fontSize: 35,
        ),
      ),
    );
  }
}