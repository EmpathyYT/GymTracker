import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/cubit/main_page_cubit.dart';
import 'package:gymtracker/utils/widgets/level_indicator_widget.dart';

import '../../constants/code_constraints.dart';

class ProfileViewerWidget extends StatefulWidget {
  const ProfileViewerWidget({super.key});

  @override
  State<ProfileViewerWidget> createState() => _ProfileViewerWidgetState();
}

class _ProfileViewerWidgetState extends State<ProfileViewerWidget>
    with SingleTickerProviderStateMixin {
  String? _userName;
  String? _biography;
  int? _userLevel;
  Color? _borderColor;
  bool isAnimated = false;
  bool isGlowing = false;
  late AnimationController _maxLevelController;
  late AnimationController _glowLevelController;
  late Animation<Color?> _maxLevelAnimation;
  late Animation<Color?> _glowLevelAnimation;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _maxLevelController.dispose();
    _glowLevelController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _userName = context.read<MainPageCubit>().currentUser.name;
    _biography = context.read<MainPageCubit>().currentUser.bio;
    _userLevel = context.read<MainPageCubit>().currentUser.level;
    if (_borderColor == null) {
      _setupColors();
    }
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant ProfileViewerWidget oldWidget) {
    _handleLevelUpdates();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    const verticalOffset = 17;
    const slant = 15;
    return Column(
      children: [
        Flexible(
          flex: 3,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Row(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: const CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.blueGrey,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: verticalOffset.toDouble()),
                      LevelIndicatorWidget(
                        userName: _userName!,
                        level: _userLevel!,
                        slant: slant,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        softWrap: true,
                        "Example long bio that is used to showcase this widget and fill in the space"!,
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 7,
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: darkenColor(
                  Theme.of(context).scaffoldBackgroundColor,
                  0.2,
                ),
                border: Border.all(
                  color: Colors.white60,
                  style: BorderStyle.solid,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              width: MediaQuery.of(context).size.width * 0.9,
              height: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 10,
                  left: 15,
                  right: 15,
                  bottom: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatRow("Workouts Complete:", "0"),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildStatRow("Example Statistic:", "12"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Row _buildStatRow(String firstString, String secondString) {
    return Row(
      children: [
        Text(
          firstString,
          style: GoogleFonts.oswald(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4, top: 4),
          child: Text(
            secondString,
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white60,
            ),
          ),
        ),
      ],
    );
  }

  Color? _borderColorBuilder() {
    return switch (_userLevel!) {
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

  void _setupColors() {
    final color = _borderColorBuilder();

    if (color == null) {
      isAnimated = true;
    } else {
      _borderColor = color;
      isGlowing = _userLevel! >= glowLevel;
    }

    if (isGlowing) {
      _setupGlowLevelAnimation(_borderColor!);
      _glowLevelController.repeat(reverse: true);
    }

    if (isAnimated) {
      _setupMaxLevelAnimation();
      _maxLevelController.repeat(reverse: true);
    }
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
    final newIsGlowing = _userLevel! >= glowLevel && !newIsAnimated;

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

  Animation _getActiveAnimation() =>
      isGlowing ? _glowLevelAnimation : _maxLevelAnimation;
}
