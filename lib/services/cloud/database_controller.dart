import 'package:gymtracker/services/cloud/cloud_notification.dart';
import 'package:gymtracker/services/cloud/cloud_squads.dart';
import 'package:gymtracker/services/cloud/cloud_user.dart';
import 'package:gymtracker/services/cloud/supabase_database_controller.dart';

abstract class DatabaseController {
  Future<void> sendFriendRequest(fromUser, toUser);

  Future<void> sendServerRequest(fromUser, toUser, squadId);

  Future<void> rejectFriendRequest(fromUser, toUser);

  Future<void> rejectServerRequest(toUser, serverId);

  Future<CloudSquad> removeUserFromSquad(userId, squadId);

  Future<CloudSquad> createSquad(name, description);

  Future<void> removeFriend(userId, friendId);

  Future<void> readFriendRequest(fromUser, toUser);

  Future<void> readServerRequest(toUser, squadId);

  Future<void> acceptServerRequest(toUser, squadId);

  Future<void> acceptFriendRequest(fromUser, toUser);

  Future<CloudUser> createUser(userName, biography, gender);

  Future<CloudSquad?> fetchSquad(squadId);

  Future<CloudUser?> fetchUser(userId, bool isOwner);

  Future<bool> userExists({String? authId, String? name});

  Future<List<CloudKinRequest>> fetchFriendRequests(userId);

  Future<List<CloudSquadRequest>> fetchServerRequests(userId);

  Stream<List<CloudUser>> fetchUsersForSearch(String query);

  Future<void> initialize();

  newFriendRequestsStream(
      userId, RealtimeCallback insertCallback, RealtimeCallback updateCallback);

  unsubscribeNewFriendRequestsStream();

  newServerRequestsStream(
      userId, RealtimeCallback insertCallback, RealtimeCallback updateCallback);

  unsubscribeNewServerRequestsStream();

  static Future<void> initCloudObjects(DatabaseController controller) async {
    CloudSquad.dbController = controller;
    CloudUser.dbController = controller;
    CloudKinRequest.dbController = controller;
    CloudSquadRequest.dbController = controller;
  }
}
