import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/constants/cloud_contraints.dart';
import 'package:gymtracker/extensions/argument_getter_extension.dart';

class NotificationsRoute extends StatefulWidget {
  const NotificationsRoute({super.key});

  @override
  State<NotificationsRoute> createState() => _NotificationsRouteState();
}

class _NotificationsRouteState extends State<NotificationsRoute> {
  late final List<Set<String>> notifications;

  @override
  @override
  void initState() {
    //notifications =
        //flattenNotifications(context.arguments<Map<String, List<String>>>());
    notifications = [
      {pendingFRQFieldName, "friend"},
      {pendingSquadReqFieldName, "server"},
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                        return ListTile(
                          title: Text(
                              "Pending ${notification.first == pendingFRQFieldName
                                  ? "Friend" : "Server"} Request",
                              style: const TextStyle(fontSize: 19)
                          ),
                          subtitle: Text(notification.last),
                        );
                      },
                    ),
                ),
              ],
            ));
  }
}

List<Set<String>> flattenNotifications(
    Map<String, List<String>?>? notifications) {
  final List<Set<String>> flattened = [];
  notifications ??= {};
  notifications.forEach((key, value) {
    value ??= [];
    for (final element in value) {
      flattened.add({key, element});
    }
  });
  return flattened;
}

//TODO create a new collection for friend requests and make the user can have access to.
//TODO also make a public info collection to separate public info from private.

