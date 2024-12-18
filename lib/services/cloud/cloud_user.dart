import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gymtracker/services/cloud/cloud_squds.dart';

import 'cloud_contraints.dart';

@immutable
class CloudUser {
  final String documentId;
  final List<CloudUser> friends;
  final List<CloudSquad> squads;
  final String name;
  final String timeCreated;

  const CloudUser({
    required this.documentId,
    required this.name,
    required this.squads,
    required this.friends,
    required this.timeCreated,
  });

  CloudUser.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        name = snapshot.data()[nameFieldName] as String,
        friends = snapshot.data()[friendsFieldName] as List<CloudUser>,
        timeCreated = snapshot.data()[timeCreatedFieldName] as String,
        squads = snapshot.data()[squadFieldName] as List<CloudSquad>;
}