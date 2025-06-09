import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/utils/dialogs/note_input_dialog.dart';
import 'package:gymtracker/utils/widgets/navigation_icons_widget.dart';
import 'package:gymtracker/views/main_page_widgets/profile_viewer.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import '../../helpers/exercise_type.dart';
import '../../services/cloud/cloud_workout.dart';

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
  final ValueNotifier<List<ExerciseType>> _exerciseListNotifier = ValueNotifier(
    [],
  );
  final ValueNotifier<bool> _isRangeNotifier = ValueNotifier(false);
  final TextEditingController _exerciseNameController = TextEditingController();
  final TextEditingController _exerciseRepsController = TextEditingController();
  final TextEditingController _exerciseSetsController = TextEditingController();
  final TextEditingController _exerciseLWeightController =
      TextEditingController();
  final TextEditingController _exerciseHWeightController =
      TextEditingController();
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
        _exerciseLWeightController.clear();
        _exerciseHWeightController.clear();
      }
    });
    _snackBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _snackBarAnimation = CurvedAnimation(
      parent: _snackBarController,
      curve: Curves.easeInOut,
    )..addStatusListener((status) async {
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

  //todo add lb/kg internal converter segment button and switch the r/s buttons to a single button
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
          Container(
            width: MediaQuery.of(context).size.width * 0.6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white60, width: 0.9),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
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
                    Text("X", style: GoogleFonts.oswald(fontSize: 15)),
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
                    Text("X", style: GoogleFonts.oswald(fontSize: 15)),
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
                ValueListenableBuilder<bool>(
                  valueListenable: _isRangeNotifier,
                  builder: (context, value, _) {
                    return _rangeOrSingle(value);
                  },
                ),
                const SizedBox(height: 10),
                StatefulBuilder(
                  builder: (context, setState) {
                    return TextButton(
                      onPressed:
                          () => setState(
                            () =>
                                _isRangeNotifier.value =
                                    !_isRangeNotifier.value,
                          ),
                      child: Text(
                        !_isRangeNotifier.value ? "Static" : "Range",
                        style: GoogleFonts.oswald(fontSize: 18),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 7),
              ],
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => _addExerciseButtonOnClick(),
            child: const Icon(Icons.arrow_downward, size: 35),
          ),
          const SizedBox(height: 20),
          Flexible(
            flex: 7,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.75,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white60, width: 0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ValueListenableBuilder(
                valueListenable: _exerciseListNotifier,
                builder: (context, value, child) {
                  return ListView.builder(
                    itemCount: value.length,
                    itemBuilder: (context, index) {
                      return buildListTile(index, value);
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
              arrowNavigationCallback:
                  (bool moveToRight) => arrowNavigationCallback(moveToRight),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildListTile(int index, List value) {
    final ExerciseType exercise = value[index];
    final noWeight =
        exercise.weightRange.item1 == 0 && exercise.weightRange.item2 == 0;

    final exerciseName =
        noWeight
            ? exercise.name
            : "${exercise.name} "
                "(${exercise.exerciseWeightToString})";

    onTap() async {
      final data = await showNoteInputDialog(
        context: context,
        initialValue: exercise.notes,
      );

      if (data != null) {
        exercise.notes = data;
        _streamEventCallback(_exerciseController.valueOrNull ?? {});
      }
    }
    
    final initWidget = ListTile(
      dense: true,
      contentPadding: const EdgeInsets.fromLTRB(15, 2, 0, 0),
      title: Text(
        exerciseName,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        "${exercise.sets} x ${exercise.reps}",
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: IconButton(
        onPressed: () => _removeFromStream(day, exercise),
        icon: const Icon(Icons.remove_circle),
      ),
    );
    if (index != 0 && index != value.length - 1) {
      return copyListTileForTap(initWidget, onTap);
    }
    final isTop = index == 0;

    return InkWell(
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isTop ? 20 : 0),
          topRight: Radius.circular(isTop ? 20 : 0),
          bottomLeft: Radius.circular(!isTop ? 20 : 0),
          bottomRight: Radius.circular(!isTop ? 20 : 0),
        ),
      ),
      onTap: () => onTap(),
      child: initWidget,
    );
  }

  Widget _rangeOrSingle(bool val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children:
          val
              ? [
                SizedBox(
                  width: 50,
                  child: TextField(
                    controller: _exerciseLWeightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      counterText: "",
                      border: InputBorder.none,
                      hintText: "Low",
                      hintStyle: GoogleFonts.montserrat(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    maxLength: 7,
                  ),
                ),
                SizedBox(
                  width: 10,
                  child: Text("-", style: GoogleFonts.oswald(fontSize: 30)),
                ),
                SizedBox(
                  width: 50,
                  child: TextField(
                    controller: _exerciseHWeightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      counterText: "",
                      border: InputBorder.none,
                      hintText: "High",
                      hintStyle: GoogleFonts.montserrat(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    maxLength: 7,
                  ),
                ),
              ]
              : [
                SizedBox(
                  width: 100,
                  child: TextField(
                    textAlign: TextAlign.center,
                    controller: _exerciseLWeightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      counterText: "",
                      border: InputBorder.none,
                      hintText: "Weight",
                      hintStyle: GoogleFonts.montserrat(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    maxLength: 7,
                  ),
                ),
              ],
    );
  }

  ListTile copyListTileForTap(ListTile tile, Function onTap) {
    return ListTile(
      title: tile.title,
      dense: tile.dense,
      contentPadding: tile.contentPadding,
      subtitle: tile.subtitle,
      leading: tile.leading,
      trailing: tile.trailing,
      onTap: () => onTap(),
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
    _exerciseController.add(
      {..._exerciseController.valueOrNull ?? {}}
        ..update(day, (e) => e..add(exercise), ifAbsent: () => [exercise]),
    );
  }

  void _removeFromStream(int day, ExerciseType exercise) {
    _exerciseController.add(
      {..._exerciseController.valueOrNull ?? {}}
        ..update(day, (e) => e..remove(exercise), ifAbsent: () => []),
    );
  }

  bool _inputValidation() {
    final exerciseName = _exerciseNameController.text.trim();
    final sets = _exerciseSetsController.text.trim();
    final reps = _exerciseRepsController.text.trim();
    final lWeight = _exerciseLWeightController.text.trim();
    final hWeight = _exerciseHWeightController.text.trim();

    final color = darkenColor(Theme.of(context).scaffoldBackgroundColor, 0.2);
    if (_validateNameInput(exerciseName) != null) {
      _showSnackBar(_validateNameInput(exerciseName)!, color);
      return false;
    } else if (_validateRepsInput(reps) != null) {
      _showSnackBar(_validateRepsInput(reps)!, color);
      return false;
    } else if (_validateSetsInput(sets) != null) {
      _showSnackBar(_validateSetsInput(sets)!, color);
      return false;
    } else if (_validateWeightInput(lWeight) != null) {
      _showSnackBar(_validateWeightInput(lWeight)!, color);
      return false;
    } else if (_isRangeNotifier.value &&
        _validateWeightInput(hWeight) != null) {
      _showSnackBar(_validateWeightInput(hWeight)!, color);
      return false;
    } else if (lWeight.isNotEmpty &&
        hWeight.isNotEmpty &&
        _validateRangesInput(lWeight, hWeight) != null) {
      _showSnackBar(_validateRangesInput(lWeight, hWeight)!, color);
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
            style: const TextStyle(color: Colors.white, fontSize: 16),
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

    final lWeight =
        _exerciseLWeightController.text.trim().isEmpty
            ? "0"
            : _exerciseLWeightController.text.trim();

    final hWeight =
        _isRangeNotifier.value ? _exerciseHWeightController.text.trim() : "0";

    _addToStream(
      day,
      ExerciseType(
        name: _exerciseNameController.text.trim(),
        sets: int.parse(_exerciseSetsController.text.trim()),
        reps: int.parse(_exerciseRepsController.text.trim()),
        weightRange: Tuple2(double.parse(lWeight), double.parse(hWeight)),
      ),
    );
  }

  String? _validateNameInput(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter the exercise name in the name field.";
    } else if (!RegExp(r'^[a-zA-Z !@#$%^&*()1-9\-,.<>=+_]+$').hasMatch(value)) {
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

  String? _validateWeightInput(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    } else if (double.tryParse(value) == null) {
      return "Please enter a valid number in the weight field(s).";
    } else {
      if (value.split('.')[1].length > 2) {
        return "Please enter a valid number with up to 2 decimal places in the weight field(s).";
      } else if (value.split('.').length > 2) {
        return "Please enter a valid number in the weight field(s).";
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
