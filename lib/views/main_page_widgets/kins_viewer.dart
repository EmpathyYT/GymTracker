import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/cubit/main_page_cubit.dart';
import 'package:gymtracker/utils/dialogs/user_info_card_dialog.dart';
import 'package:gymtracker/utils/widgets/double_widget_flipper.dart';

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

  @override
  void didChangeDependencies() {
    userFriends = context.read<MainPageCubit>().currentUser.friends;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return DoubleWidgetFlipper(
      buildOne: ({child, children}) => Center(child: child),
      buildTwo: ({child, children}) => Column(children: children!),
      isOneChild: true,
      isTwoChild: false,
      flipToTwo: userFriends?.isNotEmpty ?? false,
      childrenIfOne: [
        Padding(
          padding: const EdgeInsets.only(bottom: 50),
          child: Text(
            textAlign: TextAlign.center,
            "Every great warrior has a band of allies."
            " It’s time to gather yours.",
            style: GoogleFonts.oswald(
              fontSize: 35,
            ),
          ),
        ),
      ],
      childrenIfTwo: [
        Align(
          alignment: Alignment.topLeft,
          child: Text(_buildSubtitleText(),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              )),
        ),
        const Padding(padding: EdgeInsets.only(bottom: 10, top: 10)),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white60,
                width: 0.9,
              ),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 9),
              child: ListView.builder(
                itemCount: userFriends!.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: FutureBuilder(
                      future: CloudUser.fetchUser(userFriends![index], false),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return const LoadingListTile();
                        }

                        if (snapshot.hasError || snapshot.data == null) {
                          return const ErrorListTile();
                        }

                        final user = snapshot.data!;

                        return ListTile(
                          leading: const CircleAvatar(
                              backgroundColor: Colors.blueGrey),
                          title: Text(
                            user.name,
                            style: GoogleFonts.oswald(
                              fontSize: 20,
                            ),
                          ),
                          subtitle: Text(
                            user.bio.length > 20
                                ? "${user.bio.substring(0, 20)}..."
                                : user.bio,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () => showUserCard(
                            context: context,
                            user: user,
                          ),
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
