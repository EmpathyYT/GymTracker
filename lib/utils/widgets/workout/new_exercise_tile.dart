import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:gymtracker/constants/code_constraints.dart';
import 'package:gymtracker/utils/widgets/workout/weight_range_flipper_tile.dart';
import 'package:gymtracker/utils/widgets/workout/workout_builder_widget.dart';
import 'package:gymtracker/utils/widgets/workout/workout_search_selector.dart';
import 'package:tuple/tuple.dart';

import '../../../helpers/exercise_type.dart';

class NewExerciseTile extends StatefulWidget {
  final int index;
  final bool canDelete;
  final void Function(ExerciseType, int) onAddExercise;
  final VoidCallback? onDelete;

  const NewExerciseTile({
    super.key,
    required this.index,
    required this.canDelete,
    required this.onAddExercise,
    this.onDelete,
  });

  @override
  State<NewExerciseTile> createState() => _NewExerciseTileState();
}

class _NewExerciseTileState extends State<NewExerciseTile>
    with TickerProviderStateMixin {
  final TextEditingController exerciseNameController = TextEditingController();
  final TextEditingController _lWeight = TextEditingController();
  final TextEditingController _hWeight = TextEditingController();
  final ValueNotifier<bool> _isRangeNotifier = ValueNotifier(false);
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? _sets;
  String? _reps;

  @override
  void dispose() {
    exerciseNameController.dispose();
    _lWeight.dispose();
    _hWeight.dispose();
    _isRangeNotifier.dispose();
    formKey.currentState?.dispose();
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
                    rangeNotifier: _isRangeNotifier,
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
                      focusNode: FocusNode(canRequestFocus: false),
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
                      focusNode: FocusNode(canRequestFocus: false),
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
    final String exerciseName = exerciseNameController.text.trim();
    final double? lWeight = double.tryParse(_lWeight.text.trim());
    final double? hWeight = double.tryParse(_hWeight.text.trim());
    final int? sets = int.tryParse(_sets ?? '');
    final int? reps = int.tryParse(_reps ?? '');

    final (valid, errorMessage) = workoutInputValidator(
      _isRangeNotifier.value,
      exerciseName,
      _sets ?? '',
      _reps ?? '',
      _lWeight.text,
      _hWeight.text,
    );
    if (!valid) {
      final color = darkenColor(Theme.of(context).scaffoldBackgroundColor, 0.2);
      showSnackBar(context, this, errorMessage!, color);
      return;
    } else {
      final exerciseType = ExerciseType(
        name: exerciseName,
        sets: sets!,
        reps: reps!,
        weightRange: Tuple2(lWeight ?? 0.0, hWeight ?? 0.0),
      );
      widget.onAddExercise(exerciseType, index);
    }
  }

  int get index => widget.index;

  VoidCallback? get onDelete => widget.onDelete;

  bool get canDelete => widget.canDelete;
}
