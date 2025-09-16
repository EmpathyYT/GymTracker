import 'dart:ui';

import 'package:flutter/material.dart';

import '../misc/double_widget_flipper.dart';

class LoadingWidgetFlipper extends StatefulWidget {
  final bool isLoaded;
  final Widget child;

  const LoadingWidgetFlipper({
    super.key,
    required this.isLoaded,
    required this.child,
  });

  @override
  State<LoadingWidgetFlipper> createState() => _LoadingWidgetFlipperState();
}

class _LoadingWidgetFlipperState extends State<LoadingWidgetFlipper> {
  @override
  Widget build(BuildContext context) {
    return DoubleWidgetFlipper(
      buildOne:
          ({child, children}) => Stack(
            children: [
              child!,
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(color: Colors.transparent),
                ),
              ),
              const Center(child: CircularProgressIndicator()),
            ],
          ),
      buildTwo: ({child, children}) => child!,
      isOneChild: true,
      isTwoChild: true,
      flipToTwo: value,
      childrenIfOne: [child],
      childrenIfTwo: [child],
    );
  }

  bool get value => widget.isLoaded;

  Widget get child => widget.child;
}
