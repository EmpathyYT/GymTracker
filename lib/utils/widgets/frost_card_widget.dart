import 'dart:math' hide log;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gymtracker/constants/code_constraints.dart';
import 'package:tuple/tuple.dart';

class FrostCardWidget extends StatefulWidget {
  final Widget widget;
  final Color frostColor;

  const FrostCardWidget({
    super.key,
    required this.widget,
    required this.frostColor,
  });

  @override
  State<FrostCardWidget> createState() => _FrostCardWidgetState();
}

class _FrostCardWidgetState extends State<FrostCardWidget> {
  @override
  void didUpdateWidget(covariant FrostCardWidget oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 500,
        width: 300,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      ..._generateRandomBackgroundColor().toList(),
                    ],
                  ),
                ),
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: 500,
                width: 300,
                decoration: BoxDecoration(
                  color: frostColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: widgetToFrost,
              ),
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
      final factor = (random.nextInt(7) / 10).clamp(0.2, 0.6);
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
