import 'package:flutter/material.dart';
import 'package:gymtracker/services/cloud/database_controller.dart';

import '../../constants/cloud_contraints.dart';

@immutable
class CloudSquad {
  static late final DatabaseController dbController;
  final String id;
  final String name;
  final List<int> members;
  final DateTime timeCreated;
  final int ownerId;
  final String description;


  const CloudSquad({
    required this.id,
    required this.name,
    required this.members,
    required this.timeCreated,
    required this.ownerId,
    required this.description,
  });

  CloudSquad.fromMap(Map<String, dynamic> map)
      : id = map[idFieldName],
        name = map[squadNameFieldName],
        members = List<int>.from(map[membersFieldName]),
        timeCreated = map[timeCreatedFieldName] as DateTime,
        ownerId = map[ownerUserFieldName],
        description = map[squadDescriptionFieldName];

  static Future<CloudSquad> createSquad(String name, String description) async {
    return dbController.createSquad(name, description);
  }

  static Future<CloudSquad?> fetchSquad(String squadId) async {
    return dbController.fetchSquad(squadId);
  }

  Future<CloudSquad> removeUserFromSquad(String userId) async {
    return dbController.removeUserFromSquad(userId, id);
  }

}
