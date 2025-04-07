import 'package:flutter/material.dart';

class SrqPageSubtitle extends StatelessWidget {
  final bool multiple;

  const SrqPageSubtitle({
    super.key,
    required this.multiple
  });

  @override
  Widget build(BuildContext context) {
    var text = "The battlefield stirs—";
    if (!multiple) {
      text += "a warrior seeks your kinship!";
    } else {
      text += "warriors seek your kinship!";
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