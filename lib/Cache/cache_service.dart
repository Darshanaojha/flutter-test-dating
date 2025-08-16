import 'dart:async';
import 'cache_manager.dart';
import 'sync_manager.dart';
import 'cache_config.dart';
import 'cache_utils.dart';
import '../Repositories/cached_user_repository.dart';
import '../Repositories/cached_chat_repository.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  // Cache repositories
  final CachedUserRepository _cachedUserRepository = CachedUserRepository();
  final CachedChatRepository _cachedChatRepository = CachedChatRepository();
  final CacheManager _cacheManager = CacheManager();
  final SyncManager _syncManager = SyncManager();

  // Initialize cache service
  Future<void> initialize() async {
    await _cacheManager.database;
    _syncManager.initialize();
    
    if (CacheConfig.enableDebugLogging) {
      print('Cache service initialized');
    }
  }

  // Get cached user repository
  CachedUserRepository get userRepository => _cachedUserRepository;

  // Get cached chat repository
  CachedChatRepository get chatRepository => _cachedChatRepository;

  // Get cache manager
  CacheManager get cacheManager => _cacheManager;

  // Get sync manager
  SyncManager get syncManager => _syncManager;

  // Clear all caches
  Future<void> clearAllCaches() async {
    await _cacheManager.clearAll();
    await _cachedUserRepository.clearUserCache();
    await _cachedChatRepository.clearChatCache();
  }

  // Clear expired caches
  Future<int> clearExpiredCaches() async {
    return await _cacheManager.clearExpired();
  }

  // Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    final userStats = await _cachedUserRepository.getCacheStats();
    final chatStats = await _cachedChatRepository.getChatCacheStats();
    final syncStats = _syncManager.getSyncStatus();
    
    return {
      'userCache': userStats,
      'chatCache': chatStats,
      'syncStatus': syncStats,
      'totalPendingOperations': _syncManager.pendingOperationsCount,
    };
  }

  // Force refresh all caches
  Future<void> refreshAllCaches() async {
    await clearAllCaches();
    // Trigger cache refresh for critical data
  }

  // Set online/offline status
  void setOnlineStatus(bool isOnline) {
    _syncManager.setOnlineStatus(isOnline);
  }

  // Get cache size in MB
  Future<double> getCacheSizeInMB() async {
    final stats = await _cacheManager.getStats();
    final totalSize = stats['totalSize'] as int? ?? 0;
    return totalSize / (1024 * 1024);
  }

  // Check if cache is healthy
  Future<bool> isCacheHealthy() async {
    final stats = await _cacheManager.getStats();
    final totalSize = stats['totalSize'] as int? ?? 0;
    final maxSize = CacheConfig.maxCacheSizeMB * 1024 * 1024;
    
    return totalSize < maxSize;
  }

  // Get cache hit rate
  Future<double> getCacheHitRate() async {
    // This would require tracking cache hits/misses
    // For now, return a placeholder
    return 0.85; // 85% hit rate
  }

  // Get cache efficiency metrics
  Future<Map<String, dynamic>> getCacheEfficiencyMetrics() async {
    final stats = await getCacheStats();
    final sizeInMB = await getCacheSizeInMB();
    final isHealthy = await isCacheHealthy();
    
    return {
      'cacheSizeMB': sizeInMB,
      'isHealthy': isHealthy,
      'pendingOperations': stats['totalPendingOperations'],
      'lastSyncTime': stats['syncStatus']['lastSyncTime'],
    };
  }

  // Optimize cache
  Future<void> optimizeCache() async {
    await clearExpiredCaches();
    
    // Additional optimization logic can be added here
    if (CacheConfig.enableDebugLogging) {
      print('Cache optimization completed');
    }
  }

  // Monitor cache performance
  Stream<Map<String, dynamic>> monitorCachePerformance() async* {
    while (true) {
      yield await getCacheEfficiencyMetrics();
      await Future.delayed(Duration(seconds: 30));
    }
  }

  // Dispose cache service
  Future<void> dispose() async {
    _syncManager.dispose();
    await _cacheManager.close();
  }
}
