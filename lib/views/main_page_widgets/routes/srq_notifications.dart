import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/services/cloud/cloud_notification.dart';

import '../../../constants/code_constraints.dart';
import '../../../services/cloud/cloud_user.dart';
import '../../../utils/widgets/misc/double_widget_flipper.dart';
import '../../../utils/widgets/misc/error_list_tile.dart';
import '../../../utils/widgets/loading/loading_list_tile.dart';
import '../../../utils/widgets/misc/request_notification_tile.dart';
import '../../../utils/widgets/squads/srq_subtitle.dart';

class SrqNotificationsWidget extends StatefulWidget {
  final List<CloudSquadRequest> notifications;

  const SrqNotificationsWidget({super.key, required this.notifications});

  @override
  State<SrqNotificationsWidget> createState() => _SrqNotificationsWidgetState();
}

class _SrqNotificationsWidgetState extends State<SrqNotificationsWidget> {
  List<CloudSquadRequest>? _squadRequestsNotifications;
  List<CloudSquadRequest>? _renderedList;

  @override
  void didChangeDependencies() {
    _squadRequestsNotifications ??= widget.notifications;

    _renderedList =
        _squadRequestsNotifications?.where((e) => e.accepted == false).toList();

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, res) {
        if (didPop) return;

        for (var e in _squadRequestsNotifications!) {
          if (e.read == false) {
            e.readRequest();
          }
        }

        Navigator.of(context)
            .pop<List<CloudSquadRequest>>(_squadRequestsNotifications);
      },
      child: Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          toolbarHeight: appBarHeight,
          title: Padding(
            padding: const EdgeInsets.only(top: appBarPadding),
            child: Text(
              "Squad Calls",
              style: GoogleFonts.oswald(
                fontSize: appBarTitleSize,
              ),
            ),
          ),
        ),
        body: DoubleWidgetFlipper(
          flipToTwo: _renderedList?.isNotEmpty ?? false,
          buildOne: ({child, children}) => Padding(
              padding: const EdgeInsets.only(bottom: 90), child: child!),
          buildTwo: ({children, child}) => Column(children: children!),
          isOneChild: true,
          isTwoChild: false,
          childrenIfOne: [
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Center(
                child: Text(
                  "No squads are calling for warriors at this moment.",
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.oswald(
                    fontSize: 35,
                  ),
                ),
              ),
            )
          ],
          childrenIfTwo: [
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 16),
              child: Align(
                alignment: Alignment.topLeft,
                child:
                    SrqPageSubtitle(multiple: (_renderedList?.length ?? 0) > 1),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 70),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white60,
                      width: 0.9,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 9),
                    child: ListView.builder(
                      itemCount: _renderedList!.length,
                      itemBuilder: (context, index) {
                        final notification = _renderedList![index];
                        return FutureBuilder(
                          future:
                              CloudUser.fetchUser(notification.fromUser, false),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState !=
                                ConnectionState.done) {
                              return const LoadingListTile();
                            }

                            if (snapshot.hasError) {
                              return const ErrorListTile();
                            }

                            return AnimatedRequestTile(
                              notification: notification,
                              index: index,
                              onRemove: () {
                                setState(() {
                                  _renderedList!.removeAt(index);
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
