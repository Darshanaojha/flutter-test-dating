class DeleteMessageRequest {
  final List<String> messageIds;

  DeleteMessageRequest({
    required this.messageIds,
  });


  factory DeleteMessageRequest.fromJson(Map<String, dynamic> json) {
    return DeleteMessageRequest(
      messageIds: List<String>.from(json['message_id'] ?? []),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'message_id': messageIds,
    };
  }


  String? validate() {
    if (messageIds.isEmpty) {
      return "At least one message ID must be provided.";
    }
    return null;
  }
}
