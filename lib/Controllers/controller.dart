import 'package:dating_application/RequestModels/login.dart';
import 'package:dating_application/constants.dart';
import 'package:get/get.dart';

import '../Providers/provider.dart';
import '../RequestModels/register.dart';
import '../Screens/login.dart';

class Controller extends GetxController {
  Provider provider = Get.put(Provider());

  register(RegisterRequest registerRequest) async {
    bool result = await provider.register(registerRequest);
    if (result) {
      Get.offAll(Login);
    } else {
      showFailedSnackBar('Error', 'Internal Server Error');
    }
  }

  login(LoginRequest loginRequest) async {
    bool result = await provider.login(loginRequest);
    if (result) {
   //   Get.offAll(Home());
    } else {
      showFailedSnackBar('Error', 'Internal Server Error');
    }
  }
}
