import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get_connect.dart';

import '../Models/RequestModels/update_visibility_status_request_model.dart';
import '../Models/ResponseModels/update_visibility_status_response_model.dart';
import '../constants.dart';

class UpdateVisibilityStatusProvider extends GetConnect {
  Future<UpdateVisibilityStatusResponseModel?> updateVisibilityStatus(
      UpdateVisibilityStatusRequestModel
          updateVisibilityStatusRequestModel) async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');

      if (token == null || token.isEmpty) {
        failure('Error', 'Token not found');
        return null;
      }

      Response response = await post(
        '$baseurl/Authentication/master_setting',
        updateVisibilityStatusRequestModel.toJson(),
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
          return UpdateVisibilityStatusResponseModel.fromJson(response.body);
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
