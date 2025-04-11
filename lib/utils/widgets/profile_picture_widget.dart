import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class ProfilePictureWidget extends StatefulWidget {
  final int userLevel;

  const ProfilePictureWidget({super.key, required this.userLevel});

  @override
  State<ProfilePictureWidget> createState() => _ProfilePictureWidgetState();
}

class _ProfilePictureWidgetState extends State<ProfilePictureWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _animation;
  bool isAnimated = false;
  Color? _borderColor;
  final List<Tuple2<Color, bool>> _borderColors = [
    const Tuple2(Color(0xff0a48f5), false),
    const Tuple2(Color(0xff0583fa), false),
    const Tuple2(Color(0xff089cf7), false),
    const Tuple2(Color(0xff00cdff), false),
    const Tuple2(Color(0xff00fffd), false),
  ];

  @override
  void initState() {
    final color = _borderColorBuilder();
    if (color == null) {
      isAnimated = true;
    } else {
      _borderColor = color;
    }
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = TweenSequence<Color?>([
      for (var i = 0; i < _borderColors.length - 1; i++)
        TweenSequenceItem(
          tween: ColorTween(
            begin: _borderColors[i].item1,
            end: _borderColors[i + 1].item1,
          ),
          weight: 1,
        ),
      TweenSequenceItem(
        tween: ColorTween(
          begin: _borderColors.last.item1,
          end: _borderColors.first.item1,
        ),
        weight: 3,
      ),
    ]).animate(_controller);

    if (isAnimated) {
      _controller.repeat(reverse: true);
    }

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ProfilePictureWidget oldWidget) {
    final newIsAnimated = _borderColorBuilder() == null;

    if (newIsAnimated && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!newIsAnimated && _controller.isAnimating) {
      _controller.stop();
    }

    setState(() {
      isAnimated = newIsAnimated;
      _borderColor = _borderColorBuilder();
    });

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return !isAnimated
        ? DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _borderColor!,
                width: 4,
              ),
            ),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blueGrey,
              ),
            ),
          )
        : AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return DecoratedBox(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _animation.value!,
                      width: 4,
                    )),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blueGrey,
                  ),
                ),
              );
            },
          );
  }

  Color? _borderColorBuilder() {
    return switch (widget.userLevel) {
      <= 1 => Colors.transparent,
      == 2 => _borderColors[0].item1,
      >= 3 && <= 5 => _borderColors[1].item1,
      >= 6 && <= 10 => _borderColors[2].item1,
      >= 11 && <= 20 => _borderColors[3].item1,
      >= 21 && <= 49 => _borderColors[4].item1,
      >= 50 => null,
      _ => Colors.transparent,
    };
  }
}
