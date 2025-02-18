import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/utils/widgets/request_notification_tile.dart';
import 'package:gymtracker/views/main_page_widgets/routes/notifications.dart';

import '../../../services/cloud/firestore_user_controller.dart';

class KinRequestRoute extends StatefulWidget {
  const KinRequestRoute({super.key});

  @override
  State<KinRequestRoute> createState() => _KinRequestRouteState();
}

class _KinRequestRouteState extends State<KinRequestRoute> {
  FlatNotificationType? _krqNotifications;
  final _firestoreUserController = FirestoreUserController();

  @override
  void didChangeDependencies() {
    _krqNotifications ??= [];
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, res) {
        if (didPop) return;
        for (var notification in _krqNotifications!) {
          notification.item2.readNotification();
        }
        Navigator.of(context).pop(_krqNotifications);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Kin Requests",
            style: GoogleFonts.oswald(
              fontSize: 35,
            ),
          ),
        ),
        body: _krqNotifications?.isEmpty ?? true
            ? Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: Center(
                  child: Text(
                    "For now, you stand alone. No warriors seek kinship.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.oswald(
                      fontSize: 35,
                    ),
                  ),
                ),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20, left: 16),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: _buildSubtitle(_krqNotifications?.length ?? 0),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: ListView.builder(
                        itemCount: _krqNotifications?.length ?? 0,
                        itemBuilder: (context, index) {
                          final notification = _krqNotifications![index];
                          return FutureBuilder(
                            future: _firestoreUserController
                                .fetchUser(notification.item2.fromUserId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState !=
                                  ConnectionState.done) {
                                return buildLoadingListTile();
                              }

                              if (snapshot.hasError) {
                                return buildErrorListTile();
                              }

                              return AnimatedNotificationTile(
                                notificationInfo: notification.item2,
                                index: index,
                                onRemove: () {
                                  setState(() {
                                    _krqNotifications!.removeAt(index);
                                  });
                                },
                                snapshot: snapshot,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Text _buildSubtitle(int length) {
    var text = "The battlefield stirs—";
    if (length == 1) {
      text += "a warrior seeks your alliance!";
    } else {
      text += "warriors seek your alliance!";
    }
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        color: Colors.grey,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
