class ChatMessageEntity {
  final int? id;
  final String messageId;
  final String senderId;
  final String receiverId;
  final String message;
  final String messageType; // 'text', 'image', 'video', etc.
  final int timestamp;
  final bool isRead;
  final bool isDelivered;
  final String? mediaUrl;

  ChatMessageEntity({
    this.id,
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    this.messageType = 'text',
    required this.timestamp,
    this.isRead = false,
    this.isDelivered = false,
    this.mediaUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'messageType': messageType,
      'timestamp': timestamp,
      'isRead': isRead ? 1 : 0,
      'isDelivered': isDelivered ? 1 : 0,
      'mediaUrl': mediaUrl,
    };
  }

  factory ChatMessageEntity.fromMap(Map<String, dynamic> map) {
    return ChatMessageEntity(
      id: map['id'],
      messageId: map['messageId'],
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      message: map['message'],
      messageType: map['messageType'],
      timestamp: map['timestamp'],
      isRead: map['isRead'] == 1,
      isDelivered: map['isDelivered'] == 1,
      mediaUrl: map['mediaUrl'],
    );
  }

  ChatMessageEntity copyWith({
    int? id,
    String? messageId,
    String? senderId,
    String? receiverId,
    String? message,
    String? messageType,
    int? timestamp,
    bool? isRead,
    bool? isDelivered,
    String? mediaUrl,
  }) {
    return ChatMessageEntity(
      id: id ?? this.id,
      messageId: messageId ?? this.messageId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      message: message ?? this.message,
      messageType: messageType ?? this.messageType,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      isDelivered: isDelivered ?? this.isDelivered,
      mediaUrl: mediaUrl ?? this.mediaUrl,
    );
  }
}
