class ChatHistoryResponse {
  final bool success;
  final Payload payload;
  final Error error;

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
    var list = json['data'] as List;
    List<Message> messageList = list.map((i) => Message.fromJson(i)).toList();

    return Payload(
      data: messageList,
      message: json['message'],
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
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final String messageType;
  final String created;
  final String updated;
  final String status;
  final String deletedBySender;
  final String deletedByReceiver;
  final String isEdited;
  final String userName;

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
    required this.isEdited,
    required this.userName,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      message: json['message'],
      messageType: json['message_type'],
      created: json['created'],
      updated: json['updated'],
      status: json['status'],
      deletedBySender: json['deleted_by_sender'],
      deletedByReceiver: json['deleted_by_receiver'],
      isEdited: json['is_edited'],
      userName: json['user_name'],
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message': message,
      'message_type': messageType,
      'created': created,
      'updated': updated,
      'status': status,
      'deleted_by_sender': deletedBySender,
      'deleted_by_receiver': deletedByReceiver,
      'is_edited': isEdited,
      'user_name': userName,
    };
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
      code: json['code'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }
}
