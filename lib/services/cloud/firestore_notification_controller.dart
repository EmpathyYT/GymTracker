import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:gymtracker/constants/cloud_contraints.dart';
import 'package:gymtracker/services/cloud/cloud_notification.dart';

class NotificationController {
  final notificationCollection =
      FirebaseFirestore.instance.collection('notifications');

  NotificationController._privateConstructor();
  static final NotificationController _instance =
      NotificationController._privateConstructor();
  factory NotificationController() => _instance;

  Future<void> sendNotification(String userId, String title, String body) async {
    final notificationRef = FirebaseFirestore.instance.collection('notifications');
    await notificationRef.add({
      fromUserIdFieldName: userId,
      toUserIdFieldName: userId,
      titleFieldName: title,
      bodyFieldName: body,
      timestampFieldName: FieldValue.serverTimestamp(),
    });
  }

  Stream<List<CloudNotification>> getNotifications(String userId) {
    return FirebaseFirestore.instance
        .collection('notifications')
        .where(toUserIdFieldName, isEqualTo: userId)
        .where(readFieldName, isEqualTo: false)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => CloudNotification.fromSnapshot(doc)).toList());
  }

  Future<void> markNotificationAsRead(CloudNotification notification) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notification.notificationId)
        .update({'read': true});
  }
  //TODO work on notifications, use workmanager.
}
