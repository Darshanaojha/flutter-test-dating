import 'package:dating_application/RequestModels/login.dart';
import 'package:dating_application/constants.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get_connect/connect.dart';

import '../RequestModels/register.dart';
import '../ResponseModels/profile.dart';

class Provider extends GetConnect {
  Future<bool> register(RegisterRequest registerRequest) async {
    try {
      Response response = await post(
        $baseUrl + $registerUrl,
        registerRequest,
      );
      if (response.statusCode == 200) {
        showSuccessSnackBar('Success', response.body['payload']['message']);
        return true;
      } else {
        showFailedSnackBar(
            response.statusCode, response.body['error']['message']);
        return false;
      }
    } catch (e) {
      showFailedSnackBar('Error', e.toString());
      return false;
    }
  }

  Future<bool> login(LoginRequest loginRequest) async {
    try {
      Response response = await post(
        $baseUrl + $loginUrl,
        loginRequest,
      );
      if (response.statusCode == 200) {
        showSuccessSnackBar('Success', response.body['payload']['message']);
        LoginRequest.fromJson(response.body);
        return true;
      } else {
        showFailedSnackBar(
            response.statusCode, response.body['error']['message']);
        return false;
      }
    } catch (e) {
      showFailedSnackBar('Error', e.toString());
      return false;
    }
  }

  Future<bool> profile() async {
    try {
      Response response = await get($baseUrl + $profileUrl);
      if (response.statusCode == 200) {
        showSuccessSnackBar('Success', response.body['payload']['message']);
        ProfileResponse profileResponse =
            ProfileResponse.fromJson(response.body);
        final storage = FlutterSecureStorage();
        await storage.write(
            key: 'user', value: response.body['payload'].toString());
        return true;
      } else {
        showFailedSnackBar(
            response.statusCode, response.body['error']['message']);
        return false;
      }
    } catch (e) {
      showFailedSnackBar('Error', e.toString());
      return false;
    }
  }

  static of(BuildContext context) {}
}
