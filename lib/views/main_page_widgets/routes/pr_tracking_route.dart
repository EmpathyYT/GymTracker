import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/utils/widgets/absolute_centered_widget.dart';

import '../../../constants/code_constraints.dart';

class PrTrackingWidget extends StatefulWidget {
  const PrTrackingWidget({super.key});

  @override
  State<PrTrackingWidget> createState() => _PrTrackingWidgetState();
}

class _PrTrackingWidgetState extends State<PrTrackingWidget> {
  final GlobalKey widgetKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: appBarHeight,
        scrolledUnderElevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(top: appBarPadding),
          child: Text(
            'PR Tracker',
            style: GoogleFonts.oswald(fontSize: appBarTitleSize),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: AbsoluteCenteredWidget(
                widgetKey: widgetKey,
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: "Coming soon!",
                    style: GoogleFonts.oswald(
                      fontSize: 30,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    children: [
                      TextSpan(
                        text: "\n(Like really soon)",
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                  key: widgetKey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
