import 'package:gymtracker/services/auth/auth_provider.dart';
import 'package:gymtracker/services/cloud/cloud_notification.dart';
import 'package:gymtracker/services/cloud/cloud_pr.dart';
import 'package:gymtracker/services/cloud/cloud_squad.dart';
import 'package:gymtracker/services/cloud/cloud_user.dart';
import 'package:gymtracker/services/cloud/cloud_workout.dart';
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
  newServerRequestsStream(
    userId,
    RealtimeCallback insertCallback,
    RealtimeCallback updateCallback,
  ) =>
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
  Future<List<CloudUserAchievement>> fetchUserAchievements(userId) =>
      _provider.fetchUserAchievements(userId);

  @override
  Future<List<CloudSquadAchievement>> fetchSquadAchievements(squadId) =>
      _provider.fetchSquadAchievements(squadId);

  @override
  Future<void> readUserAchievement(String achievementId) =>
      _provider.readUserAchievement(achievementId);

  @override
  Future<void> readSquadAchievement(String achievementId) =>
      _provider.readSquadAchievement(achievementId);

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

  @override
  Future<CloudWorkout> createWorkout(
    userId,
    Map<String, dynamic> workout,
    String name,
  ) => _provider.createWorkout(userId, workout, name);

  @override
  Future<List<CloudWorkout>> fetchWorkouts(userId) =>
      _provider.fetchWorkouts(userId);

  @override
  Future<CloudWorkout> editWorkout(
    workoutId,
    String name,
    Map<String, dynamic> edits,
  ) => _provider.editWorkout(workoutId, name, edits);

  @override
  Future<void> deleteWorkout(workoutId) => _provider.deleteWorkout(workoutId);

  @override
  Future<void> finishWorkout(workoutId) => _provider.finishWorkout(workoutId);

  @override
  Future<int> getPointsLeftForNextLevel() =>
      _provider.getPointsLeftForNextLevel();

  @override
  Future<int> getWorkoutFinishedCount(userId) =>
      _provider.getWorkoutFinishedCount(userId);

  @override
  Future<List<CloudPr>> fetchPrs(userId) => _provider.fetchPrs(userId);

  @override
  Future<void> createPr(
    String userId,
    String exerciseName,
    double targetWeight,
    DateTime prDate,
  ) => _provider.createPr(
        userId,
        exerciseName,
        targetWeight,
        prDate,
      );
}
