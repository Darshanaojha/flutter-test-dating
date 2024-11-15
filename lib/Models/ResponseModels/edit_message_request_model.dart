class EditMessageRequest {
  final String message;
  final String messageId;
  final String messageType;

  EditMessageRequest({
    required this.message,
    required this.messageId,
    required this.messageType,
  });

  // Factory constructor to create EditMessageRequest from JSON
  factory EditMessageRequest.fromJson(Map<String, dynamic> json) {
    return EditMessageRequest(
      message: json['message'] ?? '',
      messageId: json['message_id'] ?? '',
      messageType: json['message_type'] ?? '',
    );
  }

  // Method to convert EditMessageRequest object to JSON
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'message_id': messageId,
      'message_type': messageType,
    };
  }

  // Validation for fields
  String? validate() {
    if (message.isEmpty) {
      return "Message cannot be empty.";
    }
    if (messageId.isEmpty) {
      return "Message ID is required.";
    }
    if (messageType.isEmpty || !['1', '2','3'].contains(messageType)) {
      return "Invalid message type. It should be either '1' or '2' or '3'.";
    }
    return null;
  }
}
