class UpdateNewPackageRequestModel {
  String packageId;

  UpdateNewPackageRequestModel({
    required this.packageId,
  });

  // Factory method to create an instance from JSON
  factory UpdateNewPackageRequestModel.fromJson(Map<String, dynamic> json) {
    return UpdateNewPackageRequestModel(
      packageId: json['package_id'],
    );
  }

  // Convert the model back to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'package_id': packageId,
    };
  }
}
