import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/extensions/argument_getter_extension.dart';
import 'package:gymtracker/services/cloud/cloud_notification.dart';
import 'package:gymtracker/services/cloud/firestore_notification_controller.dart';
import 'package:gymtracker/services/cloud/firestore_user_controller.dart';
import 'package:tuple/tuple.dart';

import '../../../constants/code_constraints.dart';

typedef FlatNotificationType = List<Tuple2<int?, CloudNotification>>;

class NotificationsRoute extends StatefulWidget {
  const NotificationsRoute({super.key});

  @override
  State<NotificationsRoute> createState() => _NotificationsRouteState();
}

class _NotificationsRouteState extends State<NotificationsRoute> {
  FlatNotificationType? normalNotifications;
  FlatNotificationType? requestsNotifications;
  final _firestoreUserController = FirestoreUserController();

  @override
  void didChangeDependencies() {
    if (normalNotifications == null && requestsNotifications == null) {
      final (normNotifications, reqNotifications) = _flattenNotifications(
          context.arguments<Map<String, NotificationsType?>>());

      normalNotifications = normNotifications;
      normalNotifications = reqNotifications;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, res) {
        if (didPop) return;
        Navigator.of(context).pop(_expandNotifications(
            normalNotifications ?? [], requestsNotifications ?? []));
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
        body: Column(
          children: [

            const Padding(padding: EdgeInsets.all(6.0)),
            normalNotifications!.isEmpty
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
                          itemCount: normalNotifications!.length,
                          itemBuilder: (context, index) {
                            final notification = normalNotifications![index];
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
                                return _normalNotificationTile(
                                    notificationInfo, snapshot);
                              },
                            );
                          },
                        ),
                      ),
                    ],
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

(
  FlatNotificationType normalNotifications,
  FlatNotificationType requestsNotifications
) _flattenNotifications(Map<String, NotificationsType?>? notifications) {
  final FlatNotificationType flatNorm = [];
  final FlatNotificationType flatReq = [];

  notifications ??= {};
  notifications.forEach((key, value) {
    value?.forEach((key, value) {
      if (key == normalNotifsKeyName) {
        flatNorm.addAll(value);
      } else {
        flatReq.addAll(value);
      }
    });
  });
  return (flatNorm, flatReq);
}

NotificationsType _expandNotifications(FlatNotificationType normalNotifications,
    FlatNotificationType requestsNotifications) {
  return {
    normalNotifsKeyName: normalNotifications,
    requestsKeyName: requestsNotifications,
  };
}
