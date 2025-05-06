import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/utils/widgets/navigation_icons_widget.dart';
import 'package:gymtracker/views/main_page_widgets/profile_viewer.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import '../../helpers/exercise_type.dart';

typedef FilteredExerciseFormat = Map<int, List<ExerciseType>>;

class ExerciseBuilderWidget extends StatefulWidget {
  final int day;
  final Function(bool moveToRight) arrowNavigationCallback;
  final BehaviorSubject<FilteredExerciseFormat> behaviorController;

  const ExerciseBuilderWidget({
    super.key,
    required this.day,
    required this.behaviorController,
    required this.arrowNavigationCallback,
  });

  @override
  State<ExerciseBuilderWidget> createState() => _ExerciseBuilderWidgetState();
}

class _ExerciseBuilderWidgetState extends State<ExerciseBuilderWidget>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<List<ExerciseType>> _exerciseListNotifier =
      ValueNotifier([]);
  final TextEditingController _exerciseNameController = TextEditingController();
  final TextEditingController _exerciseRepsController = TextEditingController();
  final TextEditingController _exerciseSetsController = TextEditingController();

  late final AnimationController _snackBarController;
  late final Animation<double> _snackBarAnimation;
  late final StreamSubscription<FilteredExerciseFormat>
      _exerciseStreamSubscription;

  @override
  void initState() {
    _exerciseListNotifier.value = _initExercises() ?? [];
    _exerciseStreamSubscription = _exerciseController.listen(
      (event) => _streamEventCallback(event),
    );
    _exerciseListNotifier.addListener(() {
      if (_exerciseListNotifier.value.isNotEmpty) {
        _exerciseNameController.clear();
        _exerciseRepsController.clear();
        _exerciseSetsController.clear();
      }
    });
    _snackBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _snackBarAnimation =
        CurvedAnimation(parent: _snackBarController, curve: Curves.easeInOut)
          ..addStatusListener((status) async {
            if (status == AnimationStatus.completed) {
              await Future.delayed(
                const Duration(milliseconds: 2500),
                () => _snackBarController.reverse(),
              );
            }
          });
    super.initState();
  }

  @override
  void dispose() {
    _snackBarController.dispose();
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
            style: GoogleFonts.oswald(
              fontSize: 30,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: MediaQuery.of(context).size.width * 0.6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white60,
                width: 0.9,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: TextField(
                      controller: _exerciseNameController,
                      decoration: InputDecoration(
                        counterText: "",
                        border: InputBorder.none,
                        hintText: "Exercise Name",
                        hintStyle: GoogleFonts.montserrat(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      autofocus: true,
                      minLines: 1,
                      maxLines: 3,
                      maxLength: 50,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  "X",
                  style: GoogleFonts.oswald(
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  width: 30,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: TextField(
                      controller: _exerciseSetsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        counterText: "",
                        border: InputBorder.none,
                        hintText: "S",
                        hintStyle: GoogleFonts.montserrat(
                          color: Colors.grey,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      maxLength: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  "X",
                  style: GoogleFonts.oswald(
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  width: 30,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: TextField(
                      controller: _exerciseRepsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        counterText: "",
                        border: InputBorder.none,
                        hintText: "R",
                        hintStyle: GoogleFonts.montserrat(
                          color: Colors.grey,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      maxLength: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => _addExerciseButtonOnClick(),
            child: const Icon(
              Icons.arrow_downward,
              size: 35,
            ),
          ),
          const SizedBox(height: 20),
          Flexible(
            flex: 7,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.75,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white60,
                  width: 0.9,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ValueListenableBuilder(
                valueListenable: _exerciseListNotifier,
                builder: (context, value, child) {
                  return ListView.builder(
                    itemCount: value.length,
                    itemBuilder: (context, index) {
                      final exercise = value[index];
                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.fromLTRB(15, 2, 0, 0),
                        title: Text(
                          exercise.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          "${exercise.sets} x ${exercise.reps}",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: NavigationIconsWidget(
              type: _navigationType,
              arrowNavigationCallback: (bool moveToRight) =>
                  arrowNavigationCallback(
                moveToRight,
              ),
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

  List<ExerciseType>? _initExercises() {
    try {
      final exercises = _exerciseController.valueOrNull;
      return exercises?[day] ?? [];
    } catch (_) {
      return null;
    }
  }

  void _addToStream(int day, ExerciseType exercise) {
    _exerciseController.add({
      ..._exerciseController.valueOrNull ?? {},
    }..update(
        day,
        (e) => e..add(exercise),
        ifAbsent: () => [exercise],
      ));
  }

  bool _inputValidation() {
    final exerciseName = _exerciseNameController.text;
    final sets = _exerciseSetsController.text;
    final reps = _exerciseRepsController.text;
    final color = darkenColor(
      Theme.of(context).scaffoldBackgroundColor,
      0.2,
    );
    if (_validateNameInput(exerciseName) != null) {
      _showSnackBar(_validateNameInput(exerciseName)!, color);
      return false;
    } else if (_validateRepsInput(reps) != null) {
      _showSnackBar(_validateRepsInput(reps)!, color);
      return false;
    } else if (_validateSetsInput(sets) != null) {
      _showSnackBar(_validateSetsInput(sets)!, color);
      return false;
    } else {
      return true;
    }
  }

  void _showSnackBar(String text, Color color) {
    _snackBarController.forward();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: FadeTransition(
          opacity: _snackBarController,
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        animation: _snackBarAnimation,
        margin: const EdgeInsets.all(20),
        elevation: 10,
      ),
    );
  }

  void _addExerciseButtonOnClick() {
    if (!_inputValidation()) return;

    _addToStream(
      day,
      ExerciseType(
        name: _exerciseNameController.text,
        sets: int.parse(_exerciseSetsController.text),
        reps: int.parse(_exerciseRepsController.text),
        weightRange: const Tuple2(0, 0),
      ),
    );
  }

  String? _validateNameInput(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter the exercise name in the name field.";
    } else if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
      return "Please enter a valid exercise name.";
    }
    return null;
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
}
