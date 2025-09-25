import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/extensions/remove_decimal_if_necessary.dart';
import 'package:gymtracker/helpers/exercise_type.dart';
import 'package:gymtracker/utils/widgets/workout/exercise_builder_widget.dart';

import '../../constants/code_constraints.dart';
import '../../cubit/main_page_cubit.dart';
import '../widgets/workout/workout_builder_widget.dart';

class ExerciseEditDialog extends StatefulWidget {
  final ExerciseType initialExercise;

  const ExerciseEditDialog({super.key, required this.initialExercise});

  @override
  State<ExerciseEditDialog> createState() => _ExerciseEditDialogState();
}

class _ExerciseEditDialogState extends State<ExerciseEditDialog>
    with TickerProviderStateMixin {
  late final TextEditingController exerciseNameController;
  late final TextEditingController exerciseSetsController;
  late final TextEditingController exerciseRepsController;
  late final TextEditingController exerciseLWeightController;
  late final TextEditingController exerciseHWeightController;
  late final ValueNotifier<bool> isRangeNotifier;
  late final TextEditingController exerciseNoteController;
  final List<AnimationController> _animationControllers = [];

  @override
  void initState() {
    initData();
    super.initState();
  }

  @override
  void dispose() {
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    exerciseNameController.dispose();
    exerciseSetsController.dispose();
    exerciseRepsController.dispose();
    exerciseLWeightController.dispose();
    exerciseHWeightController.dispose();
    isRangeNotifier.dispose();
    exerciseNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Exercise"),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
        child: Column(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white60, width: 0.9),
              ),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: ExerciseBuilderWidget(
                  exerciseNameController: exerciseNameController,
                  exerciseSetsController: exerciseSetsController,
                  exerciseRepsController: exerciseRepsController,
                  exerciseLWeightController: exerciseLWeightController,
                  exerciseHWeightController: exerciseHWeightController,
                  isRangeNotifier: isRangeNotifier,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Edit Exercise Note",
                style: GoogleFonts.oswald(fontSize: 23),
              ),
            ),
            TextField(
              controller: exerciseNoteController,
              decoration: InputDecoration(
                counterText: "",
                border: InputBorder.none,
                hintText: "Enter Note",
                hintStyle: GoogleFonts.montserrat(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              minLines: 1,
              maxLines: 4,
              maxLength: 100,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            final (res, errorMessage) = workoutInputValidator(
              isRangeNotifier.value,
              exerciseNameController.text.trim(),
              exerciseSetsController.text.trim(),
              exerciseRepsController.text.trim(),
              exerciseLWeightController.text.trim(),
              exerciseHWeightController.text.trim(),
            );

            if (res == false) {
              final color = darkenColor(
                Theme.of(context).scaffoldBackgroundColor,
                0.2,
              );
              final controller = showSnackBar(
                context,
                this,
                errorMessage!,
                color,
              );
              _animationControllers.add(controller);
              return;
            }

            final lWeight =
                exerciseLWeightController.text.trim().isEmpty
                    ? "0.0"
                    : exerciseLWeightController.text.trim();

            final hWeight =
                isRangeNotifier.value
                    ? exerciseHWeightController.text.trim()
                    : "0.0";
            final notesCheck = validateTitles(
              exerciseNoteController.text.trim(),
            );
            if (notesCheck != null &&
                exerciseNoteController.text.trim().isNotEmpty) {
              final controller = showSnackBar(
                context,
                this,
                notesCheck,
                darkenBackgroundColor(context),
              );
              _animationControllers.add(controller);
              return;
            }
            initialExercise.json = {
              'name': exerciseNameController.text.trim(),
              'reps': int.parse(exerciseRepsController.text.trim()),
              'sets': int.parse(exerciseSetsController.text.trim()),
              'weightRange': [lWeight, hWeight],
              'notes': exerciseNoteController.text.trim(),
              'type': initialExercise.type.toString(),
            };
            Navigator.of(context).pop();
          },
          child: const Text("OK"),
        ),
      ],
      scrollable: true,
    );
  }

  VoidCallback get initData => () {
    exerciseNameController =
        TextEditingController()..text = initialExercise.name!;
    exerciseSetsController =
        TextEditingController()..text = initialExercise.sets.toString();
    exerciseRepsController =
        TextEditingController()..text = initialExercise.reps.toString();
    exerciseLWeightController =
        TextEditingController()
          ..text =
              initialExercise.weightRange!.item1.toString() == "0.0"
                  ? ""
                  : initialExercise.weightRange!.item1.removeDecimalIfNecessary
                      .toString();
    exerciseHWeightController =
        TextEditingController()
          ..text =
              initialExercise.weightRange!.item2.toString() == "0.0"
                  ? ""
                  : initialExercise.weightRange!.item2.removeDecimalIfNecessary
                      .toString();
    isRangeNotifier = ValueNotifier(
      initialExercise.weightRange!.item1 !=
              initialExercise.weightRange!.item2 &&
          initialExercise.weightRange!.item2 != 0,
    );
    exerciseNoteController =
        TextEditingController()..text = initialExercise.notes;
  };

  ExerciseType get initialExercise => widget.initialExercise;
}

/// This dialog directly alters the workout information using the
/// shallow copy of the exercise, removing the need for a return.
Future<void> showWorkoutEditDialog(
  BuildContext context,
  ExerciseType exercise,
) async {
  await showDialog<ExerciseType?>(
    context: context,
    builder:
        (_) => BlocProvider.value(
          value: context.read<MainPageCubit>(),
          child: ScaffoldMessenger(
            child: Builder(
              builder: (context) {
                return Scaffold(
                  backgroundColor: Colors.transparent,
                  body: ExerciseEditDialog(initialExercise: exercise),
                );
              },
            ),
          ),
        ),
  );
}
