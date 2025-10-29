import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';
import '../Models/ResponseModels/get_all_packages_response_model.dart';
import '../constants.dart';
class FetchAllPackagesProvider extends GetConnect {
  Future<GetAllPackagesResponseModel?> fetchAllPackages() async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');

      if (token == null || token.isEmpty) {
        failure('Error in fetchAllPackages', 'Token not found');
        return null;
      }
      final response = await get(
        '$baseurl/Common/fetch_all_packages',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == null || response.body == null) {
        failure('Error in fetchAllPackages', 'Server Failed To Respond');
        return null;
      }
      print("Packages response : ${response.body.toString()}");
      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return GetAllPackagesResponseModel.fromJson(response.body);
        } else {
          failure('Error in fetchAllPackages', response.body['error']['message']);
          return null;
        }
      } else {
        failure('Error in fetchAllPackages', response.body.toString());
        return null;
      }
    } catch (e) {
      failure('Error in fetchAllPackages', e.toString());
      return null;
    }
  }
}
