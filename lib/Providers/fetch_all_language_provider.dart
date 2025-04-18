import 'package:get/get.dart';

import '../Controllers/controller.dart';
import '../Models/ResponseModels/get_all_language_response_model.dart';
import '../constants.dart';

class FetchAllLanguageProvider extends GetConnect {
  Controller controller = Get.put(Controller());
  Future<GetAllLanguagesResponse?> fetchlang() async {
    try {
      Response response = await get('$baseurl/Authentication/fetch_lang');
      if (response.statusCode == null || response.body == null) {
        failure('Error', 'Server Failed To Respond');
        return null;
      }
      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return GetAllLanguagesResponse.fromJson(response.body);
        } else {
          failure("Error", response.body['error']['message']);
          return null;
        }
      } else {
        failure(
          "Error",
          response.body.toString(),
        );
        return null;
      }
    } catch (e) {
      failure("Error", e.toString());
      return null;
    }
  }
}
