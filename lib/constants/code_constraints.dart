import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

const krqKeyName = 'frq';
const srqKeyName = 'srq';
const achievementsKeyName = 'achievements';
const oldNotifsKeyName = 'oldNotifs';
const newNotifsKeyName = 'newNotifs';
const appBarHeight = 70.0;
const appBarTitleSize = 35.0;
const appBarPadding = 7.0;
const glowLevel = 10;
const noWeightRestrictionMessage = 'No Weight Range';
const workoutCacheField = "workouts";
const mainSizeIcon = 26.0;

const Color maxLevelColor = Color(0xff8e0cf3);
final List<Tuple2<Color, bool>> borderColors = [
  const Tuple2(Color(0xff0a48f5), false),
  const Tuple2(Color(0xff0583fa), false),
  const Tuple2(Color(0xff089cf7), false),
  const Tuple2(Color(0xff00cdff), false),
  const Tuple2(Color(0xff00fffd), false),
];


Color frostColorBuilder(int level) {
  return switch (level) {
    == 2 => borderColors[0].item1,
    >= 3 && <= 5 => borderColors[1].item1,
    >= 6 && <= 10 => borderColors[2].item1,
    >= 11 && <= 20 => borderColors[3].item1,
    >= 21 && <= 49 => borderColors[4].item1,
    >= 50 => Colors.deepPurpleAccent,
    _ => const Color(0xff00599F),
  };
}

Color darkenColor(Color color, double factor) {
  assert(factor >= 0 && factor <= 1, 'Factor must be between 0 and 1');
  return Color.fromRGBO(
    (color.r * 255.0 * (1 - factor)).toInt(),
    (color.g * 255.0 * (1 - factor)).toInt(),
    (color.b * 255.0 * (1 - factor)).toInt(),
    color.a,
  );
}

AnimationController showSnackBar(
    BuildContext context,
    TickerProvider vsync,
    String message,
    Color color,
    ) {
  if (ScaffoldMessenger.of(context).mounted) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
  }

  final controller = AnimationController(
    vsync: vsync,
    duration: const Duration(milliseconds: 500),
  );

  final animation = CurvedAnimation(parent: controller, curve: Curves.easeInOut)
    ..addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        await Future.delayed(
          const Duration(milliseconds: 2500),
              () => controller.reverse(),
        );
      }
    });

  controller.forward();
  ScaffoldMessenger.of(context)
      .showSnackBar(
    SnackBar(
      content: FadeTransition(
        opacity: controller,
        child: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      duration: const Duration(seconds: 3),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      animation: animation,
      margin: const EdgeInsets.all(20),
      elevation: 10,
    ),
  )
      .closed
      .then((_) {
  });
  return controller;
}

