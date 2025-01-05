import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gymtracker/services/cloud/firestore_user_controller.dart';
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
      return _firestoreUserController.fetchUsersForSearch(query);
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
      children: [
        const Text("Enter Warrior User Name:"),
      ],
    );
  }
}
