class DatabaseConfig {
  static const String databaseName = 'dating_app.db';
  static const int databaseVersion = 3; // Incremented version for schema changes
  
  // Table names
  static const String usersTable = 'users';
  static const String chatMessagesTable = 'chat_messages';
  static const String likesTable = 'likes';
  static const String settingsTable = 'settings';
  static const String connectionsTable = 'connections';
  static const String preferencesTable = 'user_preferences';
  static const String desiresTable = 'user_desires';
  static const String languagesTable = 'user_languages';
  static const String packagesTable = 'packages';
  static const String transactionsTable = 'transactions';
  static const String ordersTable = 'orders';
  
  // Common column names
  static const String columnId = 'id';
  static const String columnUserId = 'userId';
  static const String columnCreatedAt = 'createdAt';
  static const String columnUpdatedAt = 'updatedAt';
  static const String columnIsCached = 'isCached';
  static const String columnLastSynced = 'lastSynced';
}
