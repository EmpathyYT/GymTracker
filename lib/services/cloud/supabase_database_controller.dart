import 'package:gymtracker/services/cloud/cloud_squads.dart';
import 'package:gymtracker/services/cloud/cloud_user.dart';
import 'package:gymtracker/services/cloud/database_controller.dart';

class SupabaseDatabaseController implements DatabaseController {
  @override
  Future<void> addUserToSquad(userId, squadId) {
    // TODO: implement addUserToSquad
    throw UnimplementedError();
  }

  @override
  Future<CloudSquad> createSquad(name, description) {
    // TODO: implement createSquad
    throw UnimplementedError();
  }

  @override
  Future<CloudUser> createUser(userName, authId, biography) {
    // TODO: implement createUser
    throw UnimplementedError();
  }

  @override
  Future<void> readFriendRequest(toUser, fromUser) {
    // TODO: implement readFriendRequest
    throw UnimplementedError();
  }

  @override
  Future<void> readServerRequest(toUser, squadId) {
    // TODO: implement readServerRequest
    throw UnimplementedError();
  }

  @override
  Future<void> rejectFriendRequest(toUser, fromUser) {
    // TODO: implement rejectFriendRequest
    throw UnimplementedError();
  }

  @override
  Future<void> rejectServerRequest(toUser, fromUser) {
    // TODO: implement rejectServerRequest
    throw UnimplementedError();
  }

  @override
  Future<void> removeFriend(userId, friendId) {
    // TODO: implement removeFriend
    throw UnimplementedError();
  }

  @override
  Future<void> removeUserFromSquad(userId, squadId) {
    // TODO: implement removeUserFromSquad
    throw UnimplementedError();
  }

  @override
  Future<void> sendFriendRequest(toUser, fromUser) {
    // TODO: implement sendFriendRequest
    throw UnimplementedError();
  }

  @override
  Future<void> sendServerRequest(toUser, squadId) {
    // TODO: implement sendServerRequest
    throw UnimplementedError();
  }
}