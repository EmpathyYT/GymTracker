import 'package:flutter/material.dart';

class KrqPageSubtitle extends StatelessWidget {
  final bool multiple;

  const KrqPageSubtitle({
    super.key,
    required this.multiple
  });

  @override
  Widget build(BuildContext context) {
    var text = "";
    if (!multiple) {
      text = "A lone squad calls for a worthy warrior.";
    } else {
      text += "Allies call across the void—respond to their kinship summons.";
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