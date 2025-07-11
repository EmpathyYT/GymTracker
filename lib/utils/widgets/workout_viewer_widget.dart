import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:gymtracker/helpers/exercise_type.dart';
import 'package:gymtracker/helpers/rounded_list_builder.dart';
import 'package:gymtracker/utils/widgets/big_centered_text_widget.dart';

import '../../constants/code_constraints.dart';
import '../dialogs/exercise_note_dialog.dart';
import 'navigation_icons_widget.dart';

class WorkoutViewerWidget extends StatefulWidget {
  final MapEntry<int, List<ExerciseType>> exercise;
  final Future<void> Function(BuildContext context) finishExerciseCallback;
  final Function(bool moveToRight) arrowNavigationCallback;

  const WorkoutViewerWidget({
    super.key,
    required this.exercise,
    required this.arrowNavigationCallback,
    required this.finishExerciseCallback,
  });

  @override
  State<WorkoutViewerWidget> createState() => _WorkoutViewerWidgetState();
}

class _WorkoutViewerWidgetState extends State<WorkoutViewerWidget> {
  double? mainSize;

  @override
  Widget build(BuildContext context) {
    mainSize ??= MediaQuery.of(context).size.width * 0.9;

    if (exercise.isEmpty) {
      return Expanded(
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              child: Text(
                "Day $day",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            _centerWidgetIfListEmpty() ?? const SizedBox(),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: NavigationIconsWidget(
                type: _navigationType,
                arrowNavigationCallback:
                    (bool moveToRight) => arrowNavigationCallback(moveToRight),
              ),
            ),
          ],
        ),
      );
    }
    final groupSize = AutoSizeGroup();
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Day $day",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
          ),
          Expanded(
            child: SizedBox(
              width: mainSize,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Expanded(
                    child: roundedListBuilder(
                      borderRadius: 10,
                      itemCount: exercise.length,
                      itemBuilder: (context, index) {
                        final exerciseElement = exercise[index];
                        final exerciseWeightToString =
                            exerciseElement.exerciseWeightToString;
                        return GestureDetector(
                          onTap: () {
                            showExerciseNoteDialog(
                              context,
                              exerciseElement.notes,
                            );
                          },
                          child: SizedBox(
                            height: 60,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: AutoSizeText.rich(
                                      TextSpan(
                                        text: exerciseElement.name,
                                        children: [
                                          TextSpan(
                                            text:
                                                " (${exerciseElement.sets} "
                                                "x ${exerciseElement.reps})",
                                            style: const TextStyle(
                                              fontSize: 17,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                      group: groupSize,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                const VerticalDivider(
                                  color: Colors.white60,
                                  width: 20,
                                  thickness: 1,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: AutoSizeText(
                                      exerciseWeightToString,
                                      group: groupSize,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Center(
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                          darkenColor(
                            Theme.of(context).scaffoldBackgroundColor,
                            0.2,
                          ),
                        ),
                      ),
                      onPressed:
                          () async => await finishExerciseCallback(context),
                      child: const Text("Finish Workout"),
                    ),
                  ),
                  const SizedBox(height: 10),
                  NavigationIconsWidget(
                    type: _navigationType,
                    arrowNavigationCallback:
                        (bool moveToRight) =>
                            arrowNavigationCallback(moveToRight),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _centerWidgetIfListEmpty() {
    if (exercise.isEmpty) {
      return const BigAbsoluteCenteredText(text: "No exercises for this day.");
    }
    return null;
  }

  List<ExerciseType> get exercise => widget.exercise.value;

  Function(bool moveToRight) get arrowNavigationCallback =>
      widget.arrowNavigationCallback;

  NavigationType get _navigationType {
    if (day == 1) {
      return NavigationType.right;
    } else if (day == 7) {
      return NavigationType.left;
    } else {
      return NavigationType.double;
    }
  }

  Future<void> Function(BuildContext context) get finishExerciseCallback =>
      widget.finishExerciseCallback;

  int get day => widget.exercise.key;
}
