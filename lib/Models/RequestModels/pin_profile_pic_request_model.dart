class PinProfilePicRequestModel {
  String? imgName;

  PinProfilePicRequestModel({this.imgName});

  // Factory method to create an ImageNameResponse instance from JSON
  factory PinProfilePicRequestModel.fromJson(Map<String, dynamic> json) {
    return PinProfilePicRequestModel(
      imgName: json['img_name'],
    );
  }

  // Method to convert an ImageNameResponse instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'img_name': imgName,
    };
  }
}
