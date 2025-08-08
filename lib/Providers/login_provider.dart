import 'package:get/get.dart';
import '../Controllers/controller.dart';
import '../Models/RequestModels/forget_password_request_model.dart';
import '../Models/RequestModels/forget_password_verification_request_model.dart';
import '../Models/RequestModels/user_login_request_model.dart';
import '../Models/ResponseModels/forget_password_response_model.dart';
import '../Models/ResponseModels/forget_password_verification_response_model.dart';
import '../Models/ResponseModels/user_login_response_model.dart';
import '../constants.dart';

class LoginProvider extends GetConnect {
  Controller controller = Get.find();
  Future<ForgetPasswordResponse?> getOtpForgetPassword(
      ForgetPasswordRequest forgetPasswordRequest) async {
    try {
      final requestBody = forgetPasswordRequest.toJson();
      print("Request Body getOtpForgetPassword: $requestBody");
      Response response = await post(
        "$baseurl/Profile/forget_password",
        requestBody,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
      );
      if (response.statusCode == null || response.body == null) {
        failure('Error', 'Server Failed To Respond');
        return null;
      }

      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return ForgetPasswordResponse.fromJson(response.body);
        } else {
          failure('Error', response.body['error']['message']);
          return null;
        }
      } else {
        failure(
          'Error',
          response.body.toString(),
        );
        return null;
      }
    } catch (e) {
      failure('Error', e.toString());
      return null;
    }
  }

  // OTP Verification to reset password
  Future<ForgetPasswordVerificationResponse?> otpVerificationForgetPassword(
      ForgetPasswordVerificationRequest
          forgetPasswordVerificationRequest) async {
    try {
      final requestBody = forgetPasswordVerificationRequest.toJson();
      Response response = await post(
        '$baseurl/Profile/forget_password_otp_verification',
        requestBody,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return ForgetPasswordVerificationResponse.fromJson(response.body);
        } else {
          failure('Error', response.body['error']['message']);
          return null;
        }
      } else {
        failure('Error', response.body.toString());
        return null;
      }
    } catch (e) {
      failure('Error', e.toString());
      return null;
    }
  }

// User Login
  Future<UserLoginResponse?> userLogin(
      UserLoginRequest userLoginRequest) async {
    try {
      print(userLoginRequest.toJson().toString());
      Response response = await post(
        '$baseurl/Authentication/login',
        userLoginRequest.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      print(response.body);
      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return UserLoginResponse.fromJson(response.body);
        } else {
          failure('Error', response.body['error']['message']);
          return null;
        }
      } else {
        failure('Error', response.body.toString());
        return null;
      }
    } catch (e) {
      failure('Error', e.toString());
      return null;
    }
  }
}
