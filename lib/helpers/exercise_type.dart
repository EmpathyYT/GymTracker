import 'package:tuple/tuple.dart';

class ExerciseType {
  final String name;
  final int reps;
  final int sets;
  final Tuple2<int, int> weightRange;
  final String notes;

  const ExerciseType({
    required this.name,
    required this.reps,
    required this.sets,
    required this.weightRange,
    this.notes = '',
  });

  ExerciseType.fromMap(Map<String, dynamic> map)
      : name = map['name'] as String,
        reps = map['reps'] as int,
        sets = map['sets'] as int,
        weightRange = Tuple2<int, int>(
            map['weightRange'][0] as int, map['weightRange'][1] as int? ?? 0),
        notes = map['notes'] as String? ?? '';

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'reps': reps,
      'sets': sets,
      'weightRange': [weightRange.item1, weightRange.item2],
      'notes': notes,
    };
  }
}
