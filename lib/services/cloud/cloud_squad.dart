import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gymtracker/services/cloud/cloud_notification.dart';
import 'package:gymtracker/services/cloud/database_controller.dart';

import '../../constants/cloud_contraints.dart';

@immutable
class CloudSquad {
  static late final DatabaseController dbController;
  final List<CloudSquadAchievement> achievements = [];
  final String id;
  final String name;
  final List<String> members;
  final DateTime timeCreated;
  final String ownerId;
  final String description;

  CloudSquad({
    required this.id,
    required this.name,
    required this.members,
    required this.timeCreated,
    required this.ownerId,
    required this.description,
  });

  CloudSquad.fromSupabaseMap(Map<String, dynamic> map)
      : id = map[idFieldName].toString(),
        name = map[rowName],
        members = (map[membersFieldName] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        timeCreated = DateTime.parse(map[timeCreatedFieldName]),
        ownerId = map[ownerUserFieldName].toString(),
        description = map[squadDescriptionFieldName];

  static Future<CloudSquad> createSquad(String name, String description) async {
    return dbController.createSquad(name, description);
  }

  static Future<CloudSquad?> fetchSquad(String squadId, bool isMember) async {
    final squad = await dbController.fetchSquad(squadId, isMember);
    if (squad != null) {
      await squad.getAchievements();
      return squad;
    }
    return null;

  }

  Future<CloudSquad> removeUserFromSquad(String userId) async {
    return dbController.removeUserFromSquad(userId, id);
  }

  Future<CloudSquad> edit(
      String name,
      String description,
    ) async {
    return dbController.editSquad(id, name, description);
  }

  static Future<void> leaveSquad(squadId) async {
    return dbController.leaveSquad(squadId);
  }

  Future<void> getAchievements() async {
    final achievements = await CloudSquadAchievement.fetchSquadAchievements(id);
    this.achievements.addAll(achievements);
  }
}
