import 'package:flutter/material.dart';

typedef CloserLoadingScreen = bool Function();
typedef UpdateLoadingScreen = bool Function(String text);


@immutable
class LoadingScreenController {
  final CloserLoadingScreen close;
  final UpdateLoadingScreen update;

  const LoadingScreenController({
    required this.close,
    required this.update,
  });
}