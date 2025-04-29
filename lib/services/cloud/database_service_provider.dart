import 'package:gymtracker/services/auth/auth_provider.dart';
import 'package:gymtracker/services/cloud/cloud_notification.dart';
import 'package:gymtracker/services/cloud/cloud_squads.dart';
import 'package:gymtracker/services/cloud/cloud_user.dart';
import 'package:gymtracker/services/cloud/database_controller.dart';
import 'package:gymtracker/services/cloud/supabase_database_controller.dart';

class DatabaseServiceProvider implements DatabaseController {
  final DatabaseController _provider;

  const DatabaseServiceProvider(this._provider);

  factory DatabaseServiceProvider.supabase(AuthProvider auth) =>
      DatabaseServiceProvider(SupabaseDatabaseController(auth));

  @override
  Future<CloudSquad> createSquad(name, description) =>
      _provider.createSquad(name, description);

  @override
  Future<CloudUser> createUser(userName, biography, gender) =>
      _provider.createUser(userName, biography, gender);

  @override
  Future<void> readFriendRequest(toUser, fromUser) =>
      _provider.readFriendRequest(toUser, fromUser);

  @override
  Future<void> readServerRequest(toUser, squadId) =>
      _provider.readServerRequest(toUser, squadId);

  @override
  Future<void> rejectFriendRequest(toUser, fromUser) =>
      _provider.rejectFriendRequest(toUser, fromUser);

  @override
  Future<void> rejectServerRequest(toUser, serverId) =>
      _provider.rejectServerRequest(toUser, serverId);

  @override
  Future<void> removeFriend(userId, friendId) =>
      _provider.removeFriend(userId, friendId);

  @override
  Future<CloudSquad> removeUserFromSquad(userId, squadId) =>
      _provider.removeUserFromSquad(userId, squadId);

  @override
  Future<void> sendFriendRequest(toUser, fromUser) =>
      _provider.sendFriendRequest(toUser, fromUser);

  @override
  Future<void> sendServerRequest(fromUser, toUser, squadId) =>
      _provider.sendServerRequest(fromUser, toUser, squadId);

  @override
  Future<CloudSquad?> fetchSquad(squadId, isMember) =>
      _provider.fetchSquad(squadId, isMember);

  @override
  Future<CloudUser?> fetchUser(userId, bool isOwner) =>
      _provider.fetchUser(userId, isOwner);

  @override
  Future<bool> userExists({String? authId, String? name}) =>
      _provider.userExists(authId: authId, name: name);

  @override
  Future<List<CloudUser>> fetchUsersForSquadAdding(fromUser, squadId, filter) =>
      _provider.fetchUsersForSquadAdding(fromUser, squadId, filter);

  @override
  Future<List<CloudKinRequest>> fetchFriendRequests(userId) =>
      _provider.fetchFriendRequests(userId);

  @override
  Future<List<CloudSquadRequest>> fetchServerRequests(userId) =>
      _provider.fetchServerRequests(userId);

  @override
  newFriendRequestsStream(userId, insertCallback, updateCallback) =>
      _provider.newFriendRequestsStream(userId, insertCallback, updateCallback);

  @override
  newServerRequestsStream(userId, RealtimeCallback insertCallback,
          RealtimeCallback updateCallback) =>
      _provider.newServerRequestsStream(userId, insertCallback, updateCallback);

  @override
  Future<List<CloudSquadRequest>> fetchSendingSquadRequests(userId) =>
      _provider.fetchSendingSquadRequests(userId);

  @override
  Future<List<CloudKinRequest>> fetchSendingFriendRequests(userId) =>
      _provider.fetchFriendRequests(userId);

  @override
  unsubscribeNewFriendRequestsStream() =>
      _provider.unsubscribeNewFriendRequestsStream();

  @override
  unsubscribeNewServerRequestsStream() =>
      _provider.unsubscribeNewServerRequestsStream();

  @override
  Stream<List<CloudUser>> fetchUsersForSearch(String query) =>
      _provider.fetchUsersForSearch(query);

  @override
  Future<void> acceptFriendRequest(fromUser, toUser) =>
      _provider.acceptFriendRequest(fromUser, toUser);

  @override
  Future<void> acceptServerRequest(toUser, squadId) =>
      _provider.acceptServerRequest(toUser, squadId);

  @override
  Future<void> initialize() => _provider.initialize();

  @override
  Future<CloudUser> editUser(String id, String username, String biography) =>
      _provider.editUser(id, username, biography);

  @override
  Future<List<CloudAchievement>> fetchAchievements({squadId, userId}) =>
      _provider.fetchAchievements(squadId: squadId, userId: userId);

  @override
  newAchievementsStream(userId, RealtimeCallback insertCallback) =>
      _provider.newAchievementsStream(userId, insertCallback);

  @override
  unsubscribeNewAchievementsStream() =>
      _provider.unsubscribeNewAchievementsStream();

  @override
  Future<void> leaveSquad(squadId) => _provider.leaveSquad(squadId);

  @override
  Future<CloudSquad> editSquad(String id, String name, String description) =>
      _provider.editSquad(id, name, description);
}
