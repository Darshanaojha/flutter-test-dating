import '../Database/database_config.dart';
import '../Database/database_helper.dart';
import '../Models/Entities/user_entity.dart';

class UserRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Insert or update user
  Future<int> saveUser(UserEntity user) async {
    return await _databaseHelper.insert(
      DatabaseConfig.usersTable,
      user.toMap(),
    );
  }

  // Get user by userId
  Future<UserEntity?> getUser(String userId) async {
    final users = await _databaseHelper.query(
      DatabaseConfig.usersTable,
      where: 'userId = ?',
      whereArgs: [userId],
    );
    
    if (users.isNotEmpty) {
      return UserEntity.fromMap(users.first);
    }
    return null;
  }

  // Get all users
  Future<List<UserEntity>> getAllUsers() async {
    final users = await _databaseHelper.query(
      DatabaseConfig.usersTable,
      orderBy: 'createdAt DESC',
    );
    
    return users.map((user) => UserEntity.fromMap(user)).toList();
  }

  // Update user
  Future<int> updateUser(UserEntity user) async {
    return await _databaseHelper.update(
      DatabaseConfig.usersTable,
      user.toMap(),
      where: 'userId = ?',
      whereArgs: [user.userId],
    );
  }

  // Delete user
  Future<int> deleteUser(String userId) async {
    return await _databaseHelper.delete(
      DatabaseConfig.usersTable,
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  // Search users by username
  Future<List<UserEntity>> searchUsers(String query) async {
    final users = await _databaseHelper.query(
      DatabaseConfig.usersTable,
      where: 'username LIKE ?',
      whereArgs: ['%$query%'],
    );
    
    return users.map((user) => UserEntity.fromMap(user)).toList();
  }

  // Get online users
  Future<List<UserEntity>> getOnlineUsers() async {
    final users = await _databaseHelper.query(
      DatabaseConfig.usersTable,
      where: 'isOnline = ?',
      whereArgs: [1],
    );
    
    return users.map((user) => UserEntity.fromMap(user)).toList();
  }
}
