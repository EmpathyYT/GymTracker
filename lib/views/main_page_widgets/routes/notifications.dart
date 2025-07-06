import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/constants/routes.dart';
import 'package:gymtracker/cubit/main_page_cubit.dart';
import 'package:gymtracker/extensions/date_time_extension.dart';
import 'package:gymtracker/helpers/achievement_sorter.dart';
import 'package:gymtracker/services/cloud/cloud_notification.dart';
import 'package:gymtracker/utils/widgets/big_centered_text_widget.dart';
import 'package:gymtracker/utils/widgets/double_widget_flipper.dart';
import 'package:gymtracker/utils/widgets/universal_card.dart';

import '../../../constants/code_constraints.dart';

class NotificationsRoute extends StatefulWidget {
  final RequestsSortingType notifications;

  const NotificationsRoute({super.key, required this.notifications});

  @override
  State<NotificationsRoute> createState() => _NotificationsRouteState();
}

class _NotificationsRouteState extends State<NotificationsRoute> {
  RequestsSortingType? _notifications;
  List<CloudKinRequest> _requestsNotifications = [];
  List<CloudAchievement> _otherNotifications = [];

  @override
  void didChangeDependencies() {
    if (_notifications == null) _extractNotifications();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, res) async {
        if (didPop) return;
        for (final achievement in _otherNotifications) {
          if (!achievement.read) {
            await achievement.readAchievement();
          }
        }
        if (!context.mounted) return;
        Navigator.of(context).pop<RequestsSortingType>({
          newNotifsKeyName: {
            krqKeyName: [],
            srqKeyName: _notifications![newNotifsKeyName]![srqKeyName]!,
            achievementsKeyName: [],
          },
          oldNotifsKeyName: {
            krqKeyName: _requestsNotifications,
            srqKeyName: _notifications![oldNotifsKeyName]![srqKeyName]!,
            achievementsKeyName: _otherNotifications,
          },
        });
      },
      child: Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          toolbarHeight: appBarHeight,
          title: Padding(
            padding: const EdgeInsets.only(top: appBarPadding),
            child: Text(
              "Frontline Reports",
              style: GoogleFonts.oswald(fontSize: appBarTitleSize),
            ),
          ),
        ),
        body: DoubleWidgetFlipper(
          flipToTwo: _otherNotifications.isNotEmpty,
          isOneChild: false,
          isTwoChild: false,
          buildOne:
              ({children, child}) =>
                  Stack(alignment: Alignment.center, children: children!),
          buildTwo: ({children, child}) => Column(children: children!),
          commonWidgets: [
            Column(
              children: [
                const Padding(padding: EdgeInsets.only(top: 10, bottom: 10)),
                UniversalCard(
                  title1: "No New Kinship Calls",
                  title2:
                      (_requestsNotifications.length) == 1
                          ? "A Warrior Seeks Kinship"
                          : "Warriors Seek Kinship",
                  flipToTwo: _requestsNotifications.any((e) => !(e.read)),
                  iconCallBack: () async => await _kinRequestButtonCallback(),
                ),
                const Padding(padding: EdgeInsets.all(2.0)),
                Container(
                  padding: const EdgeInsets.only(
                    top: 3,
                    bottom: 3,
                    left: 5,
                    right: 5,
                  ),
                  child: const Divider(thickness: 0.9, color: Colors.white60),
                ),
              ],
            ),
          ],
          childrenIfOne: const [
            BigCenteredText(
              text:
                  "The campfire burns quietly.\nNo reports from the frontlines.",
            ),
          ],
          childrenIfTwo: [
            Expanded(
              child: ListView.builder(
                itemCount: _otherNotifications.length,
                itemBuilder: (context, builder) {
                  final notificationInfo = _otherNotifications[builder];
                  return ListTile(
                    title: Text(
                      notificationInfo.message,
                      style: GoogleFonts.oswald(fontSize: 25),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        notificationInfo.createdAt.toReadableTzTime(),
                        style: GoogleFonts.montserrat(
                          fontSize: 15,
                          color: Colors.white60,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _kinRequestButtonCallback() async {
    await Navigator.of(
      context,
    ).pushNamed(krqNotificationsRoute, arguments: _requestsNotifications).then((
      value,
    ) {
      setState(
        () => _requestsNotifications = value as List<CloudKinRequest>? ?? [],
      );
    });
  }

  void _extractNotifications() {
    final List<CloudAchievement> otherNotifs = [];
    final List<CloudKinRequest> requestNotifs = [];

    _notifications = widget.notifications;

    for (final values in _notifications!.values) {
      otherNotifs.addAll(
        (values[achievementsKeyName] ?? [])
            .map((e) => e as CloudAchievement)
            .toList(),
      );

      requestNotifs.addAll(
        (values[krqKeyName] ?? []).map((e) => e as CloudKinRequest).toList(),
      );
    }

    _otherNotifications =
        AchievementSorter.sortByDate(
          achievements: otherNotifs,
        ).achievementsSorted;

    _requestsNotifications = requestNotifs;
  }
}

// ListTile _buildNormalNotificationTile(CloudNotification notificationInfo) {
//   return ListTile(
//     leading: const CircleAvatar(
//       radius: 25,
//       backgroundColor: Colors.white24,
//     ),
//     title: Padding(
//       padding: const EdgeInsets.only(top: 8),
//       child: Text(
//         notificationInfo.message,
//         maxLines: 3,
//         overflow: TextOverflow.ellipsis,
//         style: const TextStyle(
//           fontSize: 22,
//           fontWeight: FontWeight.w100,
//         ),
//       ),
//     ),
//     subtitle: Text(
//       "at ${notificationInfo.time.toDate().toLocal().toHourMinute()}",
//       style: const TextStyle(
//         color: Colors.grey,
//         fontSize: 13,
//         fontWeight: FontWeight.bold,
//       ),
//     ),
//   );
// }
