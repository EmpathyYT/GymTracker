import 'dart:math' hide log;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gymtracker/constants/code_constraints.dart';
import 'package:tuple/tuple.dart';

class FrostCardWidget extends StatefulWidget {
  final Widget widget;
  final Color frostColor;
  final double blurSigma;
  final Key frostKey;

  const FrostCardWidget({
    super.key,
    required this.widget,
    required this.frostColor,
    required this.blurSigma,
    required this.frostKey,
  });

  @override
  State<FrostCardWidget> createState() => _FrostCardWidgetState();
}

class _FrostCardWidgetState extends State<FrostCardWidget>
    with AutomaticKeepAliveClientMixin {
  List _cachedGradient = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _cachedGradient = _generateRandomBackgroundColor().toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
      child: Container(
        height: 500,
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            // Blurred gradient background
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  margin: EdgeInsets.all(5),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          ..._cachedGradient,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  margin: EdgeInsets.all(5),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: widget.blurSigma,
                      sigmaY: widget.blurSigma,
                    ),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),
            ),

            Container(
              decoration: BoxDecoration(
                color: frostColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: frostColor.withOpacity(0.15),
                    blurRadius: 10,
                    spreadRadius: 0.5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: widgetToFrost,
            ),
          ],
        ),
      ),
    );
  }

  Tuple3<Color, Color, Color> _generateRandomBackgroundColor() {
    final random = Random();
    final colors = List<Color>.generate(
      borderColors.length,
      (index) => borderColors[index].item1,
    )..shuffle();

    Color colorTweak(Color color) {
      final factor = (random.nextInt(8) / 10).clamp(0.2, 0.8);
      final useMultiply = random.nextBool();
      final channel = random.nextInt(3);

      int applyFactor(int value) {
        final result = useMultiply ? value * factor : value / factor;
        return result.clamp(0, 255).toInt();
      }

      return switch (channel) {
        0 => color.withGreen(applyFactor(color.green)),
        1 => color.withBlue(applyFactor(color.blue)),
        2 || _ => color.withRed(applyFactor(color.red)),
      };
    }

    return Tuple3(
      colorTweak(colors[0]).withOpacity(0.1),
      colorTweak(colors[1]).withOpacity(0.1),
      colorTweak(colors[2]).withOpacity(0.1),
    );
  }

  Color get frostColor => widget.frostColor;

  Widget get widgetToFrost => widget.widget;
}
