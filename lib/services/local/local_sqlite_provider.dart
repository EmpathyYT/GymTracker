import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:gymtracker/exceptions/local_exceptions.dart';
import 'package:gymtracker/services/local/local_db_controller.dart';
import 'package:gymtracker/services/local/local_exercise.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class LocalSqliteProvider implements LocalDatabaseController {
  Future<Database>? database;

  @override
  Future<void> initialize() async {
    Directory documentsDir = await getApplicationDocumentsDirectory();
    String dbPath = join(documentsDir.path, 'exercises.db');
    if (!(await File(dbPath).exists())) {
      await loadInitialData(dbPath);
    }

    database = openDatabase(
      dbPath,
      version: 1,
    );
  }

  @override
  Future<void> addExercise(Map<String, dynamic> exercise) async {
    if (database == null) {
      throw DbNotInitializedException();
    }

    final db = await database!;
    await db.insert(
      'exercises',
      exercise,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<Exercise> getExercise(String name) async {
    if (database == null) {
      throw DbNotInitializedException();
    }

    final db = await database!;
    final List<Map<String, dynamic>> maps = await db.query(
      'exercises',
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );
    if (maps.isEmpty) {
      throw ExerciseNotFoundException();
    }
    return Exercise.fromMap(maps.first);
  }

  @override
  Future<void> loadInitialData(String path) async {
    final ByteData data = await rootBundle.load(
      'assets/exercise_data/exercises.db',
    );
    List<int> bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );

    await File(path).writeAsBytes(bytes, flush: true);
  }

  @override
  Future<List<Exercise>> getExercises(String query) async {
    if (database == null) {
      throw DbNotInitializedException();
    }

    final db = await database!;
    final List<Map<String, dynamic>> maps = await db.query(
      'exercises',
      where: 'LOWER(Exercise) LIKE ?',
      whereArgs: ['%${query.toLowerCase()}%'],
      limit: 10,
    );
    if (maps.isEmpty) {
      return [];
    }

    return maps.map((map) => Exercise.fromMap(map)).toList();
  }

  @override
  Future<List<Exercise>> getPrExercises(String query) async {
    if (database == null) {
      throw DbNotInitializedException();
    }
    final List<String> equipment = [
      'Barbell',
      'Dumbbell',
      'Bodyweight',
      'Trap Bar'
    ];

    final placeholders = List.filled(equipment.length, '?').join(', ');

    final db = await database!;
    final List<Map<String, dynamic>> maps = await db.query(
      'exercises',
      where: 'LOWER(Exercise) LIKE ? AND "Primary Equipment" in ($placeholders)',
      whereArgs: ['%${query.toLowerCase()}%', ...equipment],
      limit: 10,
    );
    if (maps.isEmpty) {
      return [];
    }

    return maps.map((map) => Exercise.fromMap(map)).toList();
  }
}
