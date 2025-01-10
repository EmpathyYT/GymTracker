import 'package:flutter/material.dart';
import 'package:gymtracker/utils/dialogs/generic_dialog.dart';

Future<void> showSuccessDialog(
    BuildContext context,
    String title,
    String content,
) {
  return showGenericDialog(
      context: context,
      title: title,
      content: content,
      optionsBuilder: () => {
        "OK": null,
      }
  );
}
