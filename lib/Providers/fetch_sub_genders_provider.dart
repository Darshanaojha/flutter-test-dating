import 'package:dating_application/Models/RequestModels/subgender_request_model.dart';
import 'package:dating_application/Models/ResponseModels/subgender_response_model.dart';
import 'package:dating_application/constants.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';

class FetchSubGendersProvider extends GetConnect {
  Future<SubGenderResponse?> getSubGenders(
      SubGenderRequest subGenderRequest) async {
    try {
       EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');
      if (token == null || token.isEmpty) {
        failure('Error', 'Token not found');
        return null;
      }
      Response response = await post(
        "$baseurl/Common/sub_gender",
        subGenderRequest.toJson(),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
           'Authorization': 'Bearer $token',
        },
      );
      // print("Sub gender request ${subGenderRequest.toJson()}");
      // print("Sub gender response ${response.body.toString()}");
      if (response.statusCode == null || response.body == null) {
        failure('Error', 'Server Failed To Respond');
        return null;
      }
      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return SubGenderResponse.fromJson(response.body);
        } else {
          failure('Error', response.body['error']['message']);
          return null;
        }
      } else {
        failure(
          'Error',
          response.body.toString(),
        );
        return null;
      }
    } catch (e) {
      failure('Error in sub gender', e.toString());
      return null;
    }
  }
}