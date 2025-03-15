import 'package:gymtracker/constants/cloud_contraints.dart';
import 'package:gymtracker/exceptions/auth_exceptions.dart';
import 'package:gymtracker/exceptions/cloud_exceptions.dart';
import 'package:gymtracker/services/cloud/cloud_notification.dart';
import 'package:gymtracker/services/cloud/cloud_squads.dart';
import 'package:gymtracker/services/cloud/cloud_user.dart';
import 'package:gymtracker/services/cloud/database_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/auth_provider.dart';

class SupabaseDatabaseController implements DatabaseController {
  late final SupabaseClient _supabase;
  final AuthProvider _auth;

  SupabaseDatabaseController(this._auth);

  @override
  Future<CloudSquad> createSquad(name, description) async {
    if (_auth.currentUser == null) throw UserNotLoggedInException();
    final data = await _supabase.from(squadTableName).insert(
      {
        squadNameFieldName: name,
        squadDescriptionFieldName: description,
        ownerUserFieldId: _auth.currentUser!.id,
      },
    ).select();

    return CloudSquad.fromMap(data[0]);
  }

  @override
  Future<CloudUser> createUser(userName, biography) async {
    final data = await _supabase.from(userTableName).insert(
      {
        nameFieldName: userName,
        authIdFieldName: _auth.currentUser!.id,
        bioFieldName: biography,
      },
    ).select();
    return CloudUser.fromMap(data[0]);
  }

  @override
  Future<void> readFriendRequest(fromUser, toUser) async {
    if (_auth.currentUser == null) throw UserNotLoggedInException();
    await _supabase
        .from(pendingFriendRequestsTableName)
        .update({readFieldName: true})
        .eq(sendingUserFieldName, fromUser)
        .eq(recipientFieldName, toUser)
        .not(acceptedFieldName, 'eq', null);
  }

  @override
  Future<void> readServerRequest(toUser, squadId) async {
    if (_auth.currentUser == null) throw UserNotLoggedInException();
    await _supabase
        .from(pendingServerRequestsTableName)
        .update({readFieldName: true})
        .eq(recipientFieldName, toUser)
        .eq(idFieldName, squadId)
        .not(acceptedFieldName, 'eq', null);
  }

  @override
  Future<void> rejectFriendRequest(fromUser, toUser) async {
    if (_auth.currentUser == null) throw UserNotLoggedInException();
    await _supabase
        .from(pendingFriendRequestsTableName)
        .update({acceptedFieldName: null})
        .eq(sendingUserFieldName, fromUser)
        .eq(recipientFieldName, toUser)
        .not(acceptedFieldName, 'eq', null);
  }

  @override
  Future<void> rejectServerRequest(toUser, serverId) async {
    if (_auth.currentUser == null) throw UserNotLoggedInException();
    await _supabase
        .from(pendingServerRequestsTableName)
        .update({acceptedFieldName: null})
        .eq(recipientFieldName, toUser)
        .eq(idFieldName, serverId)
        .not(acceptedFieldName, 'eq', null);
  }

  @override
  Future<void> removeFriend(userId, friendId) async {
    if (_auth.currentUser == null) throw UserNotLoggedInException();
    try {
      await _supabase.rpc(
        "remove_friend",
        params: {
          'userid': userId,
          'friendid': friendId,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CloudSquad> removeUserFromSquad(userId, squadId) async {
    if (_auth.currentUser == null) throw UserNotLoggedInException();

    final server = await _supabase
        .from(squadTableName)
        .select("members")
        .eq(idFieldName, squadId);

    final serverMembers = server[0]["members"] as List<int>;
    if (!serverMembers.remove(userId)) throw UserNotInSquadException();

    final data = await _supabase
        .from(squadTableName)
        .update({membersFieldName: serverMembers})
        .eq(idFieldName, squadId)
        .select();

    return CloudSquad.fromMap(data[0]);
  }

  @override
  Future<void> sendFriendRequest(fromUser, toUser) {
    if (_auth.currentUser == null) throw UserNotLoggedInException();
    return _supabase.from(pendingFriendRequestsTableName).insert(
      {
        sendingUserFieldName: fromUser,
        recipientFieldName: toUser,
      },
    );
  }

  @override
  Future<void> sendServerRequest(fromUser, toUser, squadId) async {
    if (_auth.currentUser == null) throw UserNotLoggedInException();
    await _supabase.from(pendingServerRequestsTableName).insert(
      {
        sendingUserFieldName: fromUser,
        recipientFieldName: toUser,
        idFieldName: squadId,
      },
    );
  }

  @override
  Future<CloudSquad?> fetchSquad(squadId) async {
    final data = await _supabase.rpc("public_fetch_squad", params: {
      'squadid': squadId,
    });
    if (data.isEmpty) return null;
    return CloudSquad.fromMap(data[0]);
  }

  @override
  Future<CloudUser?> fetchUser(userId, bool isOwner) async {
    if (isOwner) {
      final data = await _supabase
          .from(userTableName)
          .select("*")
          .eq(authIdFieldName, userId);
      if (data.isEmpty) return null;
      return CloudUser.fromMap(data[0]);
    } else {
      final data = await _supabase.rpc("public_fetch_user", params: {
        'userid': userId,
      });
      if (data.isEmpty) return null;
      return CloudUser.fromMap(data[0]);
    }
  }

  @override
  Future<bool> userExists({String? authId, String? name}) async {
    if (authId == null && name == null) throw CouldNotFetchUserException();

    if (authId != null) {
      return (await _supabase
              .from(userTableName)
              .select(authIdFieldName)
              .eq(authIdFieldName, authId))
          .isNotEmpty;
    } else {
      return (await _supabase
              .from(userTableName)
              .select(nameFieldName)
              .eq(nameFieldName, name!))
          .isNotEmpty;
    }
  }

  @override
  Future<List<CloudKinRequest>> fetchFriendRequests(userId) async {
    final data = await _supabase
        .from(pendingFriendRequestsTableName)
        .select("*")
        .eq(recipientFieldName, userId);

    return data.map((e) => CloudKinRequest.fromMap(e)).toList();
  }

  @override
  Future<List<CloudSquadRequest>> fetchServerRequests(userId) async {
    final data = await _supabase
        .from(pendingServerRequestsTableName)
        .select("*")
        .eq(recipientFieldName, userId);

    return data.map((e) => CloudSquadRequest.fromMap(e)).toList();
  }

  @override
  newFriendRequestsStream(userId, insertCallback, updateCallback) {
    _supabase
        .channel("friend-requests-channel")
        .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: "public",
            table: pendingFriendRequestsTableName,
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: recipientFieldName,
              value: userId,
            ),
            callback: (event) => insertCallback(event))
        .subscribe()
        .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: "public",
            table: pendingFriendRequestsTableName,
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: recipientFieldName,
              value: userId,
            ),
            callback: (event) => updateCallback(event));
  }

  @override
  unsubscribeNewFriendRequestsStream() {
    _supabase.channel("friend-requests-channel").unsubscribe();
  }

  @override
  newServerRequestsStream(userId, insertCallback, updateCallback) {
    _supabase
        .channel("server-requests-channel")
        .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: "public",
            table: pendingServerRequestsTableName,
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: recipientFieldName,
              value: userId,
            ),
            callback: (event) => insertCallback(event))
        .subscribe()
        .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: "public",
            table: pendingServerRequestsTableName,
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: recipientFieldName,
              value: userId,
            ),
            callback: (event) => updateCallback(event));
  }

  @override
  unsubscribeNewServerRequestsStream() {
    _supabase.channel("server-requests-channel").unsubscribe();
  }

  @override
  Stream<List<CloudUser>> fetchUsersForSearch(String query) async* {
    final data = await _supabase.rpc(
      "fetch_users_for_search",
      params: {"query": query},
    );
    yield data.map((e) => CloudUser.fromMap(e)).toList();
  }

  @override
  Future<void> acceptFriendRequest(fromUser, toUser) async {
    await _supabase
        .from("FriendRequests")
        .update({acceptedFieldName: true})
        .eq(recipientFieldName, toUser)
        .eq(sendingUserFieldName, fromUser)
        .not(acceptedFieldName, 'eq', null);
  }

  @override
  Future<void> acceptServerRequest(toUser, squadId) async {
    await _supabase
        .from("ServerRequests")
        .update({acceptedFieldName: true})
        .eq(recipientFieldName, toUser)
        .eq(sendingUserFieldName, squadId)
        .not(acceptedFieldName, 'eq', null);
  }

  @override
  Future<void> initialize() async {
    _supabase = Supabase.instance.client;
  }
}
