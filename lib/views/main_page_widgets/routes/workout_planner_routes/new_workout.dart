import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/constants/code_constraints.dart';
import 'package:tuple/tuple.dart';

import '../../../../utils/widgets/workout_builder_widget.dart';

class NewWorkoutRoute extends StatefulWidget {
  const NewWorkoutRoute({super.key});

  @override
  State<NewWorkoutRoute> createState() => _NewWorkoutRouteState();
}

class _NewWorkoutRouteState extends State<NewWorkoutRoute> {
  TextEditingController exerciseNameController = TextEditingController();
  TextEditingController exerciseRepsController = TextEditingController();
  TextEditingController exerciseSetsController = TextEditingController();
  final StreamController<FilteredExerciseFormat> _controller =
      StreamController();

  @override
  void initState() {
    super.initState();
    _controller.add({
      1: [],
    });
  }

  @override
  void dispose() {
    exerciseNameController.dispose();
    exerciseRepsController.dispose();
    exerciseSetsController.dispose();
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: appBarHeight,
        scrolledUnderElevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(top: appBarPadding),
          child: Text(
            "New Workout",
            style: GoogleFonts.oswald(fontSize: appBarTitleSize),
          ),
        ),
      ),
      body: Column(
        children: [
          const Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(top: 20, left: 16),
              child: Text(
                "Fill the field below to input into the table.",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          ExerciseBuilderWidget(
            exerciseStream: _controller.stream,
            day: 1, //paginate this obviously
          ),
        ],
      ),
    );
  }

  void _addToStream(int day, Tuple3 exercise) async {
    _controller.sink.add({
      ...await _controller.stream.last,
    }..update(
        day,
        (e) => e..add(exercise),
        ifAbsent: () => [exercise],
      ));
  }
}
