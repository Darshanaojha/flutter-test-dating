import 'dart:convert';
import 'dart:math';

class CacheUtils {
  // Generate cache key
  static String generateCacheKey(String prefix, String suffix) {
    return '${prefix}_${suffix}_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  // Generate cache key for user
  static String generateUserCacheKey(String userId) {
    return 'user_${userId}_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  // Generate cache key for chat
  static String generateChatCacheKey(String chatId) {
    return 'chat_${chatId}_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  // Generate cache key for message
  static String generateMessageCacheKey(String messageId) {
    return 'message_${messageId}_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  // Generate cache key for conversation
  static String generateConversationCacheKey(String conversationId) {
    return 'conversation_${conversationId}_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  // Generate cache key for search
  static String generateSearchCacheKey(String query) {
    return 'search_${query}_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  // Generate cache key for like
  static String generateLikeCacheKey(String userId, String likedUserId) {
    return 'like_${userId}_${likedUserId}_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  // Generate cache key for settings
  static String generateSettingsCacheKey(String key, {String? userId}) {
    if (userId != null) {
      return 'settings_${key}_${userId}_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
    }
    return 'settings_${key}_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  // Serialize object to JSON string
  static String serializeToJson(dynamic object) {
    return jsonEncode(object);
  }

  // Deserialize JSON string to object
  static dynamic deserializeFromJson(String jsonString) {
    return jsonDecode(jsonString);
  }

  // Calculate object size in bytes
  static int calculateObjectSize(dynamic object) {
    return serializeToJson(object).length;
  }

  // Check if cache is stale (close to expiration)
  static bool isCacheStale(int createdAt, int ttl) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final timeLeft = ttl - (now - createdAt);
    return timeLeft < (ttl * 0.2).toInt(); // 20% of TTL remaining
  }

  // Check if cache is expired
  static bool isCacheExpired(int createdAt, int ttl) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return now > (createdAt + ttl);
  }

  // Get cache age in milliseconds
  static int getCacheAge(int createdAt) {
    return DateTime.now().millisecondsSinceEpoch - createdAt;
  }

  // Format cache age for display
  static String formatCacheAge(int ageInMs) {
    final seconds = ageInMs ~/ 1000;
    final minutes = seconds ~/ 60;
    final hours = minutes ~/ 60;
    final days = hours ~/ 24;

    if (days > 0) return '$days days ago';
    if (hours > 0) return '$hours hours ago';
    if (minutes > 0) return '$minutes minutes ago';
    return '$seconds seconds ago';
  }

  // Generate cache key for pagination
  static String generatePaginationCacheKey(String prefix, int page, int limit) {
    return '${prefix}_page_${page}_limit_${limit}_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  // Generate cache key for filtered data
  static String generateFilteredCacheKey(String prefix, Map<String, dynamic> filters) {
    final filterString = filters.entries
        .map((e) => '${e.key}_${e.value}')
        .join('_');
    return '${prefix}_filters_${filterString}_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  // Generate cache key for sorted data
  static String generateSortedCacheKey(String prefix, String sortBy, bool ascending) {
    return '${prefix}_sort_${sortBy}_${ascending ? 'asc' : 'desc'}_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  // Validate cache key format
  static bool isValidCacheKey(String key) {
    return key.isNotEmpty && !key.contains(' ') && key.length <= 255;
  }

  // Sanitize cache key
  static String sanitizeCacheKey(String key) {
    return key.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  }

  // Get cache key prefix
  static String getCacheKeyPrefix(String key) {
    final parts = key.split('_');
    return parts.isNotEmpty ? parts[0] : '';
  }

  // Get cache key suffix
  static String getCacheKeySuffix(String key) {
    final parts = key.split('_');
    return parts.length > 1 ? parts.sublist(1).join('_') : '';
  }

  // Check if cache key is for user data
  static bool isUserCacheKey(String key) {
    return key.startsWith('user_');
  }

  // Check if cache key is for chat data
  static bool isChatCacheKey(String key) {
    return key.startsWith('chat_');
  }

  // Check if cache key is for message data
  static bool isMessageCacheKey(String key) {
    return key.startsWith('message_');
  }

  // Check if cache key is for conversation data
  static bool isConversationCacheKey(String key) {
    return key.startsWith('conversation_');
  }

  // Check if cache key is for search data
  static bool isSearchCacheKey(String key) {
    return key.startsWith('search_');
  }

  // Check if cache key is for like data
  static bool isLikeCacheKey(String key) {
    return key.startsWith('like_');
  }

  // Check if cache key is for settings data
  static bool isSettingsCacheKey(String key) {
    return key.startsWith('settings_');
  }

  // Get cache key type
  static String getCacheKeyType(String key) {
    if (isUserCacheKey(key)) return 'user';
    if (isChatCacheKey(key)) return 'chat';
    if (isMessageCacheKey(key)) return 'message';
    if (isConversationCacheKey(key)) return 'conversation';
    if (isSearchCacheKey(key)) return 'search';
    if (isLikeCacheKey(key)) return 'like';
    if (isSettingsCacheKey(key)) return 'settings';
    return 'unknown';
  }

  // Generate cache key for batch operations
  static String generateBatchCacheKey(String prefix, List<String> ids) {
    final idsString = ids.join('_');
    return '${prefix}_batch_${idsString}_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  // Generate cache key for composite keys
  static String generateCompositeCacheKey(String prefix, List<String> parts) {
    final compositeString = parts.join('_');
    return '${prefix}_${compositeString}_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  // Generate cache key for date range
  static String generateDateRangeCacheKey(String prefix, DateTime start, DateTime end) {
    return '${prefix}_${start.millisecondsSinceEpoch}_${end.millisecondsSinceEpoch}_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  // Generate cache key for time-based data
  static String generateTimeBasedCacheKey(String prefix, String timeUnit) {
    final now = DateTime.now();
    final timeKey = switch (timeUnit) {
      'hour' => '${now.year}_${now.month}_${now.day}_${now.hour}',
      'day' => '${now.year}_${now.month}_${now.day}',
      'week' => '${now.year}_${now.weekOfYear}',
      'month' => '${now.year}_${now.month}',
      'year' => '${now.year}',
      _ => now.millisecondsSinceEpoch.toString(),
    };
    
    return '${prefix}_${timeUnit}_${timeKey}_${Random().nextInt(1000)}';
  }
}

// Extension for DateTime to get week of year
extension DateTimeExtension on DateTime {
  int get weekOfYear {
    final firstDayOfYear = DateTime(year, 1, 1);
    final daysSinceFirstDay = difference(firstDayOfYear).inDays;
    return ((daysSinceFirstDay + firstDayOfYear.weekday - 1) / 7).ceil();
  }
}
