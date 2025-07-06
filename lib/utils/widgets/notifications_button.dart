import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymtracker/constants/code_constraints.dart';
import 'package:gymtracker/cubit/main_page_cubit.dart';
import 'package:gymtracker/views/main_page_widgets/routes/notifications.dart';

class NotificationsButton extends StatelessWidget {
  final RequestsSortingType _notifications;

  const NotificationsButton(
      {super.key, required RequestsSortingType notifications})
      : _notifications = notifications;

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = [
      krqKeyName,
      achievementsKeyName
    ].any((key) => _notifications[newNotifsKeyName]![key]!.any((e) => !e.read));

    return IconButton(
      icon: isEmpty
          ? const Icon(
              Icons.notifications_active,
              color: Color(0xff0583fa),
            )
          : const Icon(Icons.notifications),
      iconSize: mainSizeIcon,
      onPressed: () async {
        await Navigator.of(context)
            .push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<MainPageCubit>(),
              child: NotificationsRoute(notifications: _notifications),
            ),
          ),
        )
            .then((value) async {
          if (!context.mounted) return;
          await context.read<MainPageCubit>().clearNotifications(value);
        });
      },
    );
  }
}
