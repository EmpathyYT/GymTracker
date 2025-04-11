import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymtracker/constants/code_constraints.dart';
import 'package:gymtracker/utils/widgets/big_centered_text_widget.dart';
import 'package:gymtracker/utils/widgets/double_widget_flipper.dart';
import 'package:gymtracker/utils/widgets/universal_card.dart';
import 'package:gymtracker/views/main_page_widgets/routes/srq_notifications.dart';

import '../../cubit/main_page_cubit.dart';
import '../../services/cloud/cloud_notification.dart';
import '../../services/cloud/cloud_squads.dart';
import '../../utils/widgets/error_list_tile.dart';
import '../../utils/widgets/loading_list_tile.dart';
import '../../utils/widgets/squad_tile_widget.dart';

class SquadSelectorWidget extends StatefulWidget {
  const SquadSelectorWidget({super.key});

  @override
  State<SquadSelectorWidget> createState() => _SquadSelectorWidgetState();
}

class _SquadSelectorWidgetState extends State<SquadSelectorWidget> {
  List<CloudSquadRequest>? _squadNotifications;
  List<String>? _squads;
  static DateTime? lastUpdate;

  @override
  void didChangeDependencies() async {
    if (_squadNotifications == null) _extractNotifications();
    _squads = context.read<MainPageCubit>().currentUser.squads;
    await _updateSquads();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 10, bottom: 10),
        ),
        UniversalCard(
          flipToTwo: _squadNotifications!.any((e) => e.read != true),
          iconCallBack: () async => await _cardIconCallBack(context),
          title1: "No New Squads Calling",
          title2: (_squadNotifications!.length == 1)
              ? "A Squad Calls upon you"
              : "Multiple Squads Calling upon you",
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
        DoubleWidgetFlipper(
          buildOne: ({child, children}) => Expanded(
            child: child!,
          ),
          buildTwo: ({child, children}) => Expanded(
            child: ListView.builder(
              itemCount: _squads!.length,
              itemBuilder: (context, index) {
                return _buildListItems(index);
              },
            ),
          ),
          childrenIfOne: const [
            BigCenteredText(text: "You stand without a squad.\nFor now."),
          ],
          childrenIfTwo: const [
            // Padding(
            //   padding: const EdgeInsets.fromLTRB(16, 4, 16, 5),
            //   child: Align(
            //     alignment: Alignment.topLeft,
            //     child: Text(_buildSubtitleText(),
            //         softWrap: true,
            //         style: const TextStyle(
            //           fontSize: 12,
            //           color: Colors.grey,
            //           fontWeight: FontWeight.bold,
            //         )),
            //   ),
            // ),
          ],
          isOneChild: true,
          isTwoChild: false,
          flipToTwo: _squads?.isNotEmpty ?? false,
        ),
      ],
    );
  }

  FutureBuilder<CloudSquad?> _buildListItems(index) {
    return FutureBuilder(
            future: CloudSquad.fetchSquad(_squads![index], true),
            builder: (context, snapshot) {
              final server = snapshot.data;

              if (snapshot.connectionState != ConnectionState.done) {
                return const LoadingListTile();
              }

              if (snapshot.hasError) {
                log(snapshot.error.toString());
                return const ErrorListTile();
              }

              if (snapshot.data == null) {
               return const SizedBox.shrink();
              }

              return SquadTileWidget(
                title: server!.name,
                iconCallBack: () => log("niga"),
              );
            },
          );
  }

  Future<void> _cardIconCallBack(BuildContext context) async {
    await Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<MainPageCubit>(),
          child: SrqNotificationsWidget(notifications: _squadNotifications!),
        ),
      ),
    )
        .then((value) async {
      if (!context.mounted) return;
      await context.read<MainPageCubit>().clearSquadNotifications(value);
    });
  }

  void _extractNotifications() {
    final notifications = context.read<MainPageCubit>().state.notifications;
    _squadNotifications = [];

    for (final values in notifications!.values) {
      _squadNotifications?.addAll(
          values[srqKeyName]?.map((e) => e as CloudSquadRequest).toList() ??
              []);
    }
  }

  Future<void> _updateSquads() async {
    if (lastUpdate != null &&
        lastUpdate!.difference(DateTime.now()).inSeconds < 10) {
      return;
    }
    await context.read<MainPageCubit>().reloadUser();

    setState(() {
      lastUpdate = DateTime.now();
      _squads = context.read<MainPageCubit>().currentUser.squads;
    });
  }

// String _buildSubtitleText() {
//   return switch (_squads!.length) {
//     1 =>
//       "A warrior who walks alone is stronger than a thousand with no purpose. "
//           "Choose your battles wisely.",
//     <= 3 =>
//       "A few squads, but you’re already making waves in the battlefield. "
//           "Your influence is spreading.",
//     <= 5 => "You’ve built your presence across multiple squads. "
//         "Each one strengthens your hold on the battlefield.",
//     _ => "Your empire grows as your squads multiply. "
//         "Soon, you will control the entire battlefield."
//   };
// }
}
