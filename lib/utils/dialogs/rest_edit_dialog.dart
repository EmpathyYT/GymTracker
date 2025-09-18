import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/helpers/exercise_type.dart';

import '../../constants/code_constraints.dart';
import '../../cubit/main_page_cubit.dart';

class NoteInputDialog extends StatefulWidget {
  final ExerciseType initialRest;

  const NoteInputDialog({super.key, required this.initialRest});

  @override
  State<NoteInputDialog> createState() => _NoteInputDialogState();
}

class _NoteInputDialogState extends State<NoteInputDialog>
    with TickerProviderStateMixin {
  late final TextEditingController restPeriodController;
  late final bool isMins;

  @override
  void initState() {
    restPeriodController =
        TextEditingController()..text = initialExercise.restPeriod.toString();

    super.initState();
  }

  @override
  void dispose() {
    restPeriodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Rest"),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
        child: Column(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white60, width: 0.9),
              ),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: SizedBox(
                  width: 150,
                  child: InkWell(
                    onDoubleTap: toggleForm,
                    child: TextField(
                      textAlign: TextAlign.start,
                      controller: restPeriodController,
                      decoration: InputDecoration(
                        counterText: "",
                        labelText: isMins ? "Rest (mins)" : "Rest (secs)",
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelStyle: const TextStyle(
                          color: Colors.white60,
                          fontSize: 14,
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(3)),
                        ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            double? restPeriod = double.tryParse(restPeriodController.text);
            if (restPeriod == null || restPeriod <= 0) {
              showSnackBar(
                context,
                this,
                "Please enter a valid rest period.",
                darkenBackgroundColor(context),
              );
              return;
            }
            restPeriod = double.parse(restPeriod.toStringAsPrecision(2));
            if (isMins) {
              restPeriod *= 60;
            }

            if (restPeriod > 3600) {
              showSnackBar(
                context,
                this,
                "Rest period cannot exceed 60 minutes.",
                darkenBackgroundColor(context),
              );
              return;
            }

            Navigator.of(context).pop();
          },
          child: const Text("OK"),
        ),
      ],
      scrollable: true,
    );
  }

  VoidCallback get toggleForm => () {
    setState(() {
      isMins = !isMins;
    });
  };

  ExerciseType get initialExercise => widget.initialRest;
}

/// This dialog directly alters the workout information using the
/// shallow copy of the exercise, removing the need for a return.
Future<void> showRestEditDialog(
  BuildContext context,
  ExerciseType exercise,
) async {
  await showDialog<ExerciseType?>(
    context: context,
    builder:
        (_) => BlocProvider.value(
          value: context.read<MainPageCubit>(),
          child: ScaffoldMessenger(
            child: Builder(
              builder: (context) {
                return Scaffold(
                  backgroundColor: Colors.transparent,
                  body: NoteInputDialog(initialRest: exercise),
                );
              },
            ),
          ),
        ),
  );
}
