import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';

final String baseUrl = "http://192.168.1.22/dating_backend_springboot/admin";

class UserProfileProvider extends GetConnect {
  // Gender
  Future<bool> fetchGenders() async {
    try {
      final response = await get(Uri.parse('$baseUrl/Common/gender'));
      final jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (jsonResponse['error']['code'] == 0) {
          debugPrint('Gender: ${jsonResponse['payload']['data']}');
          return true;
        } else {
          debugPrint(
              "Error occured in Gender: ${jsonResponse['error']['message']} Status: ${jsonResponse['error']['code']}");
          return false;
        }
      } else {
        debugPrint(
            'Failed to load Gender. Status code: ${response.statusCode}');
        debugPrint("${jsonResponse['error']['message']}");
        return false;
      }
    } catch (e) {
      debugPrint('An error occurred in Gender: $e');
      return false;
    }
  }

  //Preferences
  Future<bool> fetchPreferences() async {
    try {
      final response = await get(Uri.parse('$baseUrl/Common/all_preferences'));
      final jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (jsonResponse['error']['code'] == 0) {
          debugPrint('Preferences: ${jsonResponse['payload']['data']}');
          return true;
        } else {
          debugPrint(
              "Error occurred in Preferences: ${jsonResponse['error']['message']} Status: ${jsonResponse['error']['code']}");
          return false;
        }
      } else {
        debugPrint(
            'Failed to load Preferences. Status code: ${response.statusCode}');
        debugPrint("${jsonResponse['error']['message']}");
        return false;
      }
    } catch (e) {
      debugPrint('An error occurred in Preferences: $e');
      return false;
    }
  }

// Benifits
  Future<bool> fetchBenefits() async {
    try {
      final response = await get(Uri.parse('$baseUrl/Common/all_benefits'));
      final jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (jsonResponse['error']['code'] == 0) {
          debugPrint('Benefits: ${jsonResponse['payload']['data']}');
          return true;
        } else {
          debugPrint(
              "Error occurred in Benefits: ${jsonResponse['error']['message']} Status: ${jsonResponse['error']['code']}");
          return false;
        }
      } else {
        debugPrint(
            'Failed to load Benefits. Status code: ${response.statusCode}');
        debugPrint("${jsonResponse['error']['message']}");
        return false;
      }
    } catch (e) {
      debugPrint('An error occurred in Benefits: $e');
      return false;
    }
  }

// Safety Guidelines
  Future<bool> fetchSafetyGuidelines() async {
    try {
      final response =
          await get(Uri.parse('$baseUrl/Common/all_safety_guidelines'));
      final jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (jsonResponse['error']['code'] == 0) {
          debugPrint('Safety Guidelines: ${jsonResponse['payload']['data']}');
          return true;
        } else {
          debugPrint(
              "Error occurred in Safety Guidelines: ${jsonResponse['error']['message']} Status: ${jsonResponse['error']['code']}");
          return false;
        }
      } else {
        debugPrint(
            'Failed to load Safety Guidelines. Status code: ${response.statusCode}');
        debugPrint("${jsonResponse['error']['message']}");
        return false;
      }
    } catch (e) {
      debugPrint('An error occurred in Safety Guidelines: $e');
      return false;
    }
  }

// Headlines
  Future<bool> fetchHeadlines() async {
    try {
      final response = await get(Uri.parse('$baseUrl/Common/all_headlines'));
      final jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (jsonResponse['error']['code'] == 0) {
          debugPrint('Headlines: ${jsonResponse['payload']['data']}');
          return true;
        } else {
          debugPrint(
              "Error occurred in Headlines: ${jsonResponse['error']['message']} Status: ${jsonResponse['error']['code']}");
          return false;
        }
      } else {
        debugPrint(
            'Failed to load Headlines. Status code: ${response.statusCode}');
        debugPrint("${jsonResponse['error']['message']}");
        return false;
      }
    } catch (e) {
      debugPrint('An error occurred in Headlines: $e');
      return false;
    }
  }

// Sub Gender
  Future<bool> fetchSubGender(String id) async {
    try {
      final response = await post(Uri.parse('$baseUrl/Common/sub_gender'),
          body: jsonEncode({
            "gender_id": id,
          }));
      final jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (jsonResponse['error']['code'] == 0) {
          debugPrint('Headlines: ${jsonResponse['payload']['data']}');
          return true;
        } else {
          debugPrint(
              "Error occurred in Sub Gender: ${jsonResponse['error']['message']} Status: ${jsonResponse['error']['code']}");
          return false;
        }
      } else {
        debugPrint(
            'Failed to load Sub Gender. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint("An error occurred in Sub Gender: $e");
      return false;
    }
  }

  final token =
      "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJUaGVfY2xhaW0iLCJhdWQiOiJUaGVfQXVkIiwiaWF0IjoxNzMxMzk4MDUyLCJuYmYiOjE3MzEzOTgwNTIsImV4cCI6MTczMzk5MDA1MiwiZGF0YSI6WyIyOSIsInVzZXIiLCIzIl19.9BehUe9zCCEia9UU2EguEJygGY-Hxe968Rawm7dvnYc";

  // User Uploaded Photo
  Future<bool> fetchProfileUserPhotos() async {
    try {
      final response = await get(
        Uri.parse('$baseUrl/Profile/userphotos'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      final jsonResponse = jsonDecode(response.body);
      debugPrint(jsonResponse);
      if (response.statusCode == 200) {
        if (jsonResponse['error']['code'] == 0) {
          debugPrint('Profile User Photo: ${jsonResponse['payload']['data']}');
          return true;
        } else {
          debugPrint(
              "Error occurred in Profile User Photo: ${jsonResponse['error']['message']} Status: ${jsonResponse['error']['code']}");
          return false;
        }
      } else {
        debugPrint(
            'Failed to load Profile User Photo. Status code: ${response.statusCode}');
        debugPrint("${jsonResponse['error']['message']}");
        return false;
      }
    } catch (e) {
      debugPrint('An error occurred in Profile User Photo: $e');
      return false;
    }
  }

   // Update Email 
  Future<bool> updateEmail(Map<String,dynamic> data) async {
    try {
      final response = await post(
          Uri.parse('$baseUrl/Profile/update_email'), headers: {
          'Authorization': 'Bearer $token',
        },
          body: data);
      final jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (jsonResponse['error']['code'] == 0) {
          debugPrint('Update Email: ${jsonResponse['payload']['message']}');
          return true;
        } else {
          debugPrint(
              "Error occured in Update Email: ${jsonResponse['error']['message']} Status: ${jsonResponse['error']['code']}");
          return false;
        }
      } else {
        debugPrint(
            'Failed to load Update Email. Status code: ${response.statusCode}');
        debugPrint("${jsonResponse['error']['message']}");
        return false;
      }
    } catch (e) {
      debugPrint('An error occurred in Update Email: $e');
      return false;
    }
  }
}
