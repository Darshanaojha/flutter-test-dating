import 'package:dating_application/constants.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';
import '../Models/ResponseModels/BecomeCreatorPackagesResponse.dart';

class FetchAllBecomeCreatorPackageProvider extends GetConnect {
  Future<BecomeCreatorPackagesResponseModel?> getAllCreatorPackages() async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');

      if (token != null && token.isNotEmpty) {
        Response response = await get(
          "$baseurl/Profile/fetch_all_creator_packages",
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == null || response.body == null) {
          failure('Error', 'Server Failed To Respond');
          return null;
        }

        if (response.statusCode == 200) {
          final body = response.body;

          if (body is Map && body['success'] == true) {
            return BecomeCreatorPackagesResponseModel.fromJson(
                body as Map<String, dynamic>);
          } else {
            failure('Error', body['message'] ?? 'Unknown error occurred');
            return null;
          }
        } else {
          failure('Error',
              'Status Code: ${response.statusCode} - ${response.statusText}');
          return null;
        }
      } else {
        failure('Error', 'Token not found');
        return null;
      }
    } catch (e) {
      failure('Error', e.toString());
      return null;
    }
  }
}
