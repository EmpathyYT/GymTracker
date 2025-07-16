import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:gymtracker/exceptions/local_exceptions.dart';
import 'package:gymtracker/services/local/local_db_controller.dart';
import 'package:gymtracker/services/local/local_exercise.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalSqliteProvider implements LocalDatabaseController {
  Future<Database>? database;

  @override
  Future<void> initialize() async {
    final databasePath = join(await getDatabasesPath(), 'exercises.db');
    void openDb() {
      database = openDatabase(
        databasePath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE exercises (
              name TEXT PRIMARY KEY,
              difficulty TEXT,
              primary_equipment TEXT,
              main_muscle TEXT,
              secondary_muscle TEXT,
              body_region TEXT,
            )
          ''');
        },
      );
    }

    if (!await File(databasePath).exists()) {
      openDb();
      await loadInitialData();
    } else {
      openDb();
    }
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
    );
    if (maps.isEmpty) {
      throw ExerciseNotFoundException();
    }
    return Exercise.fromMap(maps.first);
  }

  @override
  Future<void> loadInitialData() async {
    final ByteData data = await rootBundle.load(
      'assets/exercise_data/exercises_export_2_front_end.csv',
    );
    List<int> bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );

    final csv = const CsvToListConverter().convert(utf8.decode(bytes))
      ..removeAt(0);

    for (final line in csv) {
      final exercise = Exercise(
        name: line[0] as String,
        difficulty: line[1] as String,
        primaryEquipment: line[2] as String,
        mainMuscle: line[3] as String,
        secondaryMuscle: line[4] as String,
        bodyRegion: line[5] as String,
      );
      await addExercise(exercise.toMap());
    }
  }

  @override
  Future<List<Exercise>> getExercises(String query) async {
    if (database == null) {
      throw DbNotInitializedException();
    }

    final db = await database!;
    final List<Map<String, dynamic>> maps = await db.query(
      'exercises',
      where: 'LOWER(name) ILIKE ?',
      whereArgs: ['%${query.toLowerCase()}%'],
    );

    if (maps.isEmpty) {
      return [];
    }

    return maps.map((map) => Exercise.fromMap(map)).toList();
  }
}
