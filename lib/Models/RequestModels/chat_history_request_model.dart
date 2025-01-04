class ChatHistoryRequestModel {
  String userId;

  ChatHistoryRequestModel({required this.userId});

  factory ChatHistoryRequestModel.fromJson(Map<String, dynamic> json) {
    if (json['user_id'] == null) {
      throw ArgumentError('User ID is required in the JSON data');
    }
    return ChatHistoryRequestModel(
      userId: json['user_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
    };
  }
}
