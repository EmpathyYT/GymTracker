import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtracker/cubit/main_page_cubit.dart';
import 'package:gymtracker/exceptions/cloud_exceptions.dart';
import 'package:gymtracker/services/cloud/cloud_user.dart';
import 'package:gymtracker/utils/dialogs/error_dialog.dart';
import 'package:gymtracker/utils/dialogs/success_dialog.dart';
import 'package:gymtracker/utils/dialogs/user_info_card_dialog.dart';
import 'package:rxdart/rxdart.dart';

import '../../../utils/widgets/big_centered_text_widget.dart';

class AddWarriorWidget extends StatefulWidget {
  const AddWarriorWidget({super.key});

  @override
  State<AddWarriorWidget> createState() => _AddWarriorWidgetState();
}

class _AddWarriorWidgetState extends State<AddWarriorWidget> {
  final TextEditingController _searchController = TextEditingController();
  final BehaviorSubject<String> _searchSubject = BehaviorSubject<String>();
  late Stream<List<CloudUser>?> _searchStream;

  @override
  void initState() {
    _searchStream = _searchSubject
        .debounceTime(const Duration(milliseconds: 300))
        .switchMap((query) {
      if (query.isEmpty) {
        return Stream.value(null);
      }
      return CloudUser.fetchUsersForSearch(query.trim().toLowerCase());
    });

    super.initState();
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
        if (state is KinViewer) {
          if (state.exception != null) {
            if (state.exception is AlreadySentFriendRequestException) {
              await showErrorDialog(
                  context, "The kinship call has already been sent.");
            } else if (state.exception is UserAlreadyFriendException) {
              await showErrorDialog(
                  context, "You and this warrior are already kin.");
            } else if (state.exception is GenericCloudException) {
              await showErrorDialog(
                  context, "The kinship call could not be delivered.");
            }
          } else if (state.success) {
            await showSuccessDialog(context, "Kinship Call Sent",
                "Your kinship request has been sent.");
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Send Kinship Call',
            style: GoogleFonts.oswald(
              fontSize: 35,
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
                  labelText: 'Seek out warrior',
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
                              await context
                                  .read<MainPageCubit>()
                                  .addUserReq(userToAddId: user.id);
                              _resetSearch();
                            },
                          ),
                          onTap: () async {
                            await showUserCard(
                              context: context,
                              user: user,
                              addUserAction: (context) async {
                                await context
                                    .read<MainPageCubit>()
                                    .addUserReq(userToAddId: user.id);
                                if (!context.mounted) return;
                                Navigator.of(context).pop();
                                _resetSearch();
                              },
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
//todo resert search controller when a request is sent
