import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'cache_config.dart';
import 'cache_metadata.dart';
// CacheManager - The Heart of Caching
class CacheManager {
  // Single static instance
  static final CacheManager _instance = CacheManager._internal();
  // Public getter to access the instance
  factory CacheManager() => _instance;
  // Private constructor
  CacheManager._internal();

  static Database? _database;
  static const String _cacheTable = 'cache_store'; // Stores actual cached data
  static const String _metadataTable = 'cache_metadata'; // Tracks cache entry metadata

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initCacheDatabase();
    return _database!;
  }

  Future<Database> _initCacheDatabase() async {
    final path = join(await getDatabasesPath(), 'dating_app_cache.db');
    
    return await openDatabase(
      path,
      version: CacheConfig.cacheVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_cacheTable (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $_metadataTable (
        key TEXT PRIMARY KEY,
        created_at INTEGER NOT NULL,
        last_accessed INTEGER NOT NULL,
        ttl INTEGER NOT NULL,
        version INTEGER NOT NULL,
        access_count INTEGER DEFAULT 0,
        size INTEGER DEFAULT 0
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades for cache schema changes
    if (oldVersion < newVersion) {
      await db.execute('DROP TABLE IF EXISTS $_cacheTable');
      await db.execute('DROP TABLE IF EXISTS $_metadataTable');
      await _onCreate(db, newVersion);
    }
  }

  // Store data in cache with TTL
  Future<void> put(String key, dynamic value, {int? ttl}) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final effectiveTTL = ttl ?? CacheConfig.userCacheTTL;
    
    try {
      // Store the actual data
      await db.insert(
        _cacheTable,
        {
          'key': key,
          'value': jsonEncode(value),
          'created_at': now,
          'updated_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Store metadata
      await db.insert(
        _metadataTable,
        {
          'key': key,
          'created_at': now,
          'last_accessed': now,
          'ttl': effectiveTTL,
          'version': CacheConfig.cacheVersion,
          'access_count': 0,
          'size': jsonEncode(value).length,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      if (CacheConfig.enableDebugLogging) {
        print('Cache put error for key $key: $e');
      }
    }
  }

  // Retrieve data from cache
  Future<dynamic> get(String key) async {
    final db = await database;
    
    try {
      // Check if cache entry exists and is not expired
      final metadata = await db.query(
        _metadataTable,
        where: 'key = ?',
        whereArgs: [key],
      );

      if (metadata.isEmpty) return null;

      final meta = CacheMetadata.fromMap(metadata.first);
      if (meta.isExpired) {
        await delete(key);
        return null;
      }

      // Update last accessed time
      await db.update(
        _metadataTable,
        {
          'last_accessed': DateTime.now().millisecondsSinceEpoch,
          'access_count': meta.accessCount + 1,
        },
        where: 'key = ?',
        whereArgs: [key],
      );

      // Retrieve the actual data
      final result = await db.query(
        _cacheTable,
        where: 'key = ?',
        whereArgs: [key],
      );

      if (result.isEmpty) return null;

      return jsonDecode(result.first['value'] as String);
    } catch (e) {
      if (CacheConfig.enableDebugLogging) {
        print('Cache get error for key $key: $e');
      }
      return null;
    }
  }

  // Delete specific cache entry
  Future<void> delete(String key) async {
    final db = await database;
    
    try {
      await db.delete(
        _cacheTable,
        where: 'key = ?',
        whereArgs: [key],
      );
      
      await db.delete(
        _metadataTable,
        where: 'key = ?',
        whereArgs: [key],
      );
    } catch (e) {
      if (CacheConfig.enableDebugLogging) {
        print('Cache delete error for key $key: $e');
      }
    }
  }

  // Clear all expired cache entries
  Future<int> clearExpired() async {
    final db = await database;
    int deletedCount = 0;
    
    try {
      final expiredKeys = await db.rawQuery('''
        SELECT m.key 
        FROM $_metadataTable m 
        WHERE (m.created_at + m.ttl) < ?
      ''', [DateTime.now().millisecondsSinceEpoch]);

      for (final key in expiredKeys) {
        await delete(key['key'] as String);
        deletedCount++;
      }
    } catch (e) {
      if (CacheConfig.enableDebugLogging) {
        print('Clear expired cache error: $e');
      }
    }
    
    return deletedCount;
  }

  // Clear all cache entries
  Future<void> clearAll() async {
    final db = await database;
    
    try {
      await db.delete(_cacheTable);
      await db.delete(_metadataTable);
    } catch (e) {
      if (CacheConfig.enableDebugLogging) {
        print('Clear all cache error: $e');
      }
    }
  }

  // Get cache statistics
  Future<Map<String, dynamic>> getStats() async {
    final db = await database;
    
    try {
      final totalEntries = await db.rawQuery('SELECT COUNT(*) as count FROM $_cacheTable');
      final expiredEntries = await db.rawQuery('''
        SELECT COUNT(*) as count 
        FROM $_metadataTable 
        WHERE (created_at + ttl) < ?
      ''', [DateTime.now().millisecondsSinceEpoch]);
      
      final totalSize = await db.rawQuery('SELECT SUM(size) as size FROM $_metadataTable');
      
      return {
        'totalEntries': totalEntries.first['count'] ?? 0,
        'expiredEntries': expiredEntries.first['count'] ?? 0,
        'totalSize': totalSize.first['size'] ?? 0,
      };
    } catch (e) {
      if (CacheConfig.enableDebugLogging) {
        print('Get cache stats error: $e');
      }
      return {};
    }
  }

  // Close the cache database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
