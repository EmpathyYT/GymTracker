import 'package:flutter/material.dart';

class LoadingListTile extends StatelessWidget {
  const LoadingListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      title: Text("Cracking the wax seal, retrieving your message.",
          style: TextStyle(fontSize: 19)),
    );
  }
}
