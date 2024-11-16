import 'package:dating_application/Models/ResponseModels/get_all_saftey_guidelines_response_model.dart';
import 'package:dating_application/constants.dart';
import 'package:get/get.dart';

class FetchAllSafetyGuildlinesProvider extends GetConnect {
  // All Safety Guidelines
  Future<SafetyGuidelinesResponse?> fetchAllSafetyGuidelines() async {
    try {
      final response = await get('$baseUrl/Common/all_safety_guidelines');
      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return SafetyGuidelinesResponse.fromJson(response.body);
        } else {
          failure('Error', response.body['error']['message']);
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
      failure('Error', e.toString());
      return null;
    }
  }
}