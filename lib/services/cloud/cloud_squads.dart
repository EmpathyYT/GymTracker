import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../constants/cloud_contraints.dart';

@immutable
class CloudSquad {
  final String documentId;
  final String name;
  final List<String> members;
  final Timestamp timeCreated;
  final String ownerId;
  final String description;
  final List<String> usersInvited;

  const CloudSquad({
    required this.documentId,
    required this.name,
    required this.members,
    required this.timeCreated,
    required this.ownerId,
    required this.description,
    required this.usersInvited,
  });

  CloudSquad.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : documentId = snapshot.id,
        name = snapshot.data()?[squadNameFieldName] as String,
        members = (snapshot.data()?[membersFieldName] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        timeCreated = snapshot.data()?[timeCreatedFieldName] as Timestamp,
        ownerId = snapshot.data()?[ownerUserFieldId] as String,
        description = snapshot.data()?[squadDescriptionFieldName] as String,
        usersInvited = (snapshot.data()?[usersInvitedFieldName] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [];
}
