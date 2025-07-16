class DbNotInitializedException implements Exception {
  final String message = 'Database not initialized';
}

class ExerciseNotFoundException implements Exception {
  final String message = 'Exercise not found in the database';
}