import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/extensions/date_time_extension.dart';

class PrSchedulerDialog extends StatefulWidget {
  final TextEditingController prNameController;
  final TextEditingController prDescriptionController;
  final DateTime prDate;

  const PrSchedulerDialog({
    super.key,
    required this.prNameController,
    required this.prDescriptionController,
    required this.prDate,
  });

  @override
  State<PrSchedulerDialog> createState() => _PrSchedulerDialogState();
}

class _PrSchedulerDialogState extends State<PrSchedulerDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Enter PR Details"),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                text: "PR Date: ",
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
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(color: Colors.white60),
            ),
            TextField(
              controller: prNameController,
              decoration: InputDecoration(
                counterText: "",
                border: InputBorder.none,
                hintText: "PR Title",
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
                hintText: "PR Target Weight",
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
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("OK"),
        ),
      ],
      scrollable: true,
    );
  }

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
}) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return PrSchedulerDialog(
        prNameController: prNameController,
        prDescriptionController: prDescriptionController,
        prDate: prDate,
      );
    },
  );
}
