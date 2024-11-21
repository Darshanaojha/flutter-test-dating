import 'package:get/get.dart';

import '../Models/ResponseModels/get_all_packages_response_model.dart';
import '../constants.dart';
class FetchAllPackagesProvider extends GetConnect {
  Future<GetAllPackagesResponseModel?> fetchAllPackages() async {
    try {
      final response = await get('$baseurl/Common/fetch_all_packages');
      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return GetAllPackagesResponseModel.fromJson(response.body);
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
