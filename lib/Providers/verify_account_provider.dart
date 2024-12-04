import 'package:dating_application/Models/RequestModels/verify_account_request_model.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';

import '../Models/ResponseModels/verify_account_response_model.dart';
import '../constants.dart';

class VerifyAccountProvider extends GetConnect {
  Future<RequestToVerifyAccountResponse?> verifyaccountprovider(
      RequestToVerifyAccount requestToVerifyAccount) async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();

      String? token = preferences.getString('token');

      if (token != null && token.isNotEmpty) {
        Response response = await post(
          '$baseurl/Profile/request_to_verify_account',
          requestToVerifyAccount.toJson(),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200 && response.body != null) {
          if (response.body['error']['code'] == 0) {
            return RequestToVerifyAccountResponse.fromJson(response.body);
          } else {
            failure('Error', response.body['error']['message']);
            return null;
          }
        } else {
          failure('Error', response.body['error']['message']);
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
