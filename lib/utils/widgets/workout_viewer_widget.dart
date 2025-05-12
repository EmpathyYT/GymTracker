import 'package:flutter/material.dart';
import 'package:gymtracker/helpers/exercise_type.dart';

import 'navigation_icons_widget.dart';

class WorkoutViewerWidget extends StatefulWidget {
  final MapEntry<int, List<ExerciseType>> exercise;
  final Function(bool moveToRight) arrowNavigationCallback;

  const WorkoutViewerWidget({
    super.key,
    required this.exercise,
    required this.arrowNavigationCallback,
  });

  @override
  State<WorkoutViewerWidget> createState() => _WorkoutViewerWidgetState();
}

class _WorkoutViewerWidgetState extends State<WorkoutViewerWidget> {
  late final double mainSize;

  @override
  void initState() {
    mainSize = MediaQuery.of(context).size.width * 0.8;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: mainSize,
      child: Column(
        children: [
          Center(
            child: Text(
              "Day $day",
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                final exerciseElement = exercise[index];
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border.fromBorderSide(
                      BorderSide(
                        width: 1,
                        color: Colors.white60,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 5),
                        child: Container(
                          width: mainSize / 2,
                          decoration: const BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: Colors.white60,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Text(
                            exerciseElement.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5, bottom: 5),
                        child: Container(
                          width: mainSize / 2,
                          child: Text(
                            exerciseElement.exerciseWeightToString,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          NavigationIconsWidget(
            type: _navigationType,
            arrowNavigationCallback: (bool moveToRight) =>
                arrowNavigationCallback(
              moveToRight,
            ),
          ),
        ],
      ),
    );
  }

  List<ExerciseType> get exercise => widget.exercise.value;

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

  int get day => widget.exercise.key;
}
