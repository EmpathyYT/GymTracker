import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/code_constraints.dart';
import '../utils/widgets/misc/absolute_centered_widget.dart';

class UpdateAppPage extends StatefulWidget {
  const UpdateAppPage({super.key});

  @override
  State<UpdateAppPage> createState() => _UpdateAppPageState();
}

class _UpdateAppPageState extends State<UpdateAppPage> {
  final GlobalKey columnKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: appBarPadding),
          child: Text(
            "PRorER",
            style: GoogleFonts.oswald(fontSize: appBarTitleSize),
          ),
        ),
        centerTitle: true,
        toolbarHeight: appBarHeight,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          AbsoluteCenteredWidget(
            widgetKey: columnKey,
            child: Column(
              key: columnKey,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.security_update_rounded,
                  size: 100,
                  color: Colors.white30,
                ),
                AutoSizeText.rich(
                  textAlign: TextAlign.center,
                  TextSpan(
                    text: 'Your war gear is behind the times, prepare anew.\n',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                        text: '(Please update the app to continue)',
                        style: TextStyle(fontSize: 12, color: Colors.white30),
                      ),
                    ],
                  ),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
