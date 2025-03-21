import 'package:flutter/material.dart';

class KrqPageSubtitle extends StatelessWidget {
  final bool multiple;

  const KrqPageSubtitle({
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