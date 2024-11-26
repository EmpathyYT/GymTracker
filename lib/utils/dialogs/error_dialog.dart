import 'package:flutter/material.dart';
import 'package:gymtracker/utils/dialogs/generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String content,
) {
  return showGenericDialog(
    context: context,
    title: "An Error Occurred",
    content: content,
    optionsBuilder: () => {
      "OK": null,
    },
  );
}