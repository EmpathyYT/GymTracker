import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/constants/code_constraints.dart';
import 'package:gymtracker/services/cloud/cloud_squads.dart';

import '../../../../cubit/main_page_cubit.dart';
import '../../../../services/cloud/cloud_user.dart';
import '../../../../utils/dialogs/success_dialog.dart';
import '../../../../utils/widgets/double_widget_flipper.dart';
import '../../../../utils/widgets/error_list_tile.dart';
import '../../../../utils/widgets/friend_tile_widget.dart';
import '../../../../utils/widgets/loading_list_tile.dart';

class MembersSquadRoute extends StatefulWidget {
  final CloudSquad squad;

  const MembersSquadRoute({super.key, required this.squad});

  @override
  State<MembersSquadRoute> createState() => _MembersSquadRouteState();
}

class _MembersSquadRouteState extends State<MembersSquadRoute> {
  final _centeredTextKey = GlobalKey();
  double _centeredTextHeight = 50;
  List<String>? squadMembers;
  CloudUser? user;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final textBox =
          _centeredTextKey.currentContext?.findRenderObject() as RenderBox?;
      if (textBox != null) {
        final textHeight = textBox.size.width;
        setState(() {
          _centeredTextHeight = textHeight;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    user ??= context.read<MainPageCubit>().currentUser;
    squadMembers ??= widget.squad.members.where((e) => e != user!.id).toList();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MainPageCubit, MainPageState>(
      listener: (context, state) async {
        if (ModalRoute.of(context)?.isCurrent ?? false) {
          if (state is SquadSelector) {
            if (state.success) {
              await showSuccessDialog(
                context,
                "Member Removed",
                "This Member has been removed from the squad.",
              );
            }
          }
        }
      },
      child: DoubleWidgetFlipper(
        buildOne: ({child, children}) => LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Positioned(
                  top: (constraints.maxHeight / 2) -
                      (_centeredTextHeight / 2) +
                      appBarHeight,
                  left: 0,
                  right: 0,
                  child: Center(
                    key: _centeredTextKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: children!,
                    ),
                  ),
                )
              ],
            );
          },
        ),
        buildTwo: ({child, children}) => Column(children: children!),
        isOneChild: false,
        isTwoChild: false,
        flipToTwo: squadMembers?.isNotEmpty ?? false,
        childrenIfOne: [
          const Icon(Icons.shield_outlined, size: 80, color: Colors.white24),
          const SizedBox(height: 16),
          Text(
            "You stand in solitude… for now.",
            style: GoogleFonts.oswald(
              fontSize: 30,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            "Send a Warrior Call and gather your warriors.",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
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
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 9),
                child: ListView.builder(
                  itemCount: squadMembers!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: FutureBuilder(
                        future:
                            CloudUser.fetchUser(squadMembers![index], false),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState !=
                              ConnectionState.done) {
                            return const LoadingListTile();
                          }

                          if (snapshot.hasError || snapshot.data == null) {
                            return const ErrorListTile();
                          }

                          final user = snapshot.data!;

                          return FriendTileWidget(
                            user: user,
                            onRemove: () async {
                              await context
                                  .read<MainPageCubit>()
                                  .removeFriend(friendId: user.id);
                              setState(() {
                                squadMembers = context
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
    return "This Squad is composed of ${squadMembers!.length} ${squadMembers!.length == 1 ? "Warrior" : "Warriors"}";
  }
}
