class SubGenderRequest {
  final int genderId;

  SubGenderRequest({
    required this.genderId,
  }) {
    // Validate genderId
    validateGenderId(genderId);
  }

  // Factory constructor to create SubGenderRequest from JSON
  factory SubGenderRequest.fromJson(Map<String, dynamic> json) {
    int genderId = json['gender_id'] ?? 0;  // Default to 0 if 'gender_id' is not present
    
    // Validate genderId
    validateGenderId(genderId);
    
    return SubGenderRequest(
      genderId: genderId,
    );
  }

  // Method to convert SubGenderRequest object to JSON
  Map<String, dynamic> toJson() {
    return {
      'gender_id': genderId,
    };
  }

  // Validate genderId (It should be a positive integer)
  static void validateGenderId(int genderId) {
    if (genderId <= 0) {
      throw FormatException('Gender ID must be a positive integer');
    }
  }
}
