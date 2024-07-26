import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/list_model.dart';

class ListDatabase {
  static final ListDatabase _instance = ListDatabase._internal();
  factory ListDatabase() => _instance;

  static Database? _database;

  ListDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'list_database.db');
    return await openDatabase(
      path,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE lists(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT
          )
        ''');
      },
      version: 1,
    );
  }

  Future<List<TaskList>> getLists() async {
    final db = await database;
    final maps = await db.query('lists');
    return List.generate(maps.length, (i) {
      return TaskList.fromMap(maps[i]);
    });
  }

  Future<void> insertList(TaskList list) async {
    final db = await database;
    await db.insert(
      'lists',
      list.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateList(TaskList list) async {
    final db = await database;
    await db.update(
      'lists',
      list.toMap(),
      where: 'id = ?',
      whereArgs: [list.id],
    );
  }

  Future<void> deleteList(int id) async {
    final db = await database;
    await db.delete(
      'lists',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
