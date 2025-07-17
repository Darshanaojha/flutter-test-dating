import 'package:get/get.dart';
import '../Controllers/controller.dart';
import '../Models/RequestModels/registration_otp_request_model.dart';
import '../Models/RequestModels/registration_otp_verification_request_model.dart';
import '../Models/ResponseModels/get_all_country_response_model.dart';
import '../Models/ResponseModels/registration_otp_response_model.dart';
import '../Models/ResponseModels/registration_otp_verification_response_model.dart';
import '../constants.dart';

class RegistrationProvider extends GetConnect {
  Controller controller = Get.find();
  Future<CountryResponse?> fetchCountries() async {
    try {
      Response response = await get('$baseurl/Common/country');

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
  Future<RegistrationOtpResponse?> getOtpForRegistration(
      RegistrationOTPRequest registrationOTPRequest) async {
    try {
      final requestBody = registrationOTPRequest.toJson();
      if (baseurl.isEmpty) {
        throw Exception("Base URL is not defined.");
      }

      Response response =
          await post('$baseurl/Authentication/sendotp', requestBody, headers: {
        'Content-Type': 'application/json',
      });

      print('Response body: ${response.body}');

      if (response.statusCode == null || response.body == null) {
        failure('Error', 'Server Failed To Respond');
        return null;
      }

      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return RegistrationOtpResponse.fromJson(response.body);
        } else {
          failure('Error', response.body['error']['message']);
          return null;
        }
      } else {
        failure('Error', response.body['error']['message']);
        return null;
      }
    } catch (e) {
      print('Error occurred: ${e.toString()}');
      failure('Error', e.toString());
      return null;
    }
  }

  // Verify password while registration
  Future<RegistrationOtpVerificationResponse?> otpVerificationForRegistration(
      RegistrationOtpVerificationRequest
          registrationOtpVerificationRequest) async {
    try {
      print(registrationOtpVerificationRequest.toJson().toString());

      Response response = await post(
        '$baseurl/Authentication/verifyotp',
        registrationOtpVerificationRequest.toJson(),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return RegistrationOtpVerificationResponse.fromJson(response.body);
        } else {
          failure('Error', response.body['error']['message']);
          return null;
        }
      } else {
        failure(
            'Error', 'Received invalid status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error occurred: ${e.toString()}');
      failure('Error', e.toString());
      return null;
    }
  }
}
