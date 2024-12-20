
import '../../constants.dart';  

class SubGenderRequest {
   String genderId;

  SubGenderRequest({
    required this.genderId, 
  });

  factory SubGenderRequest.fromJson(Map<String, dynamic> json) {
    String genderId =
        json["gender_id"] ?? '0'; 

    if (!validateGenderId(genderId)) {
      failure("Invalid Gender ID", "Gender ID must be a positive integer.");
      genderId = '0'; 
    }

    return SubGenderRequest(
      genderId: genderId,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "gender_id": genderId,
    };
  }

  static bool validateGenderId(String genderId) {
    try {
      int parsedGenderId = int.parse(genderId);
      if (parsedGenderId <= 0) {
        return false;
      }
      return true;
    } catch (e) {
      return false; 
    }
  }

}
