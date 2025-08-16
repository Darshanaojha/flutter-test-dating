class DatabaseConfig {
  static const String databaseName = 'dating_app.db';
  static const int databaseVersion = 1;
  
  // Table names
  static const String usersTable = 'users';
  static const String chatMessagesTable = 'chat_messages';
  static const String likesTable = 'likes';
  static const String settingsTable = 'settings';
  
  // Common column names
  static const String columnId = 'id';
  static const String columnUserId = 'userId';
  static const String columnCreatedAt = 'createdAt';
  static const String columnUpdatedAt = 'updatedAt';
}
