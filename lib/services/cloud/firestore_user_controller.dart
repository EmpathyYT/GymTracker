import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymtracker/services/cloud/cloud_contraints.dart';
import 'package:gymtracker/services/cloud/cloud_user.dart';

import '../../exceptions/cloud_exceptions.dart';

class FireStoreUserController {
  final users = FirebaseFirestore.instance.collection('users');

  static final FireStoreUserController _instance = FireStoreUserController
      ._internal();

  FireStoreUserController._internal();

  factory FireStoreUserController() => _instance;

  Future<void> createUser({
    required String userId,
    required String name,
    //required String photoUrl,

  }) async {
    try {
      await users.doc(userId).set({
        'name': name,
        'squads': [],
        'friends': [],
        'time_created': DateTime.now(),
        'user_name': name,
      });
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
}

Future<CloudUser> fetchUser(String userId) async {
  final user = await FirebaseFirestore.instance.collection('users').doc(userId).get();
  return CloudUser(
    name: user.data()![nameFieldName],
    squads: user.data()![squadFieldName],
    friends: user.data()![friendsFieldName],
    timeCreated: user.data()![timeCreatedFieldName],
    documentId: userId,
  );
}