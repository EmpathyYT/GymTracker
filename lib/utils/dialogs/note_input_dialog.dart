import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future<String?> showNoteInputDialog({
  required BuildContext context,
  String? initialValue,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) {
      final TextEditingController exerciseNoteController =
          TextEditingController();
      exerciseNoteController.text = initialValue ?? "";
      return AlertDialog(
        title: const Text("Enter The Exercise Note"),
        content: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: TextField(
            controller: exerciseNoteController,
            decoration: InputDecoration(
              counterText: "",
              border: InputBorder.none,
              hintText: "Enter Note",
              hintStyle: GoogleFonts.montserrat(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            autofocus: true,
            minLines: 1,
            maxLines: 4,
            maxLength: 100,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(exerciseNoteController.text),
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}
