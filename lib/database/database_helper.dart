import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('hilow.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE game (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        money INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        time TEXT NOT NULL,
        bet_amount INTEGER NOT NULL,
        bet_type TEXT NOT NULL,
        result TEXT NOT NULL,
        profit INTEGER NOT NULL
      )
    ''');

    await db.insert('game', {'money': 100000});
  }

  Future<int> getMoney() async {
    final db = await instance.database;
    final result = await db.query('game', limit: 1);
    return result.isNotEmpty ? result.first['money'] as int : 0;
  }

  Future<void> updateMoney(int money) async {
    final db = await instance.database;
    await db.update('game', {'money': money}, where: 'id = ?', whereArgs: [1]);
  }

  Future<void> insertBet({
    required String time,
    required int betAmount,
    required String betType,
    required String result,
    required int profit,
  }) async {
    final db = await instance.database;
    await db.insert('history', {
      'time': time,
      'bet_amount': betAmount,
      'bet_type': betType,
      'result': result,
      'profit': profit,
    });
  }

  Future<List<Map<String, dynamic>>> fetchHistory() async {
    final db = await instance.database;
    final result = await db.query('history', orderBy: 'id DESC');
    print("Fetched history: $result"); // 쿼리 결과 출력
    return result;
  }
}
