import 'package:dating_application/Providers/login_provider.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';

import '../Models/ResponseModels/user_login_response_model.dart';
import '../constants.dart';

class Controller extends GetxController {
  Future<void> storeUserData(UserLoginResponse userLoginResponse) async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();

      await preferences.setString('token', userLoginResponse.payload.token);
      await preferences.setString('userId', userLoginResponse.payload.userId);
      await preferences.setString('email', userLoginResponse.payload.email);
      await preferences.setString('contact', userLoginResponse.payload.contact);
    } catch (e) {
      failure('Error', e.toString());
    }
  }

  Future<bool> login(dynamic userLoginRequest) async {
    try {
      final UserLoginResponse? response =
          await LoginProvider().userLogin(userLoginRequest);

      if (response != null) {
        await storeUserData(response);
        success('Success', 'Login successful!');
        return true;
      } else {
        failure('Error', 'Login failed. Please check your credentials.');
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }
}
