import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymtracker/constants/code_constraints.dart';
import 'package:gymtracker/services/cloud/cloud_workout.dart';

import '../../cubit/main_page_cubit.dart';

class DuplicateWorkoutDialog extends StatefulWidget {
  final CloudWorkout workout;

  const DuplicateWorkoutDialog({super.key, required this.workout});

  @override
  State<DuplicateWorkoutDialog> createState() => _DuplicateWorkoutDialogState();
}

class _DuplicateWorkoutDialogState extends State<DuplicateWorkoutDialog>
    with TickerProviderStateMixin {
  final List<AnimationController> _controllers = [];
  String? workoutName;

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Duplicate Workout'),
      content: TextField(
        onChanged: (value) {
          workoutName = value;
        },
        decoration: const InputDecoration(hintText: "Enter new workout name"),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            if (workoutName != null && workoutName!.isNotEmpty) {
              if (validateTitles(workoutName) != null) {
                showSnackBar(
                  context,
                  this,
                  validateTitles(workoutName)!,
                  darkenBackgroundColor(context),
                );
                return;
              }
              await context.read<MainPageCubit>().duplicateWorkout(
                workout,
                workoutName!,
              );
              if (!context.mounted) return;
              Navigator.of(context).pop();
            } else {
              showSnackBar(
                context,
                this,
                "Please enter a valid name",
                darkenBackgroundColor(context),
              );
            }
          },
          child: const Text('Duplicate'),
        ),
      ],
    );
  }

  get workout => widget.workout;
}

Future<void> showWorkoutDuplicationDialog(
  BuildContext context,
  CloudWorkout workout,
) async {
  await showDialog<bool?>(
    context: context,
    builder:
        (_) => BlocProvider.value(
          value: context.read<MainPageCubit>(),
          child: ScaffoldMessenger(
            child: Builder(
              builder: (context) {
                return Scaffold(
                  backgroundColor: Colors.transparent,
                  body: DuplicateWorkoutDialog(workout: workout,),
                );
              },
            ),
          ),
        ),
  );
}
