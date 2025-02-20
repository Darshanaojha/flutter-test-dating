import 'package:dating_application/constants.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';
import '../Models/ResponseModels/GetUsersTotalPointsResponse.dart';

class GetUsertotalPointsProvider extends GetConnect {
  Future<GetUsersTotalPoints?> Getusertotalpointsprovider() async {
    try {
      EncryptedSharedPreferences preferences =
          await EncryptedSharedPreferences.getInstance(); // Await instance
      String? token = await preferences.getString('token'); // Await getString

      if (token == null || token.isEmpty) {
        failure("Error", "Token is not found");
        return null;
      }

      Response response = await get(
        '$baseurl/Rewardpoints/get_user_point',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token', // Fixed missing space
        },
      );
        print("totalcoin = ${response.body.toString()}");
      if (response.statusCode == 200) {

        if (response.body != null && response.body['error'] != null) {
          if (response.body['error']['code'] == 0) { // Corrected the condition
            return GetUsersTotalPoints.fromJson(response.body);
          } else {
            failure("Error", response.body['error']['code'].toString()); // Ensure code is a string
            return null;
          }
        } else {
          failure("Error", "Invalid response format");
          return null;
        }
      } else {
        failure("Error", "Failed to fetch data, Status Code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      failure("Error", e.toString());
      return null;
    }
  }
}
