import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/cubit/main_page_cubit.dart';
import 'package:gymtracker/extensions/argument_getter_extension.dart';
import 'package:gymtracker/main.dart';
import 'package:gymtracker/services/auth/auth_service.dart';
import 'package:gymtracker/services/cloud/cloud_notification.dart';
import 'package:gymtracker/services/cloud/firestore_notification_controller.dart';
import 'package:gymtracker/services/cloud/firestore_user_controller.dart';
import 'package:tuple/tuple.dart';

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

    notifications ??= flattenNotifications(
        context.arguments<Map<String, NotificationsType?>>());
    super.didChangeDependencies();
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
                                return const ListTile(
                                  title: Text(
                                      "Loading Notification, please wait...",
                                      style: TextStyle(fontSize: 19)),
                                );
                              } else if (snapshot.hasError) {
                                return const ListTile(
                                  title: Text(
                                      "Error loading notification, please try again later",
                                      style: TextStyle(fontSize: 19)),
                                );
                              }
                              return AnimatedRequestTile(
                                notificationInfo: notificationInfo,
                                index: index,
                                onRemove: () {
                                  setState(() {
                                    notifications!.removeAt(index);
                                  });
                                },
                                snapshot: snapshot,
                              );
                            });
                      },
                    ),
                  ),
                ],
              ));
  }
}

class AnimatedRequestTile extends StatefulWidget {
  final CloudNotification notificationInfo;
  final int index;
  final VoidCallback onRemove;
  final AsyncSnapshot<dynamic> snapshot;
  final _firestoreUserController = FirestoreUserController();
  final _authProvider = AuthService.firebase();

  AnimatedRequestTile({
    super.key,
    required this.notificationInfo,
    required this.index,
    required this.onRemove,
    required this.snapshot,
  });

  @override
  State<AnimatedRequestTile> createState() => _AnimatedRequestTileState();
}

class _AnimatedRequestTileState extends State<AnimatedRequestTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  final _firestoreNotificationController = FirestoreNotificationsController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _colorAnimation = const AlwaysStoppedAnimation(Colors.transparent);
  }

  Future<void> _handleAction(Color color) async {
    _colorAnimation = ColorTween(
      begin: color.withOpacity(0.3),
      end: Colors.transparent,
    ).animate(_controller);

    await _controller.forward(from: 0);
    widget.onRemove();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: _colorAnimation.value,
            borderRadius: BorderRadius.circular(4),
          ),
          child: ListTile(
            title: Text(
              "Pending ${widget.notificationInfo.type == 0 ? "Friend" : "Normal"} Request",
              style: const TextStyle(fontSize: 19),
            ),
            subtitle: Text("from ${widget.snapshot.data?.name}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () async {
                    _handleAction(Colors.green);
                    await _firestoreNotificationController.disableNotification(
                      widget.notificationInfo.notificationId
                    );
                    await widget._firestoreUserController.addFriend(
                      userId: widget._authProvider.currentUser!.id,
                      friendId: widget.notificationInfo.fromUserId,
                    );
                  },
                ),
                IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  icon: const Icon(
                    Icons.close,
                    color: Colors.red,
                  ),
                  onPressed: () async {
                    _handleAction(Colors.red);
                    await _firestoreNotificationController.disableNotification(
                        widget.notificationInfo.notificationId
                    );
                    await widget._firestoreUserController.rejectFRQ(
                      widget._authProvider.currentUser!.id,
                      widget.notificationInfo.fromUserId,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

List<Tuple2<int?, CloudNotification>> flattenNotifications(
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
