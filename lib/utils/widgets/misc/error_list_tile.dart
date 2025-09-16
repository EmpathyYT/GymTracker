import 'package:flutter/material.dart';

class ErrorListTile extends StatelessWidget {
  const ErrorListTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      title: Text("The battlefield is in chaos, come back later.",
          style: TextStyle(fontSize: 19)),
    );
  }
}