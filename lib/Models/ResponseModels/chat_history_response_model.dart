class ChatHistoryResponse {
  bool success;
  Payload payload;
  Error error;

  ChatHistoryResponse({
    required this.success,
    required this.payload,
    required this.error,
  });

  factory ChatHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ChatHistoryResponse(
      success: json['success'],
      payload: Payload.fromJson(json['payload']),
      error: Error.fromJson(json['error']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'payload': payload.toJson(),
      'error': error.toJson(),
    };
  }
}

class Payload {
  final List<Message> data;
  final String message;

  Payload({
    required this.data,
    required this.message,
  });

  factory Payload.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List? ?? [];
    List<Message> messageList = list.map((i) => Message.fromJson(i)).toList();

    return Payload(
      data: messageList,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((message) => message.toJson()).toList(),
      'message': message,
    };
  }
}

class Message {
  String? id;
  String senderId;
  String receiverId;
  String? message;
  int messageType;
  String? created;
  String? updated;
  int status;
  int deletedBySender;
  int deletedByReceiver;
  String? deletedAtSender;
  String? deletedAtReceiver;
  int isEdited;
  String? imagePath;
  int? sensitivity;
  String? timestamp;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.messageType,
    required this.created,
    required this.updated,
    required this.status,
    required this.deletedBySender,
    required this.deletedByReceiver,
    required this.deletedAtSender,
    required this.deletedAtReceiver,
    required this.isEdited,
    this.imagePath,
    this.sensitivity,
    this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    // Handle both camelCase and snake_case for senderId
    String? senderIdValue = json['sender_id']?.toString() ?? 
                           json['senderId']?.toString();
    
    if (senderIdValue == null || senderIdValue == 'null' || senderIdValue.isEmpty) {
      print('Warning: senderId is null or empty in message JSON. Available keys: ${json.keys.toList()}');
      print('Full message JSON: $json');
    }
    
    return Message(
      id: json['id']?.toString() ?? '',
      senderId: senderIdValue ?? '',
      receiverId: json['receiver_id']?.toString() ?? json['receiverId']?.toString() ?? '',
      message: json['message'],
      messageType: json['message_type'] ?? json['messageType'] ?? 1,
      created: json['created'],
      updated: json['updated'],
      status: json['status'] ?? 0,
      deletedBySender: json['deleted_by_sender'] ?? json['deletedBySender'] ?? 0,
      deletedByReceiver: json['deleted_by_receiver'] ?? json['deletedByReceiver'] ?? 0,
      deletedAtSender: json['deleted_at_sender'] ?? json['deletedAtSender'],
      deletedAtReceiver: json['deleted_at_receiver'] ?? json['deletedAtReceiver'],
      isEdited: json['is_edited'] ?? json['isEdited'] ?? 0,
      imagePath: json['imagePath'] ?? json['image_path'],
      sensitivity: json['sensitivity'],
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiver_id': receiverId,
      'message': message,
      'message_type': messageType,
      'created':
          created == null ? null : DateTime.parse(created!).toIso8601String(),
      'updated':
          updated == null ? null : DateTime.parse(updated!).toIso8601String(),
      'status': status,
      'deleted_by_sender': deletedBySender,
      'deleted_by_receiver': deletedByReceiver,
      'deleted_at_sender': deletedAtSender == null
          ? null
          : DateTime.parse(deletedAtSender!).toIso8601String(),
      'deleted_at_receiver': deletedAtReceiver == null
          ? null
          : DateTime.parse(deletedAtReceiver!).toIso8601String(),
      'is_edited': isEdited,
      'imagePath': imagePath,
      'sensitivity': sensitivity,
      'timestamp': timestamp,
    };
  }

  Message copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? message,
    int? messageType,
    String? created,
    String? updated,
    int? status,
    int? deletedBySender,
    int? deletedByReceiver,
    String? deletedAtSender,
    String? deletedAtReceiver,
    int? isEdited,
    String? imagePath,
    int? sensitivity,
    String? timestamp,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      message: message ?? this.message,
      messageType: messageType ?? this.messageType,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      status: status ?? this.status,
      deletedBySender: deletedBySender ?? this.deletedBySender,
      deletedByReceiver: deletedByReceiver ?? this.deletedByReceiver,
      deletedAtSender: deletedAtSender ?? this.deletedAtSender,
      deletedAtReceiver: deletedAtReceiver ?? this.deletedAtReceiver,
      isEdited: isEdited ?? this.isEdited,
      imagePath: imagePath ?? this.imagePath,
      sensitivity: sensitivity ?? this.sensitivity,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Message &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Error {
  final int code;
  final String message;

  Error({
    required this.code,
    required this.message,
  });

  factory Error.fromJson(Map<String, dynamic> json) {
    return Error(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }
}
