import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NoInternet extends StatelessWidget {
  const NoInternet({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Text("PRorER", style: GoogleFonts.oswald(fontSize: 25)),
          ),
          const Center(
            child: Column(
              children: [
                Icon(Icons.cloud_off, size: 100, color: Colors.white30),
                AutoSizeText.rich(
                  textAlign: TextAlign.center,
                  TextSpan(
                    text: 'Can\'t sail thy ship without the strong winds\n',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                        text: '(No Internet Connection :c)',
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
