import '../Database/database_config.dart';
import '../Database/database_helper.dart';
import '../Models/Entities/chat_message_entity.dart';

class ChatRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Insert or update chat message
  Future<int> saveMessage(ChatMessageEntity message) async {
    return await _databaseHelper.insert(
      DatabaseConfig.chatMessagesTable,
      message.toMap(),
    );
  }

  // Get message by messageId
  Future<ChatMessageEntity?> getMessage(String messageId) async {
    final messages = await _databaseHelper.query(
      DatabaseConfig.chatMessagesTable,
      where: 'messageId = ?',
      whereArgs: [messageId],
    );
    
    if (messages.isNotEmpty) {
      return ChatMessageEntity.fromMap(messages.first);
    }
    return null;
  }

  // Get all messages between two users
  Future<List<ChatMessageEntity>> getChatMessages(String userId1, String userId2) async {
    final messages = await _databaseHelper.query(
      DatabaseConfig.chatMessagesTable,
      where: '(senderId = ? AND receiverId = ?) OR (senderId = ? AND receiverId = ?)',
      whereArgs: [userId1, userId2, userId2, userId1],
      orderBy: 'timestamp ASC',
    );
    
    return messages.map((message) => ChatMessageEntity.fromMap(message)).toList();
  }

  // Get unread messages for a user
  Future<List<ChatMessageEntity>> getUnreadMessages(String userId) async {
    final messages = await _databaseHelper.query(
      DatabaseConfig.chatMessagesTable,
      where: 'receiverId = ? AND isRead = ?',
      whereArgs: [userId, 0],
      orderBy: 'timestamp ASC',
    );
    
    return messages.map((message) => ChatMessageEntity.fromMap(message)).toList();
  }

  // Update message as read
  Future<int> markAsRead(String messageId) async {
    return await _databaseHelper.update(
      DatabaseConfig.chatMessagesTable,
      {'isRead': 1},
      where: 'messageId = ?',
      whereArgs: [messageId],
    );
  }

  // Update message as delivered
  Future<int> markAsDelivered(String messageId) async {
    return await _databaseHelper.update(
      DatabaseConfig.chatMessagesTable,
      {'isDelivered': 1},
      where: 'messageId = ?',
      whereArgs: [messageId],
    );
  }

  // Delete message
  Future<int> deleteMessage(String messageId) async {
    return await _databaseHelper.delete(
      DatabaseConfig.chatMessagesTable,
      where: 'messageId = ?',
      whereArgs: [messageId],
    );
  }

  // Get recent conversations for a user
  Future<List<ChatMessageEntity>> getRecentConversations(String userId) async {
    final messages = await _databaseHelper.query(
      DatabaseConfig.chatMessagesTable,
      where: 'senderId = ? OR receiverId = ?',
      whereArgs: [userId, userId],
      orderBy: 'timestamp DESC',
      limit: 50,
    );
    
    // Group by conversation and get latest message from each
    final conversations = <String, ChatMessageEntity>{};
    for (final message in messages) {
      final entity = ChatMessageEntity.fromMap(message);
      final otherUserId = entity.senderId == userId ? entity.receiverId : entity.senderId;
      
      if (!conversations.containsKey(otherUserId) || 
          entity.timestamp > (conversations[otherUserId]?.timestamp ?? 0)) {
        conversations[otherUserId] = entity;
      }
    }
    
    return conversations.values.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
}
