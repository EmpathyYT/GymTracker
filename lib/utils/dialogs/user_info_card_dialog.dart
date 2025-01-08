import 'package:flutter/material.dart';
import 'package:gymtracker/services/cloud/cloud_contraints.dart';

Future<void> showUserCard({
  required BuildContext context,
  required Map<String, dynamic> userData,
}) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Row(
          children: [
            Text(
              userData[nameFieldName],
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {

              },
              icon: const Icon(Icons.person_add),
            ),
          ],
        ),
        content: const Placeholder(),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Center(child: Text('Close')),
          ),
        ],
      );
    },
  );
}
