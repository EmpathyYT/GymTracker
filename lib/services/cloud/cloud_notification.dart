import '../../constants/cloud_contraints.dart';
import 'database_controller.dart';

sealed class CloudNotification {
  final int id;
  final int fromUser;
  final int toUser;
  final DateTime createdAt;
  bool read;

  CloudNotification({
    required this.id,
    required this.fromUser,
    required this.toUser,
    required this.createdAt,
    required this.read,
  });
}

sealed class CloudRequest extends CloudNotification {
  bool? accepted;

  CloudRequest({
    required super.id,
    required super.fromUser,
    required super.toUser,
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
          createdAt: map[timeCreatedFieldName],
        );

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
    final requests = await dbController.fetchFriendRequests(userId);
    return requests;
  }

  static friendRequestListener(userId, insertCallback, updateCallback) {
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
          createdAt: map[timeCreatedFieldName],
        );

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
    final serverRequests = await dbController.fetchServerRequests(userId);
    return serverRequests;
  }

  static serverRequestListener(userId, insertCallback, updateCallback) {
    dbController.newServerRequestsStream(
        userId, insertCallback, updateCallback);
  }

  static unsubscribeServerRequestListener() =>
      dbController.unsubscribeNewServerRequestsStream();
}
