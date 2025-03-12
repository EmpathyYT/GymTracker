import 'package:flutter/material.dart';

class DoubleWidgetFlipper extends StatelessWidget {
  final bool flipToTwo;
  final Widget Function({List<Widget>? children, Widget? child}) buildOne;
  final Widget Function({List<Widget>? children, Widget? child}) buildTwo;
  final bool isOneChild;
  final bool isTwoChild;
  final List<Widget>? commonWidgets;
  final List<Widget> childrenIfOne;
  final List<Widget> childrenIfTwo;

  const DoubleWidgetFlipper({
    super.key,
    required this.buildOne,
    required this.buildTwo,
    required this.isOneChild,
    required this.isTwoChild,
    required this.flipToTwo,
    required this.childrenIfOne,
    required this.childrenIfTwo,
    this.commonWidgets,
  });

  @override
  Widget build(BuildContext context) {
    final firstWidget = isOneChild
        ? buildOne(child: childrenIfOne.first)
        : buildOne(children: [...?commonWidgets, ...childrenIfOne]);

    final secondWidget = isTwoChild
        ? buildTwo(child: childrenIfTwo.first)
        : buildTwo(children: [...?commonWidgets, ...childrenIfTwo]);

    return flipToTwo ? firstWidget : secondWidget;
  }
}
