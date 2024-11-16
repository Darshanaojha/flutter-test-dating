import 'package:get/get.dart';
import '../Models/RequestModels/registration_otp_request_model.dart';
import '../Models/RequestModels/registration_otp_verification_request_model.dart';
import '../Models/RequestModels/user_registration_request_model.dart';
import '../Models/ResponseModels/get_all_country_response_model.dart';
import '../Models/ResponseModels/registration_otp_response_model.dart';
import '../Models/ResponseModels/registration_otp_verification_response_model.dart';
import '../Models/ResponseModels/user_registration_response_model.dart';
import '../constants.dart';

class RegistrationProvider extends GetConnect {
  Future<CountryResponse?> fetchCountries() async {
    try {
      Response response = await get('$baseurl/Common/country');
      Get.snackbar('country', response.body.toString());
      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return CountryResponse.fromJson(response.body);
        } else {
          failure('Error', response.body['error']['message']);
          return null;
        }
      } else {
        failure('Error', response.body['error']['message']);
        return null;
      }
    } catch (e) {
      failure('Error', e.toString());
      return null;
    }
  }

  // Verify Email using OTP
  Future<RegistrationOtpResponse?> sendOtp(
      RegistrationOTPRequest registrationOTPRequest) async {
    try {
      Response response =
          await post('$baseUrl/Authentication/sendotp', registrationOTPRequest);

      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          RegistrationOtpResponse.fromJson(response.body);
        } else {
          failure('Error', response.body['error']['message']);
          return null;
        }
      } else {
        failure('Error', response.body['error']['message']);
        return null;
      }
    } catch (e) {
      failure('Error', e.toString());
      return null;
    }
    return null;
  }

  // Verify password while registration
  Future<RegistrationOtpVerificationResponse?> otpVerification(
      RegistrationOtpVerificationRequest
          registrationOtpVerificationRequest) async {
    try {
      Response response = await post('$baseUrl/Authentication/verifyotp',
          registrationOtpVerificationRequest);

      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return RegistrationOtpVerificationResponse.fromJson(response.body);
        } else {
          failure('Error', response.body['error']['message']);
          return null;
        }
      } else {
        failure('Error', response.body['error']['message']);
        return null;
      }
    } catch (e) {
      failure('Error', e.toString());
      return null;
    }
  }

  // User Registration
  Future<UserRegistrationResponse?> register(
      UserRegistrationRequest userRegistrationRequest) async {
    try {
      Response response = await post(
          '$baseUrl/Authentication/register', userRegistrationRequest);

      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return UserRegistrationResponse.fromJson(response.body);
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
