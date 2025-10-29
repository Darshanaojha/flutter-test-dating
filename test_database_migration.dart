import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() async {
  // Test the database migration
  final path = join(await getDatabasesPath(), 'dating_app_test.db');
  
  try {
    // Delete the test database if it exists
    await deleteDatabase(path);
    
    // Open the database with version 2 (old version without dob column)
    Database db = await openDatabase(
      path,
      version: 2,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId TEXT UNIQUE,
            username TEXT,
            email TEXT,
            profilePhoto TEXT,
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
      },
    );
    
    print('Database created with version 2 (without dob column)');
    
    // Close the database
    await db.close();
    
    // Now open with version 3 to trigger migration
    db = await openDatabase(
      path,
      version: 3,
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 3) {
          try {
            // Check if the dob column already exists to avoid errors
            final result = await db.rawQuery('PRAGMA table_info(users)');
            final hasDobColumn = result.any((column) => column['name'] == 'dob');
            
            if (!hasDobColumn) {
              await db.execute('ALTER TABLE users ADD COLUMN dob TEXT');
              print('Added dob column to users table');
            } else {
              print('dob column already exists');
            }
          } catch (e) {
            print('Error adding dob column: $e');
          }
        }
      },
    );
    
    print('Database upgraded to version 3 successfully');
    
    // Test inserting data with dob column
    await db.insert('users', {
      'userId': 'test-user-123',
      'username': 'testuser',
      'email': 'test@example.com',
      'profilePhoto': 'test.jpg',
      'dob': '10/09/2000',
      'gender': 'male',
      'location': 'Test City',
      'bio': 'Test bio',
      'lastSeen': 0,
      'createdAt': 0,
      'updatedAt': 0,
      'isCached': 1,
      'lastSynced': DateTime.now().millisecondsSinceEpoch
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    
    print('Successfully inserted user data with dob column');
    
    // Query the data to verify
    final results = await db.query('users');
    print('Users in database: ${results.length}');
    
    if (results.isNotEmpty) {
      final user = results.first;
      print('User dob: ${user['dob']}');
    }
    
    await db.close();
    print('Database test completed successfully!');
    
  } catch (e) {
    print('Error during database test: $e');
  }
}
