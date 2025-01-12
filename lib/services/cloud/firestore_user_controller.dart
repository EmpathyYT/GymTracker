import 'dart:developer';
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymtracker/exceptions/auth_exceptions.dart';
import 'package:gymtracker/services/auth/firebase_auth_provider.dart';
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
      name = name.trim().toLowerCase();
      await users.doc(userId).set({
        squadFieldName: [],
        friendsFieldName: [],
        timeCreatedFieldName: DateTime.now(),
        nameFieldName: name,
        squadLimitFieldName: standardSquadLimit,
        bioFieldName: '',
        levelFieldName: 1,
      });

      return CloudUser(
        name: name,
        squads: const [],
        friends: const [],
        timeCreated: Timestamp.now(),
        documentId: userId,
        squadLimit: standardSquadLimit,
        bio: '',
        level: 1,
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

        case bioFieldName:
          await users.doc(userId).update({
            bioFieldName: value as String,
          });
          break;

        case levelFieldName:
          await users.doc(userId).update({
            levelFieldName: value as int,
          });
          break;

        case squadLimitFieldName:
          await users.doc(userId).update({
            squadLimitFieldName: value as int,
          });
          break;

        case pendingFRQFieldName:
          await users.doc(userId).update({
            pendingFRQFieldName: value as List<String>,
          });
          break;

        case pendingSquadReqFieldName:
          await users.doc(userId).update({
            pendingSquadReqFieldName: value as List<String>,
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

  Future<List<String>> fetchUserFriendRequests(String userId) async {
    final user = await users.doc(userId).get();
    return (user.data()?[pendingFRQFieldName] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList() ?? [];
  }

  Future<bool> userExists(String userName) {
    return users.where(nameFieldName, isEqualTo: userName).get().then((value) {
      return value.docs.isNotEmpty;
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchUsersForSearch(String userName) {
    return users
        .where(nameFieldName, isGreaterThanOrEqualTo: userName)
        .where(nameFieldName, isLessThanOrEqualTo: '$userName\uf8ff')
        .where(FieldPath.documentId, isNotEqualTo: FirebaseAuthProvider().currentUser!.id)
        .limit(7)
        .snapshots();

  }

  Future<void> sendFriendReq({
    required String userId,
    required String friendId,
}) async {
    try {
      if (userId == friendId) {
        throw CouldNotAddFriendException();
      }
      final userFriends = await fetchUserFriendRequests(userId);
      if (userFriends.contains(friendId)) {
        throw AlreadySentFriendRequestException();
      }

      await updateUser(
        fieldName: pendingFRQFieldName,
        userId: friendId,
        value: [...userFriends, userId],
      );

    } catch (e) {
      if (e is AlreadySentFriendRequestException) {
        rethrow;
      } else {
        throw GenericCloudException();
      }
    }
  }

  Future<void> addFriend({
    required String userId,
    required String friendId,
  }) async {
    try {
      final user = await fetchUser(userId);
      final friend = await fetchUser(friendId);

      if (user.friends.contains(friendId)) {
        throw UserAlreadyFriendException();
      }

      await updateUser(
        fieldName: friendsFieldName,
        userId: userId,
        value: [...user.friends, friendId],
      );

      await updateUser(
        fieldName: friendsFieldName,
        userId: friendId,
        value: [...friend.friends, userId],
      );
    } catch (e) {
      throw CouldNotAddFriendException();
    }
  }

}
