import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/services/cloud/cloud_squad.dart';
import 'package:gymtracker/utils/widgets/squad_member_tile_widget.dart';

import '../../../../cubit/main_page_cubit.dart';
import '../../../../services/cloud/cloud_user.dart';
import '../../../../utils/dialogs/error_dialog.dart';
import '../../../../utils/dialogs/success_dialog.dart';
import '../../../../utils/widgets/absolute_centered_widget.dart';
import '../../../../utils/widgets/double_widget_flipper.dart';
import '../../../../utils/widgets/error_list_tile.dart';

class MembersSquadRoute extends StatefulWidget {
  final CloudSquad squad;
  final ValueChanged<CloudSquad> onChanged;

  const MembersSquadRoute({
    super.key,
    required this.squad,
    required this.onChanged,
  });

  @override
  State<MembersSquadRoute> createState() => _MembersSquadRouteState();
}

class _MembersSquadRouteState extends State<MembersSquadRoute> {
  List<String>? squadMembers;
  static final Map<String, CloudUser> _userCache = {};
  final GlobalKey _columnKey = GlobalKey();
  CloudUser? user;

  @override
  void initState() {
    super.initState();
    user = context.read<MainPageCubit>().currentUser;
    squadMembers = widget.squad.members;
  }

  @override
  void didUpdateWidget(covariant MembersSquadRoute oldWidget) {
    super.didUpdateWidget(oldWidget);
    squadMembers = widget.squad.members;
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
            } else if (state.exception != null) {
              await showErrorDialog(context, "Error Removing Member");
            }
          }
        }
      },
      child: DoubleWidgetFlipper(
        buildOne:
            ({child, children}) => AbsoluteCenteredWidget(
              widgetKey: _columnKey,
              child: Column(
                key: _columnKey,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: children!,
              ),
            ),
        buildTwo: ({child, children}) => Column(children: children!),
        isOneChild: false,
        isTwoChild: false,
        flipToTwo: (squadMembers?.length ?? 0) > 1,
        childrenIfOne: [
          const Icon(Icons.shield_outlined, size: 80, color: Colors.white24),
          const SizedBox(height: 16),
          Text(
            "You stand in solitude… for now.",
            style: GoogleFonts.oswald(fontSize: 30),
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
            child: Padding(
              padding: const EdgeInsets.only(bottom: 70),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white60, width: 0.9),
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
                          initialData: _userCache[squadMembers![index]],
                          future: CloudUser.fetchUser(
                            squadMembers![index],
                            false,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              _userCache[squadMembers![index]] = snapshot.data!;
                            }

                            if (snapshot.hasError) {
                              return const ErrorListTile();
                            }

                            if (snapshot.data == null) {
                              return const SizedBox.shrink();
                            }

                            final user = snapshot.data!;
                            return SquadMemberTileWidget(
                              isSelf: user == this.user!,
                              isOwner: widget.squad.ownerId == this.user!.id,
                              user: user,
                              onRemove: () async {
                                if (this.user != user) {
                                  final squad = await context
                                      .read<MainPageCubit>()
                                      .removeMember(widget.squad, user.id);

                                  if (squad != null) {
                                    widget.onChanged(squad);
                                  }
                                } else {
                                  await context
                                      .read<MainPageCubit>()
                                      .leaveSquad(widget.squad);

                                  if (context.mounted) {
                                    Navigator.pop(context, true);
                                  }
                                }
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
          ),
        ],
      ),
    );
  }

  String _buildSubtitleText() {
    return "This Squad is composed of ${squadMembers!.length} "
        "${squadMembers!.length == 1 ? "Warrior" : "Warriors"}";
  }
}
