import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:gymtracker/constants/cloud_contraints.dart';
import 'package:gymtracker/services/cloud/cloud_notification.dart';
typedef NotificationsType = Map<String, List<CloudNotification>>;

class FirestoreNotificationsController {
  final notificationCollection =
      FirebaseFirestore.instance.collection('notifications');

  FirestoreNotificationsController._privateConstructor();
  static final FirestoreNotificationsController _instance =
      FirestoreNotificationsController._privateConstructor();
  factory FirestoreNotificationsController() => _instance;

  Future<void> sendNotification(String senderId, String receiverId, int type) async {
    await notificationCollection.add({
      fromUserIdFieldName: senderId,
      toUserIdFieldName: receiverId,
      timestampFieldName: Timestamp.now(),
      readFieldName: false,
      notificationTypeFieldName: type,
    });
  }

  Stream<List<CloudNotification>> getNotifications(String userId) {
    return notificationCollection
        .where(toUserIdFieldName, isEqualTo: userId)
        .where(readFieldName, isEqualTo: false)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => CloudNotification.fromSnapshot(doc)).toList());
  }

  Future<void> markNotificationAsRead(CloudNotification notification) async {
    await notificationCollection
        .doc(notification.notificationId)
        .update({'read': true});
  }

}
