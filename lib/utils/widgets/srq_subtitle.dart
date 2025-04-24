import 'package:flutter/material.dart';

class SrqPageSubtitle extends StatelessWidget {
  final bool multiple;

  const SrqPageSubtitle({
    super.key,
    required this.multiple
  });

  @override
  Widget build(BuildContext context) {
    var text = "";
    if (!multiple) {
      text += "One of your kin beckons you to the front lines!";
    } else {
      text += "Your kin beckon you to the front lines.";
    }
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        color: Colors.grey,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}