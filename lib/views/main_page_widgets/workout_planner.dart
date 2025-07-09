import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/constants/code_constraints.dart';
import 'package:gymtracker/cubit/main_page_cubit.dart';
import 'package:gymtracker/exceptions/cloud_exceptions.dart';
import 'package:gymtracker/services/cloud/cloud_workout.dart';
import 'package:gymtracker/utils/dialogs/confirmation_dialog.dart';
import 'package:gymtracker/utils/dialogs/error_dialog.dart';
import 'package:gymtracker/utils/widgets/frost_card_widget.dart';
import 'package:gymtracker/utils/widgets/split_slanted_button.dart';
import 'package:gymtracker/views/main_page_widgets/routes/workout_planner_routes/new_workout.dart';
import 'package:gymtracker/views/main_page_widgets/routes/workout_planner_routes/workout_editor.dart';
import 'package:gymtracker/views/main_page_widgets/routes/workout_planner_routes/workout_viewer.dart';

import '../../services/cloud/cloud_user.dart';
import '../../utils/dialogs/success_dialog.dart';

class WorkoutPlannerWidget extends StatefulWidget {
  const WorkoutPlannerWidget({super.key});

  @override
  State<WorkoutPlannerWidget> createState() => _WorkoutPlannerWidgetState();
}

class _WorkoutPlannerWidgetState extends State<WorkoutPlannerWidget> {
  CloudUser? _user;
  static List<Widget>? _carouselItems;
  static List<CloudWorkout> _workouts = [];

  @override
  void initState() {
    super.initState();
    _workouts = MainPageCubit.cache[workoutCacheField] ?? [];
  }

  @override
  void didChangeDependencies() {
    _user ??= context.read<MainPageCubit>().currentUser;
    _carouselItems ??= _generateCarouselItems(_workouts);
    context.read<MainPageCubit>().fetchWorkouts(_workouts);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MainPageCubit, MainPageState>(
      listener: (context, state) async {
        if (state is WorkoutPlanner) {
          if (state.success == true) {
            await showSuccessDialog(
              context,
              state.successText![0],
              state.successText![1],
            );
          } else if (state.exception != null) {
            if (state.exception is AlreadyFinishedWorkoutException) {
              await showErrorDialog(
                context,
                "You already finished a workout today.",
              );
            } else {
              await showErrorDialog(context, "Please try again later.");
            }
          }
        }
      },
      builder: (context, state) {
        state as WorkoutPlanner;
        if (state.workouts != null &&
            (!const DeepCollectionEquality().equals(
                  _workouts,
                  state.workouts,
                ) ||
                state.workouts != _workouts)) {
          _workouts = List.from(state.workouts ?? []);
        }
        _carouselItems = _generateCarouselItems(_workouts);
        return Center(child: _buildPage());
      },
    );
  }

  List<Widget> _generateCarouselItems(List<CloudWorkout> workouts) {
    final newWorkoutWidget = FrostCardWidget(
      level: _user!.level,
      blurSigma: 10,
      widget: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "New Workout",
            textAlign: TextAlign.center,
            style: GoogleFonts.oswald(fontSize: 34),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 8.0, right: 8.0),
            child: Text(
              textAlign: TextAlign.center,
              softWrap: true,
              "Press the button below to create your first workout plan.",
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: Colors.white60,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15),
            child: IconButton(
              icon: const Icon(
                Icons.add_circle,
                size: 50,
                color: Colors.white60,
              ),
              onPressed: _newWorkoutButton,
            ),
          ),
        ],
      ),
    );
    if (workouts.isEmpty) return [newWorkoutWidget];
    return List<FrostCardWidget>.generate(workouts.length, (i) {
      return FrostCardWidget(
        level: _user!.level,
        blurSigma: 10,
        widget: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              workouts[i].name,
              textAlign: TextAlign.center,
              style: GoogleFonts.oswald(fontSize: 34),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 8.0, right: 8.0),
              child: Text(
                textAlign: TextAlign.center,
                softWrap: true,
                "Press the button below to view or edit your workout.",
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: Colors.white60,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: SplitSlantedButton(
                onLeftTap: () => _openWorkoutButton(workouts[i]),
                onMiddleTap:
                    () async => await _deleteWorkoutButton(workouts[i]),
                onRightTap: () => _editWorkoutButton(workouts[i]),
              ),
            ),
          ],
        ),
      );
    })..add(newWorkoutWidget);
  }

  Widget _buildPage() {
    return (_carouselItems?.length ?? 0) > 1
        ? PageView.builder(
          pageSnapping: true,
          controller: PageController(viewportFraction: 0.85),
          scrollBehavior: const ScrollBehavior().copyWith(overscroll: false),
          itemCount: _carouselItems!.length,
          itemBuilder: (context, index) {
            return _carouselItems![index];
          },
        )
        : FractionallySizedBox(widthFactor: 0.85, child: _carouselItems!.first);
  }

  void _newWorkoutButton() async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => BlocProvider.value(
              value: context.read<MainPageCubit>(),
              child: const NewWorkoutRoute(),
            ),
      ),
    );
  }

  void _openWorkoutButton(CloudWorkout workout) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => BlocProvider.value(
              value: context.read<MainPageCubit>(),
              child: WorkoutViewerRoute(workout: workout),
            ),
      ),
    );
  }

  void _editWorkoutButton(CloudWorkout workout) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => BlocProvider.value(
              value: context.read<MainPageCubit>(),
              child: WorkoutEditorRoute(workout: workout),
            ),
      ),
    );
  }

  Future<void> _deleteWorkoutButton(CloudWorkout workout) async {
    final result = await showConfirmationDialog(
      context,
      title: "Are you sure?",
      content: "Are you sure you want to delete this workout?",
      cancelText: "Cancel",
      confirmText: "Delete",
    );
    if (result == true) {
      if (!mounted) return;
      await context.read<MainPageCubit>().deleteWorkout(workout);
    }
  }
}
