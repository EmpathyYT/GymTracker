import 'package:flutter/material.dart';
import 'package:gymtracker/services/cloud/cloud_user.dart';

typedef AddUserAction = void Function(BuildContext context);

Future<void> showUserCard({
  required BuildContext context,
  required CloudUser user,
  AddUserAction? userAction,
  Icon? userIcon,
}) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Row(
          children: [
            Text(
              user.name,
              style: const TextStyle(
                fontSize: 26,
              ),
            ),
            const Spacer(),
            userAction != null
                ? IconButton(
                    onPressed: () => userAction(context),
                    icon: userIcon!,
                  )
                : const SizedBox.shrink(),
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
              child: Text(
                (user.bio).isNotEmpty
                    ? user.bio
                    : "The Warrior's story is yet to be written...",
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 17,
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
