import 'package:equatable/equatable.dart';
import 'package:gymtracker/extensions/remove_decimal_if_necessary.dart';
import 'package:tuple/tuple.dart';

import '../constants/code_constraints.dart';

class ExerciseType with EquatableMixin {
  String name;
  int reps;
  int sets;
  Tuple2<double, double> weightRange;
  String notes;
  bool isKg;

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
      weightRange = Tuple2<double, double>(
        double.parse(map['weightRange'][0].toString()),
        double.tryParse(map['weightRange'][1].toString()) ?? 0,
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
    String initialWeight =
        weightRange.item1.removeDecimalIfNecessary.toString();
    if (initialWeight.isEmpty || weightRange.item1 == 0) {
      return noWeightRestrictionMessage;
    }
    if (weightRange.item2 == 0 || weightRange.item2 == weightRange.item1) {
      initialWeight += " kg";
    } else {
      initialWeight += " - ${weightRange.item2.removeDecimalIfNecessary} kg";
    }
    return initialWeight;
  }

  //todo add an edit method to update the exercise type

  set json(Map<String, dynamic> map) {
    name = map['name'] as String;
    reps = map['reps'] as int;
    sets = map['sets'] as int;
    weightRange = Tuple2<double, double>(
      double.tryParse(map['weightRange'][0].toString()) ?? 0,
      double.tryParse(map['weightRange'][1].toString()) ?? 0,
    );
    notes = map['notes'] as String? ?? '';
  }

  @override
  String toString() {
    return toMap().toString();
  }

  @override
  List<Object?> get props => [name, reps, sets, weightRange, notes];
}
