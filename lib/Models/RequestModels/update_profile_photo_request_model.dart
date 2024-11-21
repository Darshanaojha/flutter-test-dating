

class UpdateProfilePhotoRequest {
  String? img1;
  String? img2;
  String? img3;
  String? img4;
  String? img5;
  String? img6;

  // Constructor
  UpdateProfilePhotoRequest({
    this.img1,
    this.img2,
    this.img3,
    this.img4,
    this.img5,
    this.img6,
  });

  // Validation method for each field
  String? validateImg(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // To convert object to JSON format (if needed for API requests)
  Map<String, dynamic> toJson() {
    return {
      'img1': img1,
      'img2': img2,
      'img3': img3,
      'img4': img4,
      'img5': img5,
      'img6': img6,
    };
  }

  // To create the object from JSON response (if needed for API responses)
  factory UpdateProfilePhotoRequest.fromJson(Map<String, dynamic> json) {
    return UpdateProfilePhotoRequest(
      img1: json['img1'],
      img2: json['img2'],
      img3: json['img3'],
      img4: json['img4'],
      img5: json['img5'],
      img6: json['img6'],
    );
  }
}
