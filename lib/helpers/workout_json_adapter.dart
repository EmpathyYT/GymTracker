import 'package:gymtracker/helpers/exercise_type.dart';
import 'package:json_annotation/json_annotation.dart';

import '../utils/widgets/workout_builder_widget.dart';

part 'workout_json_adapter.g.dart';

@JsonSerializable()
class WorkoutJsonAdapter {
  @JsonKey(name: 'workouts', fromJson: _mapFromJson, toJson: _mapToJson)
  final FilteredExerciseFormat workouts;

  WorkoutJsonAdapter({required this.workouts});

  factory WorkoutJsonAdapter.fromJson(Map<String, dynamic> json) =>
      _$WorkoutJsonAdapterFromJson(json);

  Map<String, dynamic> toJson() => _$WorkoutJsonAdapterToJson(this);


  //Adapters
  static FilteredExerciseFormat _mapFromJson(Map<String, dynamic> json) {
    final FilteredExerciseFormat workouts = {};
    json.forEach((key, value) {
      workouts[int.parse(key)] = (value as List)
          .map((e) => ExerciseType.fromMap(e as Map<String, dynamic>))
          .toList();
    });
    return workouts;
  }

  static Map<String, dynamic> _mapToJson(
      FilteredExerciseFormat workouts) {
    final Map<String, dynamic> json = {};
    workouts.forEach((key, value) {
      json[key.toString()] = value.map((e) => e.toMap()).toList();
    });
    return json;
  }
}