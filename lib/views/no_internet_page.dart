import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/constants/code_constraints.dart';
import 'package:gymtracker/utils/widgets/misc/absolute_centered_widget.dart';

class NoInternet extends StatefulWidget {
  const NoInternet({super.key});

  @override
  State<NoInternet> createState() => _NoInternetState();
}

class _NoInternetState extends State<NoInternet> {
  double? columnHeight;
  GlobalKey columnKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox renderBox =
          columnKey.currentContext?.findRenderObject() as RenderBox;
      setState(() {
        columnHeight = renderBox.size.height;
      });
    });
  }

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
                Icon(Icons.cloud_off, size: 100, color: Colors.white30),
                AutoSizeText.rich(
                  textAlign: TextAlign.center,
                  TextSpan(
                    text:
                    'Without the storm, the warship drifts alone.\n',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: '(No Internet Connection :c)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white30,
                        ),
                      ),
                    ],
                  ),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
