import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/utils/widgets/exercise_builder_list.dart';
import 'package:gymtracker/utils/widgets/navigation_icons_widget.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';

import '../../helpers/exercise_type.dart';

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
  final ValueNotifier<bool> _isRangeNotifier = ValueNotifier(false);
  final TextEditingController _exerciseNameController = TextEditingController();
  final TextEditingController _exerciseRepsController = TextEditingController();
  final TextEditingController _exerciseSetsController = TextEditingController();
  final TextEditingController _exerciseLWeightController =
      TextEditingController();
  final TextEditingController _exerciseHWeightController =
      TextEditingController();
  late final StreamSubscription<FilteredExerciseFormat>
  _exerciseStreamSubscription;
  int? draggingIndex;

  @override
  void initState() {
    _exerciseListNotifier.addListener(() {
      if (_exerciseListNotifier.value.isNotEmpty) {
        _exerciseNameController.clear();
        _exerciseRepsController.clear();
        _exerciseSetsController.clear();
        _exerciseLWeightController.clear();
        _exerciseHWeightController.clear();
      }
    });
    _exerciseListNotifier.value = _initExercises() ?? [];
    _exerciseStreamSubscription = _exerciseController.listen(
      (event) => _streamEventCallback(event),
    );
    super.initState();
  }

  @override
  void dispose() {
    _exerciseNameController.dispose();
    _exerciseRepsController.dispose();
    _exerciseSetsController.dispose();
    _exerciseLWeightController.dispose();
    _exerciseHWeightController.dispose();
    _isRangeNotifier.dispose();
    _exerciseStreamSubscription.cancel();
    _exerciseListNotifier.dispose();
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
          // Container(
          //   width: MediaQuery.of(context).size.width * 0.6,
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(12),
          //     border: Border.all(color: Colors.white60, width: 0.9),
          //   ),
          //   child: ExerciseBuilderWidget(
          //     exerciseNameController: _exerciseNameController,
          //     exerciseSetsController: _exerciseSetsController,
          //     exerciseRepsController: _exerciseRepsController,
          //     exerciseLWeightController: _exerciseLWeightController,
          //     exerciseHWeightController: _exerciseHWeightController,
          //     isRangeNotifier: _isRangeNotifier,
          //   ),
          // ),
          // const SizedBox(height: 10),
          // GestureDetector(
          //   onTap: () => _addExerciseButtonOnClick(),
          //   child: const Icon(Icons.arrow_downward, size: 35),
          // ),
          // const SizedBox(height: 20),
          // Flexible(
          //   flex: 7,
          //   child: Container(
          //     width: MediaQuery.of(context).size.width * 0.75,
          //     decoration: BoxDecoration(
          //       border: Border.all(color: Colors.white60, width: 0.9),
          //       borderRadius: BorderRadius.circular(20),
          //     ),
          //     child: ValueListenableBuilder(
          //       valueListenable: _exerciseListNotifier,
          //       builder: (context, value, child) {
          //         return ReorderableListView.builder(
          //           proxyDecorator: (child, index, animation) {
          //             return Material(
          //               elevation: 8,
          //               color: Colors.transparent,
          //               child: ScaleTransition(
          //                 scale: animation.drive(Tween(begin: 1.0, end: 0.9)),
          //                 child: child,
          //               ),
          //             );
          //           },
          //           itemCount: value.length,
          //           onReorder: (oldIndex, newIndex) {
          //             if (newIndex > oldIndex) {
          //               newIndex -= 1;
          //             }
          //             final item = value.removeAt(oldIndex);
          //             value.insert(newIndex, item);
          //             _removeFromStream(day, item.item1);
          //             _addToStream(
          //               day,
          //               item.item2,
          //               uid: item.item1,
          //               index: newIndex,
          //             );
          //           },
          //           itemBuilder: (context, index) {
          //             return _buildListTile(index, value);
          //           },
          //         );
          //       },
          //     ),
          //   ),
          // ),
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
              onAddExercise: (exercise) => _addToStream(day, exercise),
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

  void _addToStream(int day, ExerciseType exercise, {int? index, String? uid}) {
    _exerciseController.add(
      {..._exerciseController.valueOrNull ?? {}}..update(day, (e) {
        if (index != null && uid != null) {
          e.insert(index, Tuple2(uid, exercise));
        } else {
          e.add(Tuple2(uuid.v4(), exercise));
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

  // void _addExerciseButtonOnClick() {
  //   final (res, errorMessage) = workoutInputValidator(
  //     _isRangeNotifier,
  //     _exerciseNameController.text.trim(),
  //     _exerciseSetsController.text.trim(),
  //     _exerciseRepsController.text.trim(),
  //     _exerciseLWeightController.text.trim(),
  //     _exerciseHWeightController.text.trim(),
  //   );
  //
  //   if (res == false) {
  //     final color = darkenColor(Theme.of(context).scaffoldBackgroundColor, 0.2);
  //     showErrorSnackBar(context, this, errorMessage!, color);
  //     return;
  //   }
  //
  //   final lWeight =
  //       _exerciseLWeightController.text.trim().isEmpty
  //           ? "0"
  //           : _exerciseLWeightController.text.trim();
  //
  //   final hWeight =
  //       _isRangeNotifier.value ? _exerciseHWeightController.text.trim() : "0";
  //
  //   _addToStream(
  //     day,
  //     ExerciseType(
  //       name: _exerciseNameController.text.trim(),
  //       sets: int.parse(_exerciseSetsController.text.trim()),
  //       reps: int.parse(_exerciseRepsController.text.trim()),
  //       weightRange: Tuple2(double.parse(lWeight), double.parse(hWeight)),
  //     ),
  //   );
  // }

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
  final lWeightValidation = _validateWeightInput(lWeight);
  final hWeightValidation = isRange ? _validateWeightInput(hWeight) : null;
  final List<String?> validationErrors =
      [
        repsValidation,
        setsValidation,
        lWeightValidation,
        hWeightValidation,
      ].where((error) => error != null).toList();
  if (validationErrors.isNotEmpty) {
    return (false, validationErrors.first);
  } else if (hWeight.isNotEmpty && lWeight.isEmpty && isRange) {
    log("message");
    return (
      false,
      "Please enter a low weight if you are entering a high weight.",
    );
  } else if (exerciseName.isEmpty) {
    return (false, "Please enter an exercise name.");
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

String? _validateWeightInput(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  } else if (double.tryParse(value) == null) {
    return "Please enter a valid number in the weight field(s).";
  } else {
    if (value.contains('.') && value.split('.')[1].length > 2) {
      return "Please enter a valid number with up to 2 decimal places in the weight field(s).";
    } else if (double.parse(value) < 1) {
      return "Please enter a positive number greater than 0 in the weight field(s).";
    } else if (double.parse(value) > 2000) {
      return "Calm down hulk.";
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
