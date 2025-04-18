import 'package:dating_application/Models/ResponseModels/dislike_profile_response_model.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';
import '../Models/RequestModels/dislike_profile_request_model.dart';
import '../constants.dart';

class DislikeProfileProvider extends GetConnect {
  Future<DislikeProfileResponse?> dislikeProfileProvider(
      DislikeProfileRequest dislikeProfileRequest) async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');

      if (token == null || token.isEmpty) {
        failure('Error', 'Token not found');
        return null;
      }
      Get.snackbar(
          "request dislike", dislikeProfileRequest.toJson().toString());
      print(
        "request dislike${dislikeProfileRequest.toJson().toString()}",
      );
      Response response = await post(
        '$baseurl/profile/profile_dislike',
        dislikeProfileRequest.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      Get.snackbar("response dislike", response.body.toString());
      print(
        "response dislike${response.body.toString()}",
      );

      if (response.statusCode == null || response.body == null) {
        failure('Error', 'Server Failed To Respond');
        return null;
      }
      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return DislikeProfileResponse.fromJson(response.body);
        } else {
          failure('Error', response.body['error']['message']);
          return null;
        }
      } else {
        failure(response.statusCode, response.body['error']['message']);
        return null;
      }
    } catch (e) {
      failure('Error', e.toString());
      return null;
    }
  }
}
