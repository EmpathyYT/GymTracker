import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import '../../../constants/code_constraints.dart';
import '../../../views/main_page_widgets/profile_viewer.dart';

class ProfilePictureWidget extends StatefulWidget {
  final int userLevel;

  const ProfilePictureWidget({super.key, required this.userLevel});

  @override
  State<ProfilePictureWidget> createState() => _ProfilePictureWidgetState();
}

class _ProfilePictureWidgetState extends State<ProfilePictureWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _maxLevelController;
  late AnimationController _glowLevelController;
  late Animation<Color?> _maxLevelAnimation;
  late Animation<Color?> _glowLevelAnimation;
  bool isAnimated = false;
  bool isGlowing = false;
  Color? _borderColor;

  @override
  void initState() {
    final color = _borderColorBuilder();

    if (color == null) {
      isAnimated = true;
    } else {
      _borderColor = color;
      isGlowing = widget.userLevel >= glowLevel;
    }

    if (isGlowing) {
      _setupGlowLevelAnimation(_borderColor!);
      _glowLevelController.repeat(reverse: true);
    }

    if (isAnimated) {
      _setupMaxLevelAnimation();
      _maxLevelController.repeat(reverse: true);
    }

    super.initState();
  }

  @override
  void dispose() {
    _maxLevelController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ProfilePictureWidget oldWidget) {
    _handleLevelUpdates();

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return !isAnimated && !isGlowing
        ? _profilePictureBuilder(_borderColor!)
        : AnimatedBuilder(
            animation: _getActiveAnimation(),
            builder: (context, child) {
              return _profilePictureBuilder(_getActiveAnimation().value);
            },
          );
  }

  Color? _borderColorBuilder() {
    return switch (widget.userLevel) {
      <= 1 => Colors.transparent,
      == 2 => borderColors[0].item1,
      >= 3 && <= 5 => borderColors[1].item1,
      >= 6 && <= 10 => borderColors[2].item1,
      >= 11 && <= 20 => borderColors[3].item1,
      >= 21 && <= 49 => borderColors[4].item1,
      >= 50 => null,
      _ => Colors.transparent,
    };
  }

  void _setupGlowLevelAnimation(Color color) {
    _glowLevelController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _glowLevelAnimation = ColorTween(
      begin: color,
      end: darkenColor(color, 0.4),
    ).animate(_glowLevelController);
  }

  void _setupMaxLevelAnimation() {
    _maxLevelController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _maxLevelAnimation = TweenSequence<Color?>([
      for (var i = 0; i < borderColors.length - 1; i++)
        TweenSequenceItem(
          tween: ColorTween(
            begin: borderColors[i].item1,
            end: borderColors[i + 1].item1,
          ),
          weight: 1,
        ),
      TweenSequenceItem(
        tween: ColorTween(
          begin: borderColors.last.item1,
          end: maxLevelColor,
        ),
        weight: 3,
      ),
    ]).animate(_maxLevelController);
  }

  void _handleLevelUpdates() {
    final borderColorBuilder = _borderColorBuilder();
    final newIsAnimated = borderColorBuilder == null;
    final newIsGlowing = widget.userLevel >= glowLevel && !newIsAnimated;

    if (newIsAnimated && !_maxLevelController.isAnimating) {
      _maxLevelController.repeat(reverse: true);
    } else if (!newIsAnimated && _maxLevelController.isAnimating) {
      _maxLevelController.stop();
    } else if (newIsGlowing && !isGlowing) {
      _glowLevelController.repeat(reverse: true);
    } else if (!newIsGlowing && isGlowing) {
      _glowLevelController.stop();
    }

    if (newIsAnimated != isAnimated ||
        _borderColor != borderColorBuilder ||
        newIsGlowing != isGlowing) {
      setState(() {
        isAnimated = newIsAnimated;
        _borderColor = borderColorBuilder;
        isGlowing = newIsGlowing;
      });
    }
  }

  DecoratedBox _profilePictureBuilder(Color color) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color,
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
    );
  }

  Animation _getActiveAnimation() =>
      isGlowing ? _glowLevelAnimation : _maxLevelAnimation;
}
