import 'dart:developer';

import 'package:gymtracker/constants/cloud_contraints.dart';
import 'package:gymtracker/constants/code_constraints.dart';
import 'package:gymtracker/exceptions/auth_exceptions.dart';
import 'package:gymtracker/exceptions/cloud_exceptions.dart';
import 'package:gymtracker/services/cloud/cloud_notification.dart';
import 'package:gymtracker/services/cloud/cloud_pr.dart';
import 'package:gymtracker/services/cloud/cloud_squad.dart';
import 'package:gymtracker/services/cloud/cloud_user.dart';
import 'package:gymtracker/services/cloud/cloud_workout.dart';
import 'package:gymtracker/services/cloud/database_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/auth_provider.dart';

typedef RealtimeCallback = void Function(List event);

class SupabaseDatabaseController implements DatabaseController {
  late final SupabaseClient _supabase;
  final AuthProvider _auth;

  SupabaseDatabaseController(this._auth);

  @override
  Future<CloudSquad> createSquad(name, description) async {
    if (_auth.currentUser == null) throw UserNotLoggedInException();

    final user = await fetchUser(_auth.currentUser!.id, true);

    final data =
        await _supabase.from(squadTableName).insert({
          rowName: name,
          squadDescriptionFieldName: description,
          ownerUserFieldName: user!.id,
        }).select();

    return CloudSquad.fromSupabaseMap(data[0]);
  }

  @override
  Future<CloudUser> createUser(userName, biography, gender) async {
    final data =
        await _supabase.from(userTableName).insert({
          nameFieldName: userName,
          bioFieldName: biography,
          genderFieldName: gender,
        }).select();
    return CloudUser.fromSupabaseMap(data[0]);
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
        params: {'userid': userId, 'friendid': friendId},
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CloudSquad> removeUserFromSquad(userId, squadId) async {
    if (_auth.currentUser == null) throw UserNotLoggedInException();

    final data =
        await _supabase
            .rpc(
              "remove_squad_member",
              params: {'user_id': userId, 'squad_id': squadId},
            )
            .select();

    return CloudSquad.fromSupabaseMap(data[0]);
  }

  @override
  Future<void> sendFriendRequest(fromUser, toUser) async {
    if (_auth.currentUser == null) throw UserNotLoggedInException();
    await _supabase.from(pendingFriendRequestsTableName).insert({
      sendingUserFieldName: fromUser,
      recipientFieldName: toUser,
    });
  }

  @override
  Future<void> sendServerRequest(fromUser, toUser, squadId) async {
    if (_auth.currentUser == null) throw UserNotLoggedInException();
    await _supabase.from(pendingServerRequestsTableName).insert({
      sendingUserFieldName: fromUser,
      recipientFieldName: toUser,
      serverIdFieldName: squadId,
    });
  }

  @override
  Future<List<CloudUser>> fetchUsersForSquadAdding(
    fromUser,
    squadId,
    filter,
  ) async {
    if (_auth.currentUser == null) throw UserNotLoggedInException();
    final data =
        await _supabase
            .rpc(
              "get_users_for_squad_adding",
              params: {
                'user_id': fromUser,
                'serverr_id': squadId,
                'filter': filter,
              },
            )
            .select();
    return data.map((e) => CloudUser.fromSupabaseMap(e)).toList();
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

    final data = await _supabase.rpc(
      "public_fetch_squad",
      params: {'squadid': squadId},
    );
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
      return CloudUser.fromSupabaseMap(data[0]);
    } else {
      final castedUserId =
          userId.runtimeType == String ? int.parse(userId) : userId;

      final data = await _supabase.rpc(
        "public_fetch_user",
        params: {'userid': castedUserId},
      );
      if (data.isEmpty) return null;
      return CloudUser.fromSupabaseMap(data[0]);
    }
  }

  @override
  Future<bool> userExists({String? authId, String? name}) async {
    if (authId == null && name == null) throw CouldNotFetchUserException();

    if (authId != null) {
      return (await _supabase
          .from(userTableName)
          .select(authIdFieldName)
          .eq(authIdFieldName, authId)).isNotEmpty;
    } else {
      return (await _supabase.rpc(
        "check_user_name_exists",
        params: {"username": name},
      ));
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
  Future<List<CloudSquadRequest>> fetchSquadRequests(userId) async {
    final data = await _supabase
        .from(pendingServerRequestsTableName)
        .select()
        .eq(recipientFieldName, userId)
        .not(acceptedFieldName, "is", null);
    return data.map((e) => CloudSquadRequest.fromMap(e)).toList();
  }

  @override
  newFriendRequestsStream(
    userId,
    RealtimeCallback insertCallback,
    RealtimeCallback updateCallback,
  ) {
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
            insertCallback([event.newRecord]);
          },
        )
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
            updateCallback([event.oldRecord, event.newRecord]);
          },
        )
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
            updateCallback([event.oldRecord, event.newRecord]);
          },
        )
        .subscribe();
  }

  @override
  unsubscribeNewFriendRequestsStream() {
    _supabase.channel("friend-requests-channel").unsubscribe();
  }

  @override
  newServerRequestsStream(
    userId,
    RealtimeCallback insertCallback,
    RealtimeCallback updateCallback,
  ) {
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
            insertCallback([event.newRecord]);
          },
        )
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
            updateCallback([event.oldRecord, event.newRecord]);
          },
        )
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
            updateCallback([event.oldRecord, event.newRecord]);
          },
        )
        .subscribe();
  }

  @override
  unsubscribeNewServerRequestsStream() {
    _supabase.channel("server-requests-channel").unsubscribe();
  }

  @override
  Stream<List<CloudUser>> fetchUsersForSearch(String query) async* {
    final data =
        await _supabase
            .rpc("fetch_users_for_search", params: {"username": query})
            .select();
    yield data.map((e) => CloudUser.fromSupabaseMap(e)).toList();
  }

  @override
  Future<void> acceptFriendRequest(fromUser, toUser) async {
    await _supabase
        .from(pendingFriendRequestsTableName)
        .update({acceptedFieldName: true})
        .eq(recipientFieldName, toUser)
        .eq(sendingUserFieldName, fromUser)
        .not(acceptedFieldName, "is", null);
  }

  @override
  Future<void> acceptServerRequest(toUser, squadId) async {
    await _supabase
        .from(pendingServerRequestsTableName)
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
  Future<CloudSquad> editSquad(
    String id,
    String name,
    String description,
  ) async {
    try {
      final res =
          await _supabase
              .from(squadTableName)
              .update({rowName: name, squadDescriptionFieldName: description})
              .eq(idFieldName, id)
              .select();
      return CloudSquad.fromSupabaseMap(res[0]);
    } on Exception catch (_) {
      rethrow;
    }
  }

  @override
  Future<CloudUser> editUser(
    String id,
    String username,
    String biography,
  ) async {
    try {
      final res =
          await _supabase
              .from(userTableName)
              .update({nameFieldName: username, bioFieldName: biography})
              .eq(idFieldName, id)
              .select();
      return CloudUser.fromSupabaseMap(res[0]);
    } on Exception catch (_) {
      rethrow;
    }
  }

  @override
  Future<List<CloudUserAchievement>> fetchUserAchievements(userId) async {
    final data = await _supabase
        .from(userAchievementsTableName)
        .select()
        .eq(userIdFieldName, userId)
        .limit(30)
        .order(timeCreatedFieldName, ascending: false);

    return data.map((e) => CloudUserAchievement.fromMap(e)).toList();
  }

  @override
  Future<List<CloudSquadAchievement>> fetchSquadAchievements(squadId) async {
    final data = await _supabase
        .from(squadAchievementsTableName)
        .select()
        .eq(squadIdFieldName, squadId)
        .limit(30)
        .order(timeCreatedFieldName, ascending: false);

    return data.map((e) => CloudSquadAchievement.fromMap(e)).toList();
  }

  @override
  newAchievementsStream(userId, RealtimeCallback insertCallback) {
    _supabase
        .channel("achievements-channel")
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: "public",
          table: userAchievementsTableName,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: userIdFieldName,
            value: userId,
          ),
          callback: (event) {
            insertCallback([event.newRecord]);
          },
        )
        .subscribe();
  }

  @override
  unsubscribeNewAchievementsStream() {
    _supabase.channel("achievements-channel").unsubscribe();
  }

  @override
  Future<void> leaveSquad(squadId) async {
    if (_auth.currentUser == null) throw UserNotLoggedInException();

    await _supabase.rpc("leave_squad", params: {'squad_id': squadId});
  }

  @override
  Future<CloudWorkout> createWorkout(
    userId,
    Map<String, dynamic> workout,
    String name,
  ) async {
    final resWorkout =
        await _supabase.from(workoutTableName).insert({
          planFieldName: workout,
          ownerUserFieldName: userId,
          rowName: name,
        }).select();
    return CloudWorkout.fromSupabaseMap(resWorkout[0]);
  }

  @override
  Future<List<CloudWorkout>> fetchWorkouts(userId) async {
    final resWorkouts = await _supabase
        .from(workoutTableName)
        .select()
        .eq(ownerUserFieldName, userId);

    return resWorkouts.map((e) => CloudWorkout.fromSupabaseMap(e)).toList();
  }

  @override
  Future<CloudWorkout> editWorkout(
    workoutId,
    name,
    Map<String, dynamic> edits,
  ) async {
    final resWorkout =
        await _supabase
            .from(workoutTableName)
            .update({planFieldName: edits, rowName: name})
            .eq(idFieldName, workoutId)
            .select();

    return CloudWorkout.fromSupabaseMap(resWorkout[0]);
  }

  @override
  Future<void> deleteWorkout(workoutId) async {
    await _supabase
        .from(workoutTableName)
        .delete()
        .eq(idFieldName, workoutId)
        .select();
  }

  @override
  Future<void> finishWorkout(workoutId) async {
    try {
      await _supabase.from(completedWorkoutName).insert({
        workoutIdFieldName: workoutId,
      });
    } on PostgrestException {
      throw AlreadyFinishedWorkoutException();
    }
  }

  @override
  Future<int> getWorkoutFinishedCount(userId) async {
    return await _supabase.rpc(
      "count_completed_workouts",
      params: {'user_id': userId},
    );
  }

  @override
  Future<int> getPointsLeftForNextLevel() async {
    final {"pointsNeeded": points} =
        (await _supabase.functions.invoke(
          'get-points-remaining-for-level-up',
        )).data;

    return points;
  }

  @override
  Future<void> readUserAchievement(achievementId) async {
    if (_auth.currentUser == null) throw UserNotLoggedInException();
    await _supabase
        .from(userAchievementsTableName)
        .update({readFieldName: true})
        .eq(idFieldName, achievementId);
  }

  @override
  Future<void> readSquadAchievement(achievementId) async {
    if (_auth.currentUser == null) throw UserNotLoggedInException();
    await _supabase.rpc(
      "read_squad_achievement",
      params: {'achievement_id': achievementId},
    );
  }

  @override
  Future<List<CloudPr>> fetchPrs(userId) async {
    if (_auth.currentUser == null) throw UserNotLoggedInException();
    final data = _supabase
        .from(prTableName)
        .select()
        .eq(userIdFieldName, userId)
        .order(prDateFieldName, ascending: false);

    return data.then(
      (value) => value.map((e) => CloudPr.fromSupabaseMap(e)).toList(),
    );
  }

  @override
  Future<void> createPr(
    String userId,
    String exerciseName,
    double targetWeight,
    DateTime prDate,
  ) async {
    if (_auth.currentUser == null) throw UserNotLoggedInException();
    return _supabase.from(prTableName).insert({
      userIdFieldName: userId,
      exerciseNameFieldName: exerciseName,
      prTargetWeightFieldName: targetWeight,
      prDateFieldName: prDate.toIso8601String(),
    });
  }

  @override
  Future<void> addPr(
    String exercise,
    userId,
    DateTime date,
    double targetWeight,
  ) async {
    if (_auth.currentUser == null) throw UserNotLoggedInException();
    log("Adding PR: $exercise, $userId, $date, $targetWeight");
    await _supabase.from(prTableName).insert({
      userIdFieldName: userId,
      exerciseNameFieldName: exercise,
      prTargetWeightFieldName: targetWeight,
      prDateFieldName: date.toIso8601String(),
    });
  }

  @override
  Future<List<CloudPr>> getFinishedPrs(userId) async {
    if (_auth.currentUser == null) throw UserNotLoggedInException();
    return _supabase
        .from(prTableName)
        .select()
        .eq(userIdFieldName, userId)
        .not(prActualWeightFieldName, "is", null)
        .order(prDateFieldName, ascending: false)
        .then((value) => value.map((e) => CloudPr.fromSupabaseMap(e)).toList());
  }

  @override
  Future<List<CloudPr>> getAllPrs(userId) async {
    if (_auth.currentUser == null) throw UserNotLoggedInException();
    return _supabase
        .from(prTableName)
        .select()
        .eq(userIdFieldName, userId)
        .order(prDateFieldName, ascending: false)
        .then((value) => value.map((e) => CloudPr.fromSupabaseMap(e)).toList());
  }

  @override
  Future<void> confirmPrWeight(String prId, double weight) async {
    if (_auth.currentUser == null) throw UserNotLoggedInException();
    return _supabase
        .from(prTableName)
        .update({prActualWeightFieldName: weight})
        .eq(idFieldName, prId);
  }

  @override
  Future<Map<String, bool>> getAllowedVersions() async {
    final allowedVersions = await _supabase
        .schema(internalSchemaName)
        .from(buildTableName)
        .select()
        .eq(isOutdatedColumnName, false);

    return {}..addEntries(
      allowedVersions.map(
        (e) => MapEntry(
          e[versionCodeColumnName].toString(),
          e[isOutdatedColumnName],
        ),
      ),
    );
  }
}
