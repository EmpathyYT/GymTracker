class Exercise {
  final String name;
  final String mainMuscle;
  final String? secondaryMuscle;
  final String bodyRegion;
  final String primaryEquipment;
  final String difficulty;

  const Exercise({
    required this.name,
    required this.bodyRegion,
    required this.difficulty,
    required this.mainMuscle,
    required this.secondaryMuscle,
    required this.primaryEquipment
  });


  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'main_muscle': mainMuscle,
      'secondary_muscle': secondaryMuscle ?? '',
      'body_region': bodyRegion,
      'difficulty': difficulty,
      'primary_equipment': primaryEquipment,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      name: map['name'] as String,
      mainMuscle: map['main_muscle'] as String,
      secondaryMuscle: map['secondary_muscle'] as String?,
      bodyRegion: map['body_region'] as String,
      difficulty: map['difficulty'] as String,
      primaryEquipment: map['primary_equipment'] as String,
    );
  }

}
