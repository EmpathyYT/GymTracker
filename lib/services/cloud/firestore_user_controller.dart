import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymtracker/constants/cloud_contraints.dart';
import 'package:gymtracker/services/auth/firebase_auth_provider.dart';
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
        timeCreatedFieldName: DateTime.now(),
        nameFieldName: name,
        squadLimitFieldName: standardSquadLimit,
        bioFieldName: '',
        levelFieldName: 1,
      });

      await users
          .doc(userId)
          .collection(userId)
          .doc(sensitiveInformationDocumentName)
          .set({
        squadFieldName: [],
        friendsFieldName: [],
      });

      return CloudUser.newUser(userId, name);
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
          await users
              .doc(userId)
              .collection(userId)
              .doc(sensitiveInformationDocumentName)
              .update({
            squadFieldName: value as List<String>,
          });
          break;

        case friendsFieldName:
          await users
              .doc(userId)
              .collection(userId)
              .doc(sensitiveInformationDocumentName)
              .update({
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

  Future<CloudUser> fetchUser(String userId, {bool isPersonal = false}) async {
    try {
      final publicSnapshot = await users.doc(userId).get();

      if (isPersonal) {
        final sensitiveSnapshot = await users
            .doc(userId)
            .collection(userId)
            .doc(sensitiveInformationDocumentName)
            .get();

        return CloudUser.privateUserFromSnapshot(
          publicSnapshot,
          sensitiveSnapshot,
        );
      } else {
        return CloudUser.publicUserFromSnapshot(publicSnapshot);
      }
    } catch (e) {
      throw CouldNotFetchUserException();
    }
  }

  Future<List<String>> fetchUserFriends(String userId) async {
    if (FirebaseAuthProvider().currentUser!.id != userId) {
      throw CouldNotFetchUserException();
    }

    final userfrs = await users
        .doc(userId)
        .collection(userId)
        .doc(sensitiveInformationDocumentName)
        .get();

    return userfrs.data()![friendsFieldName] as List<String>;
  }

  Future<bool> isUserSentFriendRequest(String userId, String friendId) async {
    try {
      final userfrq = await users
          .doc(friendId)
          .collection(friendId)
          .doc(requestsDocumentName)
          .collection(pendingFRQFieldName)
          .doc(userId)
          .get();

      return userfrq.exists && userfrq.data()!.containsKey(isAccepted);
    } catch (e) {
      throw CouldNotFetchUserException();
    }
  }

  Future<bool> userExists(String userName) {
    return users.where(nameFieldName, isEqualTo: userName).get().then((value) {
      return value.docs.isNotEmpty;
    });
  }

  Future<bool> isAlreadySentFriendRequest(
      String userId, String friendId) async {
    final userfrq = await users
        .doc(friendId)
        .collection(friendId)
        .doc(requestsDocumentName)
        .collection(pendingFRQFieldName)
        .doc(userId)
        .get();

    return userfrq.exists && !userfrq.data()!.containsKey(isAccepted);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchUsersForSearch(
      String userName) {
    return users
        .where(nameFieldName, isGreaterThanOrEqualTo: userName)
        .where(nameFieldName, isLessThanOrEqualTo: '$userName\uf8ff')
        .where(FieldPath.documentId,
            isNotEqualTo: FirebaseAuthProvider().currentUser!.id)
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

      final userFriends = await fetchUser(userId, isPersonal: true);
      if (userFriends.friends!.contains(friendId)) {
        throw UserAlreadyFriendException();
      }

      if (await isAlreadySentFriendRequest(userId, friendId)) {
        throw AlreadySentFriendRequestException();
      }

      if (await isUserSentFriendRequest(userId, friendId)) {
        addFriend(userId: userId, friendId: friendId);
      }

      await users
          .doc(friendId)
          .collection(friendId)
          .doc(requestsDocumentName)
          .collection(pendingFRQFieldName)
          .doc(userId)
          .set({
        sendingUserFieldName: userId,
      });

      await users
          .doc(userId)
          .collection(userId)
          .doc(requestsDocumentName)
          .collection(pendingFRQFieldName)
          .doc(friendId)
          .set({
        recipientFieldName: userId,
        isAccepted: false,
      });
    } on UserAlreadyFriendException {
      rethrow;
    } on AlreadySentFriendRequestException {
      rethrow;
    } catch (e) {
      throw GenericCloudException();
    }
  }

  Future<void> acceptFrq(String userId, String friendId) async {
    try {
      final frq = await users
          .doc(friendId)
          .collection(friendId)
          .doc(requestsDocumentName)
          .collection(pendingFRQFieldName)
          .doc(userId)
          .get();

      if (frq.exists) {
        frq.reference.update({
          isAccepted: true,
        });
      }
    } catch (e) {
      throw GenericCloudException();
    }
  }

  Future<void> deleteFRQ(String userId, String friendId) async {
    try {
      await users
          .doc(userId)
          .collection(userId)
          .doc(requestsDocumentName)
          .collection(pendingFRQFieldName)
          .doc(friendId)
          .delete();
    } catch (e) {
      throw CouldNotDeleteFriendRequestException();
    }
  }

  Future<void> updateFriends(String userId, String newFriendId) async {
    try {
      final user = await fetchUser(userId, isPersonal: true);
      if (user.friends!.contains(newFriendId)) {
        throw UserAlreadyFriendException();
      }

      await users
          .doc(userId)
          .collection(userId)
          .doc(sensitiveInformationDocumentName)
          .update({
        friendsFieldName: [...?user.friends, newFriendId],
      });
    } catch (e) {
      throw CouldNotAddFriendException();
    }
  }

  Future<void> addSquad(String userId, String squadId) async {
    try {
      if (userId != FirebaseAuthProvider().currentUser!.id) {
        throw CouldNotAddMemberToSquadException();
      }
      final user = await fetchUser(userId, isPersonal: true);
      if (user.squads!.contains(squadId)) {
        throw GenericCloudException();
      }

      await users
          .doc(userId)
          .collection(userId)
          .doc(sensitiveInformationDocumentName)
          .update({
        squadFieldName: [...?user.squads, squadId],
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeSquad(String userId, String squadId) async {
    try {
      if (userId != FirebaseAuthProvider().currentUser!.id) {
        throw CouldNotRemoveMemberFromSquadException();
      }
      final user = await fetchUser(userId, isPersonal: true);
      if (!user.squads!.contains(squadId)) {
        throw GenericCloudException();
      }

      await users
          .doc(userId)
          .collection(userId)
          .doc(sensitiveInformationDocumentName)
          .update({
        squadFieldName: [
          ...user.squads!.where((element) => element != squadId)
        ],
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addFriend({
    required String userId,
    required String friendId,
  }) async {
    try {
      final user = await fetchUser(userId, isPersonal: true);

      if (user.friends!.contains(friendId)) {
        throw UserAlreadyFriendException();
      }

      await deleteFRQ(userId, friendId);

      if (await isUserSentFriendRequest(userId, friendId)) {
        await acceptFrq(userId, friendId);
      }

      await updateFriends(userId, friendId);
    } catch (e) {
      throw CouldNotAddFriendException();
    }
  }
}
