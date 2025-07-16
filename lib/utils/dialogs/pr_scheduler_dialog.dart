import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/extensions/date_time_extension.dart';
import 'package:gymtracker/utils/widgets/workout_builder_widget.dart';

import '../../constants/code_constraints.dart';

class PrSchedulerDialog extends StatefulWidget {
  final TextEditingController prNameController;
  final TextEditingController prDescriptionController;
  final DateTime prDate;
  final TimeOfDay prTime;

  const PrSchedulerDialog({
    super.key,
    required this.prNameController,
    required this.prDescriptionController,
    required this.prDate,
    required this.prTime,
  });

  @override
  State<PrSchedulerDialog> createState() => _PrSchedulerDialogState();
}

class _PrSchedulerDialogState extends State<PrSchedulerDialog>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Enter PR Details"),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  text: "Date: ",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text: prDate.toDateWithoutTime(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Text.rich(
                TextSpan(
                  text: "Time: ",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                  children: [
                    TextSpan(
                      text: prTime.format(context),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(color: Colors.white60),
              ),
              TextField(
                controller: prNameController,
                decoration: InputDecoration(
                  counterText: "",
                  border: InputBorder.none,
                  hintText: "Title",
                  hintStyle: GoogleFonts.montserrat(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                autofocus: true,
                minLines: 1,
                maxLines: 3,
                maxLength: 50,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: prDescriptionController,
                decoration: InputDecoration(
                  counterText: "",
                  border: InputBorder.none,
                  hintText: "Target Weight",
                  hintStyle: GoogleFonts.montserrat(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                autofocus: true,
                minLines: 1,
                maxLines: 1,
                maxLength: 7,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: false,
                ),
              ),
            ],
          ),
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
            final weightError = _validateWeightInput(
              prDescriptionController.text,
            );
            if (weightError != null ||
                prNameController.text.isEmpty) {
              showErrorSnackBar(
                context,
                this,
                weightError ?? "Please enter the target weight for the PR.",
                darkenColor(Theme.of(context).scaffoldBackgroundColor, 0.2),
              );
            } else {
              Navigator.pop(context);
            }
          },
          child: const Text("OK"),
        ),
      ],
    );
  }

  String? _validateWeightInput(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    } else if (double.tryParse(value) == null) {
      return "Please enter a valid number in the weight field(s).";
    } else {
      if (value.contains('.') && value.split('.')[1].length > 2) {
        return "Please enter a valid number with up to 2 decimal places in the weight field(s).";
      } else if (double.parse(value) < 1) {
        return "Please enter a positive number greater than 0 in the weight field(s).";
      } else if (double.parse(value) > 2000) {
        return "Calm down hulk.";
      }
    }
    return null;
  }

  TimeOfDay get prTime => widget.prTime;

  TextEditingController get prNameController => widget.prNameController;

  TextEditingController get prDescriptionController =>
      widget.prDescriptionController;

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
    builder: (BuildContext context) {
      return PrSchedulerDialog(
        prNameController: prNameController,
        prDescriptionController: prDescriptionController,
        prDate: prDate,
        prTime: prTime,
      );
    },
  );
}
