import 'dart:developer';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:gymtracker/constants/code_constraints.dart';
import 'package:gymtracker/services/cloud/cloud_squads.dart';
import 'package:gymtracker/services/cloud/cloud_user.dart';

import '../services/cloud/cloud_notification.dart';

part 'main_page_state.dart';

typedef RequestsSortingType = Map<String, Map<String, List<CloudNotification>>>;

class MainPageCubit extends Cubit<MainPageState> {
  final CloudUser _currentUser; //todo update user info every few seconds
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
        emit(NewSquad(notifications: notifications));
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
      emit(NewSquad(
        isLoading: true,
        loadingText: "Creating Squad...",
        notifications: state.notifications,
      ));
      await CloudSquad.createSquad(name, description);
      emit(NewSquad(
        notifications: state.notifications,
      ));
    } catch (e) {
      log(e.toString());
      emit(NewSquad(
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
    } catch (e) {
      emit(KinViewer(
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
    final krqData = state.notifications![newNotifsKeyName]![krqKeyName]!;

    _addMissingNotifications(
        currentNotifications, krqData, newFrqData, krqKeyName);

    currentNotifications[oldNotifsKeyName]![krqKeyName]!.removeWhere((e) {
      final notification = e as CloudKinRequest;
      return (notification.accepted != false);
    });

    emit(state.copyWith(notifications: currentNotifications));
  }

  Future<void> clearSquadNotifications(
      RequestsSortingType notifications) async {
    final currentNotifications = notifications;
    final newSrqData = state.notifications![newNotifsKeyName]![srqKeyName]!;
    final srqData = notifications[oldNotifsKeyName]![srqKeyName]!;

    _addMissingNotifications(
        currentNotifications, srqData, newSrqData, srqKeyName);

    currentNotifications[oldNotifsKeyName]![srqKeyName]!.removeWhere((e) {
      final notification = e as CloudSquadRequest;
      return (notification.accepted != false);
    });

    emit(state.copyWith(notifications: currentNotifications));
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
                    (e) => e..insert(0, newNotification),
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

  CloudUser get currentUser => _currentUser;

  void _addMissingNotifications(
      Map currentNotifications, List oldData, List newData, String key) {
    for (final notification in newData) {
      if (!oldData.contains(notification)) {
        currentNotifications[newNotifsKeyName]?[key]?.add(notification);
      }
    }
  }
}
