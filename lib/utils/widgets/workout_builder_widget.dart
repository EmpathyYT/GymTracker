import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/utils/dialogs/exercise_edit_dialog.dart';
import 'package:gymtracker/utils/widgets/exercise_builder_widget.dart';
import 'package:gymtracker/utils/widgets/navigation_icons_widget.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';

import '../../constants/code_constraints.dart';
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
          Container(
            width: MediaQuery.of(context).size.width * 0.6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white60, width: 0.9),
            ),
            child: ExerciseBuilderWidget(
              exerciseNameController: _exerciseNameController,
              exerciseSetsController: _exerciseSetsController,
              exerciseRepsController: _exerciseRepsController,
              exerciseLWeightController: _exerciseLWeightController,
              exerciseHWeightController: _exerciseHWeightController,
              isRangeNotifier: _isRangeNotifier,
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
                  return ReorderableListView.builder(
                    proxyDecorator: (child, index, animation) {
                      return Material(
                        elevation: 8,
                        color: Colors.transparent,
                        child: ScaleTransition(
                          scale: animation.drive(Tween(begin: 1.0, end: 0.9)),
                          child: child,
                        ),
                      );
                    },
                    itemCount: value.length,
                    onReorder: (oldIndex, newIndex) {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      final item = value.removeAt(oldIndex);
                      value.insert(newIndex, item);
                      _removeFromStream(day, item.item1);
                      _addToStream(
                        day,
                        item.item2,
                        uid: item.item1,
                        index: newIndex,
                      );
                    },
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

  Widget buildListTile(int index, List<Tuple2<String, ExerciseType>> value) {
    final ExerciseType exercise = value[index].item2;
    final String uuid = value[index].item1;
    final noWeight =
        exercise.weightRange.item1 == 0 && exercise.weightRange.item2 == 0;

    final exerciseName =
        noWeight
            ? exercise.name
            : "${exercise.name} "
                "(${exercise.exerciseWeightToString})";

    onTap() async {
      await showWorkoutEditDialog(context, exercise).then((_) {
        if (!mounted) return;
        FocusScope.of(context).requestFocus(FocusNode());
      });
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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => _removeFromStream(day, uuid),
            icon: const Icon(Icons.remove_circle),
          ),
          ReorderableDragStartListener(
            key: ValueKey(draggingIndex == index),
            index: index,
            child: const Icon(Icons.drag_handle),
          ),
        ],
      ),
    );
    if (index != 0 && index != value.length - 1) {
      return copyListTileForTap(initWidget, onTap, uuid, index);
    }
    final isTop = index == 0;

    return InkWell(
      key: ValueKey("$uuid ${index == draggingIndex}"),
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

  ListTile copyListTileForTap(
    ListTile tile,
    Function onTap,
    String uuid,
    int index,
  ) {
    return ListTile(
      key: ValueKey("$uuid ${index == draggingIndex}"),
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

  void _addExerciseButtonOnClick() {
    final (res, errorMessage) = workoutInputValidator(
      _isRangeNotifier,
      _exerciseNameController.text.trim(),
      _exerciseSetsController.text.trim(),
      _exerciseRepsController.text.trim(),
      _exerciseLWeightController.text.trim(),
      _exerciseHWeightController.text.trim(),
    );

    if (res == false) {
      final color = darkenColor(Theme.of(context).scaffoldBackgroundColor, 0.2);
      showErrorSnackBar(context, this, errorMessage!, color);
      return;
    }

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

void showErrorSnackBar(
  BuildContext context,
  TickerProvider vsync,
  String message,
  Color color,
) {
  if (ScaffoldMessenger.of(context).mounted) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
  }

  final controller = AnimationController(
    vsync: vsync,
    duration: const Duration(milliseconds: 500),
  );

  final animation = CurvedAnimation(parent: controller, curve: Curves.easeInOut)
    ..addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        await Future.delayed(
          const Duration(milliseconds: 2500),
          () => controller.reverse(),
        );
      }
    });

  controller.forward();
  ScaffoldMessenger.of(context)
      .showSnackBar(
        SnackBar(
          content: FadeTransition(
            opacity: controller,
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          duration: const Duration(seconds: 3),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          animation: animation,
          margin: const EdgeInsets.all(20),
          elevation: 10,
        ),
      )
      .closed
      .then((_) {
        controller.dispose();
      });
}

(bool, String?) workoutInputValidator(
  ValueNotifier<bool> isRangeNotifier,
  exerciseName,
  sets,
  reps,
  lWeight,
  hWeight,
) {
  if (_validateNameInput(exerciseName) != null) {
    return (false, _validateNameInput(exerciseName));
  } else if (_validateRepsInput(reps) != null) {
    return (false, _validateRepsInput(reps));
  } else if (_validateSetsInput(sets) != null) {
    return (false, _validateSetsInput(sets));
  } else if (_validateWeightInput(lWeight) != null) {
    return (false, _validateWeightInput(lWeight));
  } else if (isRangeNotifier.value && _validateWeightInput(hWeight) != null) {
    return (false, _validateWeightInput(hWeight));
  } else if (lWeight.isNotEmpty &&
      hWeight.isNotEmpty &&
      _validateRangesInput(lWeight, hWeight) != null) {
    return (false, _validateRangesInput(lWeight, hWeight));
  } else {
    return (true, null);
  }
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
