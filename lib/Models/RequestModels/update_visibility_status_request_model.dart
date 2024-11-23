class UpdateVisibilityStatusRequestModel {
  String? status;

  UpdateVisibilityStatusRequestModel({this.status});

  factory UpdateVisibilityStatusRequestModel.fromJson(
      Map<String, dynamic> json) {
    return UpdateVisibilityStatusRequestModel(
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
    };
  }
}
