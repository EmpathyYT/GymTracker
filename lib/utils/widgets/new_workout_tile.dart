import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:gymtracker/constants/code_constraints.dart';
import 'package:gymtracker/utils/widgets/weight_range_flipper_tile.dart';
import 'package:gymtracker/utils/widgets/workout_search_selector.dart';
import 'package:tuple/tuple.dart';

import '../../helpers/exercise_type.dart';

class NewWorkoutTile extends StatefulWidget {
  final int index;
  final bool canDelete;
  final void Function(ExerciseType) onAddExercise;
  final VoidCallback? onDelete;

  const NewWorkoutTile({
    super.key,
    required this.index,
    required this.canDelete,
    required this.onAddExercise,
    this.onDelete,
  });

  @override
  State<NewWorkoutTile> createState() => _NewWorkoutTileState();
}

class _NewWorkoutTileState extends State<NewWorkoutTile>
    with TickerProviderStateMixin {
  final TextEditingController exerciseNameController = TextEditingController();
  final TextEditingController _lWeight = TextEditingController();
  final TextEditingController _hWeight = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? _sets;
  String? _reps;

  @override
  void dispose() {
    exerciseNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minVerticalPadding: 1,
      visualDensity: const VisualDensity(vertical: -4),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      title: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 150,
                  child: WorkoutSearchSelector(
                    exerciseNameController: exerciseNameController,
                    initialExercises: const [],
                    decoratorProps: const DropDownDecoratorProps(
                      decoration: InputDecoration(
                        labelText: "Search for an exercise",
                        labelStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: WeightRangeFlipperTile(
                    lWeightController: _lWeight,
                    hWeightController: _hWeight,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 70,
                    height: 50,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 18,
                        textBaseline: TextBaseline.alphabetic,
                      ),
                      decoration: const InputDecoration(
                        counterText: "",
                        labelText: "Sets",
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelStyle: TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(3)),
                        ),
                      ),
                      maxLength: 2,
                      onSaved: (value) => _sets = value,
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 70,
                    height: 50,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 18,
                        textBaseline: TextBaseline.alphabetic,
                      ),
                      decoration: const InputDecoration(
                        counterText: "",
                        labelText: "Reps",
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelStyle: TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(3)),
                        ),
                      ),
                      maxLength: 2,
                      onSaved: (value) => _reps = value,
                    ),
                  ),
                  Expanded(child: Container()),
                  Row(
                    children: [
                      canDelete
                          ? IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: onDelete!,
                          )
                          : const SizedBox.shrink(),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: submitForm,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void submitForm() {
    formKey.currentState?.save();
    final repsValidation = _validateRepsInput(_reps);
    final setsValidation = _validateSetsInput(_sets);
    final lWeightValidation = _validateWeightInput(_lWeight.text);
    final hWeightValidation = _validateWeightInput(_hWeight.text);
    final String exerciseName = exerciseNameController.text.trim();
    final double? lWeight = double.tryParse(_lWeight.text.trim());
    final double? hWeight = double.tryParse(_hWeight.text.trim());
    final int? sets = int.tryParse(_sets ?? '');
    final int? reps = int.tryParse(_reps ?? '');
    final List<String?> validationErrors =
        [
          repsValidation,
          setsValidation,
          lWeightValidation,
          hWeightValidation,
        ].where((error) => error != null).toList();
    if (validationErrors.isNotEmpty) {
      showErrorSnackBar(
        context,
        this,
        validationErrors.first!,
        darkenColor(Theme.of(context).scaffoldBackgroundColor, 0.2),
      );
    }
    if (hWeight != null && lWeight == null) {
      showErrorSnackBar(
        context,
        this,
        "Please enter a valid lower bound weight.",
        darkenColor(Theme.of(context).scaffoldBackgroundColor, 0.2),
      );
    } else if (exerciseName.isEmpty) {
      showErrorSnackBar(
        context,
        this,
        "Please enter an exercise name.",
        darkenColor(Theme.of(context).scaffoldBackgroundColor, 0.2),
      );
    } else if (_lWeight.text.isNotEmpty && _hWeight.text.isNotEmpty) {
      final rangesValidation = _validateRangesInput(
        _lWeight.text,
        _hWeight.text,
      );
      if (rangesValidation != null) {
        showErrorSnackBar(
          context,
          this,
          rangesValidation,
          darkenColor(Theme.of(context).scaffoldBackgroundColor, 0.2),
        );
      }
    } else {
      widget.onAddExercise(
        ExerciseType(
          name: exerciseName,
          sets: sets!,
          reps: reps!,
          weightRange: Tuple2<double, double>(lWeight ?? 0.0, hWeight ?? 0.0),
        ),
      );
    }
  }

  String? _validateRangesInput(String low, String high) {
    if (low.isEmpty) {
      return "Please enter a lower bound value.";
    } else if (high.isEmpty) {
      return "Please enter the upper bound value.";
    } else if (double.parse(low) > double.parse(high)) {
      return "Please enter a valid range.";
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

  int get index => widget.index;

  VoidCallback? get onDelete => widget.onDelete;

  bool get canDelete => widget.canDelete;
}
