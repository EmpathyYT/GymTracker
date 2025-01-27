import 'package:bloc/bloc.dart';
import 'package:gymtracker/services/auth/firebase_auth_provider.dart';
import 'package:gymtracker/services/cloud/cloud_notification.dart';
import 'package:gymtracker/services/cloud/firestore_squad_controller.dart';
import 'package:gymtracker/services/cloud/firestore_user_controller.dart';

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

  void changePage(int index) {
    switch (index) {
      case 0:
        emit(const SquadSelector());
        break;
      case 1:
        emit(const AddWarrior());
        break;
      case 2:
        emit(const NewSquad());
        break;
      case 3:
        emit(const Settings());
        break;
      default:
        emit(const SquadSelector());
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
      emit(const AddWarrior(success: true));
    } catch (e) {
      emit(AddWarrior(exception: e as Exception));
    }
  }

  Stream<List<CloudNotification>> notificationsStream() {
    final notifications = _firestoreNotificationController
        .getNotifications(_firebaseAuthProvider.currentUser!.id);
    return notifications;
  }

  Future<List<String>> getFriendRequests() async {
    return _firestoreUserController
        .fetchUserFriendRequests(_firebaseAuthProvider.currentUser!.id);
  }

  void newNotifications(
      MainPageState state, Map<String, List<CloudNotification>> notifDiff) {
    emit(state.copyWith(notifications: notifDiff));
  }

}
