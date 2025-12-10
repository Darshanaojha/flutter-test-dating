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
        // failure('Error in dislikeProfileProvider', 'Token not found'); // Commented out for swipe actions
        return null;
      }
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
      print(
        "response dislike${response.body.toString()}",
      );

      if (response.statusCode == null || response.body == null) {
        // failure('Error in dislikeProfileProvider', 'Server Failed To Respond'); // Commented out for swipe actions
        return null;
      }
      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return DislikeProfileResponse.fromMap(response.body);
        } else {
          // failure('Error in dislikeProfileProvider',
          //     response.body['error']['message']); // Commented out for swipe actions
          return null;
        }
      } else {
        // failure(
        //     response.statusCode.toString(), response.body['error']['message']); // Commented out for swipe actions
        return null;
      }
    } catch (e) {
      print("Error in DislikeProfileProvider: $e");
      // failure('Errorrr', e.toString()); // Commented out for swipe actions
      return null;
    }
  }
}
