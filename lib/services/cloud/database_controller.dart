import 'package:gymtracker/services/cloud/cloud_notification.dart';
import 'package:gymtracker/services/cloud/cloud_squads.dart';
import 'package:gymtracker/services/cloud/cloud_user.dart';


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
  Future<CloudUser> createUser(userName, biography);
  Future<CloudSquad?> fetchSquad(squadId);
  Future<CloudUser?> fetchUser(userId, bool isOwner);
  Future<bool> userExists({String? authId, String? name});
  Future<List<CloudKinRequest>> fetchFriendRequests(userId);
  Future<List<CloudSquadRequest>> fetchServerRequests(userId);
  Stream<List<CloudUser>> fetchUsersForSearch(String query);

  newFriendRequestsStream(userId, insertCallback, updateCallback);
  unsubscribeNewFriendRequestsStream();
  newServerRequestsStream(userId, insertCallback, updateCallback);
  unsubscribeNewServerRequestsStream();


  static void initCloudObjects(DatabaseController controller) {
    CloudSquad.dbController = controller;
    CloudUser.dbController = controller;
    CloudKinRequest.dbController = controller;
    CloudSquadRequest.dbController = controller;
  }
}