import 'database_helper.dart';
import '../Repositories/user_repository.dart';
import '../Repositories/chat_repository.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // Initialize database
  static Future<void> init() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.database; // This will trigger database creation
  }

  // Repositories
  final UserRepository userRepository = UserRepository();
  final ChatRepository chatRepository = ChatRepository();

  // Close database
  static Future<void> close() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.close();
  }

  // Clear all data (useful for logout)
  static Future<void> clearAllData() async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;
    
    await db.delete('users');
    await db.delete('chat_messages');
    await db.delete('likes');
    await db.delete('settings');
  }
}
