import 'package:flutter/material.dart';

import '../../constants/code_constraints.dart';

class AbsoluteCenteredWidget extends StatefulWidget {
  final Widget child;
  final GlobalKey widgetKey;

  const AbsoluteCenteredWidget({
    super.key,
    required this.child,
    required this.widgetKey,
  });

  @override
  State<AbsoluteCenteredWidget> createState() => _AbsoluteCenteredWidgetState();
}

class _AbsoluteCenteredWidgetState extends State<AbsoluteCenteredWidget> {
  double _widgetHeight = 0;
  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox renderBox =
          widget.widgetKey.currentContext?.findRenderObject() as RenderBox;
      setState(() {
        _widgetHeight = renderBox.size.height;
        _opacity = 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Positioned(
              top: (constraints.maxHeight / 2) -
                  (_widgetHeight / 2) -
                  appBarHeight,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: _opacity,
                child: widget.child,
              ),
            )
          ],
        );
      },
    );
  }
}
