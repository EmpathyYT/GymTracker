import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gymtracker/cubit/main_page_cubit.dart';
import 'package:gymtracker/exceptions/cloud_exceptions.dart';
import 'package:gymtracker/constants/cloud_contraints.dart';
import 'package:gymtracker/services/cloud/firestore_user_controller.dart';
import 'package:gymtracker/utils/dialogs/error_dialog.dart';
import 'package:gymtracker/utils/dialogs/success_dialog.dart';
import 'package:gymtracker/utils/dialogs/user_info_card_dialog.dart';
import 'package:rxdart/rxdart.dart';

class AddWarriorWidget extends StatefulWidget {
  const AddWarriorWidget({super.key});

  @override
  State<AddWarriorWidget> createState() => _AddWarriorWidgetState();
}

class _AddWarriorWidgetState extends State<AddWarriorWidget> {
  final TextEditingController _searchController = TextEditingController();
  final BehaviorSubject<String> _searchSubject = BehaviorSubject<String>();
  final FirestoreUserController _firestoreUserController =
      FirestoreUserController();
  late Stream<QuerySnapshot<Map<String, dynamic>>?> _searchStream;

  @override
  void initState() {
    _searchStream = _searchSubject
        .debounceTime(const Duration(milliseconds: 300))
        .switchMap((query) {
      if (query.isEmpty) {
        return Stream.value(null);
      }
      return _firestoreUserController
          .fetchUsersForSearch(query.trim().toLowerCase());
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
        if (state.success) {
          await showSuccessDialog(
              context, "Request Sent", "The friend request has been sent.");
        }
        if (context.mounted) {
          if (state.exception is AlreadySentFriendRequestException) {
            await showErrorDialog(
                context, "You have already sent a friend request to this user");
          } else if (state.exception is UserAlreadyFriendException) {
            await showErrorDialog(
                context, "You are already friends with this user");
          } else if (state.exception is GenericCloudException) {
            await showErrorDialog(context, "An error occurred");
          }
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(padding: EdgeInsets.all(1.5)),
          TextField(
            controller: _searchController,
            onChanged: _searchSubject.add,
            decoration: const InputDecoration(
              labelText: 'Search for accounts',
              border: OutlineInputBorder(),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>?>(
                stream: _searchStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Text('Search for accounts'),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('An error occurred'),
                    );
                  }

                  if (snapshot.data == null) {
                    return const Center(
                      child: Text('Search for accounts'),
                    );
                  }

                  final users = snapshot.data!.docs;
                  if (users.isEmpty) {
                    return const Center(
                      child: Text('No users found'),
                    );
                  }
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];

                      return ListTile(
                        title: Text(
                          user.data()[nameFieldName],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.person_add),
                          onPressed: () {
                            context
                                .read<MainPageCubit>()
                                .addUserReq(userToAddId: user.id);
                          },
                        ),
                        onTap: () async {
                          await showUserCard(
                            context: context,
                            userData: user.data(),
                            addUserAction: () {
                              context
                                  .read<MainPageCubit>()
                                  .addUserReq(userToAddId: user.id);
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
    );
  }
}
