import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'database_config.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), DatabaseConfig.databaseName);
    
    return await openDatabase(
      path,
      version: DatabaseConfig.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT UNIQUE,
        username TEXT,
        email TEXT,
        profilePhoto TEXT,
        age INTEGER,
        gender TEXT,
        location TEXT,
        bio TEXT,
        isOnline INTEGER,
        lastSeen INTEGER,
        createdAt INTEGER,
        updatedAt INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE chat_messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        messageId TEXT UNIQUE,
        senderId TEXT,
        receiverId TEXT,
        message TEXT,
        messageType TEXT,
        timestamp INTEGER,
        isRead INTEGER,
        isDelivered INTEGER,
        mediaUrl TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE likes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT,
        likedUserId TEXT,
        isLike INTEGER,
        timestamp INTEGER,
        UNIQUE(userId, likedUserId)
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT UNIQUE,
        value TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
  }

  // Generic CRUD operations
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> query(String table, 
      {String? where, List<dynamic>? whereArgs, String? orderBy, int? limit}) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  Future<int> update(String table, Map<String, dynamic> data, 
      {String? where, List<dynamic>? whereArgs}) async {
    final db = await database;
    return await db.update(
      table,
      data,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<int> delete(String table, 
      {String? where, List<dynamic>? whereArgs}) async {
    final db = await database;
    return await db.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
