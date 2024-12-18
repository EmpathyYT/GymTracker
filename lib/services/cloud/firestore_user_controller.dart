import 'package:cloud_firestore/cloud_firestore.dart';

import '../../exceptions/cloud_exceptions.dart';

class FireStoreUserController {
  final users = FirebaseFirestore.instance.collection('users');

  static final FireStoreUserController _instance = FireStoreUserController._internal();
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

}