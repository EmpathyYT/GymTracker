import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/main_page_cubit.dart';
import '../../views/main_page_widgets/routes/add_warrior.dart';
import '../../views/main_page_widgets/routes/pr_tracking_route.dart';

class PrTrackingButton extends StatelessWidget {
  final MainPageState _state;

  const PrTrackingButton({
    super.key,
    required MainPageState state,
  }) : _state = state;

  @override
  Widget build(BuildContext context) {
    return (_state is WorkoutPlanner)
        ? IconButton(
      icon: const Icon(Icons.stacked_line_chart),
      iconSize: 30,
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
    )
        : const SizedBox.shrink();
  }
}