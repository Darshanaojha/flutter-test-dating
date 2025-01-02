import 'package:dating_application/Models/ResponseModels/chat_history_response_model.dart';

class ChatResponse {
  String message;
  bool success;
  List<Message> chats;

  ChatResponse({
    required this.message,
    required this.success,
    required this.chats,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    var chatList = json['chats'] as List?; 
    List<Message> parsedChats = chatList != null
        ? chatList.map((chat) => Message.fromJson(chat)).toList()
        : [];

    return ChatResponse(
      message: json['message'],
      success: json['success'],
      chats: parsedChats,
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> chatList =
        chats.map((chat) => chat.toJson()).toList();

    return {
      'message': message,
      'success': success,
      'chats': chatList,
    };
  }
}
