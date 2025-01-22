import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../constants/cloud_contraints.dart';

@immutable
class CloudUser with EquatableMixin {
  final String documentId;
  final List<String>? friends;
  final List<String>? squads;
  final String name;
  final Timestamp timeCreated;
  final int squadLimit;
  final String bio;
  final int level;

  const CloudUser({
    required this.documentId,
    required this.name,
    required this.squads,
    required this.friends,
    required this.timeCreated,
    required this.squadLimit,
    required this.bio,
    required this.level,
  });

  CloudUser.newUser(String userId, String name)
      : this(
          documentId: userId,
          name: name,
          squads: [],
          friends: [],
          timeCreated: Timestamp.now(),
          squadLimit: 0,
          bio: '',
          level: 0,
        );

  CloudUser.publicUserFromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        name = snapshot.data()?[nameFieldName] as String,
        friends = [],
        squads = [],
        timeCreated = snapshot.data()?[timeCreatedFieldName] as Timestamp,
        squadLimit = snapshot.data()?[squadLimitFieldName] as int,
        bio = snapshot.data()?[bioFieldName] as String,
        level = snapshot.data()?[levelFieldName] as int;

  CloudUser.privateUserFromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> userSnapshot,
      DocumentSnapshot<Map<String, dynamic>> sensitiveInfoSnapshot)
      : documentId = userSnapshot.id,
        name = userSnapshot.data()?[nameFieldName] as String,
        friends = sensitiveInfoSnapshot.data()?[friendsFieldName] as List<String>,
        squads = sensitiveInfoSnapshot.data()?[squadFieldName] as List<String>,
        timeCreated = userSnapshot.data()?[timeCreatedFieldName] as Timestamp,
        squadLimit = userSnapshot.data()?[squadLimitFieldName] as int,
        bio = userSnapshot.data()?[bioFieldName] as String,
        level = userSnapshot.data()?[levelFieldName] as int;

  @override
  List<Object?> get props => [documentId, name, timeCreated];
}
