import 'package:dating_application/Models/ResponseModels/get_all_desires_model_response.dart';
import 'package:dating_application/constants.dart';
import 'package:get/get.dart';

class FetchAllDesiresProvider extends GetConnect {
  // Desires
  Future<Desire?> fetchDesires() async {
    try {
      final response = await get('$baseurl/Common/all_desires');
      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return Desire.fromJson(response.body);
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
