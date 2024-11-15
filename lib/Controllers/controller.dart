
import 'package:dating_application/Models/RequestModels/user_login_request_model.dart';
import 'package:dating_application/constants.dart';
import 'package:get/get.dart';



import '../Providers/provider.dart';
import '../Screens/login.dart';

class Controller extends GetxController {
  Provider provider = Get.put(Provider());

  // static var selectedIndex;

  // register(RegisterRequest registerRequest) async {
  //   bool result = await provider.register(registerRequest);
  //   if (result) {
  //     Get.offAll(Login);
  //   } else {
  //     showFailedSnackBar('Error', 'Internal Server Error');
  //   }
  // }

  login(UserLoginRequest loginRequest) async {
    bool result = await provider.login(loginRequest);
    if (result) {
    //  Get.offAll(Home());
    } else {
      failure('Error', 'Internal Server Error');
    }
  }
}
