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
      }
      final response = await get('$baseurl/Rewardpoints/get_point_to_amount',
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token'
          });

      if (response.statusCode == 200) {
        print(response.body.toString());
        if (response.body['error']['code'] == 0) {
          return PointAmountResponse.fromJson(response.body);
        } else {
          failure("Error", response.body['error']['code']);
          return null;
        }
      } else {
        failure("Error", response.body.toString());
        return null;
      }
    } catch (e) {
      failure('Error', e.toString());
      return null;
    }
  }
}
