import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/connect.dart';

import '../Models/ResponseModels/get_all_verification_response_model.dart';
import '../constants.dart';

class FetchVerificationtypeProvider extends GetConnect {
  Future<GetVerificationTypeResponse?> fetchAllVerificationProvider() async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');

      if (token == null || token.isEmpty) {
        failure('Error', 'Token not found');
        return null;
      }
      final response = await get(
        '$baseurl/VerificationTypes/verificationTypes',
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
          return GetVerificationTypeResponse.fromMap(response.body);
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
}
