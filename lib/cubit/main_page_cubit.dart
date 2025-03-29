import 'dart:developer';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:gymtracker/constants/cloud_contraints.dart';
import 'package:gymtracker/constants/code_constraints.dart';
import 'package:gymtracker/services/cloud/cloud_squads.dart';
import 'package:gymtracker/services/cloud/cloud_user.dart';

import '../services/cloud/cloud_notification.dart';

part 'main_page_state.dart';

typedef RequestsSortingType = Map<String, Map<String, List<CloudNotification>>>;

class MainPageCubit extends Cubit<MainPageState> {
  final CloudUser _currentUser;
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

  Future<void> clearNotifications(RequestsSortingType oldNotifications) async {
    final currentNotifications = oldNotifications;
    emit(state.copyWith(notifications: currentNotifications));
  }

  Future<void> emitStartingNotifications() async {
    if (state.notifications != null) return;
    final frqData = await CloudKinRequest.fetchFriendRequests(_currentUser.id);
    log(frqData.toString());
    final srqData =
        await CloudSquadRequest.fetchServerRequests(_currentUser.id);

    final RequestsSortingType notifications = {
      oldNotifsKeyName: {
        frqKeyName: [],
        srqKeyName: [],
        othersKeyName: [], //TODO for the future
      },
      newNotifsKeyName: {
        frqKeyName: [],
        srqKeyName: [],
        othersKeyName: [],
      }
    };

    for (final frq in frqData) {
      if (frq.read) {
        notifications[oldNotifsKeyName]![frqKeyName]!.add(frq);
      } else {
        notifications[newNotifsKeyName]![frqKeyName]!.add(frq);
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
        final key = event[0]!.first.containsKey(serverIdFieldName)
            ? srqKeyName
            : frqKeyName;

        final newNotification = (key == frqKeyName)
            ? CloudKinRequest.fromMap(event[0]!.first)
            : CloudSquadRequest.fromMap(event[0]!.first);

        emit(
          state.copyWith(
            notifications: currNotifications
              ..update(
                newNotifsKeyName,
                (e) => e
                  ..update(
                    key,
                    (e) => e..insert(0, newNotification),
                  ),
              ),
          ),
        );
      },
      (event) {
        log(event.toString());
      },
    );

    return () {
      listeningToNotifications = false;
      CloudKinRequest.unsubscribeFriendRequestListener();
      CloudSquadRequest.unsubscribeServerRequestListener();
    };
  }

  CloudUser get currentUser => _currentUser;
}