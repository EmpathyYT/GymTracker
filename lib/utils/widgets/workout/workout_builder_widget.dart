import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/utils/widgets/misc/navigation_icons_widget.dart';
import 'package:gymtracker/utils/widgets/workout/exercise_builder_list.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';
import '../../../constants/code_constraints.dart';
import '../../../helpers/exercise_type.dart';

typedef FilteredExerciseFormat = Map<int, List<Tuple2<String, ExerciseType>>>;

class WorkoutBuilderWidget extends StatefulWidget {
  final int day;
  final Function(bool moveToRight) arrowNavigationCallback;
  final BehaviorSubject<FilteredExerciseFormat> behaviorController;
  final Uuid uuid;

  const WorkoutBuilderWidget({
    super.key,
    required this.day,
    required this.behaviorController,
    required this.arrowNavigationCallback,
    required this.uuid,
  });

  @override
  State<WorkoutBuilderWidget> createState() => _WorkoutBuilderWidgetState();
}

class _WorkoutBuilderWidgetState extends State<WorkoutBuilderWidget>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<List<Tuple2<String, ExerciseType>>>
  _exerciseListNotifier = ValueNotifier([]);
  late final StreamSubscription<FilteredExerciseFormat>
  _exerciseStreamSubscription;
  int? draggingIndex;

  @override
  void initState() {
    _exerciseListNotifier.value = _initExercises() ?? [];
    _exerciseStreamSubscription = _exerciseController.listen(
      (event) => _streamEventCallback(event),
    );
    super.initState();
  }

  @override
  void dispose() {
    _exerciseListNotifier.dispose();
    _exerciseStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            "Day $day",
            textAlign: TextAlign.center,
            style: GoogleFonts.oswald(fontSize: 30),
          ),
          const SizedBox(height: 10),
          Flexible(
            flex: 7,
            child: ExerciseBuilderList(
              exerciseListNotifier: _exerciseListNotifier,
              onReorder: (index, exercise) {
                if (exercise == null) return;
                _removeFromStream(day, exercise.item1);
                _addToStream(
                  day,
                  exercise.item2,
                  uid: exercise.item1,
                  index: index,
                );
              },
              onAddExercise:
                  (exercise, index) =>
                      _addToStream(day, exercise, index: index),
              onRemoveExercise: (uid) {
                _removeFromStream(day, uid);
              },
              day: day,
            ),
          ),
          Flexible(
            flex: 1,
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

  void _streamEventCallback(FilteredExerciseFormat event) {
    final exercises = event[day] ?? [];
    _exerciseListNotifier.value = [...exercises];
  }

  List<Tuple2<String, ExerciseType>>? _initExercises() {
    try {
      final exercises = _exerciseController.valueOrNull;
      final dayExercises = exercises?[day] ?? [];
      return dayExercises;
    } catch (_) {
      return null;
    }
  }

  void _addToStream(
    int day,
    ExerciseType exercise, {
    required int index,
    String? uid,
  }) {
    _exerciseController.add(
      {..._exerciseController.valueOrNull ?? {}}..update(day, (e) {
        if (uid != null) {
          e.insert(index, Tuple2(uid, exercise));
        } else {
          e.insert(index, Tuple2(uuid.v4(), exercise));
        }
        return e;
      }, ifAbsent: () => [Tuple2(uuid.v4(), exercise)]),
    );
  }

  void _removeFromStream(int day, String uuid) {
    _exerciseController.add(
      {..._exerciseController.valueOrNull ?? {}}..update(
        day,
        (e) => e..removeWhere((e) => e.item1 == uuid),
        ifAbsent: () => [],
      ),
    );
  }

  int get day => widget.day;

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

  BehaviorSubject<FilteredExerciseFormat> get _exerciseController =>
      widget.behaviorController;

  Uuid get uuid => widget.uuid;
}

(bool, String?) workoutInputValidator(
  bool isRange,
  String exerciseName,
  String sets,
  String reps,
  String lWeight,
  String hWeight,
) {
  final repsValidation = _validateRepsInput(reps);
  final setsValidation = _validateSetsInput(sets);
  final lWeightValidation = validateWeightInput(lWeight);
  final hWeightValidation = isRange ? validateWeightInput(hWeight) : null;
  final exerciseNameValidation = validateTitles(exerciseName);
  final List<String?> validationErrors =
      [
        repsValidation,
        setsValidation,
        lWeightValidation,
        hWeightValidation,
        exerciseNameValidation,
      ].where((error) => error != null).toList();
  if (validationErrors.isNotEmpty) {
    return (false, validationErrors.first);
  } else if (hWeight.isNotEmpty && lWeight.isEmpty && isRange) {
    return (
      false,
      "Please enter a low weight if you are entering a high weight.",
    );
  } else if (lWeight.isNotEmpty && hWeight.isNotEmpty && isRange) {
    final rangesValidation = _validateRangesInput(lWeight, hWeight);
    if (rangesValidation != null) {
      return (false, rangesValidation);
    } else {
      return (true, null);
    }
  } else {
    return (true, null);
  }
}

String? _validateRepsInput(String? value) {
  if (value == null || value.isEmpty) {
    return "Please enter a number in the reps field.";
  } else if (int.tryParse(value) == null) {
    return "Please enter a valid number in the reps field.";
  } else {
    if (int.parse(value) < 1) {
      return "Please enter a number greater than 0 in the reps field.";
    } else if (int.parse(value) > 60) {
      return "What blasphemy are you doing? "
          "Enter a number less than 60 in the reps field.";
    }
  }
  return null;
}

String? _validateSetsInput(String? value) {
  if (value == null || value.isEmpty) {
    return "Please enter a number in the sets field.";
  } else if (int.tryParse(value) == null) {
    return "Please enter a valid number in the sets field.";
  } else {
    if (int.parse(value) < 1) {
      return "Please enter a number greater than 0 in the sets field.";
    } else if (int.parse(value) > 30) {
      return "What on God's green earth are you thinking?? "
          "Enter a number less than 30 in the sets field.";
    }
  }
  return null;
}

String? _validateRangesInput(String low, String high) {
  if (double.parse(low) > double.parse(high)) {
    return "Please enter a valid range.";
  }
  return null;
}
