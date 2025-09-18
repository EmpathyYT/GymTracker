import 'package:flutter/material.dart';

import '../../../helpers/exercise_type.dart';
import '../../dialogs/exercise_edit_dialog.dart';

class ExerciseTile extends StatefulWidget {
  final ExerciseType exerciseData;
  final String uuid;
  final int index;
  final VoidCallback rebuildList;
  final Function(String) onRemoveExercise;
  final bool exerciseAdderExists;

  const ExerciseTile({
    super.key,
    required this.exerciseData,
    required this.index,
    required this.uuid,
    required this.rebuildList,
    required this.onRemoveExercise,
    required this.exerciseAdderExists,
  });

  @override
  State<ExerciseTile> createState() => _ExerciseTileState();
}

class _ExerciseTileState extends State<ExerciseTile> {
  late final bool isTop;
  late final String exerciseName;
  late final bool noWeightRestriction;

  @override
  void initState() {
    super.initState();
    isTop = index == 0;
    final weightRange = exercise.weightRange;
    noWeightRestriction = weightRange!.item1 == 0 && weightRange.item2 == 0;
    exerciseName =
        (noWeightRestriction
            ? exercise.name
            : "${exercise.name} "
                "(${exercise.exerciseWeightToString})")!;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isTop ? 20 : 0),
          topRight: Radius.circular(isTop ? 20 : 0),
          bottomLeft: Radius.circular(!isTop ? 20 : 0),
          bottomRight: Radius.circular(!isTop ? 20 : 0),
        ),
      ),
      onTap: onTap,
      child: ListTile(
        minVerticalPadding: 1,
        visualDensity: const VisualDensity(vertical: -4),
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15),
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
              onPressed: () => onRemoveExercise(uuid),
              icon: const Icon(Icons.remove_circle),
            ),
            !exerciseAdderExists
                ? ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_handle),
                )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  int get index => widget.index;

  ExerciseType get exercise => widget.exerciseData;

  String get uuid => widget.uuid;

  bool get exerciseAdderExists => widget.exerciseAdderExists;

  VoidCallback get rebuildList => widget.rebuildList;

  VoidCallback get onTap => () async {
    await showWorkoutEditDialog(context, exercise).then((_) {
      rebuildList();
      if (!mounted) return;
      FocusScope.of(context).requestFocus(FocusNode());
    });
  };

  Function(String) get onRemoveExercise => widget.onRemoveExercise;
}
