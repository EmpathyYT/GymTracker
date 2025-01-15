import 'package:flutter/material.dart';
import 'package:gymtracker/constants/cloud_contraints.dart';

typedef AddUserAction = void Function();

Future<void> showUserCard({
  required BuildContext context,
  required Map<String, dynamic> userData,
  required AddUserAction addUserAction,
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
              onPressed: () => addUserAction(),
              icon: const Icon(Icons.person_add),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white12,
                  width: 1.2,
                ),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text(userData[bioFieldName] ?? 'No bio',
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w100,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
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
