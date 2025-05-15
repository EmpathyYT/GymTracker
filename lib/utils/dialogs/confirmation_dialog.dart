import 'package:flutter/material.dart';
import 'package:gymtracker/utils/dialogs/generic_dialog.dart';

Future<bool?> showConfirmationDialog(
  BuildContext context, {
  required String title,
  required String content,
  required String confirmText,
  required String cancelText,
}) async {
  return await showGenericDialog<bool>(
    context: context,
    title: title,
    content: content,
    optionsBuilder: () {
      return {cancelText: false, confirmText: true};
    },
  );
}
