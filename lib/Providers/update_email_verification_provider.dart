import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';

import '../Models/RequestModels/update_emailid_otp_verification_request_model.dart';
import '../Models/ResponseModels/update_emailid_otp_verification_response_model.dart';
import '../constants.dart';

class UpdateEmailVerificationProvider extends GetConnect {
  Future<UpdateEmailVerificationResponse?> verifyEmailOtp(
      UpdateEmailVerificationRequest request) async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');

      if (token != null && token.isNotEmpty) {
        Response response = await post(
          '$baseurl/Profile/verifyotp',
          request.toJson(),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
        );
        if (response.statusCode == null || response.body == null) {
          failure('Error', 'Server Failed To Respond');
          return null;
        }

        if (response.statusCode == 200) {
          if (response.body['error']['code'] == 0) {
            return UpdateEmailVerificationResponse.fromJson(response.body);
          } else {
            failure('Error', response.body['error']['message']);
            return null;
          }
        } else {
          failure('Error', response.body.toString());
          return null;
        }
      } else {
        failure('Error', 'Token not found');
        return null;
      }
    } catch (e) {
      failure('Error', e.toString());
      return null;
    }
  }
}
