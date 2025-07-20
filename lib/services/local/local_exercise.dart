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
    required this.primaryEquipment,
  });

  Map<String, dynamic> toMap() {
    return {
      'Exercise': name,
      'Prime Mover Muscle': mainMuscle,
      'Secondary Muscle': secondaryMuscle ?? '',
      'Body Region': bodyRegion,
      'Difficulty Level': difficulty,
      'Primary Equipment': primaryEquipment,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      name: map['Exercise'] as String,
      mainMuscle: map['Prime Mover Muscle'] as String,
      secondaryMuscle: map['Secondary Muscle'] as String?,
      bodyRegion: map['Body Region'] as String,
      difficulty: map['Difficulty Level'] as String,
      primaryEquipment: map['Primary Equipment'] as String,
    );
  }

  @override
  String toString() {
    return 'Exercise{name: $name, mainMuscle: $mainMuscle, secondaryMuscle: $secondaryMuscle, bodyRegion: $bodyRegion, primaryEquipment: $primaryEquipment, difficulty: $difficulty}';
  }
}
