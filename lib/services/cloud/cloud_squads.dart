import 'package:flutter/material.dart';
import 'package:gymtracker/services/cloud/database_controller.dart';

import '../../constants/cloud_contraints.dart';

@immutable
class CloudSquad {
  static late final DatabaseController dbController;
  final String id;
  final String name;
  final List<String> members;
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

  CloudSquad.fromSupabaseMap(Map<String, dynamic> map)
      : id = map[idFieldName].toString(),
        name = map[squadNameFieldName],
        members = (map[membersFieldName] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        timeCreated = DateTime.parse(map[timeCreatedFieldName]),
        ownerId = map[ownerUserFieldName],
        description = map[squadDescriptionFieldName];

  static Future<CloudSquad> createSquad(String name, String description) async {
    return dbController.createSquad(name, description);
  }

  static Future<CloudSquad?> fetchSquad(String squadId, bool isMember) async {
    return dbController.fetchSquad(squadId, isMember);
  }

  Future<CloudSquad> removeUserFromSquad(String userId) async {
    return dbController.removeUserFromSquad(userId, id);
  }



}
