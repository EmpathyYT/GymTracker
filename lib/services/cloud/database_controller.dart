import 'package:gymtracker/services/cloud/cloud_squads.dart';
import 'package:gymtracker/services/cloud/cloud_user.dart';

abstract class DatabaseController {
  Future<void> sendFriendRequest(toUser, fromUser);
  Future<void> sendServerRequest(toUser, squadId);
  Future<void> rejectFriendRequest(toUser, fromUser);
  Future<void> rejectServerRequest(toUser, fromUser);
  Future<void> addUserToSquad(userId, squadId);
  Future<void> removeUserFromSquad(userId, squadId);
  Future<CloudSquad> createSquad(name, description);
  Future<void> removeFriend(userId, friendId);
  Future<void> readFriendRequest(toUser, fromUser);
  Future<void> readServerRequest(toUser, squadId);
  Future<CloudUser> createUser(userName, authId, biography);

}