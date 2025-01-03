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
  String id;
  String senderId;
  String receiverId;
  String message;
  int messageType;
  String? created;
  String? updated;
  int status;
  int deletedBySender;
  int deletedByReceiver;
  String? deletedAtSender;
  String? deletedAtReceiver;
  int isEdited;

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
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'].toString(),
      senderId: json['sender_id'].toString(),
      receiverId: json['receiver_id'].toString(),
      message: json['message'].toString(),
      messageType: json['message_type'],
      created: json['created'].toString(),
      updated: json['updated'].toString(),
      status: json['status'],
      deletedBySender: json['deleted_by_sender'],
      deletedByReceiver: json['deleted_by_receiver'],
      deletedAtSender: json['deleted_at_sender'].toString(),
      deletedAtReceiver: json['deleted_at_receiver'].toString(),
      isEdited: json['is_edited'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message': message,
      'message_type': messageType,
      'created': DateTime.parse(created ?? ''),
      'updated': DateTime.parse(updated ?? ''),
      'status': status,
      'deleted_by_sender': deletedBySender,
      'deleted_by_receiver': deletedByReceiver,
      'deleted_at_sender': DateTime.parse(deletedAtSender ?? ''),
      'deleted_at_receiver': DateTime.parse(deletedAtReceiver ?? ''),
      'is_edited': isEdited,
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
    );
  }
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
