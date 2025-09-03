import 'package:dating_application/constants.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';
import '../Models/ResponseModels/GetPointCreditedDebitedResponse.dart';
class GetPointCreditedDebitedProvider extends GetConnect {
  Future<GetPointCreditedDebitedResponse?>
      getpointcrediteddebitedprovider() async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');
      if (token == null || token.isEmpty) {
        failure("Error in getpointcrediteddebitedprovider", "Token Not Found");
        return null;
      }

      final response = await get(
        '$baseurl/Rewardpoints/get_creditdebit_history',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer$token'
        },
      );
      if (response.statusCode == null || response.body == null) {
        failure('Error in getpointcrediteddebitedprovider', 'Server Failed To Respond');
        return null;
      }

      if (response.statusCode == 200) {
        if (response.body != null && response.body['error'] != null) {
          if (response.body['error']['message'] == 0) {
            return GetPointCreditedDebitedResponse.fromJson(response.body);
          } else {
            failure("Error in getpointcrediteddebitedprovider", response.body['error']['code']);
            return null;
          }
        } else {
          failure("Error in getpointcrediteddebitedprovider", "Status Code Invalid Formate");
          return null;
        }
      } else {
        failure("Error",
            "Failed to fetch data, Status Code: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      failure("Error in getpointcrediteddebitedprovider", e.toString());
      return null;
    }
  }
}
