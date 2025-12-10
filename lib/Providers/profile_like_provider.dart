import 'package:dating_application/Models/RequestModels/profile_like_request_model.dart';
import 'package:dating_application/Models/ResponseModels/profile_like_response_model.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants.dart';

class ProfileLikeProvider extends GetConnect {
  Future<ProfileLikeResponse?> profileLikeProvider(
      ProfileLikeRequest profileLikeRequest) async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');

      if (token == null || token.isEmpty) {
        // failure('Error in profileLikeProvider', 'Token not found'); // Commented out for swipe actions
        return null;
      }

      Response response = await post(
        '$baseurl/Profile/profile_like',
        profileLikeRequest.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == null || response.body == null) {
        debugPrint("Error in profileLikeProvider: ${response.statusCode}");
        return null;
      }

      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return ProfileLikeResponse.fromJson(response.body);
        } else {
          // failure('Oops!', response.body['error']['message']); // Commented out for swipe actions
          debugPrint(
              "Error in profileLikeProvider: ${response.body['error']['message']}");
          return null;
        }
      } else {
        debugPrint(
            "Error in profileLikeProvider: ${response.body['error']['message']}");
        return null;
      }
    } catch (e) {
      // failure('Excep in profileLikeProvider', e.toString()); // Commented out for swipe actions
      return null;
    }
  }
}
