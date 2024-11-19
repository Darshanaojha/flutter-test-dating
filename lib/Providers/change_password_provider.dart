import 'package:dating_application/constants.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';

import '../Models/RequestModels/change_password_request.dart';
import '../Models/ResponseModels/change_password_response_model.dart';
class ChangePasswordProvider extends GetConnect {

  Future<ChangePasswordResponse?> changePassword(ChangePasswordRequest request) async {
    try {

      EncryptedSharedPreferences preferences = EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');
      
      if (token != null && token.isNotEmpty) {

        Response response = await post(
          '$baseurl/Profile/change_password',
          request.toJson(), 
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {

          if (response.body['error']['code'] == 0) {

            return ChangePasswordResponse.fromJson(response.body);
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
    } finally {

      print("Change password operation completed.");
    }
  }

  
}
