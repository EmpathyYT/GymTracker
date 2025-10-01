import 'package:gymtracker/services/cloud/cloud_notification.dart';
import 'package:gymtracker/services/cloud/cloud_pr.dart';
import 'package:gymtracker/services/cloud/cloud_squad.dart';
import 'package:gymtracker/services/cloud/cloud_user.dart';
import 'package:gymtracker/services/cloud/cloud_workout.dart';
import 'package:gymtracker/services/cloud/supabase_database_controller.dart';

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

  Future<CloudUser> createUser(userName, biography, gender);

  Future<CloudSquad?> fetchSquad(squadId, isMember);

  Future<CloudUser> editUser(String id, String username, String biography);

  Future<CloudUser?> fetchUser(userId, bool isOwner);

  Future<bool> userExists({String? authId, String? name});

  Future<List<CloudUser>> fetchUsersForSquadAdding(fromUser, squadId, filter);

  Future<List<CloudKinRequest>> fetchSendingFriendRequests(userId);

  Future<List<CloudSquadRequest>> fetchSendingSquadRequests(userId);

  Future<List<CloudKinRequest>> fetchFriendRequests(userId);

  Future<List<CloudSquadRequest>> fetchSquadRequests(userId);

  Stream<List<CloudUser>> fetchUsersForSearch(String query);

  Future<void> readUserAchievement(String achievementId);

  Future<void> readSquadAchievement(String achievementId);

  Future<List<CloudUserAchievement>> fetchUserAchievements(userId);

  Future<List<CloudSquadAchievement>> fetchSquadAchievements(squadId);

  Future<void> leaveSquad(squadId);

  Future<void> initialize();

  Future<CloudSquad> editSquad(String id, String name, String description);

  Future<CloudWorkout> createWorkout(
    userId,
    Map<String, dynamic> workout,
    String name,
  );

  Future<List<CloudWorkout>> fetchWorkouts(userId);

  newFriendRequestsStream(
    userId,
    RealtimeCallback insertCallback,
    RealtimeCallback updateCallback,
  );

  unsubscribeNewFriendRequestsStream();

  newServerRequestsStream(
    userId,
    RealtimeCallback insertCallback,
    RealtimeCallback updateCallback,
  );

  unsubscribeNewServerRequestsStream();

  newAchievementsStream(userId, RealtimeCallback insertCallback);

  unsubscribeNewAchievementsStream();

  Future<CloudWorkout> editWorkout(
    workoutId,
    String name,
    Map<String, dynamic> edits,
  );

  Future<void> deleteWorkout(workoutId);

  Future<void> finishWorkout(workoutId);

  Future<int> getWorkoutFinishedCount(userId);

  Future<int> getPointsLeftForNextLevel();

  Future<List<CloudPr>> fetchPrs(userId);

  Future<void> createPr(
    String userId,
    String exerciseName,
    double targetWeight,
    DateTime prDate,
  );

  Future<void> addPr(
    String exercise,
    userId,
    DateTime date,
    double targetWeight,
  );

  Future<List<CloudPr>> getFinishedPrs(userId);

  Future<List<CloudPr>> getAllPrs(userId);

  Future<void> confirmPrWeight(String prId, double weight);

  Future<Map<String, bool>> getAllowedVersions();


  static Future<void> initCloudObjects(DatabaseController controller) async {
    CloudSquad.dbController = controller;
    CloudUser.dbController = controller;
    CloudKinRequest.dbController = controller;
    CloudSquadRequest.dbController = controller;
    CloudUserAchievement.dbController = controller;
    CloudSquadAchievement.dbController = controller;
    CloudWorkout.dbController = controller;
    CloudPr.dbController = controller;
  }
}
