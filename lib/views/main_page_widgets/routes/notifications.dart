import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/constants/cloud_contraints.dart';
import 'package:gymtracker/extensions/argument_getter_extension.dart';
import 'package:gymtracker/services/cloud/cloud_notification.dart';
import 'package:gymtracker/services/cloud/firestore_notification_controller.dart';
import 'package:gymtracker/services/cloud/firestore_user_controller.dart';

class NotificationsRoute extends StatefulWidget {
  const NotificationsRoute({super.key});

  @override
  State<NotificationsRoute> createState() => _NotificationsRouteState();
}

class _NotificationsRouteState extends State<NotificationsRoute> {
  late final List<Set> notifications;
  final _firestoreUserController = FirestoreUserController();

  @override
  Widget build(BuildContext context) {
    notifications =
        flattenNotifications(context.arguments<NotificationsType?>());
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Notifications",
            style: GoogleFonts.oswald(
              fontSize: 30,
            ),
          ),
        ),
        body: notifications.isEmpty
            ? Center(
          child: Text(
            "No new notifications",
            style: GoogleFonts.oswald(
              fontSize: 30,
            ),
          ),
        )
            : Column(
          children: [
            const Padding(padding: EdgeInsets.all(6.0)),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: const Divider(
                thickness: 0.8,
                color: Colors.grey,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  final CloudNotification notificationInfo = notification.last;
                  return FutureBuilder(
                      future: _firestoreUserController.fetchUser(
                          notificationInfo.fromUserId),
                      builder: (context, snapshot) {
                        return ListTile(
                          title: Text(
                              "Pending ${notification.first ==
                                  pendingFRQFieldName
                                  ? "Friend"
                                  : "Server"} Request",
                              style: const TextStyle(fontSize: 19)),
                          subtitle: Text("from ${snapshot.data?.name}"),
                        );
                      }
                  );
                },
              ),
            ),
          ],
        ));
  }
}

List<Set> flattenNotifications(NotificationsType? notifications) {
  final List<Set> flattened = [];
  notifications ??= {};
  notifications.forEach((key, value) {
    for (final element in value) {
      flattened.add({key, element});
    }
  });
  return flattened;
}
