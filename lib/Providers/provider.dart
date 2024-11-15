
import 'package:dating_application/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get_connect/connect.dart';

import '../Models/RequestModels/user_login_request_model.dart';


class Provider extends GetConnect {
 

  Future<bool> login(UserLoginRequest loginRequest) async {
    try {
      Response response = await post(
        $baseUrl + $loginUrl,
        loginRequest,
      );
      if (response.statusCode == 200) {
        success('Success', response.body['payload']['message']);
        UserLoginRequest.fromJson(response.body);
        return true;
      } else {
        failure(
            response.statusCode, response.body['error']['message']);
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }


  static of(BuildContext context) {}
}
