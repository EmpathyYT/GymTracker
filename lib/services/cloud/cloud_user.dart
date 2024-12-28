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
  final String timeCreated;

  const CloudUser({
    required this.documentId,
    required this.name,
    required this.squads,
    required this.friends,
    required this.timeCreated,
  });

  CloudUser.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        name = snapshot.data()?[nameFieldName] as String,
        friends = snapshot.data()?[friendsFieldName] as List<String>,
        timeCreated = snapshot.data()?[timeCreatedFieldName] as String,
        squads = snapshot.data()?[squadFieldName] as List<String>;

  @override
  List<Object?> get props => [documentId, name, squads, friends, timeCreated];
}
