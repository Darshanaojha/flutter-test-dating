import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Models/ResponseModels/user_suggestions_response_model.dart';
import '../constants.dart';
import 'package:flutter/foundation.dart';



class UserSuggestionsProvider extends GetConnect {
  Future<UserSuggestionsResponseModel?> userSuggestions() async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');

      if (token == null || token.isEmpty) {
        failure('Error in userSuggestions', 'Token not found');
        return null;
      }
      Response response = await get(
        '$baseurl/Chats/user_suggestions',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      debugPrint('User Suggestions Response: ${response.body.toString()}');
      if (response.statusCode == null || response.body == null) {
        failure('Error in userSuggestions', 'Server Failed To Respond');
        return null;
      }

      if (response.statusCode == 200 && response.body != null) {
        if (response.body['error']['code'] == 0) {
          debugPrint(
              "user suggestion response in provider = ${response.body.toString()}");
          return UserSuggestionsResponseModel.fromJson(response.body);
        } else {
          failure('Error in userSuggestions', response.body['error']['message']);
          return null;
        }
      } else {
        failure(response.statusCode, response.body['error']['message']);
        return null;
      }
    } catch (e) {
      failure('Error in userSuggestions', e.toString());
      return null;
    }
  }
}
