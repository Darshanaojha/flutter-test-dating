class PinProfilePicRequestModel {
  String? imgName;

  PinProfilePicRequestModel({this.imgName});

  factory PinProfilePicRequestModel.fromJson(Map<String, dynamic> json) {
    return PinProfilePicRequestModel(
      imgName: json['img_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'img_name': imgName,
    };
  }
}
