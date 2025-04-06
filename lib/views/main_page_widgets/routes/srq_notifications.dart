import 'package:flutter/widgets.dart';
import 'package:gymtracker/services/cloud/cloud_notification.dart';

import '../../../constants/code_constraints.dart';
import '../../../cubit/main_page_cubit.dart';

class SrqNotificationsWidget extends StatefulWidget {
  final RequestsSortingType notifications;

  const SrqNotificationsWidget({super.key, required this.notifications});

  @override
  State<SrqNotificationsWidget> createState() => _SrqNotificationsWidgetState();
}

class _SrqNotificationsWidgetState extends State<SrqNotificationsWidget> {
  List<CloudSquadRequest> _squadRequestsNotifications = [];

  @override
  void didChangeDependencies() {
    for (final value in widget.notifications.values) {
      if (value[srqKeyName] != null) {
        _squadRequestsNotifications.addAll(
            value[srqKeyName]?.map((e) => e as CloudSquadRequest) ?? []);
      }
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, res) {
        if (didPop) return;

        for (var e in _squadRequestsNotifications) {
          if (e.read == false) {
            e.readRequest();
          }
        }

        Navigator.of(context).pop<RequestsSortingType>({
          newNotifsKeyName: {
            krqKeyName: widget.notifications[newNotifsKeyName]![krqKeyName]!,
            srqKeyName: [],
            othersKeyName:
                widget.notifications[newNotifsKeyName]![othersKeyName]!,
          },
          oldNotifsKeyName: {
            krqKeyName: widget.notifications[oldNotifsKeyName]![krqKeyName]!,
            srqKeyName: _squadRequestsNotifications,
            othersKeyName:
                widget.notifications[oldNotifsKeyName]![othersKeyName]!,
          },
        });
      },
      child: const Placeholder(),
    );
  }
}
