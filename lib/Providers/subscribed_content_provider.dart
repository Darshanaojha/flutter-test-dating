import 'package:dating_application/constants.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';
import '../Models/ResponseModels/creator_package_response.dart';
class FetchAllBecomeCreatorPackageProvider extends GetConnect {
  Future<PackageResponse?> getAllCreatorPackages() async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');

      if (token != null && token.isNotEmpty) {
        Response response = await get(
          "$springbooturl/creator/get-creators-packages-userSide",
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == null || response.body == null) {
          failure('Error in getAllCreatorPackages', 'Server Failed To Respond');
          return null;
        }

        if (response.statusCode == 200) {
          final body = response.body;

          if (body is Map && body['success'] == true) {
            return PackageResponse.fromJson(
                body as Map<String, dynamic>);
          } else {
            failure('Error in getAllCreatorPackages', body['message'] ?? 'Unknown error occurred');
            return null;
          }
        } else {
          failure('Error in getAllCreatorPackages', response.body.toString());
          return null;
        }
      } else {
        failure('Error in getAllCreatorPackages', 'Token not found');
        return null;
      }
    } catch (e) {
      failure('Error in getAllCreatorPackages', e.toString());
      return null;
    }
  }
}
