import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuple/tuple.dart';

typedef FilteredExerciseFormat = Map<int, List<Tuple3>>;

class ExerciseBuilderWidget extends StatefulWidget {
  final int day;

  // int is the day of the format, useful for filtering for the day
  final Stream<FilteredExerciseFormat> exerciseStream;

  const ExerciseBuilderWidget({
    super.key,
    required this.day,
    required this.exerciseStream,
  });

  @override
  State<ExerciseBuilderWidget> createState() => _ExerciseBuilderWidgetState();
}

class _ExerciseBuilderWidgetState extends State<ExerciseBuilderWidget> {
  final ValueNotifier<List<Tuple3>> _exerciseListNotifier = ValueNotifier([]);
  late final StreamSubscription<FilteredExerciseFormat>
      _exerciseStreamSubscription;

  @override
  void initState() {
    // Subscribe to the exercise stream
    super.initState();
  }

  @override
  void dispose() {
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
            "Day 1",
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
            onTap: () {},
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
                        title: Text(exercise.item1),
                        subtitle: Text(
                          "${exercise.item2} x ${exercise.item3}",
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
            child: Center(
              child: GestureDetector(
                onTap: () {},
                child: const Icon(
                  Icons.arrow_forward,
                  size: 35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int get day => widget.day;

  Stream<FilteredExerciseFormat> get exerciseStream => widget.exerciseStream;
}
