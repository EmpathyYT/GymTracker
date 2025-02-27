import 'package:gymtracker/services/cloud/cloud_squads.dart';
import 'package:gymtracker/services/cloud/cloud_user.dart';
import 'package:gymtracker/services/cloud/database_controller.dart';
import 'package:gymtracker/services/cloud/supabase_database_controller.dart';

class DatabaseServiceProvider implements DatabaseController {
  final DatabaseController provider;

  const DatabaseServiceProvider(this.provider);

  factory DatabaseServiceProvider.supabase() =>
      DatabaseServiceProvider(SupabaseDatabaseController());

  @override
  Future<void> addUserToSquad(userId, squadId) =>
      provider.addUserToSquad(userId, squadId);

  @override
  Future<CloudSquad> createSquad(name, description) =>
      provider.createSquad(name, description);

  @override
  Future<CloudUser> createUser(userName, authId, biography) =>
      provider.createUser(userName, authId, biography);

  @override
  Future<void> readFriendRequest(toUser, fromUser) =>
      provider.readFriendRequest(toUser, fromUser);

  @override
  Future<void> readServerRequest(toUser, squadId) =>
      provider.readServerRequest(toUser, squadId);

  @override
  Future<void> rejectFriendRequest(toUser, fromUser) =>
      provider.rejectFriendRequest(toUser, fromUser);

  @override
  Future<void> rejectServerRequest(toUser, fromUser) =>
      provider.rejectServerRequest(toUser, fromUser);

  @override
  Future<void> removeFriend(userId, friendId) =>
      provider.removeFriend(userId, friendId);

  @override
  Future<void> removeUserFromSquad(userId, squadId) =>
      provider.removeUserFromSquad(userId, squadId);

  @override
  Future<void> sendFriendRequest(toUser, fromUser) =>
      provider.sendFriendRequest(toUser, fromUser);

  @override
  Future<void> sendServerRequest(toUser, squadId) =>
      provider.sendServerRequest(toUser, squadId);
}
