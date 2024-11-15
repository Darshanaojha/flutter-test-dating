class EstablishConnectionMessageRequest {
  final String receiverId;
  final String message;

  EstablishConnectionMessageRequest({
    required this.receiverId,
    required this.message,
  }) {

    if (receiverId.isEmpty) {
      throw ArgumentError("Receiver ID is required.");
    }
    if (int.tryParse(receiverId) == null) {
      throw ArgumentError("Receiver ID must be a valid number.");
    }
    if (message.isEmpty) {
      throw ArgumentError("Message is required.");
    }
    if (message.length > 500) {
      throw ArgumentError("Message cannot be more than 500 characters.");
    }
  }

  factory EstablishConnectionMessageRequest.fromJson(Map<String, dynamic> json) {
    return EstablishConnectionMessageRequest(
      receiverId: json['receiver_id'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'receiver_id': receiverId,
      'message': message,
    };
  }
}
