import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gymtracker/extensions/remove_decimal_if_necessary.dart';
import 'package:gymtracker/helpers/exercise_type.dart';

class RestPeriodTile extends StatefulWidget {
  final int index;
  final ExerciseType restData;
  final String uuid;
  final bool exerciseAdderExists;
  final Function(String) onRemoveExercise;

  const RestPeriodTile({
    super.key,
    required this.index,
    required this.restData,
    required this.uuid,
    required this.exerciseAdderExists,
    required this.onRemoveExercise,
  });

  @override
  State<RestPeriodTile> createState() => _RestPeriodTileState();
}

class _RestPeriodTileState extends State<RestPeriodTile> {
  late bool isTop;
  late bool isMins;
  late double restPeriod;

  @override
  void initState() {
    super.initState();
    isTop = index == 0;
    restPeriod = exercise.restPeriod ?? 0;
    isMins = exercise.isInMins ?? false;
    if (isMins) restPeriod /= 60;
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
        title: const Text(
          "Rest Period",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          "${restPeriod.removeDecimalIfNecessary} ${isMins ? "minutes (${(restPeriod * 60).ceil()} seconds)" : "seconds"}",
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

  bool get exerciseAdderExists => widget.exerciseAdderExists;

  String get uuid => widget.uuid;

  ExerciseType get exercise => widget.restData;

  int get index => widget.index;

  Function(String) get onRemoveExercise => widget.onRemoveExercise;

  VoidCallback get onTap => () {
    log("message");
  };
}
