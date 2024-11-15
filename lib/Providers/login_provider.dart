import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';

final String baseUrl = "http://192.168.1.22/dating_backend_springboot/admin";

class LoginProvider extends GetConnect {

    // Reset Password for Forget Password using OTP
  Future<bool> getOtp(dynamic data) async {
    try {
      final response = await post(
          Uri.parse('$baseUrl/Profile/forget_password'),
          body: jsonEncode(data));
      if (response.body.isEmpty) {
        debugPrint('Empty response body.');
        return false;
      }
      final jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (jsonResponse['error']['code'] == 0) {
          debugPrint('Get OTP for forget password: ${jsonResponse['payload']['message']}');
          return true;
        } else {
          debugPrint(
              "Error occured in Get OTP for forget password: ${jsonResponse['error']['message']} Status: ${jsonResponse['error']['code']}");
          return false;
        }
      } else {
        debugPrint(
            'Failed to load Get OTP for forget password. Status code: ${response.statusCode}');
        debugPrint("${jsonResponse['error']['message']}");
        return false;
      }
    } catch (e) {
      debugPrint('An error occurred in Get OTP for forget password: $e');
      return false;
    }
  }

  // OTP Verification to reset password
  Future<bool> otpVerification(dynamic data) async {
    try {
      final response = await post(
          Uri.parse('$baseUrl/Profile/forget_password_otp_verification'),
          body: jsonEncode(data));
      if (response.body.isEmpty) {
        debugPrint('Empty response body.');
        return false;
      }
      final jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (jsonResponse['error']['code'] == 0) {
          debugPrint('OTP Verification to reset password: ${jsonResponse['payload']['message']}');
          return true;
        } else {
          debugPrint(
              "Error occured in OTP Verification to reset password: ${jsonResponse['error']['message']} Status: ${jsonResponse['error']['code']}");
          return false;
        }
      } else {
        debugPrint(
            'Failed to load OTP Verification to reset password. Status code: ${response.statusCode}');
        debugPrint("${jsonResponse['error']['message']}");
        return false;
      }
    } catch (e) {
      debugPrint('An error occurred in OTP Verification to reset password: $e');
      return false;
    }
  }

    final token =
      "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJUaGVfY2xhaW0iLCJhdWQiOiJUaGVfQXVkIiwiaWF0IjoxNzMxMzk4MDUyLCJuYmYiOjE3MzEzOTgwNTIsImV4cCI6MTczMzk5MDA1MiwiZGF0YSI6WyIyOSIsInVzZXIiLCIzIl19.9BehUe9zCCEia9UU2EguEJygGY-Hxe968Rawm7dvnYc";

  // Change Password
   Future<bool> changePassword(Map<String,dynamic> data) async {
    try {
      final response = await post(
          Uri.parse('$baseUrl/Profile/change_password'),headers: {
          'Authorization': 'Bearer $token',
        },
          body: data);
      if (response.body.isEmpty) {
        debugPrint('Empty response body.');
        return false;
      }
      final jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (jsonResponse['error']['code'] == 0) {
          debugPrint('Change Password: ${jsonResponse['payload']['message']}');
          return true;
        } else {
          debugPrint(
              "Error occured in Change Password: ${jsonResponse['error']['message']} Status: ${jsonResponse['error']['code']}");
          return false;
        }
      } else {
        debugPrint(
            'Failed to load Change Password. Status code: ${response.statusCode}');
        debugPrint("${jsonResponse['error']['message']}");
        return false;
      }
    } catch (e) {
      debugPrint('An error occurred in Change Password: $e');
      return false;
    }
  }

  // User Login
  Future<bool> userLogin(Map<String, dynamic> data) async {
    try {
      final response =
          await post(Uri.parse('$baseUrl/Authentication/login'), body: jsonEncode(data));
      final jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (jsonResponse['error']['code'] == 0) {
          debugPrint('User Login: ${jsonResponse['payload']}');
          return true;
        } else {
          debugPrint(
              "Error occured in User Login: ${jsonResponse['error']['message']} Status: ${jsonResponse['error']['code']}");
          return false;
        }
      } else {
        debugPrint(
            'Failed to load User Login. Status code: ${response.statusCode}');
        debugPrint("${jsonResponse['error']['message']}");
        return false;
      }
    } catch (e) {
      debugPrint('An error occurred in User Login: $e');
      return false;
    }
  }
}
