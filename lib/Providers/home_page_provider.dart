import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';

final String baseUrl = "http://192.168.1.22/dating_backend_springboot/admin";

class HomePageProvider extends GetConnect {
  // Desires
  Future<bool> fetchDesires() async {
    try {
      final response = await get(Uri.parse('$baseUrl/Common/all_desires'));
      final jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (jsonResponse['error']['code'] == 0) {
          debugPrint('Desires: ${jsonResponse['payload']['data']}');
          return true;
        } else {
          debugPrint(
              "Error occurred in Desires: ${jsonResponse['error']['message']} Status: ${jsonResponse['error']['code']}");
          return false;
        }
      } else {
        debugPrint(
            'Failed to load Desires. Status code: ${response.statusCode}');
        debugPrint("${jsonResponse['error']['message']}");
        return false;
      }
    } catch (e) {
      debugPrint('An error occurred in Desires: $e');
      return false;
    }
  }

  final token =
      "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJUaGVfY2xhaW0iLCJhdWQiOiJUaGVfQXVkIiwiaWF0IjoxNzMxMzk4MDUyLCJuYmYiOjE3MzEzOTgwNTIsImV4cCI6MTczMzk5MDA1MiwiZGF0YSI6WyIyOSIsInVzZXIiLCIzIl19.9BehUe9zCCEia9UU2EguEJygGY-Hxe968Rawm7dvnYc";
// Profiles
  Future<bool> fetchProfile() async {
    try {
      final response = await get(
        Uri.parse('$baseUrl/Profile/profile'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      final jsonResponse = jsonDecode(response.body);
      debugPrint(jsonResponse);
      if (response.statusCode == 200) {
        if (jsonResponse['error']['code'] == 0) {
          debugPrint('Profile: ${jsonResponse['payload']['data']}');
          return true;
        } else {
          debugPrint(
              "Error occurred in Profile: ${jsonResponse['error']['message']} Status: ${jsonResponse['error']['code']}");
          return false;
        }
      } else {
        debugPrint(
            'Failed to load Profile. Status code: ${response.statusCode}');
        debugPrint("${jsonResponse['error']['message']}");
        return false;
      }
    } catch (e) {
      debugPrint('An error occurred in Profile: $e');
      return false;
    }
  }

  // All Active Users
  Future<bool> fetchAllActiveUsers() async {
    try {
      final response = await post(
        Uri.parse('$baseUrl/Profile/fetch_all_active_user'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      final jsonResponse = jsonDecode(response.body);
      debugPrint(jsonResponse);
      if (response.statusCode == 200) {
        if (jsonResponse['error']['code'] == 0) {
          debugPrint('All Active Users: ${jsonResponse['payload']['data']}');
          return true;
        } else {
          debugPrint(
              "Error occurred in All Active Users: ${jsonResponse['error']['message']} Status: ${jsonResponse['error']['code']}");
          return false;
        }
      } else {
        debugPrint(
            'Failed to load All Active Users. Status code: ${response.statusCode}');
        debugPrint("${jsonResponse['error']['message']}");
        return false;
      }
    } catch (e) {
      debugPrint('An error occurred in All Active Users: $e');
      return false;
    }
  }
}
