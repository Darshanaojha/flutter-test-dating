import 'package:dating_application/Models/ResponseModels/get_all_gender_from_response_model.dart';
import 'package:dating_application/constants.dart';
import 'package:get/get.dart';

class FetchAllGendersProvider extends GetConnect {
  // Gender
  Future<GenderResponse?> fetchGenders() async {
    try {
      final response = await get('$baseurl/Common/gender');
      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return GenderResponse.fromJson(response.body);
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
