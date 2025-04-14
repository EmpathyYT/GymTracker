import 'dart:ui';
import 'package:tuple/tuple.dart';

const krqKeyName = 'frq';
const srqKeyName = 'srq';
const othersKeyName = 'others';
const oldNotifsKeyName = 'oldNotifs';
const newNotifsKeyName = 'newNotifs';
const appBarHeight = 70.0;
const appBarPadding = 7.0;
const glowLevel = 10;


const Color maxLevelColor = Color(0xff8e0cf3);
final List<Tuple2<Color, bool>> borderColors = [
  const Tuple2(Color(0xff0a48f5), false),
  const Tuple2(Color(0xff0583fa), false),
  const Tuple2(Color(0xff089cf7), false),
  const Tuple2(Color(0xff00cdff), false),
  const Tuple2(Color(0xff00fffd), false),
];