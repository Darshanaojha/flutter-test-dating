class CacheConfig {
  // Cache TTL (Time To Live) in milliseconds
  static const int userCacheTTL = 30 * 60 * 1000; // 30 minutes
  static const int chatCacheTTL = 15 * 60 * 1000; // 15 minutes
  static const int settingsCacheTTL = 60 * 60 * 1000; // 1 hour
  
  // Cache size limits
  static const int maxCacheSizeMB = 50;
  static const int maxUserCacheEntries = 100;
  static const int maxChatCacheEntries = 500;
  
  // Sync intervals
  static const int backgroundSyncInterval = 5 * 60 * 1000; // 5 minutes
  static const int retrySyncInterval = 30 * 1000; // 30 seconds
  
  // Cache versioning
  static const int cacheVersion = 1;
  
  // Debug settings
  static const bool enableDebugLogging = true;
  static const bool enablePerformanceMetrics = true;
}
