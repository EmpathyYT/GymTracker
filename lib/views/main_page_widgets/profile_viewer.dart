import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/cubit/main_page_cubit.dart';
import 'package:gymtracker/services/cloud/cloud_user.dart';
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
  int? _completedWorkoutsCount;
  int? _pointsLeftForNextLevel;
  double? _averageWorkoutsPerMonth;
  int? _userLevel;
  Color? _borderColor;
  bool isAnimated = false;
  bool isGlowing = false;
  AutoSizeGroup group = AutoSizeGroup();
  static final ValueNotifier<bool> _isLoadedNotifier = ValueNotifier<bool>(
    false,
  );
  static final ValueNotifier<bool> didCalculate = ValueNotifier<bool>(false);
  static final ValueNotifier<bool> didFetch = ValueNotifier<bool>(false);
  late AnimationController _maxLevelController;
  late AnimationController _glowLevelController;
  late Animation<Color?> _maxLevelAnimation;
  late Animation<Color?> _glowLevelAnimation;
  late final CloudUser user;

  @override
  void dispose() {
    _maxLevelController.dispose();
    _glowLevelController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    didCalculate.addListener(checkIfAllLoaded);
    didFetch.addListener(checkIfAllLoaded);
  }

  @override
  void didChangeDependencies() {
    user = context.read<MainPageCubit>().currentUser;

    if (user.pointsForNextLevel == null) {
      loadStatistics();
    }
    _userName = user.name;
    _biography = user.bio;
    _userLevel = user.level;
    _completedWorkoutsCount = user.completedWorkoutsCount;
    _pointsLeftForNextLevel = user.pointsForNextLevel;
    _averageWorkoutsPerMonth = user.averageWorkoutsPerMonth;

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
      valueListenable: _isLoadedNotifier,
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
                                didCalculateNotifier: didCalculate,
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
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 7.5),
                    child: Text(
                      "Statistics & Badges",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                        child: PageView.builder(
                          itemCount: 3,
                          itemBuilder: (context, index) {
                            return SizedBox(
                              width: MediaQuery.of(context).size.width * 0.9,
                              child: _buildStatWidget(index),
                            );
                          },
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

  Widget _buildStatWidget(int index) {
    final data = statistics[index]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: data.children,
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

  Map<int, Column> get statistics => {
    0: Column(
      children: [
        const Icon(Icons.leaderboard, color: Colors.white, size: 60),
        const SizedBox(height: 5),
        AutoSizeText.rich(
          group: group,
          maxLines: 2,
          textAlign: TextAlign.center,
          TextSpan(
            text: "Current Level: ",
            style: GoogleFonts.montserrat(fontSize: 28, color: Colors.white70),
            children: <TextSpan>[
              TextSpan(
                text: _userLevel.toString(),
                style: GoogleFonts.montserrat(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: "\nPoints left for the next level: ",
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  color: Colors.white60,
                ),
              ),
              TextSpan(
                text: _pointsLeftForNextLevel.toString(),
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
    1: Column(
      children: [
        const Icon(Icons.leaderboard, color: Colors.white, size: 60),
        const SizedBox(height: 5),
        AutoSizeText.rich(
          group: group,
          maxLines: 2,
          textAlign: TextAlign.center,
          TextSpan(
            text: "Completed Workouts: ",
            style: GoogleFonts.montserrat(fontSize: 28, color: Colors.white70),
            children: <TextSpan>[
              TextSpan(
                text: _completedWorkoutsCount.toString(),
                style: GoogleFonts.montserrat(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: "\nAverage workouts per month: ",
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  color: Colors.white60,
                ),
              ),
              TextSpan(
                text: _averageWorkoutsPerMonth.toString(),
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
    2: Column(
      children: [
        const Icon(
          Icons.star_purple500_outlined,
          color: Colors.white,
          size: 60,
        ),
        const SizedBox(height: 5),
        Text(
          textAlign: TextAlign.center,
          "This area is going to be used for badges",
          style: GoogleFonts.montserrat(fontSize: 28, color: Colors.white),
        ),
      ],
    ),
  };

  void checkIfAllLoaded() {
    if (didCalculate.value && didFetch.value) {
      setState(() {
        _isLoadedNotifier.value = true;
        _completedWorkoutsCount = user.completedWorkoutsCount;
        _pointsLeftForNextLevel = user.pointsForNextLevel;
        _averageWorkoutsPerMonth = user.averageWorkoutsPerMonth;
      });
    }
  }

  Future<void> loadStatistics() async {
    user.setStatistics().then((value) {
      didFetch.value = true;
    });
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
