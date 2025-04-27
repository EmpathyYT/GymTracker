import 'package:gymtracker/constants/cloud_contraints.dart';
import 'package:gymtracker/exceptions/auth_exceptions.dart';
import 'package:gymtracker/exceptions/cloud_exceptions.dart';
import 'package:gymtracker/services/cloud/cloud_notification.dart';
import 'package:gymtracker/services/cloud/cloud_squads.dart';
import 'package:gymtracker/services/cloud/cloud_user.dart';
import 'package:gymtracker/services/cloud/database_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/auth_provider.dart';

typedef RealtimeCallback = void Function(RealtimeNotificationsShape event);

class SupabaseDatabaseController implements DatabaseController {
  late final SupabaseClient _supabase;
  final AuthProvider _auth;

  SupabaseDatabaseController(this._auth);

  @override
  Future<CloudSquad> createSquad(name, description) async {
    if (_auth.currentUser == null) throw UserNotLoggedInException();

    final user = await fetchUser(_auth.currentUser!.id, true);

    final data = await _supabase.from(squadTableName).insert(
      {
        squadNameFieldName: name,
        squadDescriptionFieldName: description,
        ownerUserFieldName: user!.id,
      },
    ).select();

    return CloudSquad.fromSupabaseMap(data[0]);
  }

  @override
  Future<CloudUser> createUser(userName, biography, gender) async {
    final data = await _supabase.from(userTableName).insert(
      {
        nameFieldName: userName,
        bioFieldName: biography,
        genderFieldName: gender
      },
    ).select();
    return CloudUser.fromSubabaseMap(data[0]);
  }

  @override
  Future<void> readFriendRequest(fromUser, toUser) async {
    if (_auth.currentUser == null) throw UserNotLoggedInException();
    await _supabase
        .from(pendingFriendRequestsTableName)
        .update({readFieldName: true})
        .eq(sendingUserFieldName, fromUser)
        .eq(recipientFieldName, toUser)
        .not(acceptedFieldName, "is", null);
  }

  @override
  Future<void> readServerRequest(toUser, squadId) async {
    if (_auth.currentUser == null) throw UserNotLoggedInException();
    await _supabase
        .from(pendingServerRequestsTableName)
        .update({readFieldName: true})
        .eq(recipientFieldName, toUser)
        .eq(serverIdFieldName, squadId)
        .not(acceptedFieldName, "is", null);
  }

  @override
  Future<void> rejectFriendRequest(fromUser, toUser) async {
    if (_auth.currentUser == null) throw UserNotLoggedInException();
    await _supabase
        .from(pendingFriendRequestsTableName)
        .update({acceptedFieldName: null})
        .eq(sendingUserFieldName, fromUser)
        .eq(recipientFieldName, toUser)
        .not(acceptedFieldName, "is", null);
  }

  @override
  Future<void> rejectServerRequest(toUser, serverId) async {
    if (_auth.currentUser == null) throw UserNotLoggedInException();
    await _supabase
        .from(pendingServerRequestsTableName)
        .update({acceptedFieldName: null})
        .eq(recipientFieldName, toUser)
        .eq(serverIdFieldName, serverId)
        .not(acceptedFieldName, "is", null);
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
        .select(membersFieldName)
        .eq(idFieldName, squadId);

    final serverMembers = (server[0][membersFieldName] as List<dynamic>)
        .map((e) => e.toString())
        .toList();

    if (!serverMembers.remove(userId)) throw UserNotInSquadException();

    final data = await _supabase
        .from(squadTableName)
        .update({membersFieldName: serverMembers})
        .eq(idFieldName, squadId)
        .select();

    return CloudSquad.fromSupabaseMap(data[0]);
  }

  @override
  Future<void> sendFriendRequest(fromUser, toUser) async {
    if (_auth.currentUser == null) throw UserNotLoggedInException();
    await _supabase.from(pendingFriendRequestsTableName).insert(
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
        serverIdFieldName: squadId,
      },
    );
  }

  @override
  Future<List<CloudUser>> fetchUsersForSquadAdding(
      fromUser, squadId, filter) async {
    if (_auth.currentUser == null) throw UserNotLoggedInException();
    final data = await _supabase.rpc(
      "get_users_for_squad_adding",
      params: {
        'user_id': fromUser,
        'serverr_id': squadId,
        'filter': filter,
      },
    ).select();
    return data.map((e) => CloudUser.fromSubabaseMap(e)).toList();
  }

  @override
  Future<CloudSquad?> fetchSquad(squadId, isMember) async {
    if (isMember) {
      final data = await _supabase
          .from(squadTableName)
          .select("*")
          .eq(idFieldName, squadId);
      if (data.isEmpty) return null;
      return CloudSquad.fromSupabaseMap(data[0]);
    }

    final data = await _supabase.rpc("public_fetch_squad", params: {
      'squadid': squadId,
    });
    if (data.isEmpty) return null;
    return CloudSquad.fromSupabaseMap(data[0]);
  }

  @override
  Future<CloudUser?> fetchUser(userId, bool isOwner) async {
    if (isOwner) {
      final data = await _supabase
          .from(userTableName)
          .select("*")
          .eq(authIdFieldName, userId);
      if (data.isEmpty) return null;
      return CloudUser.fromSubabaseMap(data[0]);
    } else {
      final castedUserId =
          userId.runtimeType == String ? int.parse(userId) : userId;

      final data = await _supabase.rpc("public_fetch_user", params: {
        'userid': castedUserId,
      });
      if (data.isEmpty) return null;
      return CloudUser.fromSubabaseMap(data[0]);
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
          .rpc("check_user_name_exists", params: {"username": name}));
    }
  }

  @override
  Future<List<CloudKinRequest>> fetchSendingFriendRequests(userId) async {
    final data = await _supabase
        .from(pendingFriendRequestsTableName)
        .select()
        .eq(sendingUserFieldName, userId)
        .not(acceptedFieldName, "is", null);

    return data.map((e) => CloudKinRequest.fromMap(e)).toList();
  }

  @override
  Future<List<CloudSquadRequest>> fetchSendingSquadRequests(userId) async {
    final data = await _supabase
        .from(pendingServerRequestsTableName)
        .select()
        .eq(sendingUserFieldName, userId)
        .not(acceptedFieldName, "is", null);

    return data.map((e) => CloudSquadRequest.fromMap(e)).toList();
  }

  @override
  Future<List<CloudKinRequest>> fetchFriendRequests(userId) async {
    final data = await _supabase
        .from(pendingFriendRequestsTableName)
        .select()
        .eq(recipientFieldName, userId)
        .not(acceptedFieldName, "is", null);

    return data.map((e) => CloudKinRequest.fromMap(e)).toList();
  }

  @override
  Future<List<CloudSquadRequest>> fetchServerRequests(userId) async {
    final data = await _supabase
        .from(pendingServerRequestsTableName)
        .select()
        .eq(recipientFieldName, userId)
        .not(acceptedFieldName, "is", null);
    return data.map((e) => CloudSquadRequest.fromMap(e)).toList();
  }

  @override
  newFriendRequestsStream(userId, RealtimeCallback insertCallback,
      RealtimeCallback updateCallback) {
    final RealtimeNotificationsShape insertShape = {
      0: [],
    };

    final RealtimeNotificationsShape updateShape = {
      1: [],
    };

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
            callback: (event) {
              insertShape[0] = [event.newRecord];
              insertCallback(insertShape);
            })
        .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: "public",
            table: pendingFriendRequestsTableName,
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: recipientFieldName,
              value: userId,
            ),
            callback: (event) {
              updateShape[1] = [event.oldRecord, event.newRecord];
              updateCallback(updateShape);
            })
        .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: "public",
            table: pendingFriendRequestsTableName,
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: sendingUserFieldName,
              value: userId,
            ),
            callback: (event) {
              updateShape[1] = [event.oldRecord, event.newRecord];
              updateCallback(updateShape);
            })
        .subscribe();
  }

  @override
  unsubscribeNewFriendRequestsStream() {
    _supabase.channel("friend-requests-channel").unsubscribe();
  }

  @override
  newServerRequestsStream(userId, RealtimeCallback insertCallback,
      RealtimeCallback updateCallback) {
    final RealtimeNotificationsShape insertShape = {
      0: [],
    };

    final RealtimeNotificationsShape updateShape = {
      1: [],
    };

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
            callback: (event) {
              insertShape[0] = [event.newRecord];
              insertCallback(insertShape);
            })
        .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: "public",
            table: pendingServerRequestsTableName,
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: recipientFieldName,
              value: userId,
            ),
            callback: (event) {
              updateShape[1] = [event.oldRecord, event.newRecord];
              updateCallback(updateShape);
            })
        .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: "public",
            table: pendingServerRequestsTableName,
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: sendingUserFieldName,
              value: userId,
            ),
            callback: (event) {
              updateShape[1] = [event.oldRecord, event.newRecord];
              updateCallback(updateShape);
            })
        .subscribe();
  }

  @override
  unsubscribeNewServerRequestsStream() {
    _supabase.channel("server-requests-channel").unsubscribe();
  }

  @override
  Stream<List<CloudUser>> fetchUsersForSearch(String query) async* {
    final data = await _supabase.rpc(
      "fetch_users_for_search",
      params: {"username": query},
    ).select();
    yield data.map((e) => CloudUser.fromSubabaseMap(e)).toList();
  }

  @override
  Future<void> acceptFriendRequest(fromUser, toUser) async {
    await _supabase
        .from("FriendRequests")
        .update({acceptedFieldName: true})
        .eq(recipientFieldName, toUser)
        .eq(sendingUserFieldName, fromUser)
        .not(acceptedFieldName, "is", null);
  }

  @override
  Future<void> acceptServerRequest(toUser, squadId) async {
    await _supabase
        .from("ServerRequests")
        .update({acceptedFieldName: true})
        .eq(recipientFieldName, toUser)
        .eq(serverIdFieldName, squadId)
        .not(acceptedFieldName, "is", null);
  }

  @override
  Future<void> initialize() async {
    _supabase = Supabase.instance.client;
  }

  @override
  Future<CloudUser> editUser(
      String id, String username, String biography) async {
    try {
      final res = await _supabase
          .from(userTableName)
          .update({
            nameFieldName: username,
            bioFieldName: biography,
          })
          .eq(idFieldName, id)
          .select();
      return CloudUser.fromSubabaseMap(res[0]);
    } on Exception catch (_) {
      rethrow;
    }
  }

  @override
  Future<List<CloudAchievement>> fetchAchievements({squadId, userId}) async {
    if (squadId == null && userId == null) {
      throw CouldNotFetchAchievementsException();
    }

    if (squadId != null) {
      final data = await _supabase
          .from(achievementsTableName)
          .select()
          .containedBy(achievementSquadsFieldName, [squadId]);

      return data.map((e) => CloudAchievement.fromMap(e)).toList();
    } else {
      final data = await _supabase
          .from(achievementsTableName)
          .select()
          .eq(userIdFieldName, userId);

      return data.map((e) => CloudAchievement.fromMap(e)).toList();
    }
  }

  @override
  newAchievementsStream(userId, RealtimeCallback insertCallback) {
    final RealtimeNotificationsShape insertShape = {
      0: [],
    };

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
          callback: (event) {
            insertShape[0] = [event.newRecord];
            insertCallback(insertShape);
          },
        )
        .subscribe();
  }

  @override
  unsubscribeNewAchievementsStream() {
    _supabase.channel("server-requests-channel").unsubscribe();
  }
}
