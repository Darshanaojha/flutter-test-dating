class DeleteMessageRequest {
  final List<String> messageIds;

  DeleteMessageRequest({
    required this.messageIds,
  });

  // Factory constructor to create DeleteMessageRequest from JSON
  factory DeleteMessageRequest.fromJson(Map<String, dynamic> json) {
    return DeleteMessageRequest(
      messageIds: List<String>.from(json['message_id'] ?? []),
    );
  }

  // Method to convert DeleteMessageRequest object to JSON
  Map<String, dynamic> toJson() {
    return {
      'message_id': messageIds,
    };
  }

  // Validation for the messageIds list
  String? validate() {
    if (messageIds.isEmpty) {
      return "At least one message ID must be provided.";
    }
    return null;
  }
}
