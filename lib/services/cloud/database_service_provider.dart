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
  Future<CloudSquad?> fetchSquad(squadId) => _provider.fetchSquad(squadId);

  @override
  Future<CloudUser?> fetchUser(userId, bool isOwner) =>
      _provider.fetchUser(userId, isOwner);

  @override
  Future<bool> userExists({String? authId, String? name}) =>
      _provider.userExists(authId: authId, name: name);

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
}
