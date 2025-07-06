import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/cubit/main_page_cubit.dart';
import 'package:gymtracker/services/cloud/cloud_workout.dart';
import 'package:gymtracker/utils/widgets/workout_viewer_widget.dart';

import '../../../../constants/code_constraints.dart';

class WorkoutViewerRoute extends StatefulWidget {
  final CloudWorkout workout;

  const WorkoutViewerRoute({super.key, required this.workout});

  @override
  State<WorkoutViewerRoute> createState() => _WorkoutViewerRouteState();
}

class _WorkoutViewerRouteState extends State<WorkoutViewerRoute> {
  late final PageController _pageController;
  late final List<Widget> _workoutWidgets;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _workoutWidgets = _buildWorkoutWidgets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: appBarHeight,
        scrolledUnderElevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(top: appBarPadding),
          child: Text(
            workout.name,
            style: GoogleFonts.oswald(fontSize: appBarTitleSize),
          ),
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Don't forget to press finish once you finish your workout!",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: 7,
              itemBuilder:
                  (context, index) =>
                      Column(children: [_workoutWidgets[index]]),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildWorkoutWidgets() {
    return List.generate(7, (index) {
      return WorkoutViewerWidget(
        exercise: MapEntry(index + 1, workout.workouts[index + 1]!),
        arrowNavigationCallback: (bool moveToRight) {
          if (moveToRight) {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeIn,
            );
          } else {
            _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeIn,
            );
          }
        },
        finishExerciseCallback: (BuildContext context) async {
          await context.read<MainPageCubit>().finishWorkout(workout);
          if (context.mounted) {
            if (context.mounted) Navigator.of(context).pop();
          }
        },
      );
    });
  }

  CloudWorkout get workout => widget.workout;
}
