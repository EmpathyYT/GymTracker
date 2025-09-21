import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:gymtracker/extensions/remove_decimal_if_necessary.dart';
import 'package:tuple/tuple.dart';

import '../constants/code_constraints.dart';

class ExerciseType with EquatableMixin {
  ExerciseTypesEnum type;
  String? name;
  int? reps;
  int? sets;
  Tuple2<double, double>? weightRange;
  String notes;
  bool? isKg;
  double? restPeriod;
  bool? isInMins;

  ExerciseType({
    required this.type,
    this.name,
    this.reps,
    this.sets,
    this.weightRange,
    this.restPeriod,
    this.isInMins,
    this.notes = '',
    this.isKg = true,
  });

  ExerciseType.fromMap(Map<String, dynamic> map)
    : name = map['name'] as String?,
      reps = map['reps'] as int?,
      sets = map['sets'] as int?,
      type =
          map['type'] == 'rest'
              ? ExerciseTypesEnum.rest
              : ExerciseTypesEnum.exercise,
      weightRange =
          map['type'] == 'rest'
              ? null
              : Tuple2<double, double>(
                double.tryParse(map['weightRange'][0].toString()) ?? 0.0,
                double.tryParse(map['weightRange'][1].toString()) ?? 0.0,
              ),
      restPeriod = double.tryParse(map['restPeriod'].toString()),
      isInMins = bool.tryParse(map['isInMins'].toString()),
      notes = map['notes'] as String? ?? '',
      isKg = true; //todo when settings are added

  Map<String, dynamic> toMap() {
    if (type == ExerciseTypesEnum.rest) {
      return {'type': 'rest', 'restPeriod': restPeriod!, 'isInMins': isInMins!};
    } else {
      return {
        'type': 'exercise',
        'name': name,
        'reps': reps,
        'sets': sets,
        'weightRange': [weightRange!.item1, weightRange!.item2],
        'notes': notes,
      };
    }
  }

  String get exerciseWeightToString {
    if (type == ExerciseTypesEnum.rest) return noWeightRestrictionMessage;
    String initialWeight =
        weightRange!.item1.removeDecimalIfNecessary.toString();
    if (initialWeight.isEmpty || weightRange!.item1 == 0) {
      return noWeightRestrictionMessage;
    }
    if (weightRange!.item2 == 0 || weightRange!.item2 == weightRange!.item1) {
      initialWeight += " kg";
    } else {
      initialWeight += " - ${weightRange!.item2.removeDecimalIfNecessary} kg";
    }
    return initialWeight;
  }

  //todo add an edit method to update the exercise type

  set json(Map<String, dynamic> map) {
    name = map['name'] as String?;
    reps = map['reps'] as int?;
    sets = map['sets'] as int?;
    type =
        map['type'] == 'rest'
            ? ExerciseTypesEnum.rest
            : ExerciseTypesEnum.exercise;
    weightRange = setWeightRange(map);
    restPeriod = double.tryParse(map['restPeriod'].toString());
    isInMins = bool.tryParse(map['isInMins'].toString());
    notes = map['notes'] as String? ?? '';
  }

  Tuple2<double, double>? setWeightRange(Map<String, dynamic> map) {
    if (type == ExerciseTypesEnum.rest) return null;

    weightRange = Tuple2<double, double>(
      double.tryParse(map['weightRange'][0].toString()) ?? 0.0,
      double.tryParse(map['weightRange'][1].toString()) ?? 0.0,
    );
    return weightRange;
  }

  @override
  String toString() {
    return toMap().toString();
  }

  @override
  List<Object?> get props => [
    name,
    reps,
    sets,
    weightRange,
    notes,
    type,
    restPeriod,
    isInMins,
    isKg,
  ];
}

enum ExerciseTypesEnum { exercise, rest, addExerciseIndicator }
