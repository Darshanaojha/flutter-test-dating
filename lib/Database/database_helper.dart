import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'database_config.dart';
import 'package:dating_application/Models/Entities/chat_message_entity.dart';
import 'package:dating_application/Models/ResponseModels/user_suggestions_response_model.dart'
    as suggestions;
import 'package:dating_application/Models/ResponseModels/get_all_favourites_response_model.dart'
    as favorites;
import 'package:dating_application/Models/ResponseModels/ProfileResponse.dart'
    as profile;

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
        dob TEXT,
        gender TEXT,
        location TEXT,
        bio TEXT,
        lastSeen INTEGER,
        createdAt INTEGER,
        updatedAt INTEGER,
        isCached INTEGER DEFAULT 1,
        lastSynced INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE chat_messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        messageId TEXT UNIQUE,
        senderId TEXT,
        receiverId TEXT,
        message TEXT,
        timestamp INTEGER,
        isRead INTEGER,
        isDelivered INTEGER,
        isCached INTEGER DEFAULT 1,
        lastSynced INTEGER
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
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS connections (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId TEXT,
          connectedUserId TEXT,
          status TEXT,
          createdAt INTEGER,
          updatedAt INTEGER,
          isCached INTEGER DEFAULT 1,
          lastSynced INTEGER,
          UNIQUE(userId, connectedUserId)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS user_preferences (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId TEXT,
          preferenceId TEXT,
          preferenceName TEXT,
          createdAt INTEGER,
          updatedAt INTEGER,
          UNIQUE(userId, preferenceId)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS user_desires (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId TEXT,
          desireId TEXT,
          desireName TEXT,
          createdAt INTEGER,
          updatedAt INTEGER,
          UNIQUE(userId, desireId)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS user_languages (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId TEXT,
          languageId TEXT,
          languageName TEXT,
          createdAt INTEGER,
          updatedAt INTEGER,
          UNIQUE(userId, languageId)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS packages (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          packageId TEXT UNIQUE,
          name TEXT,
          description TEXT,
          price REAL,
          duration INTEGER,
          features TEXT,
          createdAt INTEGER,
          updatedAt INTEGER,
          isCached INTEGER DEFAULT 1
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS transactions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          transactionId TEXT UNIQUE,
          userId TEXT,
          amount REAL,
          type TEXT,
          status TEXT,
          description TEXT,
          createdAt INTEGER,
          updatedAt INTEGER,
          isCached INTEGER DEFAULT 1
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS orders (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          orderId TEXT UNIQUE,
          userId TEXT,
          packageId TEXT,
          status TEXT,
          totalAmount REAL,
          createdAt INTEGER,
          updatedAt INTEGER,
          isCached INTEGER DEFAULT 1
        )
      ''');
    }
    
    // Add migration for version 2 to 3 - add dob column to users table
    if (oldVersion < 3) {
      try {
        // Check if the dob column already exists to avoid errors
        final result = await db.rawQuery('PRAGMA table_info(users)');
        final hasDobColumn = result.any((column) => column['name'] == 'dob');
        
        if (!hasDobColumn) {
          await db.execute('ALTER TABLE users ADD COLUMN dob TEXT');
        }
      } catch (e) {
        // If altering table fails, we'll handle it gracefully
        print('Error adding dob column: $e');
      }
    }
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> query(String table,
      {String? where,
      List<dynamic>? whereArgs,
      String? orderBy,
      int? limit}) async {
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

  Future<void> clearTable(String table) async {
    final db = await database;
    await db.delete(table);
  }

  // Chat Messages Caching Methods
  Future<void> cacheChatMessages(List<ChatMessageEntity> messages) async {
    final db = await database;
    final batch = db.batch();

    for (final message in messages) {
      batch.insert(
          'chat_messages',
          {
            'messageId': message.messageId,
            'senderId': message.senderId,
            'receiverId': message.receiverId,
            'message': message.message,
            'timestamp': message.timestamp,
            'isRead': message.isRead,
            'isDelivered': message.isDelivered,
            'isCached': 1,
            'lastSynced': DateTime.now().millisecondsSinceEpoch
          },
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit();
  }

  Future<List<ChatMessageEntity>> getCachedChatMessages(
      String userId, String otherUserId) async {
    final db = await database;
    final results = await db.query('chat_messages',
        where:
            '(senderId = ? AND receiverId = ?) OR (senderId = ? AND receiverId = ?)',
        whereArgs: [userId, otherUserId, otherUserId, userId],
        orderBy: 'timestamp ASC');

    return results.map((map) => ChatMessageEntity.fromMap(map)).toList();
  }

  // User Profile Caching Methods
  Future<void> saveUserProfile(profile.UserData userData) async {
    final db = await database;
    await db.insert(
        'users',
        {
          'userId': userData.id,
          'username': userData.name,
          'email': userData.email,
          'profilePhoto': userData.profileImage,
          'dob': userData.dob,
          'gender': userData.gender,
          'location': userData.city,
          'bio': userData.bio,
          'lastSeen': int.tryParse(userData.lastSeen ?? '0') ?? 0,
          'createdAt': int.tryParse(userData.created) ?? 0,
          'updatedAt': int.tryParse(userData.updated) ?? 0,
          'isCached': 1,
          'lastSynced': DateTime.now().millisecondsSinceEpoch
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<profile.UserData?> getUserProfile(String userId) async {
    final db = await database;
    final results = await db.query('users',
        where: 'userId = ?', whereArgs: [userId], limit: 1);

    if (results.isEmpty) return null;

    final userMap = results.first;
    return profile.UserData(
      id: userMap['userId'] as String? ?? '',
      name: userMap['username'] as String? ?? '',
      email: userMap['email'] as String? ?? '',
      mobile: '',
      city: userMap['location'] as String? ?? '',
      address: '',
      gender: userMap['gender'] as String? ?? '',
      subGender: '',
      countryId: '',
      password: '',
      latitude: '',
      longitude: '',
      otp: '',
      type: '',
      dob: userMap['dob'] as String? ?? '',
      nickname: '',
      interest: '',
      bio: userMap['bio'] as String? ?? '',
      emailAlerts: '',
      lookingFor: '',
      username: userMap['username'] as String? ?? '',
      profileImage: userMap['profilePhoto'] as String? ?? '',
      userActiveStatus: '',
      statusSetting: '',
      accountVerificationStatus: '',
      accountHighlightStatus: '',
      status: '',
      created: (userMap['createdAt'] as int?)?.toString() ?? '',
      updated: (userMap['updatedAt'] as int?)?.toString() ?? '',
      genderName: '',
      subGenderName: '',
    );
  }

  // User Suggestions Caching Methods
  Future<void> cacheUserSuggestions(
      List<suggestions.SuggestedUser> suggestions) async {
    final db = await database;
    final batch = db.batch();

    for (final suggestion in suggestions) {
      batch.insert(
          'users',
          {
            'userId': suggestion.userId,
            'username': suggestion.name,
            'email': suggestion.email,
            'profilePhoto': suggestion.profileImage,
            'dob': suggestion.dob,
            'gender': suggestion.gender,
            'location': suggestion.city,
            'bio': suggestion.bio,
            'lastSeen': int.tryParse(suggestion.lastSeen ?? '0') ?? 0,
            'createdAt': int.tryParse(suggestion.created ?? '0') ?? 0,
            'updatedAt': int.tryParse(suggestion.updated ?? '0') ?? 0,
            'isCached': 1,
            'lastSynced': DateTime.now().millisecondsSinceEpoch
          },
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit();
  }

  Future<List<suggestions.SuggestedUser>> getCachedUserSuggestions() async {
    final db = await database;
    final results = await db.query('users',
        where: 'isCached = 1', orderBy: 'lastSynced DESC');

    return results.map((map) => _convertMapToSuggestedUser(map)).toList();
  }

  // Favorites Caching Methods
  Future<void> cacheFavorites(List<favorites.Favourite> favorites) async {
    final db = await database;
    final batch = db.batch();

    for (final favorite in favorites) {
      batch.insert(
          'users',
          {
            'userId': favorite.userId,
            'username': favorite.name,
            'email': favorite.email,
            'profilePhoto': favorite.profileImage,
            'dob': favorite.dob,
            'gender': favorite.gender,
            'location': favorite.city,
            'bio': favorite.bio,
            'lastSeen': int.tryParse(favorite.lastSeen ?? '0') ?? 0,
            'createdAt': int.tryParse(favorite.created ?? '0') ?? 0,
            'updatedAt': int.tryParse(favorite.updated ?? '0') ?? 0,
            'isCached': 1,
            'lastSynced': DateTime.now().millisecondsSinceEpoch
          },
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit();
  }

  Future<List<favorites.Favourite>> getCachedFavorites() async {
    final db = await database;
    final results = await db.query('users',
        where: 'isCached = 1', orderBy: 'lastSynced DESC');

    return results.map((map) => _convertMapToFavourite(map)).toList();
  }

  suggestions.SuggestedUser _convertMapToSuggestedUser(
      Map<String, dynamic> map) {
    return suggestions.SuggestedUser(
      userId: map['userId'] as String?,
      name: map['username'] as String?,
      email: map['email'] as String?,
      profileImage: map['profilePhoto'] as String?,
      gender: map['gender'] as String?,
      city: map['location'] as String?,
      bio: map['bio'] as String?,
      lastSeen: (map['lastSeen'] as int?)?.toString(),
      created: (map['createdAt'] as int?)?.toString(),
      updated: (map['updatedAt'] as int?)?.toString(),
      dob: map['dob'] as String? ?? '',
    );
  }

  favorites.Favourite _convertMapToFavourite(Map<String, dynamic> map) {
    return favorites.Favourite(
      userId: map['userId'] as String?,
      name: map['username'] as String?,
      email: map['email'] as String?,
      profileImage: map['profilePhoto'] as String?,
      gender: map['gender'] as String?,
      city: map['location'] as String?,
      bio: map['bio'] as String?,
      lastSeen: (map['lastSeen'] as int?)?.toString(),
      created: (map['createdAt'] as int?)?.toString(),
      updated: (map['updatedAt'] as int?)?.toString(),
      dob: map['dob'] as String? ?? '',
    );
  }
}
