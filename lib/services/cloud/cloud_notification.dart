import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymtracker/constants/cloud_contraints.dart';


class CloudNotification {
  final String notificationId;
  final String fromUserId;
  final String toUserId;
  final int type;
  bool read;
  final Timestamp time;
  final String message;

  CloudNotification({
    required this.notificationId,
    required this.fromUserId,
    required this.toUserId,
    required this.type,
    required this.read,
    required this.time,
    required this.message,
  });

  CloudNotification.testingNotif(this.time)
      :
        notificationId = "test",
        fromUserId = "vMM1p8I06NQ4YAGCoWOTGejPIZq2",
        toUserId = "hxzqod6a1kZZNxlQC8DTGAegZoi2",
        type = 2,
        read = true,
        message = "test";


  CloudNotification.fromSnapshot(QueryDocumentSnapshot snapshot)
      : notificationId = snapshot.id,
        fromUserId = snapshot[fromUserIdFieldName],
        toUserId = snapshot[toUserIdFieldName],
        type = snapshot[notificationTypeFieldName],
        read = snapshot[readFieldName],
        time = snapshot[timestampFieldName] as Timestamp,
        message = snapshot[notificationTypeFieldName] == 2
            ? snapshot[messageFieldName] : "";

  void readNotification() => read = true;
}