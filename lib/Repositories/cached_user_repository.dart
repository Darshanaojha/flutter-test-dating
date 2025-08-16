import '../Models/Entities/user_entity.dart';
import '../Cache/cache_manager.dart';
import '../Cache/cache_config.dart';
import 'user_repository.dart';

class CachedUserRepository {
  final UserRepository _userRepository = UserRepository();
  final CacheManager _cacheManager = CacheManager();

  // Cache key prefixes
  static const String _userKeyPrefix = 'user_';
  static const String _allUsersKey = 'all_users';
  static const String _onlineUsersKey = 'online_users';
  static const String _searchPrefix = 'search_';

  // Save user with caching
  Future<int> saveUser(UserEntity user) async {
    final result = await _userRepository.saveUser(user);
    
    // Update cache
    await _cacheManager.put(
      '$_userKeyPrefix${user.userId}',
      user.toMap(),
      ttl: CacheConfig.userCacheTTL,
    );
    
    // Invalidate related caches
    await _invalidateUserCaches();
    
    return result;
  }

  // Get user with cache-first strategy
  Future<UserEntity?> getUser(String userId) async {
    final cacheKey = '$_userKeyPrefix$userId';
    
    // Try cache first
    final cachedData = await _cacheManager.get(cacheKey);
    if (cachedData != null) {
      return UserEntity.fromMap(cachedData);
    }
    
    // Fallback to database
    final user = await _userRepository.getUser(userId);
    if (user != null) {
      await _cacheManager.put(
        cacheKey,
        user.toMap(),
        ttl: CacheConfig.userCacheTTL,
      );
    }
    
    return user;
  }

  // Get all users with caching
  Future<List<UserEntity>> getAllUsers() async {
    final cachedData = await _cacheManager.get(_allUsersKey);
    
    if (cachedData != null) {
      final List<dynamic> usersList = cachedData;
      return usersList.map((user) => UserEntity.fromMap(user)).toList();
    }
    
    final users = await _userRepository.getAllUsers();
    
    if (users.isNotEmpty) {
      await _cacheManager.put(
        _allUsersKey,
        users.map((user) => user.toMap()).toList(),
        ttl: CacheConfig.userCacheTTL,
      );
    }
    
    return users;
  }

  // Get online users with caching
  Future<List<UserEntity>> getOnlineUsers() async {
    final cachedData = await _cacheManager.get(_onlineUsersKey);
    
    if (cachedData != null) {
      final List<dynamic> usersList = cachedData;
      return usersList.map((user) => UserEntity.fromMap(user)).toList();
    }
    
    final users = await _userRepository.getOnlineUsers();
    
    if (users.isNotEmpty) {
      await _cacheManager.put(
        _onlineUsersKey,
        users.map((user) => user.toMap()).toList(),
        ttl: CacheConfig.userCacheTTL,
      );
    }
    
    return users;
  }

  // Search users with caching
  Future<List<UserEntity>> searchUsers(String query) async {
    final cacheKey = '$_searchPrefix$query';
    final cachedData = await _cacheManager.get(cacheKey);
    
    if (cachedData != null) {
      final List<dynamic> usersList = cachedData;
      return usersList.map((user) => UserEntity.fromMap(user)).toList();
    }
    
    final users = await _userRepository.searchUsers(query);
    
    if (users.isNotEmpty) {
      await _cacheManager.put(
        cacheKey,
        users.map((user) => user.toMap()).toList(),
        ttl: CacheConfig.userCacheTTL,
      );
    }
    
    return users;
  }

  // Update user with cache invalidation
  Future<int> updateUser(UserEntity user) async {
    final result = await _userRepository.updateUser(user);
    
    // Update individual cache
    await _cacheManager.put(
      '$_userKeyPrefix${user.userId}',
      user.toMap(),
      ttl: CacheConfig.userCacheTTL,
    );
    
    // Invalidate related caches
    await _invalidateUserCaches();
    
    return result;
  }

  // Delete user with cache invalidation
  Future<int> deleteUser(String userId) async {
    final result = await _userRepository.deleteUser(userId);
    
    // Remove from cache
    await _cacheManager.delete('$_userKeyPrefix$userId');
    
    // Invalidate related caches
    await _invalidateUserCaches();
    
    return result;
  }

  // Invalidate all user-related caches
  Future<void> _invalidateUserCaches() async {
    await _cacheManager.delete(_allUsersKey);
    await _cacheManager.delete(_onlineUsersKey);
    
    // Clear search caches (keys starting with search_)
    final stats = await _cacheManager.getStats();
    // Note: In a real implementation, you might want to track search keys
  }

  // Force refresh cache for specific user
  Future<void> refreshUserCache(String userId) async {
    await _cacheManager.delete('$_userKeyPrefix$userId');
    await getUser(userId); // This will re-cache
  }

  // Clear all user caches
  Future<void> clearUserCache() async {
    await _cacheManager.delete(_allUsersKey);
    await _cacheManager.delete(_onlineUsersKey);
    
    // Clear individual user caches
    final users = await _userRepository.getAllUsers();
    for (final user in users) {
      await _cacheManager.delete('$_userKeyPrefix${user.userId}');
    }
  }

  // Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    return await _cacheManager.getStats();
  }
}
