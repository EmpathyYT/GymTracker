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

class SquadSelectorWidget extends StatefulWidget {
  const SquadSelectorWidget({super.key});

  @override
  State<SquadSelectorWidget> createState() => _SquadSelectorWidgetState();
}

class _SquadSelectorWidgetState extends State<SquadSelectorWidget> {
  List<CloudSquadRequest>? _squadNotifications;

  @override
  void didChangeDependencies() {
    if (_squadNotifications == null) _extractNotifications();
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
          iconCallBack: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<MainPageCubit>(),
                  child: SrqNotificationsWidget(
                      notifications: _squadNotifications ?? []),
                ),
              ),
            ).then<RequestsSortingType>((RequestsSortingType value) {

            });
          },
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
          buildTwo: ({child, children}) => Expanded(child: child!),
          childrenIfOne: const [
            BigCenteredText(text: "You stand alone.\nFor now."),
          ],
          childrenIfTwo: [
            ListView.builder(
              itemCount: _squadNotifications!.length,
              itemBuilder: (context, index) {
                return FutureBuilder(
                    future: CloudSquad.fetchSquad(
                        _squadNotifications![index].serverId.toString()),
                    builder: (context, snapshot) {
                      final server = snapshot.data;

                      if (snapshot.connectionState != ConnectionState.done) {
                        return const LoadingListTile();
                      }

                      if (snapshot.hasError) {
                        return const ErrorListTile();
                      }

                      return ListTile(
                        title: Text(server!.name),
                      );
                    });
              },
            ),
          ],
          isOneChild: true,
          isTwoChild: true,
          flipToTwo: _squadNotifications?.isNotEmpty ?? false,
        ),
      ],
    );
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
}
