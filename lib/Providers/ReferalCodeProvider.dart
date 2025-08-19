import 'package:dating_application/constants.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';
import '../Models/RequestModels/ReferalCodeRequestModel.dart';
import '../Models/ResponseModels/ReferalCodeResponse.dart';
class ReferalCodeProvider extends GetConnect {
  Future<ReferralCodeResponse?> referalcodeprovider(
      ReferralCodeRequestModel referalcoderequesmodel) async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');
      if (token == null || token.isEmpty) {
        failure("Error in referalcodeprovider", "Token Is Not Found");
        return null;
      }

      Response response = await post(
        '$baseurl/Rewardpoints/get_referal_code',
        referalcoderequesmodel.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
      );
      if (response.statusCode == null || response.body == null) {
        failure('Error in referalcodeprovider', 'Server Failed To Respond');
        return null;
      }

      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return ReferralCodeResponse.fromJson(response.body);
        } else {
          failure("Error in referalcodeprovider", response.body['error']['message']);
          return null;
        }
      } else {
        failure(response.statusCode, response.body['error']['code']);
        return null;
      }
    } catch (e) {
      failure("Error in referalcodeprovider", e.toString());
      return null;
    }
  }
}
