
import '../../constants.dart';  // For Get.snackbar

class SubGenderRequest {
   String genderId;

  SubGenderRequest({
    required this.genderId, 
  });

  // Factory constructor to create SubGenderRequest from JSON
  factory SubGenderRequest.fromJson(Map<String, dynamic> json) {
    String genderId =
        json["gender_id"] ?? '0'; // Default to 0 if 'gender_id' is not present

    // Validate genderId before creating the object
    if (!validateGenderId(genderId)) {
      failure("Invalid Gender ID", "Gender ID must be a positive integer.");
      genderId = '0';  // Default value in case of invalid input
    }

    return SubGenderRequest(
      genderId: genderId,
    );
  }

  // Method to convert SubGenderRequest object to JSON
  Map<String, dynamic> toJson() {
    return {
      "gender_id": genderId,
    };
  }

  // Validate genderId (It should be a positive integer)
  static bool validateGenderId(String genderId) {
    // Try to parse genderId as an integer and check if it's positive
    try {
      int parsedGenderId = int.parse(genderId);
      if (parsedGenderId <= 0) {
        return false;
      }
      return true; // Valid genderId
    } catch (e) {
      return false; // Not a valid integer
    }
  }

}
