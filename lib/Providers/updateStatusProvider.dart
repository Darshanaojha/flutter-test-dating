import 'package:dating_application/Models/ResponseModels/updateStatusResponse.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../constants.dart';

class Updatestatusprovider extends GetConnect {
  Future<UpdateStatusResponse?> updateStatus(String status) async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');
      if (token == null || token.isEmpty) {
        failure('Error', 'Token not found');
        return null;
      }
      debugPrint('$springbooturl/users/updateStatus?status=$status');
      Response response = await post(
        '$springbooturl/users/updateStatus?status=$status',
        null,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      debugPrint(response.body.toString());
      if (response.statusCode == null || response.body == null) {
        failure('Error', 'Server Failed To Respond');
        return null;
      }

      if (response.statusCode == 200) {
        return UpdateStatusResponse.fromJson(response.body);
      } else {
        failure('Error', response.body['message']);
        return null;
      }
    } catch (e) {
      failure('Error in user photo', e.toString());
      return null;
    }
  }
}
