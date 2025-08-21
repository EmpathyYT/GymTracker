import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/extensions/date_time_extension.dart';
import 'package:gymtracker/utils/widgets/workout_search_selector.dart';

import '../../constants/code_constraints.dart';
import '../../cubit/main_page_cubit.dart';

class PrSchedulerDialog extends StatefulWidget {
  final TextEditingController prNameController;
  final TextEditingController prWeightController;
  final DateTime prDate;
  final TimeOfDay prTime;

  const PrSchedulerDialog({
    super.key,
    required this.prNameController,
    required this.prWeightController,
    required this.prDate,
    required this.prTime,
  });

  @override
  State<PrSchedulerDialog> createState() => _PrSchedulerDialogState();
}

class _PrSchedulerDialogState extends State<PrSchedulerDialog>
    with TickerProviderStateMixin {
  // Collecting all controllers to dispose them after the dialog is closed
  // This is necessary to avoid memory leaks and ensure proper cleanup
  final controllerLists = <AnimationController>[];

  @override
  void dispose() {
    for (var controller in controllerLists) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var mainWidth = MediaQuery.of(context).size.width * 0.8;
    return AlertDialog(
      title: const Text("Enter PR Details"),
      content: SizedBox(
        width: mainWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...richTextList,
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(color: Colors.white60),
            ),
            workoutSearchSelector,
            const SizedBox(height: 16),
            workoutTextField,
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        TextButton(onPressed: _okButtonCallback, child: const Text("OK")),
      ],
    );
  }


  /// Handles the OK button action for scheduling a PR.
  ///
  /// Validation:
  /// - Ensures the target weight is valid via `validateWeightInput(...)`.
  /// - Ensures the PR name is not empty.
  ///
  /// On success:
  /// - Calls `MainPageCubit.addPr(...)` with the combined UTC date-time and
  ///   parsed target weight.
  /// - Clears the text controllers and pops the dialog returning `true`.
  ///
  /// On error:
  /// - Displays a snackbar with either a validation message or a generic error.
  ///
  /// Side effects:
  /// - Tracks created snackbar `AnimationController`s in `controllerLists`
  ///   for proper disposal.
  /// - Interacts with navigation by popping the current route on success.
  ///
  /// Returns:
  /// - A `Future<void>` that completes when the flow finishes.
  Future<void> _okButtonCallback() async {
    final weightError = validateWeightInput(prWeightController.text);
    if (weightError != null || prNameController.text.isEmpty) {
      controllerLists.add(
        showSnackBar(
          context,
          this,
          weightError ?? "Please enter the target weight for the PR.",
          darkenBackgroundColor(context),
        ),
      );
    } else {
      try {
        await context.read<MainPageCubit>().addPr(
          prNameController.text,
          prDate.copyWith(hour: prTime.hour, minute: prTime.minute).toUtc(),
          double.parse(prWeightController.text),
        );
        if (!mounted) return;
        prNameController.clear();
        prWeightController.clear();
        Navigator.pop(context, true);
      } catch (e) {
        controllerLists.add(
          showSnackBar(
            context,
            this,
            "An unexpected error occurred while scheduling the PR.",
            darkenBackgroundColor(context),
          ),
        );
      }
    }
  }

  WorkoutSearchSelector get workoutSearchSelector => WorkoutSearchSelector(
    exerciseNameController: prNameController,
    initialExercises: const [
      "Barbell Conventional Deadlift",
      "Barbell Sumo Deadlift",
      "Barbell Bench Press",
      "Barbell High Bar Back Squat",
      "Barbell Low Bar Back Squat",
      "Barbell Overhead Press",
    ],
    isPr: true,
  );

  TextField get workoutTextField => TextField(
    controller: prWeightController,
    decoration: InputDecoration(
      counterText: "",
      border: InputBorder.none,
      hintText: "Target Weight",
      hintStyle: GoogleFonts.montserrat(color: Colors.grey, fontSize: 16),
    ),
    autofocus: true,
    minLines: 1,
    maxLines: 1,
    maxLength: 7,
    keyboardType: const TextInputType.numberWithOptions(
      decimal: true,
      signed: false,
    ),
  );

  List<Text> get richTextList => [
    Text.rich(
      TextSpan(
        text: "Date: ",
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        children: [
          TextSpan(
            text: prDate.toDateWithoutTime(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ),
    Text.rich(
      TextSpan(
        text: "Time: ",
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        children: [
          TextSpan(
            text: prTime.format(context),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ),
  ];

  TimeOfDay get prTime => widget.prTime;

  TextEditingController get prNameController => widget.prNameController;

  TextEditingController get prWeightController => widget.prWeightController;

  DateTime get prDate => widget.prDate;
}

Future<void> showPrSchedulerDialog(
  BuildContext context, {
  required TextEditingController prNameController,
  required TextEditingController prDescriptionController,
  required DateTime prDate,
  required TimeOfDay prTime,
}) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext _) {
      return BlocProvider.value(
        value: context.read<MainPageCubit>(),
        child: MediaQuery.removeViewInsets(
          removeBottom: true,
          context: context,
          child: Builder(
            builder: (_) {
              return Scaffold(
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.transparent,
                body: PrSchedulerDialog(
                  prNameController: prNameController,
                  prWeightController: prDescriptionController,
                  prDate: prDate,
                  prTime: prTime,
                ),
              );
            },
          ),
        ),
      );
    },
  );
}
