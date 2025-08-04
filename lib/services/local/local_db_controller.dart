import 'package:gymtracker/services/local/local_exercise.dart';

abstract class LocalDatabaseController {
  Future<void> loadInitialData(String path);
  Future<void> initialize();
  Future<void> addExercise(Map<String, dynamic> exercise);
  Future<Exercise> getExercise(String name);
  Future<List<Exercise>> getExercises(String query);
  Future<List<Exercise>> getPrExercises(String query);

}