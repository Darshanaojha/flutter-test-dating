import '../Models/Entities/chat_message_entity.dart';
import '../Cache/cache_manager.dart';
import '../Cache/cache_config.dart';
import 'chat_repository.dart';

class CachedChatRepository {
  final ChatRepository _chatRepository = ChatRepository();
  final CacheManager _cacheManager = CacheManager();

  // Cache key prefixes
  static const String _chatKeyPrefix = 'chat_';
  static const String _recentConversationsKey = 'recent_conversations_';
  static const String _unreadMessagesKey = 'unread_messages_';

  // Save chat message with caching
  Future<int> saveMessage(ChatMessageEntity message) async {
    final result = await _chatRepository.saveMessage(message);
    
    // Update cache
    await _cacheManager.put(
      '$_chatKeyPrefix${message.messageId}',
      message.toMap(),
      ttl: CacheConfig.chatCacheTTL,
    );
    
    // Invalidate related caches
    await _invalidateChatCaches(message.senderId, message.receiverId);
    
    return result;
  }

  // Get chat messages with cache-first strategy
  Future<List<ChatMessageEntity>> getChatMessages(String userId1, String userId2) async {
    final cacheKey = '$_chatKeyPrefix${userId1}_${userId2}';
    
    // Try cache first
    final cachedData = await _cacheManager.get(cacheKey);
    if (cachedData != null) {
      final List<dynamic> messagesList = cachedData;
      return messagesList.map((msg) => ChatMessageEntity.fromMap(msg)).toList();
    }
    
    // Fallback to database
    final messages = await _chatRepository.getChatMessages(userId1, userId2);
    
    if (messages.isNotEmpty) {
      await _cacheManager.put(
        cacheKey,
        messages.map((msg) => msg.toMap()).toList(),
        ttl: CacheConfig.chatCacheTTL,
      );
    }
    
    return messages;
  }

  // Get unread messages with caching
  Future<List<ChatMessageEntity>> getUnreadMessages(String userId) async {
    final cacheKey = '$_unreadMessagesKey$userId';
    final cachedData = await _cacheManager.get(cacheKey);
    
    if (cachedData != null) {
      final List<dynamic> messagesList = cachedData;
      return messagesList.map((msg) => ChatMessageEntity.fromMap(msg)).toList();
    }
    
    final messages = await _chatRepository.getUnreadMessages(userId);
    
    if (messages.isNotEmpty) {
      await _cacheManager.put(
        cacheKey,
        messages.map((msg) => msg.toMap()).toList(),
        ttl: CacheConfig.chatCacheTTL,
      );
    }
    
    return messages;
  }

  // Get recent conversations with caching
  Future<List<ChatMessageEntity>> getRecentConversations(String userId) async {
    final cacheKey = '$_recentConversationsKey$userId';
    final cachedData = await _cacheManager.get(cacheKey);
    
    if (cachedData != null) {
      final List<dynamic> messagesList = cachedData;
      return messagesList.map((msg) => ChatMessageEntity.fromMap(msg)).toList();
    }
    
    final messages = await _chatRepository.getRecentConversations(userId);
    
    if (messages.isNotEmpty) {
      await _cacheManager.put(
        cacheKey,
        messages.map((msg) => msg.toMap()).toList(),
        ttl: CacheConfig.chatCacheTTL,
      );
    }
    
    return messages;
  }

  // Mark message as read with cache update
  Future<int> markAsRead(String messageId) async {
    final result = await _chatRepository.markAsRead(messageId);
    
    // Update individual message cache
    final message = await _chatRepository.getMessage(messageId);
    if (message != null) {
      final updatedMessage = message.copyWith(isRead: true);
      await _cacheManager.put(
        '$_chatKeyPrefix$messageId',
        updatedMessage.toMap(),
        ttl: CacheConfig.chatCacheTTL,
      );
    }
    
    // Invalidate related caches
    await _invalidateChatCaches();
    
    return result;
  }

  // Mark message as delivered with cache update
  Future<int> markAsDelivered(String messageId) async {
    final result = await _chatRepository.markAsDelivered(messageId);
    
    // Update individual message cache
    final message = await _chatRepository.getMessage(messageId);
    if (message != null) {
      final updatedMessage = message.copyWith(isDelivered: true);
      await _cacheManager.put(
        '$_chatKeyPrefix$messageId',
        updatedMessage.toMap(),
        ttl: CacheConfig.chatCacheTTL,
      );
    }
    
    // Invalidate related caches
    await _invalidateChatCaches();
    
    return result;
  }

  // Delete message with cache invalidation
  Future<int> deleteMessage(String messageId) async {
    final result = await _chatRepository.deleteMessage(messageId);
    
    // Remove from cache
    await _cacheManager.delete('$_chatKeyPrefix$messageId');
    
    // Invalidate related caches
    await _invalidateChatCaches();
    
    return result;
  }

  // Invalidate chat-related caches
  Future<void> _invalidateChatCaches([String? senderId, String? receiverId]) async {
    // Invalidate specific chat caches
    if (senderId != null && receiverId != null) {
      final chatKey = '$_chatKeyPrefix${senderId}_$receiverId';
      await _cacheManager.delete(chatKey);
      
      final reverseChatKey = '$_chatKeyPrefix${receiverId}_$senderId';
      await _cacheManager.delete(reverseChatKey);
    }
    
    // Invalidate general chat caches
    await _cacheManager.delete(_recentConversationsKey);
    await _cacheManager.delete(_unreadMessagesKey);
  }

  // Force refresh chat cache for specific conversation
  Future<void> refreshChatCache(String userId1, String userId2) async {
    final cacheKey = '$_chatKeyPrefix${userId1}_$userId2';
    await _cacheManager.delete(cacheKey);
    await getChatMessages(userId1, userId2); // This will re-cache
  }

  // Clear all chat caches
  Future<void> clearChatCache() async {
    await _cacheManager.delete(_recentConversationsKey);
    await _cacheManager.delete(_unreadMessagesKey);
    
    // Clear individual message caches (keys starting with chat_)
    // Note: In a real implementation, you might want to track these keys
  }

  // Get chat cache statistics
  Future<Map<String, dynamic>> getChatCacheStats() async {
    return await _cacheManager.getStats();
  }
}
