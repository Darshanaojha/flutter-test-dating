import 'package:get/get.dart';
import '../Models/RequestModels/forget_password_request_model.dart';
import '../Models/RequestModels/forget_password_verification_request_model.dart';
import '../Models/RequestModels/user_login_request_model.dart';
import '../Models/ResponseModels/forget_password_response_model.dart';
import '../Models/ResponseModels/forget_password_verification_response_model.dart';
import '../Models/ResponseModels/user_login_response_model.dart';
import '../constants.dart';
import 'package:get/get_connect/connect.dart';

class LoginProvider extends GetConnect {
  // Reset Password for Forget Password using OTP
  Future<ForgetPasswordResponse?> getOtp(
      ForgetPasswordRequest forgetPasswordRequest) async {
    try {
      Response response = await post(
        "$baseurl/Profile/forget_password",
        forgetPasswordRequest,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
      );

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
      Response response = await post(
        '$baseurl/Profile/forget_password_otp_verification',
        forgetPasswordVerificationRequest,
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
      Response response = await post(
        '$baseurl/Authentication/login',
        userLoginRequest,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

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