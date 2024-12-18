import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gymtracker/services/cloud/cloud_user.dart';

import 'cloud_contraints.dart';

@immutable
class CloudSquad {
  final String documentId;
  final String name;
  final List<CloudUser> members;
  final String timeCreated;
  final String ownerId;

  const CloudSquad({
    required this.documentId,
    required this.name,
    required this.members,
    required this.timeCreated,
    required this.ownerId,
  });

  CloudSquad.fromSnapshot(QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        name = snapshot.data()[squadNameFieldName] as String,
        members = snapshot.data()[membersFieldName] as List<CloudUser>,
        timeCreated = snapshot.data()[timeCreatedFieldName] as String,
        ownerId = snapshot.data()[ownerUserFieldId] as String;

}