import 'package:dating_application/constants.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';
import '../Models/ResponseModels/GetUsersTotalPointsResponse.dart';

class GetUsertotalPointsProvider extends GetConnect {
  Future<GetUsersTotalPoints?> getusertotalpointsprovider() async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');

      if (token == null || token.isEmpty) {
        failure("Error", "Token is not found");
        return null;
      }

      Response response = await get(
        '$baseurl/Rewardpoints/get_user_point',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == null || response.body == null) {
        failure('Error', 'Server Failed To Respond');
        return null;
      }
      print("totalcoin = ${response.body.toString()}");
      if (response.statusCode == 200) {
        if (response.body != null && response.body['error'] != null) {
          if (response.body['error']['code'] == 0) {
            return GetUsersTotalPoints.fromJson(response.body);
          } else {
            failure("Error", response.body['error']['code'].toString());
            return null;
          }
        } else {
          failure("Error", "Invalid response format");
          return null;
        }
      } else {
        failure("Error",
            "Failed to fetch data, Status Code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      failure("Error", e.toString());
      return null;
    }
  }
}
