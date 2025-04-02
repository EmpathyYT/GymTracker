import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/constants/code_constraints.dart';
import 'package:gymtracker/extensions/argument_getter_extension.dart';
import 'package:gymtracker/services/cloud/cloud_user.dart';
import 'package:gymtracker/utils/widgets/double_widget_flipper.dart';
import 'package:gymtracker/utils/widgets/error_list_tile.dart';
import 'package:gymtracker/utils/widgets/krq_subtitle.dart';
import 'package:gymtracker/utils/widgets/loading_list_tile.dart';
import 'package:gymtracker/utils/widgets/request_notification_tile.dart';

import '../../../services/cloud/cloud_notification.dart';

class KinRequestRoute extends StatefulWidget {
  const KinRequestRoute({super.key});

  @override
  State<KinRequestRoute> createState() => _KinRequestRouteState();
}

class _KinRequestRouteState extends State<KinRequestRoute> {
  List<CloudKinRequest>? _krqNotifications;
  List<CloudKinRequest>? _listToBuild;


  @override
  void didChangeDependencies() {
    _krqNotifications ??= context.arguments<List<CloudKinRequest>>() ?? [];
    _listToBuild =
        _krqNotifications!.where((e) => e.accepted != null).toList();

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, res) {
        if (didPop) return;
        _krqNotifications?.forEach((e) async {
          if (e.read == true) return;
          await e.readRequest();
        });
        Navigator.of(context).pop(_krqNotifications);
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: appBarHeight,
          title: Padding(
            padding: const EdgeInsets.only(top: appBarPadding),
            child: Text(
              "Kinship Calls",
              style: GoogleFonts.oswald(
                fontSize: 35,
              ),
            ),
          ),
        ),
        body: DoubleWidgetFlipper(
          flipToTwo: _listToBuild?.isNotEmpty ?? false,
          buildOne: ({child, children}) => Padding(
              padding: const EdgeInsets.only(bottom: 90), child: child!),
          buildTwo: ({children, child}) => Column(children: children!),
          isOneChild: true,
          isTwoChild: false,
          childrenIfOne: [
            Center(
              child: Text(
                "For now, you stand alone.\nNo warriors seek kinship.",
                textAlign: TextAlign.center,
                style: GoogleFonts.oswald(
                  fontSize: 35,
                ),
              ),
            )
          ],
          childrenIfTwo: [
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 16),
              child: Align(
                alignment: Alignment.topLeft,
                child: KrqPageSubtitle(
                    multiple: (_listToBuild?.length ?? 0) > 1),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ListView.builder(
                  itemCount: _listToBuild
                          ?.where((e) => e.accepted != null)
                          .length ??
                      0,
                  itemBuilder: (context, index) {
                    final notification = _listToBuild![index];
                    return FutureBuilder(
                      future: CloudUser.fetchUser(notification.fromUser, false),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return const LoadingListTile();
                        }

                        if (snapshot.hasError) {
                          return const ErrorListTile();
                        }

                        return AnimatedFriendRequestTile(
                          notification: notification,
                          index: index,
                          onRemove: () {
                            setState(() {});
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
}
