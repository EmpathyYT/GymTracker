import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constants/code_constraints.dart';
import '../../cubit/main_page_cubit.dart';
import '../../views/main_page_widgets/routes/pr_tracking_route.dart';

class PrTrackerButton extends StatefulWidget {
  final MainPageState? state;

  const PrTrackerButton({super.key, required this.state});

  @override
  State<PrTrackerButton> createState() => _PrTrackerButtonState();
}

class _PrTrackerButtonState extends State<PrTrackerButton>
    with SingleTickerProviderStateMixin {

  late AnimationController _maxLevelController;
  late Animation<Color?> _maxLevelAnimation;

  @override
  void initState() {
    super.initState();
    _setupMaxLevelAnimation();
    _maxLevelController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _maxLevelController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return (widget.state is WorkoutPlanner)
        ? AnimatedBuilder(
          animation: _maxLevelAnimation,
          builder: (context, widget) {
            return IconButton(
              icon: const Icon(Icons.stacked_line_chart),
              iconSize: mainSizeIcon,
              color: _maxLevelAnimation.value,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (_) => BlocProvider.value(
                          value: context.read<MainPageCubit>(),
                          child: const PrTrackingWidget(),
                        ),
                  ),
                );
              },
            );
          }
        )
        : const SizedBox.shrink();
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

}
