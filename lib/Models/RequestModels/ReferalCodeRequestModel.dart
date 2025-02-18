import 'package:dating_application/constants.dart';

class ReferralCodeRequestModel {
  String mobile;

  ReferralCodeRequestModel({required this.mobile});

  factory ReferralCodeRequestModel.fromJson(Map<String, dynamic> json) {
    return ReferralCodeRequestModel(mobile: json['mobileno'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'mobileno': mobile};
  }

  bool validate() {
    String? mobileError = validateMobile(mobile);
    if (mobileError != null) {
      failure("Error", mobileError);
      return false;
    }
    return true;
  }

  String? validateMobile(String mobile) {
    if (mobile.isEmpty) {
      return "Mobile Number Cannot Be Empty";
    }

    final mobileRegExp = RegExp(r'^[0-9]{10}$');
    if (!mobileRegExp.hasMatch(mobile)) {
      return "Invalid Mobile Number Format";
    }

    return null; // Valid mobile number
  }
}
