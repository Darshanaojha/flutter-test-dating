class GetAllChatHistoryPageResponse {
  final bool success;
  final String message;
  final ChatHistoryPayload payload;
  final ErrorDetails error;

  GetAllChatHistoryPageResponse({
    required this.success,
    required this.message,
    required this.payload,
    required this.error,
  });


  factory GetAllChatHistoryPageResponse.fromJson(Map<String, dynamic> json) {
    return GetAllChatHistoryPageResponse(
      success: json['success'],
      message: json['payload']['message'],
      payload: ChatHistoryPayload.fromJson(json['payload']),
      error: ErrorDetails.fromJson(json['error']),
    );
  }
}

class ErrorDetails {
  final int code;
  final String message;

  ErrorDetails({required this.code, required this.message});

  factory ErrorDetails.fromJson(Map<String, dynamic> json) {
    return ErrorDetails(
      code: json['code'],
      message: json['message'],
    );
  }
}

class ChatHistoryPayload {
  final List<UserConnections> data;

  ChatHistoryPayload({required this.data});
  factory ChatHistoryPayload.fromJson(Map<String, dynamic> json) {
    return ChatHistoryPayload(
      data: List<UserConnections>.from(
          json['data'].map((x) => UserConnections.fromJson(x))),
    );
  }
}

class UserConnections {
  final String id;
  final String userId;
  final String conectionId;
  final String type;
  final String status;
  final String created;
  final String updated;
  final String name;
  final String username;
  final String profileImage;
  final String lastSeen;
  final String useractivestatus;

  UserConnections({
    required this.id,
    required this.userId,
    required this.conectionId,
    required this.type,
    required this.status,
    required this.created,
    required this.updated,
    required this.name,
    required this.username,
    required this.profileImage,
    required this.lastSeen,
    required this.useractivestatus,
  });

  factory UserConnections.fromJson(Map<String, dynamic> json) {
    return UserConnections(
      id: json['id'],
      userId: json['user_id'],
      conectionId: json['conection_id'],
      type: json['type'],
      status: json['status'],
      created: json['created'],
      updated: json['updated'],
      name: json['name'],
      username: json['username'],
      profileImage: json['profile_image'],
      lastSeen: json['last_seen'],
      useractivestatus:json['user_active_status'],
    );
  }
}
