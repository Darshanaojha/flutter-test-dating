import 'package:get/get.dart';

import '../Models/ResponseModels/get_all_benifites_response_model.dart';
import '../constants.dart';

class FetchBenefitsProvider extends GetConnect {
  Future<BenefitsResponse?> fetchBenefits() async {
    try {
      Response response = await get('$baseurl/Common/all_benefits');
      if (response.statusCode == null || response.body == null) {
        failure('Error', 'Server Failed To Respond');
        return null;
      }
      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return BenefitsResponse.fromJson(response.body);
        } else {
          failure('Error', response.body['error']['message']);
          return null;
        }
      } else {
        failure('Error', response.body.toString());
        return null;
      }
    } catch (e) {
      failure('Error', e.toString());
      return null;
    }
  }
}
