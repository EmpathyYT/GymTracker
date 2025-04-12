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
  final glowLevel = 10;
  final Color _maxLevelColor = const Color(0xff8e0cf3);
  late AnimationController _maxLevelController;
  late AnimationController _glowLevelController;
  late Animation<Color?> _maxLevelAnimation;
  late Animation<Color?> _glowLevelAnimation;
  bool isAnimated = false;
  bool isGlowing = false;
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
      == 2 => _borderColors[0].item1,
      >= 3 && <= 5 => _borderColors[1].item1,
      >= 6 && <= 10 => _borderColors[2].item1,
      >= 11 && <= 20 => _borderColors[3].item1,
      >= 21 && <= 49 => _borderColors[4].item1,
      >= 50 => null,
      _ => Colors.transparent,
    };
  }

  Color darkenColor(Color color, double factor) {
    assert(factor >= 0 && factor <= 1, 'Factor must be between 0 and 1');
    return Color.fromRGBO(
      (color.red * (1 - factor)).toInt(),
      (color.green * (1 - factor)).toInt(),
      (color.blue * (1 - factor)).toInt(),
      color.opacity,
    );
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
          end: _maxLevelColor,
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
