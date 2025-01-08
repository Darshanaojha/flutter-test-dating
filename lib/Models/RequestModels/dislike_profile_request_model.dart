import 'dart:convert';

class DislikeProfileRequest {
  String id;

  DislikeProfileRequest({required this.id});

  factory DislikeProfileRequest.fromMap(Map<String, dynamic> map) {
    return DislikeProfileRequest(
      id: map['id'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
    };
  }

  String toJson() {
    return json.encode(toMap());
  }

  factory DislikeProfileRequest.fromJson(String source) {
    return DislikeProfileRequest.fromMap(json.decode(source));
  }
}
