import 'package:flutter/material.dart';
import 'package:gymtracker/utils/widgets/workout_builder_widget.dart';

class WorkoutViewerWidget extends StatefulWidget {
  final FilteredExerciseFormat exercise;

  const WorkoutViewerWidget({
    super.key,
    required this.exercise,
  });

  @override
  State<WorkoutViewerWidget> createState() => _WorkoutViewerWidgetState();
}

class _WorkoutViewerWidgetState extends State<WorkoutViewerWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Expanded(
        child: ListView.builder(
          itemBuilder: (context, index) {},
        ),
      ),
    );
  }
}
