import 'package:tuple/tuple.dart';

import '../constants/code_constraints.dart';

class ExerciseType {
  final String name;
  final int reps;
  final int sets;
  final Tuple2<int, int> weightRange;
  String notes;
  final bool isKg;

  ExerciseType({
    required this.name,
    required this.reps,
    required this.sets,
    required this.weightRange,
    this.notes = '',
    this.isKg = true,
  });

  ExerciseType.fromMap(Map<String, dynamic> map)
    : name = map['name'] as String,
      reps = map['reps'] as int,
      sets = map['sets'] as int,
      weightRange = Tuple2<int, int>(
        map['weightRange'][0] as int,
        map['weightRange'][1] as int? ?? 0,
      ),
      notes = map['notes'] as String? ?? '',
      isKg = true; //todo when settings are added

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'reps': reps,
      'sets': sets,
      'weightRange': [weightRange.item1, weightRange.item2],
      'notes': notes,
    };
  }

  String get exerciseWeightToString {
    String initialWeight = weightRange.item1.toString();
    if (initialWeight.isEmpty || weightRange.item1 == 0) {
      return noWeightRestrictionMessage;
    }
    if (weightRange.item2 == 0 || weightRange.item2 == weightRange.item1) {
      initialWeight += " kg";
    } else {
      initialWeight += " - ${weightRange.item2} kg";
    }
    return initialWeight;
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
