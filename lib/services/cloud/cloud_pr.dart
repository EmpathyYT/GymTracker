import 'package:gymtracker/constants/cloud_contraints.dart';

import 'database_controller.dart';

class CloudPr {
  static late final DatabaseController dbController;
  final String id;
  final String exercise;
  final DateTime date;
  final double targetWeight;
  final double? actualWeight;

  CloudPr({
    required this.id,
    required this.exercise,
    required this.date,
    required this.targetWeight,
    this.actualWeight,
  });

  CloudPr.fromSupabaseMap(Map<String, dynamic> map)
    : id = map[idFieldName].toString(),
      exercise = map[exerciseNameFieldName],
      date = DateTime.parse(map[prDateFieldName]),
      targetWeight = double.parse(map[prTargetWeightFieldName].toString()),
      actualWeight = map[prActualWeightFieldName];

  static Future<List<CloudPr>> fetchPrs(userId) async {
    return await dbController.fetchPrs(userId);
  }

  static Future<void> addPr(
    String exercise,
    userId,
    DateTime date,
    double targetWeight,
  ) async {
    await dbController.addPr(userId, exercise, date, targetWeight);
  }
}
