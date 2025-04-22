import 'dart:developer';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:gymtracker/bloc/auth_bloc.dart';
import 'package:gymtracker/constants/code_constraints.dart';
import 'package:gymtracker/services/cloud/cloud_squads.dart';
import 'package:gymtracker/services/cloud/cloud_user.dart';

import '../exceptions/cloud_exceptions.dart';
import '../services/cloud/cloud_notification.dart';

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
        emit(ProfileViewer(notifications: notifications));
        break;
      case 3:
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
      emit(SquadSelector(
        isLoading: true,
        loadingText: "Creating Squad...",
        notifications: state.notifications,
      ));
      await CloudSquad.createSquad(name, description);
      emit(SquadSelector(
        notifications: state.notifications,
      ));
    } catch (e) {
      emit(SquadSelector(
        exception: e as Exception,
        notifications: state.notifications,
      ));
    }
  }

  Future<void> addUserReq({
    required String userToAddId,
  }) async {
    try {
      emit(KinViewer(
        isLoading: true,
        loadingText: "Adding Warrior...",
        notifications: state.notifications,
      ));
      await CloudKinRequest.sendRequest(_currentUser.id, userToAddId);
      emit(KinViewer(
        success: true,
        notifications: state.notifications,
      ));

      emit(KinViewer(
        success: false,
        notifications: state.notifications,
      ));
    } catch (e) {
      emit(KinViewer(
        exception: e as Exception,
        notifications: state.notifications,
      ));
    }
  }

  Future<void> addSquadReq({
    required String userToAddId,
    required String squadId,
  }) async {
    try {
      emit(SquadSelector(
        isLoading: true,
        loadingText: "Inviting Warrior...",
        notifications: state.notifications,
      ));
      await CloudSquadRequest.sendServerRequest(
        _currentUser.id,
        userToAddId,
        squadId,
      );
      emit(SquadSelector(
        success: true,
        notifications: state.notifications,
      ));

      emit(SquadSelector(
        success: false,
        notifications: state.notifications,
      ));
    } catch (e) {
      emit(SquadSelector(
        exception: e as Exception,
        notifications: state.notifications,
      ));
    }
  }

  void newNotifications(RequestsSortingType notificationDiff) {
    emit(state.copyWith(notifications: notificationDiff));
  }

  Future<void> clearKinNotifications(RequestsSortingType notifications) async {
    final currentNotifications = notifications;
    final newFrqData = state.notifications![newNotifsKeyName]![krqKeyName]!;
    final krqData = notifications[oldNotifsKeyName]![krqKeyName]!;

    _addMissingNotifications(
        currentNotifications, krqData, newFrqData, krqKeyName);

    currentNotifications[oldNotifsKeyName]![krqKeyName]!.removeWhere((e) {
      final notification = e as CloudKinRequest;
      return (notification.accepted != false);
    });

    emit(state.copyWith(notifications: currentNotifications));
  }

  Future<void> clearSquadNotifications(
      List<CloudSquadRequest> notifications) async {
    final newNotifications = state.notifications!;

    newNotifications[newNotifsKeyName]![srqKeyName]!
        .removeWhere((e) => notifications.any((x) => x == e));

    newNotifications[oldNotifsKeyName]![srqKeyName] = notifications
      ..removeWhere((e) => e.accepted != false);

    emit(state.copyWith(notifications: newNotifications));
  }

  Future<void> emitStartingNotifications() async {
    if (state.notifications != null) return;

    final frqData = await CloudKinRequest.fetchFriendRequests(_currentUser.id);

    final srqData =
        await CloudSquadRequest.fetchServerRequests(_currentUser.id);

    final RequestsSortingType notifications = {
      oldNotifsKeyName: {
        krqKeyName: [],
        srqKeyName: [],
        othersKeyName: [], //TODO for the future
      },
      newNotifsKeyName: {
        krqKeyName: [],
        srqKeyName: [],
        othersKeyName: [],
      }
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
    log(notifications.toString());
    emit(state.copyWith(notifications: notifications));
  }

  VoidCallback listenToNotifications() {
    if (listeningToNotifications) return () {};
    listeningToNotifications = true;
    CloudKinRequest.friendRequestListener(
      _currentUser.id,
      (RealtimeNotificationsShape event) {
        final RequestsSortingType currNotifications = state.notifications!;

        final newNotification = CloudKinRequest.fromMap(event[0]!.first);

        emit(
          state.copyWith(
            notifications: currNotifications
              ..update(
                newNotifsKeyName,
                (e) => e
                  ..update(
                    krqKeyName,
                    (e) => e..add(newNotification),
                  ),
              ),
          ),
        );
      },
      (event) {
        log("event.toString()"); //todo make update only when accepted is changed to true or null, for both receiver and sender
      },
    );

    return () {
      listeningToNotifications = false;
      CloudKinRequest.unsubscribeFriendRequestListener();
      CloudSquadRequest.unsubscribeServerRequestListener();
    };
  }

  Future<void> reloadUser() async {
    _currentUser = (await CloudUser.fetchUser(currentUser.authId, true))!;
  }

  void _addMissingNotifications(
      Map currentNotifications, List oldData, List newData, String key) {
    for (final notification in newData) {
      if (!oldData.contains(notification)) {
        currentNotifications[newNotifsKeyName]?[key]?.add(notification);
      }
    }
  }

  Future<void> editUser({required String name, required String bio}) async {
    try {
      emit(ProfileViewer(
        isLoading: true,
        loadingText: "Editing Profile...",
        notifications: state.notifications,
      ));
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
      emit(ProfileViewer(
        success: true,
        notifications: state.notifications,
      ));
    } catch (e) {
      emit(ProfileViewer(
        exception: e as Exception,
        notifications: state.notifications,
      ));
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
      emit(
        KinViewer(
          success: true,
          notifications: state.notifications,
        ),
      );

      emit(
        KinViewer(
          success: false,
          notifications: state.notifications,
        ),
      );

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

  CloudUser get currentUser => _currentUser;
}
