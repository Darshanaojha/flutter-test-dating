

class SubGenderRequest {
  String genderId;

  SubGenderRequest({
    required this.genderId,
  });

  factory SubGenderRequest.fromJson(Map<String, dynamic> json) {
    String genderId = json["gender_id"] ?? '0';

    return SubGenderRequest(
      genderId: genderId,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "gender_id": genderId,
    };
  }
}
