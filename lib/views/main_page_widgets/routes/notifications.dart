import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/extensions/argument_getter_extension.dart';
import 'package:gymtracker/services/cloud/cloud_notification.dart';
import 'package:gymtracker/services/cloud/firestore_notification_controller.dart';
import 'package:gymtracker/services/cloud/firestore_user_controller.dart';
import 'package:tuple/tuple.dart';

import '../../../constants/code_constraints.dart';
import '../../../utils/widgets/notification_tile.dart';

class NotificationsRoute extends StatefulWidget {
  const NotificationsRoute({super.key});

  @override
  State<NotificationsRoute> createState() => _NotificationsRouteState();
}

class _NotificationsRouteState extends State<NotificationsRoute> {
  List<Tuple2<int?, CloudNotification>>? notifications;
  final _firestoreUserController = FirestoreUserController();

  @override
  void didChangeDependencies() {
    notifications ??= _flattenNotifications(
        context.arguments<Map<String, NotificationsType?>>());
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, res) {
        if (didPop) return;
        Navigator.of(context).pop(_expandNotifications(notifications ?? []));
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Notifications",
            style: GoogleFonts.oswald(
              fontSize: 30,
            ),
          ),
        ),
        body: notifications!.isEmpty
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
                      itemCount: notifications!.length,
                      itemBuilder: (context, index) {
                        final notification = notifications![index];
                        final CloudNotification notificationInfo =
                            notification.item2;
                        return FutureBuilder(
                          future: _firestoreUserController
                              .fetchUser(notificationInfo.fromUserId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState !=
                                ConnectionState.done) {
                              return _loadingListTile();
                            } else if (snapshot.hasError) {
                              return _errorListTile();
                            }
                            return notificationInfo.type != 2
                                ? AnimatedNotificationTile(
                                    notificationInfo: notificationInfo,
                                    index: index,
                                    snapshot: snapshot,
                                    onRemove: () {
                                      setState(() {
                                        notifications!.removeAt(index);
                                      });
                                    },
                                  )
                                : _normalNotificationTile(
                                    notificationInfo, snapshot);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  ListTile _loadingListTile() {
    return const ListTile(
      title: Text("Loading Notification, please wait...",
          style: TextStyle(fontSize: 19)),
    );
  }

  ListTile _errorListTile() {
    return const ListTile(
      title: Text("Error loading notification, please try again later",
          style: TextStyle(fontSize: 19)),
    );
  }
}

ListTile _normalNotificationTile(
    CloudNotification notificationInfo, AsyncSnapshot snapshot) {
  return ListTile(
    title: Text(
      notificationInfo.message,
      style: const TextStyle(fontSize: 19),
    ),
  );
}

List<Tuple2<int?, CloudNotification>> _flattenNotifications(
    Map<String, NotificationsType?>? notifications) {
  final List<Tuple2<int?, CloudNotification>> flattened = [];
  notifications ??= {};
  notifications.forEach((key, value) {
    value?.forEach((key, value) {
      flattened.addAll(value);
    });
  });
  return flattened;
}

NotificationsType _expandNotifications(
    List<Tuple2<int?, CloudNotification>> notifications) {
  final NotificationsType expanded = {
    normalNotifsKeyName: [],
    requestsKeyName: [],
  };

  for (var element in notifications) {
    final int? type = element.item1;
    if (type == null) {
      expanded[normalNotifsKeyName]?.add(element);
    } else {
      expanded[requestsKeyName]?.add(element);
    }
  }

  return expanded;
}
