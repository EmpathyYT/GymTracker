import 'package:gymtracker/services/local/local_db_controller.dart';
import 'package:gymtracker/services/local/local_exercise.dart';
import 'package:gymtracker/services/local/local_sqlite_provider.dart';

class LocalDatabaseProvider implements LocalDatabaseController {
  final LocalDatabaseController controller;

  // Singleton instance
  static final LocalDatabaseProvider _instance =
      LocalDatabaseProvider._internal();

  // Private constructor
  LocalDatabaseProvider._internal() : controller = LocalSqliteProvider() {
    Future.sync(() async => await controller.initialize());
  }

  // Factory constructor to return the singleton instance
  factory LocalDatabaseProvider() {
    return _instance;
  }

  @override
  Future<void> addExercise(Map<String, dynamic> exercise) =>
      controller.addExercise(exercise);

  @override
  Future<Exercise> getExercise(String name) => controller.getExercise(name);

  @override
  Future<List<Exercise>> getExercises(String query) =>
      controller.getExercises(query);

  @override
  Future<void> initialize() => controller.initialize();

  @override
  Future<void> loadInitialData(path) => controller.loadInitialData(path);

  @override
  Future<List<Exercise>> getPrExercises(String query) =>
      controller.getPrExercises(query);
}
