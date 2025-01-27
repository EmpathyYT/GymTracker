import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gymtracker/constants/cloud_contraints.dart';

@immutable
class CloudNotification {
  final String notificationId;
  final String fromUserId;
  final String toUserId;
  final int type;
  final bool read;
  final Timestamp time;

  const CloudNotification({
    required this.notificationId,
    required this.fromUserId,
    required this.toUserId,
    required this.type,
    required this.read,
    required this.time,
  });

  CloudNotification.fromSnapshot(QueryDocumentSnapshot snapshot)
      : notificationId = snapshot.id,
        fromUserId = snapshot[fromUserIdFieldName],
        toUserId = snapshot[toUserIdFieldName],
        type = snapshot[notificationTypeFieldName],
        read = snapshot[readFieldName],
        time = snapshot[timestampFieldName] as Timestamp;

}