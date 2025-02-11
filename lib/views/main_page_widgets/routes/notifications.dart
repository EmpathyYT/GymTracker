import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/extensions/hour_minute_second_format.dart';
import 'package:gymtracker/services/cloud/cloud_notification.dart';
import 'package:gymtracker/services/cloud/firestore_notification_controller.dart';
import 'package:gymtracker/services/cloud/firestore_user_controller.dart';
import 'package:gymtracker/utils/widgets/stack_column_flipper.dart';
import 'package:gymtracker/utils/widgets/universal_card.dart';
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
      // final (normNotifications, reqNotifications) = _flattenNotifications(
      //     context.arguments<Map<String, NotificationsType?>>());

      normalNotifications = [
        Tuple2(null, CloudNotification.testingNotif(Timestamp.now())),
        Tuple2(
            null,
            CloudNotification.testingNotif(
                Timestamp.fromDate(DateTime.utc(2023)))),
        Tuple2(null, CloudNotification.testingNotif(Timestamp.fromDate(DateTime.utc(2022)))),
      ];

       normalNotifications
          ?.sort((a, b) => a.item2.time.compareTo(b.item2.time));

      // normalNotifications = normNotifications;
      // requestsNotifications = reqNotifications;
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
        body: StackColumnFlipper(
          flipToColumn: normalNotifications!.isNotEmpty,
          commonWidgets: [
            const Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
            ),
            UniversalCard(
              isNewRequests: normalNotifications!.isNotEmpty,
              iconCallBack: () {},
            ),
            const Padding(padding: EdgeInsets.all(2.0)),
            Container(
              padding: const EdgeInsets.only(
                top: 3,
                bottom: 3,
                left: 5,
                right: 5,
              ),
              child: const Divider(
                thickness: 0.9,
                color: Colors.white60,
              ),
            ),
          ],
          ifStack: [
            Center(
              child: Text(
                "No New Notifications",
                style: GoogleFonts.oswald(
                  fontSize: 35,
                ),
              ),
            )
          ],
          ifColumn: [
            Expanded(
              child: ListView.builder(
                itemCount: normalNotifications!.length,
                itemBuilder: (context, index) {
                  final notification = normalNotifications![index];
                  final CloudNotification notificationInfo = notification.item2;
                  return FutureBuilder(
                    future: _firestoreUserController
                        .fetchUser(notificationInfo.fromUserId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
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
      style: const TextStyle(fontSize: 22),
    ),
    subtitle: Text(
      "Today at ${notificationInfo.time.toDate().toLocal().toHourMinute()}",
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 15,
      ),
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

// List<Widget> _sortNotificationsByDate(FlatNotificationType notifications) {
//   final List<Widget> widgetList = [];
//   final sortedNotifications = notifications
//     ..sort((a, b) => a.item2.time.compareTo(b.item2.time));
//
//   for (final notificationTuple in notifications) {
//     final notification = notificationTuple.item2;
//     date = notification.time.toDate().toLocal();
//
//   }
// }
