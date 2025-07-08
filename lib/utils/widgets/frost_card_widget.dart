import 'dart:math' hide log;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gymtracker/constants/code_constraints.dart';
import 'package:tuple/tuple.dart';

class FrostCardWidget extends StatefulWidget {
  final Widget widget;
  final double blurSigma;
  final int level;

  const FrostCardWidget({
    super.key,
    required this.widget,
    required this.blurSigma,
    required this.level,
  });

  @override
  State<FrostCardWidget> createState() => _FrostCardWidgetState();
}

class _FrostCardWidgetState extends State<FrostCardWidget>
    with AutomaticKeepAliveClientMixin {
  List _cachedGradient = [];
  Color? _frostColor;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _frostColor = frostColorBuilder(level);
    _cachedGradient = _generateRandomBackgroundColor().toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: FractionallySizedBox(
        widthFactor: 1,
        heightFactor: 0.8,
        child: DecoratedBox(
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
                    margin: const EdgeInsets.all(8),
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
                    margin: const EdgeInsets.all(8),
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
                  color: _frostColor!.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _frostColor!.withValues(alpha: 0.15),
                      blurRadius: 10,
                      spreadRadius: 0.5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: widgetToFrost,
              ),
            ],
          ),
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
        0 => color.withGreen(applyFactor((color.g * 255).round())),
        1 => color.withBlue(applyFactor((color.b * 255).round())),
        2 || _ => color.withRed(applyFactor((color.r * 255).round())),
      };
    }

    return Tuple3(
      colorTweak(colors[0]).withValues(alpha: 0.1),
      colorTweak(colors[1]).withValues(alpha: 0.1),
      colorTweak(colors[2]).withValues(alpha: 0.1),
    );
  }



  int get level => widget.level;
  Widget get widgetToFrost => widget.widget;
}
