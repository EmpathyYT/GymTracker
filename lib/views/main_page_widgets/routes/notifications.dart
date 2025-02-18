import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/constants/routes.dart';
import 'package:gymtracker/extensions/argument_getter_extension.dart';
import 'package:gymtracker/extensions/date_time_extension.dart';
import 'package:gymtracker/extensions/different_dates_extension.dart';
import 'package:gymtracker/services/cloud/cloud_notification.dart';
import 'package:gymtracker/services/cloud/firestore_notification_controller.dart';
import 'package:gymtracker/services/cloud/firestore_user_controller.dart';
import 'package:gymtracker/utils/widgets/stack_column_flipper.dart';
import 'package:gymtracker/utils/widgets/universal_card.dart';
import 'package:intl/intl.dart';
import 'package:tuple/tuple.dart';

import '../../../constants/code_constraints.dart';

typedef FlatNotificationType = List<Tuple2<int?, CloudNotification>>;

class NotificationsRoute extends StatefulWidget {
  const NotificationsRoute({super.key});

  @override
  State<NotificationsRoute> createState() => _NotificationsRouteState();
}

class _NotificationsRouteState extends State<NotificationsRoute> {
  FlatNotificationType? _normalNotifications;
  FlatNotificationType? _requestsNotifications;
  List<Widget>? _notificationWidgets;
  final _firestoreUserController = FirestoreUserController();

  @override
  void didChangeDependencies() {
    if (_normalNotifications == null && _requestsNotifications == null) {
      final (normNotifications, reqNotifications) = _flattenNotifications(
          context.arguments<Map<String, NotificationsType?>>());

      // _normalNotifications = [
      //   Tuple2(null, CloudNotification.testingNotif(Timestamp.now())),
      //   Tuple2(null,
      //       CloudNotification.testingNotif(Timestamp.fromDate(
      //           DateTime.now().subtract(const Duration(minutes: 1))))),
      //   Tuple2(
      //       null,
      //       CloudNotification.testingNotif(Timestamp.fromDate(
      //           DateTime.now().subtract(const Duration(days: 1))))),
      //   Tuple2(
      //       null,
      //       CloudNotification.testingNotif(Timestamp.fromDate(
      //           DateTime.now().subtract(const Duration(days: 2))))),
      // ];

      _normalNotifications = normNotifications
        ..sort((a, b) => -a.item2.time.compareTo(b.item2.time));

      _requestsNotifications = reqNotifications;
      log(reqNotifications.toString());
      _notificationWidgets =
          _notificationListViewWidgetBuilder(_normalNotifications!);
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
            _normalNotifications ?? [], _requestsNotifications ?? []));
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Notifications",
            style: GoogleFonts.oswald(
              fontSize: 35,
            ),
          ),
        ),
        body: StackColumnFlipper(
          flipToColumn: _normalNotifications?.isNotEmpty ?? false,
          commonWidgets: [
            const Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
            ),
            UniversalCard(
              isNewRequests:
              _requestsNotifications?.any((e) => e.item2.read == false) ??
                  false,
              iconCallBack: () async {
                await Navigator.of(context)
                    .pushNamed(
                  krqNotificationsRoute,
                  arguments: _requestsNotifications,
                )
                    .then((value) {
                  setState(() {
                    if ((value as List).isEmpty) return;
                    _requestsNotifications = value as FlatNotificationType?;
                  });
                });
              },
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
                itemCount: (_normalNotifications!.length +
                    _normalNotifications!.numberOfDifferentDates()),
                itemBuilder: (context, index) {
                  return _notificationWidgets![index];
                  // final notificationInfo = normalNotifications![]
                  // return FutureBuilder(
                  //   future: _firestoreUserController
                  //       .fetchUser(notificationInfo.fromUserId),
                  //   builder: (context, snapshot) {
                  //     if (snapshot.connectionState != ConnectionState.done) {
                  //       return _loadingListTile();
                  //     } else if (snapshot.hasError) {
                  //       return _errorListTile();
                  //     }
                  //     return _normalNotificationTile(
                  //         notificationInfo);
                  //   },
                  // );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

ListTile _normalNotificationTile(CloudNotification notificationInfo) {
  return ListTile(
    title: Text(
      notificationInfo.message,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w100,
      ),
    ),
    subtitle: Text(
      "\t at ${notificationInfo.time.toDate().toLocal().toHourMinute()}",
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 15,
        fontWeight: FontWeight.w200,
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

List<Widget> _notificationListViewWidgetBuilder(
    FlatNotificationType notifications) {
  final List<Widget> widgets = [];
  for (int i = 0; i < notifications.length; i++) {
    final notification = notifications[i].item2;
    final prevNotification = i == 0 ? null : notifications[i - 1].item2;
    final title = notification.time.toDate().toLocal();

    if (i == 0 ||
        prevNotification?.time.toDate().toLocal().day !=
            notification.time.toDate().toLocal().day) {
      widgets.add(
        Padding(
          padding: EdgeInsets.only(top: i == 0 ? 8 : 18, bottom: 5, left: 8),
          child: Text(
            title.day == DateTime.now().day
                ? "Today"
                : title.day ==
                        DateTime.now().subtract(const Duration(days: 1)).day
                    ? "Yesterday"
                    : DateFormat('EEEE').format(title),
            style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w200),
          ),
        ),
      );
    }
    widgets.add(_normalNotificationTile(notification));
  }
  return widgets;
}

ListTile buildLoadingListTile() {
  return const ListTile(
    title: Text("Loading Notification, please wait...",
        style: TextStyle(fontSize: 19)),
  );
}

ListTile buildErrorListTile() {
  return const ListTile(
    title: Text("Error loading notification, please try again later",
        style: TextStyle(fontSize: 19)),
  );
}
