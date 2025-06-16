import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExerciseBuilderWidget extends StatefulWidget {
  final TextEditingController exerciseNameController;
  final TextEditingController exerciseSetsController;
  final TextEditingController exerciseRepsController;
  final TextEditingController exerciseLWeightController;
  final TextEditingController exerciseHWeightController;
  final ValueNotifier<bool> isRangeNotifier;

  const ExerciseBuilderWidget({
    super.key,
    required this.exerciseNameController,
    required this.exerciseSetsController,
    required this.exerciseRepsController,
    required this.exerciseLWeightController,
    required this.exerciseHWeightController,
    required this.isRangeNotifier,
  });

  @override
  State<ExerciseBuilderWidget> createState() => _ExerciseBuilderWidgetState();
}

class _ExerciseBuilderWidgetState extends State<ExerciseBuilderWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Flexible(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: TextField(
                  controller: exerciseNameController,
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
                  controller: exerciseSetsController,
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
                  controller: exerciseRepsController,
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
          valueListenable: isRangeNotifier,
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
                    () => isRangeNotifier.value = !isRangeNotifier.value,
                  ),
              child: Text(
                !isRangeNotifier.value ? "Static" : "Range",
                style: GoogleFonts.oswald(fontSize: 18),
              ),
            );
          },
        ),
        const SizedBox(height: 7),
      ],
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
                    controller: exerciseLWeightController,
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
                    controller: exerciseHWeightController,
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
                    controller: exerciseLWeightController,
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

  TextEditingController get exerciseNameController =>
      widget.exerciseNameController;

  TextEditingController get exerciseSetsController =>
      widget.exerciseSetsController;

  TextEditingController get exerciseRepsController =>
      widget.exerciseRepsController;

  TextEditingController get exerciseLWeightController =>
      widget.exerciseLWeightController;

  TextEditingController get exerciseHWeightController =>
      widget.exerciseHWeightController;

  ValueNotifier<bool> get isRangeNotifier => widget.isRangeNotifier;

}
