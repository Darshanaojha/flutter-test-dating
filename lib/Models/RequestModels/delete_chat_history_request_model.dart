class DeleteChatRequest {
   String deleteChatWith;

  DeleteChatRequest({required this.deleteChatWith});
  Map<String, dynamic> toJson() {
    return {
      'delete_chat_with': deleteChatWith,
    };
  }

  factory DeleteChatRequest.fromJson(Map<String, dynamic> json) {
    return DeleteChatRequest(
      deleteChatWith: json['delete_chat_with'] ?? '',
    );
  }
}
