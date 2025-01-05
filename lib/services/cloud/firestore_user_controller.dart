import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymtracker/services/cloud/cloud_contraints.dart';
import 'package:gymtracker/services/cloud/cloud_user.dart';

import '../../exceptions/cloud_exceptions.dart';

class FirestoreUserController {
  final users = FirebaseFirestore.instance.collection('users');

  static final FirestoreUserController _instance =
      FirestoreUserController._internal();

  FirestoreUserController._internal();

  factory FirestoreUserController() => _instance;

  Future<CloudUser> createUser({
    required String userId,
    required String name,
    //required String photoUrl,
  }) async {
    try {
      await users.doc(userId).set({
        squadFieldName: [],
        friendsFieldName: [],
        timeCreatedFieldName: DateTime.now(),
        nameFieldName: name,
        squadLimitFieldName: standardSquadLimit,
      });

      return CloudUser(
        name: name,
        squads: const [],
        friends: const [],
        timeCreated: Timestamp.now(),
        documentId: userId,
        squadLimit: standardSquadLimit,
      );

    } catch (e) {
      throw CouldNotCreateUserException();
    }
  }

  Future<void> updateUser({
    required String fieldName,
    required String userId,
    required dynamic value,
  }) async {
    try {
      switch (fieldName) {
        case squadFieldName:
          await users.doc(userId).update({
            squadFieldName: value as List<String>,
          });
          break;

        case friendsFieldName:
          await users.doc(userId).update({
            friendsFieldName: value as List<String>,
          });
          break;

        case nameFieldName:
          await users.doc(userId).update({
            nameFieldName: value as String,
          });
          break;
      }
    } catch (e) {
      throw CouldNotUpdateUserException();
    }
  }

  Future<void> deleteUser({required String userId}) async {
    try {
      await users.doc(userId).delete();
    } catch (e) {
      throw CouldNotDeleteUserException();
    }
  }

  Future<CloudUser> fetchUser(String userId) async {
    final user = await users.doc(userId).get();


    return CloudUser.fromSnapshot(user);
  }

  Future<bool> userExists(String userName) {
    return users.where(nameFieldName, isEqualTo: userName).get().then((value) {
      return value.docs.isNotEmpty;
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchUsersForSearch(String userName) {
    return users
        .where("username", isGreaterThanOrEqualTo: userName)
        .where("username", isLessThanOrEqualTo: '$userName\uf8ff')
        .snapshots();

  }
}
