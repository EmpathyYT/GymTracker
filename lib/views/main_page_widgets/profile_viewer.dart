import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/cubit/main_page_cubit.dart';
import 'package:gymtracker/utils/widgets/level_indicator_widget.dart';
import 'package:gymtracker/utils/widgets/loading_widget_flipper.dart';

import '../../constants/code_constraints.dart';

class ProfileViewerWidget extends StatefulWidget {
  const ProfileViewerWidget({super.key});

  @override
  State<ProfileViewerWidget> createState() => _ProfileViewerWidgetState();
}

class _ProfileViewerWidgetState extends State<ProfileViewerWidget>
    with TickerProviderStateMixin {
  String? _userName;
  String? _biography;
  int? _userLevel;
  Color? _borderColor;
  bool isAnimated = false;
  bool isGlowing = false;
  static ValueNotifier<bool> isLoadedNotifier = ValueNotifier<bool>(false);
  late AnimationController _maxLevelController;
  late AnimationController _glowLevelController;
  late Animation<Color?> _maxLevelAnimation;
  late Animation<Color?> _glowLevelAnimation;

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
    super.didUpdateWidget(widget);
  }

  @override
  Widget build(BuildContext context) {
    const verticalOffset = 17;
    const slant = 15;

    return ValueListenableBuilder<bool>(
      valueListenable: isLoadedNotifier,
      builder: (BuildContext context, bool value, Widget? child) {
        return LoadingWidgetFlipper(
          isLoaded: value,
          child: Column(
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
                            _buildAnimationIfActive(
                              (color) => LevelIndicatorWidget(
                                isLoadedNotifier: isLoadedNotifier,
                                color: color,
                                userName: _userName!,
                                level: _userLevel!,
                                slant: slant,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              softWrap: true,
                              _biography!,
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
                  child: _buildAnimationIfActive(
                    (color) => Container(
                      decoration: BoxDecoration(
                        color: darkenColor(
                          Theme.of(context).scaffoldBackgroundColor,
                          0.2,
                        ),
                        border: Border.all(
                          color: color,
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
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Padding _buildStatRow(String firstString, String secondString) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Text(
            firstString,
            style: GoogleFonts.oswald(fontSize: 17, color: Colors.white),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 4),
            child: Text(
              secondString,
              style: GoogleFonts.montserrat(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.white60,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color? borderColorBuilder() {
    return switch (_userLevel!) {
      == 2 => borderColors[0].item1,
      >= 3 && <= 5 => borderColors[1].item1,
      >= 6 && <= 10 => borderColors[2].item1,
      >= 11 && <= 20 => borderColors[3].item1,
      >= 21 && <= 49 => borderColors[4].item1,
      >= 50 => null,
      _ => Colors.white60,
    };
  }

  void _setupColors() {
    final color = borderColorBuilder();
    if (color == null) {
      isAnimated = true;
    } else {
      _borderColor = color;
      isGlowing = _userLevel! >= glowLevel;
    }
    _setupMaxLevelAnimation();
    _setupGlowLevelAnimation(_borderColor!);

    if (isGlowing) {
      _glowLevelController.repeat(reverse: true);
    }

    if (isAnimated) {
      _maxLevelController.repeat(reverse: true);
    }
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
        tween: ColorTween(begin: borderColors.last.item1, end: maxLevelColor),
        weight: 3,
      ),
    ]).animate(_maxLevelController);
  }

  void _handleLevelUpdates() {
    final newBorderColor = borderColorBuilder();
    final newIsAnimated = newBorderColor == null;
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

    isAnimated = newIsAnimated;
    _borderColor = newBorderColor;
    isGlowing = newIsGlowing;
  }

  Animation _getActiveAnimation() =>
      isGlowing ? _glowLevelAnimation : _maxLevelAnimation;

  Widget _buildAnimationIfActive(Function(Color color) widget) {
    if (!isAnimated && !isGlowing) {
      return widget(_borderColor!);
    } else {
      return AnimatedBuilder(
        animation: _getActiveAnimation(),
        builder: (context, child) {
          return widget(_getActiveAnimation().value);
        },
      );
    }
  }
}

Color darkenColor(Color color, double factor) {
  assert(factor >= 0 && factor <= 1, 'Factor must be between 0 and 1');
  return Color.fromRGBO(
    (color.r * 255.0 * (1 - factor)).toInt(),
    (color.g * 255.0 * (1 - factor)).toInt(),
    (color.b * 255.0 * (1 - factor)).toInt(),
    color.a,
  );
}
