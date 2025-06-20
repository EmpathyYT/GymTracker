import 'package:flutter/material.dart';

import 'generic_dialog.dart';

Future<void> showExerciseNoteDialog(BuildContext context, String note) {
  return showGenericDialog(
    context: context,
    title: 'Exercise Notes',
    content: note.isEmpty ? 'No notes available for this exercise.' : note,
    optionsBuilder: () => {"Yes": null},
  );
}
