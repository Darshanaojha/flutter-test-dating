import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get_connect.dart';

import '../Models/RequestModels/share_profile_request_model.dart';
import '../Models/ResponseModels/share_profile_response_model.dart';
import '../constants.dart';

class ShareProfileProvider extends GetConnect {
  Future<ShareProfileResponseModel?> shareProfileUser(
      ShareProfileRequestModel shareProfileRequestModel) async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');
      if (token == null || token.isEmpty) {
        failure('Error', 'Token not found');
        return null;
      }
      Response response = await post(
        '$baseurl/Profile/shareProfile',
        shareProfileRequestModel.toJson(),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return ShareProfileResponseModel.fromJson(response.body);
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
