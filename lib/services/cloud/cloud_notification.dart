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
  final String id;
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

sealed class CloudAchievement extends CloudNotification {
  String message;

  CloudAchievement({
    required super.id,
    required super.createdAt,
    required super.read,
    required this.message,
  });

  Future<void> readAchievement();

  CloudAchievement.fromMap(Map<String, dynamic> map)
    : message = map[messageFieldName],
      super(
        id: map[idFieldName].toString(),
        createdAt: DateTime.parse(map[timeCreatedFieldName]),
        read: map[readFieldName] ?? false,
      );
}

class CloudSquadAchievement extends CloudAchievement {
  final String squadId;
  final List<String> readBy;
  static late final DatabaseController dbController;

  CloudSquadAchievement({
    required super.id,
    required super.createdAt,
    required super.read,
    required super.message,
    required this.squadId,
    required this.readBy,
  });

  CloudSquadAchievement.fromMap(Map<String, dynamic> map)
    : squadId = map[squadIdFieldName].toString(),
      readBy =
          (map[readByFieldName] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      super(
        id: map[idFieldName].toString(),
        createdAt: DateTime.parse(map[timeCreatedFieldName]),
        read: false,
        message: map[messageFieldName],
      );

  static Future<List<CloudSquadAchievement>> fetchSquadAchievements(
    squadId,
  ) async {
    return dbController.fetchSquadAchievements(squadId);
  }

  @override
  List<Object?> get props => [id, squadId];

  @override
  String toString() {
    return 'CloudSquadAchievement{squadId: $squadId, id: $id, createdAt: $createdAt, read: $read, message: $message, readBy: $readBy}';
  }

  @override
  Future<void> readAchievement() async {
    read = true;
    return dbController.readSquadAchievement(id);
  }
}

class CloudUserAchievement extends CloudAchievement {
  final String userId;
  static late final DatabaseController dbController;

  CloudUserAchievement({
    required super.id,
    required super.createdAt,
    required super.read,
    required super.message,
    required this.userId,
  });

  CloudUserAchievement.fromMap(super.map)
    : userId = map[userIdFieldName].toString(),
      super.fromMap();

  static Future<List<CloudUserAchievement>> fetchUserAchievements(
    userId,
  ) async {
    return dbController.fetchUserAchievements(userId);
  }

  static achievementListener(userId, RealtimeCallback insertCallback) =>
      dbController.newAchievementsStream(userId, insertCallback);

  static unsubscribeAchievementListener() =>
      dbController.unsubscribeNewAchievementsStream();

  @override
  List<Object?> get props => [id, userId];

  @override
  String toString() {
    return 'CloudUserAchievements{userId: $userId, id: $id, createdAt: $createdAt, read: $read, message: $message}';
  }

  @override
  Future<void> readAchievement() async {
    read = true;
    return dbController.readUserAchievement(id);
  }
}

sealed class CloudRequest extends CloudNotification {
  bool? accepted;
  final String fromUser;
  final String toUser;

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
        id: map[idFieldName].toString(),
        fromUser: map[sendingUserFieldName].toString(),
        toUser: map[recipientFieldName].toString(),
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
    userId,
  ) async {
    return dbController.fetchFriendRequests(userId);
  }

  static friendRequestListener(
    userId,
    RealtimeCallback insertCallback,
    RealtimeCallback updateCallback,
  ) {
    dbController.newFriendRequestsStream(
      userId,
      insertCallback,
      updateCallback,
    );
  }

  static unsubscribeFriendRequestListener() =>
      dbController.unsubscribeNewFriendRequestsStream();
}

class CloudSquadRequest extends CloudRequest {
  static late final DatabaseController dbController;
  final String serverId;

  CloudSquadRequest({
    required super.id,
    required super.fromUser,
    required super.toUser,
    required super.createdAt,
    required super.read,
    required super.accepted,
    required this.serverId,
  });

  CloudSquadRequest.fromMap(Map<String, dynamic> map)
    : serverId = map[serverIdFieldName].toString(),
      super(
        id: map[idFieldName],
        fromUser: map[sendingUserFieldName].toString(),
        toUser: map[recipientFieldName].toString(),
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
    userId,
  ) async {
    return dbController.fetchSendingSquadRequests(userId);
  }

  static serverRequestListener(
    userId,
    RealtimeCallback insertCallback,
    RealtimeCallback updateCallback,
  ) {
    dbController.newServerRequestsStream(
      userId,
      insertCallback,
      updateCallback,
    );
  }

  static unsubscribeServerRequestListener() =>
      dbController.unsubscribeNewServerRequestsStream();
}
