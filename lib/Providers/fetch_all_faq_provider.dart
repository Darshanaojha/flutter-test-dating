import 'package:dating_application/constants.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';
import '../Models/ResponseModels/get_all_faq_response_model.dart';
class FetchAllFaqProvider extends GetConnect {
  Future<FAQResponseModel?> fetchFaq() async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');
      if (token != null && token.isNotEmpty) {
        Response response = await get(
          '$baseurl/Profile/faq',
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == null || response.body == null) {
          failure('Error in fetchFaq', 'Server Failed To Respond');
          return null;
        }

        if (response.statusCode == 200) {
          if (response.body['error']['code'] == 0) {
            return FAQResponseModel.fromJson(response.body);
          } else {
            failure("Error in fetchFaq", response.body['error']['message']);
            return null;
          }
        } else {
          failure(
            "Error",
            response.body.toString(),
          );
          return null;
        }
      }
    } catch (e) {
      failure("Error in fetchFaq", e.toString());
      return null;
    }
    return null;
  }
}
