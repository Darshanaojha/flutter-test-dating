import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get_connect/connect.dart';

import '../Models/RequestModels/update_profile_photo_request_model.dart';
import '../Models/ResponseModels/update_profile_photo_response_model.dart';
import '../constants.dart';

class UpdateProfilePhotoProvider extends GetConnect {
  Future<UserProfileUpdatePhotoResponse?> updateprofilephoto(
      UpdateProfilePhotoRequest
          reportUserReasonFeedbackRequestModel) async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');

      if (token == null || token.isEmpty) {
        failure('Error', 'Token not found');
        return null;
      }

      Response response = await post(
        '$baseurl/Profile/update_profile_photo',
        reportUserReasonFeedbackRequestModel.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return UserProfileUpdatePhotoResponse.fromJson(response.body);
        } else {
          failure('Error', response.body['error']['message']);
          return null;
        }
      } else {
        failure(response.statusCode, response.body['error']['message']);
        return null;
      }
    } catch (e) {
      failure('Error', e.toString());
      return null;
    }
  }
}