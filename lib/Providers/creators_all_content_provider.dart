import 'package:dating_application/Models/ResponseModels/creators_content_model.dart';
import 'package:dating_application/constants.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreatorAllContentProvider extends GetConnect {
  Future<CreatorContentResponse?> fetchCreatorContent() async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');
      if (token == null || token.isEmpty) {
        failure('Error', 'Token not found');
        return null;
      }
      Response response = await get(
        '$springbooturl/creator/by-creator',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      debugPrint("Creator Package : ${response.body}");
      if (response.statusCode == null || response.body == null) {
        failure('Error', 'Server Failed To Respond');
        return null;
      }
      if (response.statusCode == 200) {
        // If 'error' field exists, handle error
        if (response.body is Map && response.body.containsKey('error')) {
          if (response.body['error']['code'] == 0) {
            return CreatorContentResponse.fromJson(response.body);
          } else {
            failure("Error", response.body['error']['message']);
            return null;
          }
        } else {
          // No 'error' field, treat as success
          return CreatorContentResponse.fromJson(response.body);
        }
      } else {
        failure(
          "Error",
          response.body.toString(),
        );
        return null;
      }
    } catch (e) {
      debugPrint(e.toString());
      failure("Error in generic", e.toString());
      return null;
    }
  }
}
