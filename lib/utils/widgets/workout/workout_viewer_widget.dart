import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:gymtracker/extensions/remove_decimal_if_necessary.dart';
import 'package:gymtracker/helpers/exercise_type.dart';
import 'package:gymtracker/helpers/rounded_list_builder.dart';

import '../../../constants/code_constraints.dart';
import '../../dialogs/exercise_note_dialog.dart';
import '../misc/big_centered_text_widget.dart';
import '../misc/navigation_icons_widget.dart';

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
              bottom: 15,
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
                  Flexible(
                    flex: 6,
                    child: roundedListBuilder(
                      borderRadius: 10,
                      itemCount: exercise.length,
                      itemBuilder: (context, index) {
                        final exerciseElement = exercise[index];
                        final rightCell = _rightCellBuilder(
                          exerciseElement,
                          groupSize,
                        );
                        final leftCell = _leftCellBuilder(
                          exerciseElement,
                          groupSize,
                        );
                        return GestureDetector(
                          onTap: () {
                            if (exerciseElement.type ==
                                ExerciseTypesEnum.rest) {
                              return;
                            }
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
                                    child: leftCell,
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
                                    child: rightCell,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Column(
                      children: [
                        ElevatedButton(
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

                        NavigationIconsWidget(
                          type: _navigationType,
                          arrowNavigationCallback:
                              (bool moveToRight) =>
                                  arrowNavigationCallback(moveToRight),
                        ),
                      ],
                    ),
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

  Widget _rightCellBuilder(
    ExerciseType exerciseElement,
    AutoSizeGroup groupSize,
  ) {
    final restPeriod = exerciseElement.restPeriod;
    String data;
    if (restPeriod == null) {
      data = "${exerciseElement.sets} x ${exerciseElement.reps}";
    } else {
      final isMins = exerciseElement.isInMins ?? false;
      if (isMins) {
        data =
            "${restPeriod.removeDecimalIfNecessary} minutes\n"
            "(${(restPeriod * 60).ceil()} seconds)";
      } else {
        data = "${restPeriod.removeDecimalIfNecessary} seconds";
      }
    }

    return AutoSizeText(
      data,
      group: groupSize,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
    );
  }

  Widget _leftCellBuilder(
    ExerciseType exerciseElement,
    AutoSizeGroup groupSize,
  ) {
    final double? restPeriod = exerciseElement.restPeriod;
    final List<TextSpan> children = [];

    if (restPeriod == null) {
      children.add(
        TextSpan(
          text:
              "\n(${exerciseElement.sets} "
              "x ${exerciseElement.reps})",
          style: const TextStyle(fontSize: 17, color: Colors.white70),
        ),
      );
    }
    return AutoSizeText.rich(
      TextSpan(
        text: restPeriod == null ? exerciseElement.name : "Rest Period",
        children: children,
      ),
      group: groupSize,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
    );
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
