import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../constants/cloud_contraints.dart';

@immutable
class CloudUser with EquatableMixin {
  final String documentId;
  final List<String> friends;
  final List<String> squads;
  final String name;
  final Timestamp timeCreated;
  final int squadLimit;
  final String bio;
  final int level;
  final List<String> pendingFrq;
  final List<String> pendingSrq;

  const CloudUser({
    required this.documentId,
    required this.name,
    required this.squads,
    required this.friends,
    required this.timeCreated,
    required this.squadLimit,
    required this.bio,
    required this.level,
    required this.pendingFrq,
    required this.pendingSrq,
  });

  CloudUser.newUser(String userId, String name): this(
    documentId: userId,
    name: name,
    squads: [],
    friends: [],
    timeCreated: Timestamp.now(),
    squadLimit: 0,
    bio: '',
    level: 0,
    pendingFrq: [],
    pendingSrq: [],
  );

  CloudUser.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        name = snapshot.data()?[nameFieldName] as String,
        friends = (snapshot.data()?[friendsFieldName] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        timeCreated = snapshot.data()?[timeCreatedFieldName] as Timestamp,
        squads = (snapshot.data()?[squadFieldName] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        squadLimit = snapshot.data()?[squadLimitFieldName] as int,
        bio = snapshot.data()?[bioFieldName] as String,
        level = snapshot.data()?[levelFieldName] as int,
        pendingFrq = (snapshot.data()?[pendingFRQFieldName] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        pendingSrq =
            (snapshot.data()?[pendingSquadReqFieldName] as List<dynamic>?)
                    ?.map((e) => e as String)
                    .toList() ??
                [];

  @override
  List<Object?> get props => [documentId, name, squads, friends, timeCreated];


}
