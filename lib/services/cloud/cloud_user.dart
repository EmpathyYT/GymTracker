import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'cloud_contraints.dart';

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

  CloudUser.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        name = snapshot.data()?[nameFieldName] as String,
        friends = (snapshot.data()?[friendsFieldName] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ?? [],
        timeCreated = snapshot.data()?[timeCreatedFieldName] as Timestamp,
        squads = (snapshot.data()?[squadFieldName] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ?? [],
        squadLimit = snapshot.data()?[squadLimitFieldName] as int,
        bio = snapshot.data()?[bioFieldName] as String,
        level = snapshot.data()?[levelFieldName] as int;



  @override
  List<Object?> get props => [documentId, name, squads, friends, timeCreated];
}
