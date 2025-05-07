import 'package:gymtracker/helpers/workout_json_adapter.dart';
import 'package:gymtracker/services/cloud/database_controller.dart';

import '../../constants/cloud_contraints.dart';
import '../../utils/widgets/workout_builder_widget.dart';

class CloudWorkout extends WorkoutJsonAdapter {
  static late final DatabaseController dbController;

  final String id;
  final String ownerId;
  final DateTime timeCreated;

  CloudWorkout({
    required this.id,
    required this.ownerId,
    required this.timeCreated,
    required super.workouts,
  });

  CloudWorkout.fromSupabaseMap(Map<String, dynamic> map)
      : id = map[idFieldName].toString(),
        ownerId = map[ownerUserFieldName].toString(),
        timeCreated = DateTime.parse(map[timeCreatedFieldName]),
        super(workouts: map[planFieldName]);

  static Future<CloudWorkout> createWorkout(
      FilteredExerciseFormat workouts) async {
    final json = WorkoutJsonAdapter(workouts: workouts).toJson();
    return await dbController.createWorkout(json);
  }
}
