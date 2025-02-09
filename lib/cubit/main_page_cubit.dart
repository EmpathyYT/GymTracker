import 'package:bloc/bloc.dart';
import 'package:gymtracker/services/auth/firebase_auth_provider.dart';
import 'package:gymtracker/services/cloud/cloud_notification.dart';
import 'package:gymtracker/services/cloud/firestore_squad_controller.dart';
import 'package:gymtracker/services/cloud/firestore_user_controller.dart';

import '../constants/cloud_contraints.dart';
import '../services/cloud/firestore_notification_controller.dart';

part 'main_page_state.dart';

class MainPageCubit extends Cubit<MainPageState> {
  MainPageCubit() : super(const SquadSelector());
  final FirestoreUserController _firestoreUserController =
      FirestoreUserController();
  final FirestoreSquadController _firestoreSquadController =
      FirestoreSquadController();
  final FirestoreNotificationsController _firestoreNotificationController =
      FirestoreNotificationsController();
  final FirebaseAuthProvider _firebaseAuthProvider = FirebaseAuthProvider();

  void changePage(int index, {notifications = const {}}) {
    switch (index) {
      case 0:
        emit(SquadSelector(notifications: notifications));
        break;
      case 1:
        emit(AddWarrior(notifications: notifications));
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
    final currentUser = _firebaseAuthProvider.currentUser;
    try {
      emit(const NewSquad(isLoading: true, loadingText: "Creating Squad..."));
      await _firestoreSquadController.createSquad(
          name: name, creatorId: currentUser!.id, description: description);
      emit(const NewSquad());
    } catch (e) {
      emit(NewSquad(exception: e as Exception));
    }
  }

  Future<void> addUserReq({
    required String userToAddId,
  }) async {
    try {
      emit(const AddWarrior(isLoading: true, loadingText: "Adding Warrior..."));
      await _firestoreUserController.sendFriendReq(
          userId: _firebaseAuthProvider.currentUser!.id, friendId: userToAddId);
      _firestoreNotificationController.sendNotification(
        _firebaseAuthProvider.currentUser!.id,
        userToAddId,
        frqType,
        ""
      );
      emit(const AddWarrior(success: true));
    } catch (e) {
      emit(AddWarrior(exception: e as Exception));
    }
  }

  Stream<List<CloudNotification>> normalNotificationsStream() {
    return _firestoreNotificationController
        .getNormalNotifications(_firebaseAuthProvider.currentUser!.id);
  }

  Future<NotificationsType> getStartingNotifs() async {
    return (await _firestoreNotificationController
        .getStartingNotifs(_firebaseAuthProvider.currentUser!.id));
  }

  void newNotifications(MainPageState state, NotificationsType notifDiff) {
    emit(state.copyWith(notifications: notifDiff));
  }

  Future<void> clearNotifications(MainPageState state) async {
    final currentNotifs = state.notifications;

    for (final key in currentNotifs!.keys) {
      for (final notif in currentNotifs[key]!) {
        await _firestoreNotificationController
            .markNotificationAsRead(notif.item2);
      }
    }

    emit(state.copyWith(notifications: const {}));
  }

  Future<void> disableNotification(String notifId) async {
    await _firestoreNotificationController.disableNotification(notifId);
  }
}
