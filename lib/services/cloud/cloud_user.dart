import 'dart:developer';

import 'package:equatable/equatable.dart';
import '../../constants/cloud_contraints.dart';
import 'database_controller.dart';

class CloudUser with EquatableMixin {
  static late final DatabaseController dbController;

  final String id;
  final List<String>? friends;
  final List<String>? squads;
  final String name;
  final DateTime timeCreated;
  final int? squadLimit;
  final String bio;
  final String? authId;
  final int level;
  int? pointsForNextLevel;
  double? averageWorkoutsPerMonth;
  int? completedWorkoutsCount;

  CloudUser({
    required this.id,
    required this.name,
    required this.bio,
    required this.level,
    required this.timeCreated,
    this.squadLimit,
    this.squads,
    this.friends,
    this.authId,
  });

  CloudUser.fromSupabaseMap(Map<String, dynamic> data)
    : id = (data[idFieldName] as int).toString(),
      name = data[nameFieldName],
      friends =
          (data[friendsFieldName] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      squads =
          (data[squadFieldName] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      timeCreated = DateTime.tryParse(data[timeCreatedFieldName] as String)!,
      squadLimit = data[squadLimitFieldName] ?? 0,
      bio = data[bioFieldName] ?? "",
      level = data[levelFieldName],
      authId = data[authIdFieldName] ?? "";

  @override
  String toString() {
    return 'CloudUser(id: $id, name: $name, bio: $bio, level: $level, timeCreated: $timeCreated, squadLimit: $squadLimit, squads: $squads, friends: $friends)';
  }

  @override
  List<Object?> get props => [id];

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
    String userName,
    String biography,
    bool gender,
  ) {
    return dbController.createUser(userName, biography, gender);
  }

  Future<void> removeFriend(String friendId) {
    return dbController.removeFriend(id, friendId);
  }

  Future<CloudUser> editUser(String name, String bio) {
    return dbController.editUser(id, name, bio);
  }

  Future<int> getCompletedWorkoutsCount() {
    return dbController.getWorkoutFinishedCount(id);
  }

  double _getAverageWorkoutsPerMonth() {
    final workoutCount = completedWorkoutsCount;
    final averageWorkouts = (workoutCount ?? 0) / 30;
    return double.parse(averageWorkouts.toStringAsPrecision(2));
  }

  Future<void> setStatistics() async {
    completedWorkoutsCount = await getCompletedWorkoutsCount();
    pointsForNextLevel = await dbController.getPointsLeftForNextLevel();
    averageWorkoutsPerMonth = _getAverageWorkoutsPerMonth();
    return;
  }

  static Future<List<CloudUser>> fetchUsersForSquadAdding(
    fromUser,
    squadId,
    filter,
  ) {
    return dbController.fetchUsersForSquadAdding(fromUser, squadId, filter);
  }
}
