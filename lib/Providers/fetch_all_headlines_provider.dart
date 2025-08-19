import 'package:dating_application/Models/ResponseModels/get_all_headlines_response_model.dart';
import 'package:dating_application/constants.dart';
import 'package:get/get.dart';
class FetchAllHeadlinesProvider extends GetConnect {
  Future<HeadlinesResponse?> fetchAllHeadlines() async {
    try {
      final response = await get('$baseurl/Common/all_headlines');

      if (response.statusCode == null || response.body == null) {
        failure('Error in fetchAllHeadlines', 'Server Failed To Respond');
        return null;
      }
      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return HeadlinesResponse.fromJson(response.body);
        } else {
          failure('Error in fetchAllHeadlines', response.body['error']['message']);
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
      failure('Error in fetchAllHeadlines', e.toString());
      return null;
    }
  }
}
