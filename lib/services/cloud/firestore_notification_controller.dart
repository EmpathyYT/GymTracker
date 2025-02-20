import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymtracker/constants/cloud_contraints.dart';
import 'package:gymtracker/constants/code_constraints.dart';
import 'package:gymtracker/services/cloud/cloud_notification.dart';
import 'package:tuple/tuple.dart';

typedef NotificationsType = Map<String, List<Tuple2<int?, CloudNotification>>>;

class FirestoreNotificationsController {
  final notificationCollection =
      FirebaseFirestore.instance.collection('notifications');

  FirestoreNotificationsController._privateConstructor();

  static final FirestoreNotificationsController _instance =
      FirestoreNotificationsController._privateConstructor();

  factory FirestoreNotificationsController() => _instance;

  Future<void> sendNotification(
      String senderId, String receiverId, int type, String message) async {
    await notificationCollection.add({
      fromUserIdFieldName: senderId,
      toUserIdFieldName: receiverId,
      timestampFieldName: Timestamp.now(),
      readFieldName: false,
      notificationTypeFieldName: type,
      messageFieldName: type == 2 ? message : "",
    });
  }

  Future<void> disableNotification(String notificationId) async {
    await notificationCollection.doc(notificationId).update({
      disabledFieldName: true,
    });
  }

  Future<NotificationsType> getStartingNotifs(
      String userId) async {
    final DateTime now = DateTime.now();
    final DateTime threeDaysAgo = now.subtract(const Duration(days: 3));
    final Timestamp threeDaysAgoTimestamp = Timestamp.fromDate(threeDaysAgo);

    final NotificationsType notifs = {
      requestsKeyName: [],
      normalNotifsKeyName: [],
    };

    await notificationCollection
        .where(timestampFieldName, isGreaterThan: threeDaysAgoTimestamp)
        .where(toUserIdFieldName, isEqualTo: userId)
        .where(notificationTypeFieldName, isEqualTo: otherType)
        .where(readFieldName, isEqualTo: true)
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        final CloudNotification notif = CloudNotification.fromSnapshot(doc);
        notifs[normalNotifsKeyName]?.add(Tuple2(null, notif));
      }
    });

    await notificationCollection
        .where(disabledFieldName, isEqualTo: false)
        .where(readFieldName, isEqualTo: true)
        .where(toUserIdFieldName, isEqualTo: userId)
        .where(notificationTypeFieldName, isEqualTo: frqType)
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        final CloudNotification notif = CloudNotification.fromSnapshot(doc);

        notifs[requestsKeyName]?.add(Tuple2(notif.type, notif));
      }
    });
    return notifs;
  }



  Stream<List<CloudNotification>> getNormalNotifications(String userId) {
    return notificationCollection
        .where(toUserIdFieldName, isEqualTo: userId)
        .where(readFieldName, isEqualTo: false)
        .where(notificationTypeFieldName, isNotEqualTo: srqType)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CloudNotification.fromSnapshot(doc))
            .toList());
  }

  Future<void> markNotificationAsRead(CloudNotification notification) async {
    await notificationCollection
        .doc(notification.notificationId)
        .update({'read': true});
  }


  Future<void> deleteNotification(CloudNotification notification) async {
    await notificationCollection.doc(notification.notificationId).delete();
  }
}
