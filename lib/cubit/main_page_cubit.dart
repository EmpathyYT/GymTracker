import 'package:bloc/bloc.dart';
import 'package:gymtracker/constants/code_constraints.dart';
import 'package:gymtracker/services/cloud/cloud_squads.dart';
import 'package:gymtracker/services/cloud/cloud_user.dart';

import '../services/cloud/cloud_notification.dart';

part 'main_page_state.dart';

typedef RequestsSortingType = Map<String, Map<String, List>>;

class MainPageCubit extends Cubit<MainPageState> {
  final CloudUser _currentUser;

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

  void newNotifications(RequestsSortingType notifDiff) {
    emit(state.copyWith(notifications: notifDiff));
  }

  Future<void> clearNotifications() async {
    if (state.notifications == null) return;
    final currentNotifs = state.notifications!;

    for (final values in currentNotifs[newNotifsKeyName]!.values) {
      for (final notif in values) {
        await notif.readRequest();
      }
    }

    final readFrqNotifs = currentNotifs[oldNotifsKeyName]![frqKeyName]!
      ..addAll(currentNotifs[newNotifsKeyName]![frqKeyName]!);

    final readSrqNotifs = currentNotifs[oldNotifsKeyName]![srqKeyName]!
      ..addAll(currentNotifs[newNotifsKeyName]![srqKeyName]!);

    emit(state.copyWith(notifications: {
      oldNotifsKeyName: {
        frqKeyName: readFrqNotifs,
        srqKeyName: readSrqNotifs,
        othersKeyName: [],
      },
      newNotifsKeyName: {
        frqKeyName: [],
        srqKeyName: [],
        othersKeyName: [],
      }
    }));
  }


  void listenForNotifications() {
    //todo
  }

  Future<void> emitStartingNotifs() async {
    if (state.notifications != null) return;
    final frqData = await CloudKinRequest.fetchFriendRequests(_currentUser.id);
    final srqData =
        await CloudSquadRequest.fetchServerRequests(_currentUser.id);

    final notifications = {
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

    emit(state.copyWith(notifications: notifications));
  }

  CloudUser get currentUser => _currentUser;
}
