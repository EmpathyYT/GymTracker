import 'dart:developer';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:gymtracker/bloc/auth_bloc.dart';
import 'package:gymtracker/constants/code_constraints.dart';
import 'package:gymtracker/services/cloud/cloud_squads.dart';
import 'package:gymtracker/services/cloud/cloud_user.dart';
import 'package:gymtracker/utils/widgets/workout_builder_widget.dart';

import '../exceptions/cloud_exceptions.dart';
import '../services/cloud/cloud_notification.dart';
import '../services/cloud/cloud_workout.dart';

part 'main_page_state.dart';

typedef RequestsSortingType = Map<String, Map<String, List<CloudNotification>>>;

class MainPageCubit extends Cubit<MainPageState> {
  CloudUser _currentUser;
  bool listeningToNotifications = false;

  MainPageCubit(this._currentUser) : super(const SquadSelector());

  void changePage(int index, {notifications}) {
    switch (index) {
      case 0:
        emit(SquadSelector(notifications: notifications));
        break;
      case 1:
        emit(KinViewer(notifications: notifications));
        break;
      case 2:
        emit(WorkoutPlanner(notifications: notifications));
        break;
      case 3:
        emit(ProfileViewer(notifications: notifications));
        break;
      case 4:
        emit(Settings(notifications: notifications));
        break;
      default:
        emit(SquadSelector(notifications: notifications));
    }
  }

  Future<void> createSquad({
    required String name,
    required String description,
  }) async {
    try {
      emit(
        SquadSelector(
          isLoading: true,
          loadingText: "Creating Squad...",
          notifications: state.notifications,
        ),
      );
      final squad = await CloudSquad.createSquad(name, description);
      emit(SquadSelector(newSquad: squad, notifications: state.notifications));
    } catch (e) {
      emit(
        SquadSelector(
          exception: e as Exception,
          notifications: state.notifications,
        ),
      );
    }
  }

  Future<void> addUserReq({required String userToAddId}) async {
    try {
      emit(
        KinViewer(
          isLoading: true,
          loadingText: "Adding Warrior...",
          notifications: state.notifications,
        ),
      );
      await CloudKinRequest.sendRequest(_currentUser.id, userToAddId);
      emit(KinViewer(success: true, notifications: state.notifications));

      emit(KinViewer(success: false, notifications: state.notifications));
    } catch (e) {
      emit(
        KinViewer(
          exception: e as Exception,
          notifications: state.notifications,
        ),
      );
    }
  }

  Future<void> addSquadReq({
    required String userToAddId,
    required String squadId,
  }) async {
    try {
      emit(
        SquadSelector(
          isLoading: true,
          loadingText: "Inviting Warrior...",
          notifications: state.notifications,
        ),
      );
      await CloudSquadRequest.sendServerRequest(
        _currentUser.id,
        userToAddId,
        squadId,
      );
      emit(SquadSelector(success: true, notifications: state.notifications));

      emit(SquadSelector(success: false, notifications: state.notifications));
    } catch (e) {
      emit(
        SquadSelector(
          exception: e as Exception,
          notifications: state.notifications,
        ),
      );
    }
  }

  void newNotifications(RequestsSortingType notificationDiff) {
    emit(state.copyWith(notifications: notificationDiff));
  }

  Future<void> leaveSquad(CloudSquad squad) async {
    emit(
      SquadSelector(
        isLoading: true,
        loadingText: "Leaving Squad...",
        notifications: state.notifications,
      ),
    );

    await CloudSquad.leaveSquad(squad.id);

    emit(SquadSelector(success: true, notifications: state.notifications));

    emit(SquadSelector(success: false, notifications: state.notifications));
  }

  Future<void> clearKinNotifications(RequestsSortingType notifications) async {
    final currentNotifications = notifications;
    final newFrqData = state.notifications![newNotifsKeyName]![krqKeyName]!;
    final krqData = notifications[oldNotifsKeyName]![krqKeyName]!;

    _addMissingNotifications(
      currentNotifications,
      krqData,
      newFrqData,
      krqKeyName,
    );

    currentNotifications[oldNotifsKeyName]![krqKeyName]!.removeWhere((e) {
      final notification = e as CloudKinRequest;
      return (notification.accepted != false);
    });

    emit(state.copyWith(notifications: currentNotifications));
  }

  Future<void> clearSquadNotifications(
    List<CloudSquadRequest> notifications,
  ) async {
    final newNotifications = state.notifications!;

    newNotifications[newNotifsKeyName]![srqKeyName]!.removeWhere(
      (e) => notifications.any((x) => x == e),
    );

    newNotifications[oldNotifsKeyName]![srqKeyName] =
        notifications..removeWhere((e) => e.accepted != false);

    emit(state.copyWith(notifications: newNotifications));
  }

  Future<void> emitStartingNotifications() async {
    if (state.notifications != null) return;

    final frqData = await CloudKinRequest.fetchFriendRequests(_currentUser.id);

    final srqData = await CloudSquadRequest.fetchServerRequests(
      _currentUser.id,
    );

    final achievements = await CloudAchievement.fetchUserAchievements(
      _currentUser.id,
    );

    final RequestsSortingType notifications = {
      oldNotifsKeyName: {
        krqKeyName: [],
        srqKeyName: [],
        achievementsKeyName: [],
      },
      newNotifsKeyName: {
        krqKeyName: [],
        srqKeyName: [],
        achievementsKeyName: [],
      },
    };

    for (final frq in frqData) {
      if (frq.read) {
        notifications[oldNotifsKeyName]![krqKeyName]!.add(frq);
      } else {
        notifications[newNotifsKeyName]![krqKeyName]!.add(frq);
      }
    }

    for (final srq in srqData) {
      if (srq.read) {
        notifications[oldNotifsKeyName]![srqKeyName]!.add(srq);
      } else {
        notifications[newNotifsKeyName]![srqKeyName]!.add(srq);
      }
    }

    for (final achievement in achievements) {
      if (achievement.read) {
        notifications[oldNotifsKeyName]![achievementsKeyName]!.add(achievement);
      } else {
        notifications[newNotifsKeyName]![achievementsKeyName]!.add(achievement);
      }
    }

    log(notifications.toString());
    emit(state.copyWith(notifications: notifications));
  }

  VoidCallback listenToNotifications() {
    if (listeningToNotifications) return () {};
    listeningToNotifications = true;
    CloudKinRequest.friendRequestListener(
      _currentUser.id,
      (List event) {
        final RequestsSortingType currNotifications = state.notifications!;
        final newNotification = CloudKinRequest.fromMap(event[0]);

        emit(
          state.copyWith(
            notifications:
                currNotifications..update(
                  newNotifsKeyName,
                  (e) => e..update(krqKeyName, (e) => e..add(newNotification)),
                ),
          ),
        );
      },
      (List event) {
        final (oldKrq, newKrq) = (
          CloudKinRequest.fromMap(event[0]),
          CloudKinRequest.fromMap(event[1]),
        );
        if (newKrq.accepted != false) {
          log("event.toString()");
        }
      },
    );

    CloudSquadRequest.serverRequestListener(
      _currentUser.id,
      (List event) {
        final RequestsSortingType currNotifications = state.notifications!;
        final newNotification = CloudSquadRequest.fromMap(event[0]);
        emit(
          state.copyWith(
            notifications:
                currNotifications..update(
                  newNotifsKeyName,
                  (e) => e..update(srqKeyName, (e) => e..add(newNotification)),
                ),
          ),
        );
      },
      (List event) {
        final (oldSrq, newSrq) = (
          CloudSquadRequest.fromMap(event[0]),
          CloudSquadRequest.fromMap(event[1]),
        );
        if (newSrq.accepted != false) {
          log("event.toString()");
        }
      },
    );

    CloudAchievement.achievementListener(_currentUser.id, (
        List event,
    ) {
      final RequestsSortingType currNotifications = state.notifications!;
      final newNotification = CloudAchievement.fromMap(event[0]);
      emit(
        state.copyWith(
          notifications:
              currNotifications..update(
                newNotifsKeyName,
                (e) =>
                    e..update(
                      achievementsKeyName,
                      (e) => e..add(newNotification),
                    ),
              ),
        ),
      );
    });

    return () {
      listeningToNotifications = false;
      CloudKinRequest.unsubscribeFriendRequestListener();
      CloudSquadRequest.unsubscribeServerRequestListener();
      CloudAchievement.unsubscribeAchievementListener();
    };
  }

  Future<void> reloadUser() async {
    _currentUser = (await CloudUser.fetchUser(currentUser.authId, true))!;
  }

  void _addMissingNotifications(
    Map currentNotifications,
    List oldData,
    List newData,
    String key,
  ) {
    for (final notification in newData) {
      if (!oldData.contains(notification)) {
        currentNotifications[newNotifsKeyName]?[key]?.add(notification);
      }
    }
  }

  Future<CloudSquad?> editSquad({
    required CloudSquad squad,
    required String name,
    required String description,
  }) async {
    try {
      emit(
        SquadSelector(
          isLoading: true,
          loadingText: "Editing Squad...",
          notifications: state.notifications,
        ),
      );
      final newSquad = await squad.edit(name, description);

      emit(SquadSelector(success: true, notifications: state.notifications));
      emit(SquadSelector(success: false, notifications: state.notifications));
      return newSquad;
    } catch (e) {
      emit(
        SquadSelector(
          exception: e as Exception,
          notifications: state.notifications,
        ),
      );
      return null;
    }
  }

  Future<void> editUser({required String name, required String bio}) async {
    try {
      emit(
        ProfileViewer(
          isLoading: true,
          loadingText: "Editing Profile...",
          notifications: state.notifications,
        ),
      );
      if (currentUser.name != name &&
          !await AuthBloc.checkValidUsername(name)) {
        throw InvalidUserNameFormatException();
      } else if (!RegExp(r'^[a-zA-Z0-9._ ]+$').hasMatch(bio)) {
        throw InvalidBioFormatException();
      } else if (bio.length > 130) {
        throw BioTooLongException();
      } else if (bio == currentUser.bio && name == currentUser.name) {
        throw NoChangesMadeException();
      }
      final user = await _currentUser.editUser(name, bio);
      _currentUser = user;
      emit(ProfileViewer(success: true, notifications: state.notifications));
    } catch (e) {
      emit(
        ProfileViewer(
          exception: e as Exception,
          notifications: state.notifications,
        ),
      );
    }
  }

  Future<void> removeFriend({required String friendId}) async {
    emit(
      KinViewer(
        isLoading: true,
        loadingText: "Removing Friend...",
        notifications: state.notifications,
      ),
    );

    try {
      await _currentUser.removeFriend(friendId);
      emit(KinViewer(success: true, notifications: state.notifications));

      emit(KinViewer(success: false, notifications: state.notifications));

      await reloadUser();
    } catch (e) {
      emit(
        KinViewer(
          exception: e as Exception,
          notifications: state.notifications,
        ),
      );
    }
  }

  Future<CloudSquad?> removeMember(CloudSquad squad, memberId) async {
    emit(
      SquadSelector(
        isLoading: true,
        loadingText: "Removing Member...",
        notifications: state.notifications,
      ),
    );
    try {
      final newSquad = await squad.removeUserFromSquad(memberId);
      emit(SquadSelector(success: true, notifications: state.notifications));
      emit(SquadSelector(success: false, notifications: state.notifications));

      return newSquad;
    } catch (e) {
      emit(
        SquadSelector(
          exception: e as Exception,
          notifications: state.notifications,
        ),
      );
    }
    return null;
  }

  Future<void> fetchWorkouts(List<CloudWorkout> initialWorkouts) async {
    try {
      final workouts = await CloudWorkout.fetchWorkouts(currentUser.id);
      if (initialWorkouts == workouts) return;
      emit(
        WorkoutPlanner(workouts: workouts, notifications: state.notifications),
      );
    } catch (e) {
      e as TypeError;
      emit(
        WorkoutPlanner(
          exception: e as Exception,
          notifications: state.notifications,
        ),
      );
    }
  }

  Future<void> saveWorkout(FilteredExerciseFormat exercise, String name) async {
    if (exercise.values.every((element) => element.isEmpty)) return;
    final workouts = List<CloudWorkout>.from(
      (state as WorkoutPlanner).workouts ?? [],
    );
    emit(
      WorkoutPlanner(
        workouts: workouts,
        isLoading: true,
        loadingText: "Saving Workout...",
        notifications: state.notifications,
      ),
    );

    try {
      final data = await CloudWorkout.createWorkout(
        currentUser.id,
        exercise,
        name,
      );

      emit(
        WorkoutPlanner(
          successText: ["Workout Created", "Your workout has been created."],
          workouts: workouts,
          success: true,
          notifications: state.notifications,
        ),
      );
      emit(
        WorkoutPlanner(
          workouts: (workouts)..add(data),
          success: false,
          notifications: state.notifications,
        ),
      );
    } catch (e) {
      emit(
        WorkoutPlanner(
          exception: e as Exception,
          workouts: workouts,
          notifications: state.notifications,
        ),
      );
    }
  }

  Future<void> editWorkout(
    CloudWorkout workout,
    FilteredExerciseFormat exercise,
    String name,
  ) async {
    if (!const DeepCollectionEquality().equals(exercise, workout.workouts) ||
        workout.name != name) {
      emit(
        WorkoutPlanner(
          isLoading: true,
          loadingText: "Editing Workout...",
          workouts: (state as WorkoutPlanner).workouts,
          notifications: state.notifications,
        ),
      );

      try {
        final data = await workout.editWorkout(name, exercise);
        final workouts =
            (state as WorkoutPlanner).workouts?.where((e) {
                return e.id != workout.id;
              }).toList()
              ?..add(data);
        emit(
          WorkoutPlanner(
            successText: ["Workout Edited", "Your workout has been edited."],
            workouts: workouts,
            success: true,
            notifications: state.notifications,
          ),
        );
        emit(
          WorkoutPlanner(
            workouts: workouts,
            success: false,
            notifications: state.notifications,
          ),
        );
      } catch (e) {
        emit(
          WorkoutPlanner(
            workouts: (state as WorkoutPlanner).workouts,
            exception: e as Exception,
            notifications: state.notifications,
          ),
        );
      }
    }
  }

  Future<void> deleteWorkout(CloudWorkout workout) async {
    final workouts = (state as WorkoutPlanner).workouts;
    emit(
      WorkoutPlanner(
        isLoading: true,
        loadingText: "Deleting Workout...",
        workouts: (state as WorkoutPlanner).workouts,
        notifications: state.notifications,
      ),
    );
    try {
      await workout.deleteWorkout();
      final newWorkouts = workouts?.where((e) => e.id != workout.id).toList();
      emit(
        WorkoutPlanner(
          successText: ["Workout Deleted", "Your workout has been deleted."],
          workouts: newWorkouts,
          success: true,
          notifications: state.notifications,
        ),
      );
      emit(
        WorkoutPlanner(
          workouts: newWorkouts,
          success: false,
          notifications: state.notifications,
        ),
      );
    } catch (e) {
      emit(
        WorkoutPlanner(
          workouts: workouts,
          exception: e as Exception,
          notifications: state.notifications,
        ),
      );
    }
  }

  CloudUser get currentUser => _currentUser;
}
