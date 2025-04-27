import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:gymtracker/services/cloud/supabase_database_controller.dart';

import '../../constants/cloud_contraints.dart';
import 'database_controller.dart';

typedef RealtimeNotificationsShape = Map<int, List<Map<String, dynamic>>>;
/*
First Map: 0 -> insert, 1 -> update
List: If update the first element represents the old record,
  the second element represents the new record
 */

sealed class CloudNotification with EquatableMixin {
  final int id;
  final DateTime createdAt;
  bool read;

  CloudNotification({
    required this.id,
    required this.createdAt,
    required this.read,
  });

  @override
  List<Object?> get props => [id];
}

class CloudAchievement extends CloudNotification {
  String message;
  static late final DatabaseController dbController;

  CloudAchievement({
    required super.id,
    required super.createdAt,
    required super.read,
    required this.message,
  });

  void readAchievement() {
    read = true;
  } // todo will keep track of reading through cache

  CloudAchievement.fromMap(Map<String, dynamic> map)
      : message = map[messageFieldName],
        super(
          id: map[idFieldName],
          createdAt: DateTime.parse(map[timeCreatedFieldName]),
          read: false,
        );

  static Future<List<CloudAchievement>> fetchUserAchievements(userId) async {
    return dbController.fetchAchievements(userId: userId);
  }

  static Future<List<CloudAchievement>> fetchSquadAchievements(squadId) async {
    return dbController.fetchAchievements(squadId: squadId);
  }

  static achievementListener(userId, RealtimeCallback insertCallback) =>
      dbController.newAchievementsStream(userId, insertCallback);

  static unsubscribeAchievementListener() =>
      dbController.unsubscribeNewAchievementsStream();
}

sealed class CloudRequest extends CloudNotification {
  bool? accepted;
  final int fromUser;
  final int toUser;

  CloudRequest({
    required super.id,
    required this.fromUser,
    required this.toUser,
    required super.createdAt,
    required super.read,
    required this.accepted,
  });

  Future<void> readRequest();

  Future<void> rejectRequest();

  Future<void> acceptRequest();
}

class CloudKinRequest extends CloudRequest {
  static late final DatabaseController dbController;

  CloudKinRequest({
    required super.id,
    required super.fromUser,
    required super.toUser,
    required super.createdAt,
    required super.read,
    required super.accepted,
  });

  CloudKinRequest.fromMap(Map<String, dynamic> map)
      : super(
          id: map[idFieldName],
          fromUser: map[sendingUserFieldName],
          toUser: map[recipientFieldName],
          read: map[readFieldName],
          accepted: map[acceptedFieldName],
          createdAt: DateTime.parse(map[timeCreatedFieldName]),
        );

  @override
  List<Object?> get props => [id];

  @override
  String toString() {
    return 'CloudKinRequest{id: $id, fromUser: $fromUser, toUser: $toUser, createdAt: $createdAt, read: $read, accepted: $accepted}';
  }

  @override
  Future<void> readRequest() async {
    dbController.readFriendRequest(fromUser, toUser);
    read = true;
  }

  @override
  Future<void> rejectRequest() async {
    dbController.rejectFriendRequest(fromUser, toUser);
    accepted = null;
  }

  @override
  Future<void> acceptRequest() async {
    dbController.acceptFriendRequest(fromUser, toUser);
    accepted = true;
  }

  static Future<void> sendRequest(fromUser, toUser) async {
    try {
      dbController.sendFriendRequest(fromUser, toUser);
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<CloudKinRequest>> fetchFriendRequests(userId) async {
    return dbController.fetchFriendRequests(userId);
  }

  static Future<List<CloudKinRequest>> fetchSendingFriendRequests(
      userId) async {
    return dbController.fetchFriendRequests(userId);
  }

  static friendRequestListener(userId, RealtimeCallback insertCallback,
      RealtimeCallback updateCallback) {
    dbController.newFriendRequestsStream(
        userId, insertCallback, updateCallback);
  }

  static unsubscribeFriendRequestListener() =>
      dbController.unsubscribeNewFriendRequestsStream();
}

class CloudSquadRequest extends CloudRequest {
  static late final DatabaseController dbController;
  final int serverId;

  CloudSquadRequest(
      {required super.id,
      required super.fromUser,
      required super.toUser,
      required super.createdAt,
      required super.read,
      required super.accepted,
      required this.serverId});

  CloudSquadRequest.fromMap(Map<String, dynamic> map)
      : serverId = map[serverIdFieldName],
        super(
          id: map[idFieldName],
          fromUser: map[sendingUserFieldName],
          toUser: map[recipientFieldName],
          read: map[readFieldName],
          accepted: map[acceptedFieldName],
          createdAt: DateTime.parse(map[timeCreatedFieldName]),
        );

  @override
  List<Object?> get props => [id];

  @override
  String toString() {
    return 'CloudSquadRequest{serverId: $serverId, id: $id, fromUser: $fromUser, toUser: $toUser, createdAt: $createdAt, read: $read, accepted: $accepted}';
  }

  @override
  Future<void> rejectRequest() async {
    dbController.rejectServerRequest(toUser, serverId);
    accepted = null;
  }

  @override
  Future<void> readRequest() async {
    dbController.readServerRequest(toUser, serverId);
    read = true;
  }

  @override
  Future<void> acceptRequest() async {
    dbController.acceptServerRequest(toUser, serverId);
    accepted = true;
  }

  static Future<void> sendServerRequest(fromUser, toUser, serverId) async {
    dbController.sendServerRequest(fromUser, toUser, serverId);
  }

  static Future<List<CloudSquadRequest>> fetchServerRequests(userId) async {
   return dbController.fetchServerRequests(userId);

  }

  static Future<List<CloudSquadRequest>> fetchSendingSquadRequests(
      userId) async {
    return dbController.fetchSendingSquadRequests(userId);
  }

  static serverRequestListener(userId, RealtimeCallback insertCallback,
      RealtimeCallback updateCallback) {
    dbController.newServerRequestsStream(
        userId, insertCallback, updateCallback);
  }

  static unsubscribeServerRequestListener() =>
      dbController.unsubscribeNewServerRequestsStream();
}
