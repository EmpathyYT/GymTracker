import 'package:flutter/material.dart';

import 'generic_dialog.dart';

Future<void> showForgotPasswordDialog(
    BuildContext context,
    ) {
  return showGenericDialog(
    context: context,
    title: "Reset Link Sent",
    content: "We have sent a reset link to your email.",
    optionsBuilder: () => {
      "OK": null,
    },
  );
}
