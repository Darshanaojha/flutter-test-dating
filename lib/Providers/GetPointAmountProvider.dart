import 'package:dating_application/constants.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';
import '../Models/ResponseModels/GetPointAmountResponse.dart';
class GetPointAmountProvider extends GetConnect {
  Future<PointAmountResponse?> getpointamount() async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');

      if (token == null || token.isEmpty) {
        failure("Token", "Token is Not Found");
        return null;
      }

      final response = await get(
        '$baseurl/Rewardpoints/get_point_to_amount',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
      );
      if (response.statusCode == null || response.body == null) {
        failure('Error in getpointamount', 'Server Failed To Respond');
        return null;
      }
      if (response.statusCode == 200) {
        print(response.body.toString());
        if (response.body != null && response.body['error'] != null) {
          if (response.body['error']['code'] == 0) {
            return PointAmountResponse.fromJson(response.body);
          } else {
            failure("Error in getpointamount", response.body['error']['code']);
            return null;
          }
        } else {
          failure("Error in getpointamount", "Invalid response format");
          return null;
        }
      } else {
        failure("Error",
            "Failed to fetch data, Status Code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      failure('Error in getpointamount', e.toString());
      return null;
    }
  }
}
