import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../constants/cloud_contraints.dart';
import 'database_controller.dart';

@immutable
class CloudUser with EquatableMixin {
  static late final DatabaseController dbController;

  final String id;
  final List<String>? friends;
  final List<String>? squads;
  final String name;
  final DateTime timeCreated;
  final int? squadLimit;
  final String bio;
  final int? authId;
  final int level;

  const CloudUser(
      {required this.id,
      required this.name,
      required this.bio,
      required this.level,
      required this.timeCreated,
      this.squadLimit,
      this.squads,
      this.friends,
      this.authId});

  CloudUser.fromMap(Map<String, dynamic> data)
      : id = data[idFieldName],
        name = data[nameFieldName],
        friends = List<String>.from(data[friendsFieldName] ?? []),
        squads = List<String>.from(data[squadFieldName] ?? []),
        timeCreated = data[timeCreatedFieldName] as DateTime,
        squadLimit = data[squadLimitFieldName] ?? 0,
        bio = data[bioFieldName] ?? "",
        level = data[levelFieldName],
        authId = data[authIdFieldName];

  @override
  List<Object?> get props => [authId];

  ///In case param [isOwner] is true, pass the authId as the userId.
  static Future<CloudUser?> fetchUser(userId, bool isOwner) {
    return dbController.fetchUser(userId, isOwner);
  }

  static Stream<List<CloudUser>> fetchUsersForSearch(String username) {
    return dbController.fetchUsersForSearch(username);
  }

  static Future<bool> userExists({String? authId, String? name}) {
    return dbController.userExists(authId: authId, name: name);
  }

  static Future<CloudUser> createUser(
      String userName, String biography, bool gender) {
    return dbController.createUser(userName, biography, gender);
  }

  Future<void> removeFriend(String friendId) {
    return dbController.removeFriend(id, friendId);
  }
}
