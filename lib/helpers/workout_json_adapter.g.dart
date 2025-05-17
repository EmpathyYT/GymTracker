// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_json_adapter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutJsonAdapter _$WorkoutJsonAdapterFromJson(Map<String, dynamic> json) =>
    WorkoutJsonAdapter(
      workouts: WorkoutJsonAdapter.mapFromJson(
          json['workouts'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WorkoutJsonAdapterToJson(WorkoutJsonAdapter instance) =>
    <String, dynamic>{
      'workouts': WorkoutJsonAdapter._mapToJson(instance.workouts),
    };
