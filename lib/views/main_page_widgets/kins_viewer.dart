import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymtracker/cubit/main_page_cubit.dart';
import 'package:gymtracker/utils/dialogs/success_dialog.dart';
import 'package:gymtracker/utils/widgets/big_centered_text_widget.dart';
import 'package:gymtracker/utils/widgets/double_widget_flipper.dart';
import 'package:gymtracker/utils/widgets/friend_tile_widget.dart';

import '../../services/cloud/cloud_user.dart';
import '../../utils/widgets/error_list_tile.dart';
import '../../utils/widgets/loading_list_tile.dart';

class FriendsViewerWidget extends StatefulWidget {
  const FriendsViewerWidget({super.key});
  @override
  State<FriendsViewerWidget> createState() => _FriendsViewerWidgetState();
}

class _FriendsViewerWidgetState extends State<FriendsViewerWidget> {
  List<String>? userFriends;
  static final Map<String, CloudUser> _kinCache = {};
  @override
  void didChangeDependencies() {
    userFriends = context.read<MainPageCubit>().currentUser.friends;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MainPageCubit, MainPageState>(
      listener: (context, state) async {
        if (ModalRoute.of(context)?.isCurrent ?? false) {
          if (state is KinViewer) {
            if (state.success) {
              await showSuccessDialog(
                context,
                "Kinship Severed",
                "Kinship with warrior has been severed.",
              );
            }
          }
        }
      },
      child: DoubleWidgetFlipper(
        buildOne: ({child, children}) => Center(child: child),
        buildTwo: ({child, children}) => Column(children: children!),
        isOneChild: true,
        isTwoChild: false,
        flipToTwo: userFriends?.isNotEmpty ?? false,
        childrenIfOne: const [
          BigAbsoluteCenteredText(
            text: "Every great warrior has a band of allies."
                " It’s time to gather yours.",
          ),
        ],
        childrenIfTwo: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              _buildSubtitleText(),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.only(bottom: 10, top: 10)),
          Expanded(
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
                  itemCount: userFriends!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: FutureBuilder(
                        initialData: _kinCache[userFriends![index]],
                        future: CloudUser.fetchUser(userFriends![index], false),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            _kinCache[userFriends![index]] = snapshot.data!;
                          }

                          if (snapshot.hasError) {
                            return const ErrorListTile();
                          }

                          if (snapshot.data == null) {
                            return const SizedBox.shrink();
                          }

                          final user = snapshot.data!;

                          return FriendTileWidget(
                            user: user,
                            onRemove: () async {
                              await context
                                  .read<MainPageCubit>()
                                  .removeFriend(friendId: user.id);
                              setState(() {
                                userFriends = context
                                    .read<MainPageCubit>()
                                    .currentUser
                                    .friends;
                              });
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _buildSubtitleText() {
    return userFriends!.length <= 10
        ? "Legends aren’t built on numbers, "
            "but on the strength of those who stand beside you."
        : "Only the strongest warriors attract such a mighty kinship. "
            "You are building a legacy!";
  }
}
