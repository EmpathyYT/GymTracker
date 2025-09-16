import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/services/cloud/cloud_squad.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../constants/code_constraints.dart';
import '../../../../cubit/main_page_cubit.dart';
import '../../../../exceptions/cloud_exceptions.dart';
import '../../../../services/cloud/cloud_user.dart';
import '../../../../utils/dialogs/error_dialog.dart';
import '../../../../utils/dialogs/success_dialog.dart';
import '../../../../utils/dialogs/user_info_card_dialog.dart';
import '../../../../utils/widgets/misc/big_centered_text_widget.dart';

class AddMemberRoute extends StatefulWidget {
  final CloudSquad squad;

  const AddMemberRoute({super.key, required this.squad});

  @override
  State<AddMemberRoute> createState() => _AddMemberRouteState();
}

class _AddMemberRouteState extends State<AddMemberRoute> {
  final TextEditingController _searchController = TextEditingController();
  final BehaviorSubject<String> _searchSubject = BehaviorSubject<String>();
  late Stream<List<CloudUser>?> _searchStream;

  @override
  void didChangeDependencies() {
    final user = context.read<MainPageCubit>().currentUser;

    _searchStream = _searchSubject
        .debounceTime(const Duration(milliseconds: 300))
        .switchMap((query) async* {
      yield await CloudUser.fetchUsersForSquadAdding(
        user.id,
        widget.squad.id,
        query,
      );
    });
    _searchSubject.add('');
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MainPageCubit, MainPageState>(
      listener: (context, state) async {
        if (state is SquadSelector) {
          if (state.exception != null) {
            if (state.exception is AlreadySentFriendRequestException) {
              await showErrorDialog(
                  context, "The Warrior Call has already been sent.");
            } else if (state.exception is UserAlreadyFriendException) {
              await showErrorDialog(
                  context, "Warrior is already a member of your squad.");
            } else if (state.exception is GenericCloudException) {
              await showErrorDialog(
                  context, "The Warrior Call could not be delivered.");
            }
          } else if (state.success) {
            await showSuccessDialog(context, "Warrior Call Sent",
                "Your Warrior Call has been sent.");
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: appBarHeight,
          scrolledUnderElevation: 0,
          title: Padding(
            padding: const EdgeInsets.only(top: appBarPadding),
            child: Text(
              'Send Warrior Call',
              style: GoogleFonts.oswald(
                fontSize: appBarTitleSize,
              ),
            ),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12),
              child: TextField(
                controller: _searchController,
                onChanged: _searchSubject.add,
                decoration: InputDecoration(
                  labelText: 'Seek Out Warrior',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.grey,
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<CloudUser>?>(
                  stream: _searchStream,
                  builder: (context, snapshot) {
                    final user = context.read<MainPageCubit>().currentUser;

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const BigCenteredText(text: "Scout for Warriors");
                    }

                    if (snapshot.data == null) {
                      if (_searchController.text == user.name) {
                        return const BigCenteredText(
                            text: "Look Into The Mirror");
                      } else {
                        return const BigCenteredText(
                            text: "Scout For Warriors");
                      }
                    }

                    final users = snapshot.data!;
                    if (users.isEmpty) {
                      if (_searchController.text == user.name) {
                        return const BigCenteredText(
                            text: "Look Into The Mirror");
                      } else {
                        return const BigCenteredText(text: "No Warriors Found");
                      }
                    }
                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];

                        return ListTile(
                          title: Text(
                            user.name,
                            style: GoogleFonts.oswald(
                              fontSize: 25,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.person_add),
                            onPressed: () async {
                              await context.read<MainPageCubit>().addSquadReq(
                                    userToAddId: user.id,
                                    squadId: widget.squad.id,
                                  );
                              _resetSearch();
                            },
                          ),
                          onTap: () async {
                            await showUserCard(
                              context: context,
                              user: user,
                              userAction: (context) async {
                                await context.read<MainPageCubit>().addSquadReq(
                                      userToAddId: user.id,
                                      squadId: widget.squad.id,
                                    );
                                if (!context.mounted) return;
                                Navigator.of(context).pop();
                                _resetSearch();
                              },
                              userIcon: const Icon(Icons.person_add),
                            );
                          },
                        );
                      },
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }

  void _resetSearch() {
    _searchController.clear();
    _searchSubject.add('');
  }
}
