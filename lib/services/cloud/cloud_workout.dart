import 'package:equatable/equatable.dart';
import 'package:gymtracker/helpers/workout_json_adapter.dart';
import 'package:gymtracker/services/cloud/database_controller.dart';

import '../../constants/cloud_contraints.dart';
import '../../utils/widgets/workout_builder_widget.dart';

class CloudWorkout extends WorkoutJsonAdapter with EquatableMixin {
  static late final DatabaseController dbController;

  final String name;
  final String id;
  final String ownerId;
  final DateTime timeCreated;

  CloudWorkout({
    required this.id,
    required this.ownerId,
    required this.timeCreated,
    this.name = "",
    required super.workouts,
  });

  CloudWorkout.fromSupabaseMap(Map<String, dynamic> map)
    : id = map[idFieldName].toString(),
      ownerId = map[ownerUserFieldName].toString(),
      timeCreated = DateTime.parse(map[timeCreatedFieldName]),
      name = map[rowName],
      super(workouts: WorkoutJsonAdapter.mapFromJson(map[planFieldName]));

  static Future<CloudWorkout> createWorkout(
    userId,
    FilteredExerciseFormat workouts,
    String name,
  ) async {
    final json = WorkoutJsonAdapter(workouts: workouts).toJson();
    return await dbController.createWorkout(userId, json, name);
  }

  static Future<List<CloudWorkout>> fetchWorkouts(userId) async {
    return await dbController.fetchWorkouts(userId);
  }

  Future<CloudWorkout> editWorkout(FilteredExerciseFormat workouts) async {
    return await dbController.editWorkout(id, toJson());
  }

  Future<void> deleteWorkout() async {
    await dbController.deleteWorkout(id);
  }

  @override
  String toString() {
    return 'CloudWorkout{id: $id, ownerId: $ownerId, '
        'timeCreated: $timeCreated, workouts: $workouts}';
  }

  @override
  List<Object?> get props => [id];
}
