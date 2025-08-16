import '../Models/Entities/user_entity.dart';
import '../Models/Entities/chat_message_entity.dart';
import 'cache_service.dart';

class CacheUsageExample {
  final CacheService _cacheService = CacheService();

  // Example of using cached user repository
  Future<void> exampleUserCaching() async {
    await _cacheService.initialize();

    // Create a sample user
    final user = UserEntity(
      userId: 'user123',
      username: 'johndoe',
      email: 'john@example.com',
      profilePhoto: 'https://example.com/profile.jpg',
      age: 25,
      gender: 'male',
      location: 'New York',
      bio: 'Software developer',
      isOnline: true,
      lastSeen: DateTime.now().millisecondsSinceEpoch,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    // Save user with caching
    await _cacheService.userRepository.saveUser(user);

    // Get user from cache
    final cachedUser = await _cacheService.userRepository.getUser('user123');
    print('Cached user: ${cachedUser?.username}');

    // Search users with caching
    final searchResults = await _cacheService.userRepository.searchUsers('john');
    print('Search results: ${searchResults.length} users found');

    // Get cache stats
    final stats = await _cacheService.getCacheStats();
    print('Cache stats: $stats');
  }

  // Example of using cached chat repository
  Future<void> exampleChatCaching() async {
    await _cacheService.initialize();

    // Create a sample message
    final message = ChatMessageEntity(
      messageId: 'msg123',
      senderId: 'user123',
      receiverId: 'user456',
      message: 'Hello, how are you?',
      messageType: 'text',
      timestamp: DateTime.now().millisecondsSinceEpoch,
      isRead: false,
      isDelivered: false,
    );

    // Save message with caching
    await _cacheService.chatRepository.saveMessage(message);

    // Get chat messages from cache
    final messages = await _cacheService.chatRepository.getChatMessages('user123', 'user456');
    print('Cached messages: ${messages.length} messages found');

    // Get recent conversations from cache
    final conversations = await _cacheService.chatRepository.getRecentConversations('user123');
    print('Recent conversations: ${conversations.length} conversations found');

    // Mark message as read
    await _cacheService.chatRepository.markAsRead('msg123');
  }

  // Example of offline/online sync
  Future<void> exampleSyncUsage() async {
    await _cacheService.initialize();

    // Simulate going offline
    _cacheService.setOnlineStatus(false);
    print('Offline mode activated');

    // Queue operations while offline
    final offlineMessage = ChatMessageEntity(
      messageId: 'offline_msg_1',
      senderId: 'user123',
      receiverId: 'user456',
      message: 'This message was sent while offline',
      messageType: 'text',
      timestamp: DateTime.now().millisecondsSinceEpoch,
      isRead: false,
      isDelivered: false,
    );

    // Queue the message for sync
    await _cacheService.syncManager.queueSaveMessage(offlineMessage);

    // Check pending operations
    final pendingCount = _cacheService.syncManager.pendingOperationsCount;
    print('Pending operations: $pendingCount');

    // Simulate coming back online
    _cacheService.setOnlineStatus(true);
    print('Online mode activated - sync will happen automatically');
  }

  // Example of cache optimization
  Future<void> exampleCacheOptimization() async {
    await _cacheService.initialize();

    // Get current cache stats
    final initialStats = await _cacheService.getCacheStats();
    print('Initial cache stats: $initialStats');

    // Optimize cache
    await _cacheService.optimizeCache();

    // Get updated cache stats
    final optimizedStats = await _cacheService.getCacheStats();
    print('Optimized cache stats: $optimizedStats');

    // Check cache health
    final isHealthy = await _cacheService.isCacheHealthy();
    print('Cache is healthy: $isHealthy');
  }

  // Example of monitoring cache performance
  Future<void> exampleCacheMonitoring() async {
    await _cacheService.initialize();

    // Start monitoring cache performance
    final subscription = _cacheService.monitorCachePerformance().listen((metrics) {
      print('Cache metrics: $metrics');
    });

    // Stop monitoring after 2 minutes
    await Future.delayed(Duration(minutes: 2));
    await subscription.cancel();
  }

  // Run all examples
  Future<void> runAllExamples() async {
    print('=== Starting Cache Usage Examples ===');
    
    await exampleUserCaching();
    await exampleChatCaching();
    await exampleSyncUsage();
    await exampleCacheOptimization();
    
    print('=== Cache Usage Examples Completed ===');
  }
}
