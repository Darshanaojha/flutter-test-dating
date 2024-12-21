class UpdateProfilePhotoRequest {
  String? img1;
  String? img2;
  String? img3;
  String? img4;
  String? img5;
  String? img6;

  UpdateProfilePhotoRequest({
    this.img1,
    this.img2,
    this.img3,
    this.img4,
    this.img5,
    this.img6,
  });

  String? validateImg(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  bool validate() {
    if (validateImg(img1, 'Image 1') != null ||
        validateImg(img2, 'Image 2') != null ||
        validateImg(img3, 'Image 3') != null ||
        validateImg(img4, 'Image 4') != null ||
        validateImg(img5, 'Image 5') != null ||
        validateImg(img6, 'Image 6') != null) {
      return false;
    }
    return true; // All images are valid
  }

  // Convert to JSON
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

  // Convert from JSON
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
