import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class CaseHistoryService {
  CaseHistoryService._();

  static final CaseHistoryService instance = CaseHistoryService._();

  Database? _database;

  Future<Database> get _db async {
    if (_database != null) return _database!;

    final databasesPath = await getDatabasesPath();
    final databasePath = path.join(databasesPath, 'architect_solver_history.db');

    _database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE cases (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            description TEXT NOT NULL,
            project_type TEXT NOT NULL,
            location TEXT NOT NULL DEFAULT '',
            created_at TEXT NOT NULL
          )
        ''');
      },
    );

    return _database!;
  }

  Future<int> saveCase({
    required String description,
    required String projectType,
    required String location,
  }) async {
    final database = await _db;
    return database.insert('cases', {
      'description': description.trim(),
      'project_type': projectType.trim(),
      'location': location.trim(),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, Object?>>> getCases() async {
    final database = await _db;
    return database.query('cases', orderBy: 'created_at DESC');
  }

  Future<int> deleteCase(int id) async {
    final database = await _db;
    return database.delete('cases', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
