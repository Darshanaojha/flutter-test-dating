import 'package:dating_application/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CheckUsernameProvider extends GetConnect {
  Future<Map<String, dynamic>?> checkUsernameAvailability(String username) async {
    try {
      print("📤 Checking username availability: $username");
      print("📤 Request URL: $baseurl/Authentication/check_username_availability/$username");
      
      Response response = await get(
        '$baseurl/Authentication/check_username_availability/$username',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      
      print("📥 Response status: ${response.statusCode}");
      print("📥 Response body: ${response.body}");
      
      if (response.statusCode == null || response.body == null) {
        failure('Error in checkUsernameAvailability', 'Server Failed To Respond');
        return null;
      }

      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          // Check the payload message to determine availability
          String? payloadMessage = response.body['payload']?['message']?.toString().toLowerCase();
          bool isAvailable = payloadMessage != null && 
                            (payloadMessage.contains('available') || 
                             payloadMessage.contains('is available'));
          
          return {
            'available': isAvailable,
            'message': response.body['payload']?['message'] ?? 
                      response.body['error']?['message'] ?? 
                      'Username check completed',
          };
        } else {
          failure('Error in checkUsernameAvailability', response.body['error']['message']);
          return {
            'available': false,
            'message': response.body['error']['message'] ?? 'Username not available',
          };
        }
      } else if (response.statusCode == 409) {
        // Username already exists - not available
        String errorMessage = response.body['error']?['message'] ?? 'Username already exists';
        return {
          'available': false,
          'message': errorMessage,
        };
      } else {
        failure('Error in checkUsernameAvailability', 'Status code: ${response.statusCode}');
        return {
          'available': false,
          'message': response.body['error']?['message'] ?? 'Username not available',
        };
      }
    } catch (e) {
      failure('Error in checkUsernameAvailability EXCEPTION', e.toString());
      return null;
    }
  }
}
