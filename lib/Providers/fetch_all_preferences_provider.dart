import 'package:dating_application/Models/ResponseModels/get_all_whoareyoulookingfor_response_model.dart';
import 'package:dating_application/constants.dart';
import 'package:get/get.dart';
class FetchAllPreferencesProvider extends GetConnect {
  //Preferences
  Future<UserPreferencesResponse?> fetchPreferences() async {
    try {
      final response = await get('$baseurl/Common/all_preferences');
      if (response.statusCode == null || response.body == null) {
        failure('Error in fetchPreferences', 'Server Failed To Respond');
        return null;
      }
      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return UserPreferencesResponse.fromJson(response.body);
        } else {
          failure('Error in fetchPreferences', response.body['error']['message']);
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
      failure('Error in preferences', e.toString());
      return null;
    }
  }
}