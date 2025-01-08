import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gymtracker/services/cloud/cloud_contraints.dart';
import 'package:gymtracker/services/cloud/firestore_user_controller.dart';
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
    return Column(
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
                log(users.toString());
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];

                    return ListTile(
                      title: Text(user.data()[nameFieldName],),
                      trailing: IconButton(
                        icon: const Icon(Icons.person_add),
                        onPressed: () {

                        },

                      ),
                      onTap: () async {
                        await showUserCard(
                          context: context,
                          userData: user.data(),
                        );
                      },
                    );
                  },
                );
              }),
        ),
      ],
    );
  }
}
