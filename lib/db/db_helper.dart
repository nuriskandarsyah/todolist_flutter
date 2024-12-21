import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'todo.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE todos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            task TEXT NOT NULL,
            isCompleted INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  // Tambahkan tugas baru
  Future<int> addTodo(String task, int isCompleted) async {
    final db = await database;
    return await db.insert('todos', {
      'task': task,
      'isCompleted': isCompleted,
    });
  }

  // Ambil semua tugas
  Future<List<Map<String, dynamic>>> getAllTodos() async {
    final db = await database;
    return await db.query('todos', orderBy: 'id DESC');
  }

  // Perbarui tugas
  Future<int> updateTodo(int id, String task, int isCompleted) async {
    final db = await database;
    return await db.update(
      'todos',
      {
        'task': task,
        'isCompleted': isCompleted,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Hapus tugas
  Future<int> deleteTodo(int id) async {
    final db = await database;
    return await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
