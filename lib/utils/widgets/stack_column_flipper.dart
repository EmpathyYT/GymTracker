import 'package:flutter/material.dart';

class StackColumnFlipper extends StatelessWidget {
  final bool flipToColumn;
  final List<Widget> commonWidgets;
  final List<Widget> ifStack;
  final List<Widget> ifColumn;

  const StackColumnFlipper({
    super.key,
    required this.flipToColumn,
    required this.ifStack,
    required this.ifColumn,
    required this.commonWidgets,
  });

  @override
  Widget build(BuildContext context) {
    return flipToColumn
        ? Column(
            children: [
              ...commonWidgets,
              ...ifColumn,
            ],
          )
        : Stack(
            children: [...commonWidgets, ...ifStack],
          );
  }
}
