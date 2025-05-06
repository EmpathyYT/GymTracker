import 'package:json_annotation/json_annotation.dart';

import 'exercise_type.dart';

class ExerciseTypeJsonAdapter
    implements JsonConverter<ExerciseType, Map<String, dynamic>> {
  const ExerciseTypeJsonAdapter();

  @override
  ExerciseType fromJson(Map<String, dynamic> json) =>
      ExerciseType.fromMap(json);

  @override
  Map<String, dynamic> toJson(ExerciseType object) => object.toMap();
}
