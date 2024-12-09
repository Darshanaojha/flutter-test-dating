
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';

import '../Models/RequestModels/app_setting_request_model.dart';
import '../Models/ResponseModels/app_setting_response_model.dart';
import '../constants.dart';

class AppSettingProvider extends GetConnect {
  Future<AppSettingResponse?> appsettingprovider(
      AppSettingRequest blockToRequestModel) async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');

      if (token == null || token.isEmpty) {
        failure('Error', 'Token not found');
        return null;
      }

      Response response = await post(
        '$baseurl/Authentication/appSettings',
        blockToRequestModel.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return AppSettingResponse.fromJson(response.body);
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
