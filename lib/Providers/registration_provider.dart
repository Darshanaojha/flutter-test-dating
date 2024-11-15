import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';

final String baseUrl = "http://192.168.1.22/dating_backend_springboot/admin";

// Countries
class RegistrationProvider extends GetConnect{
    Future<bool> fetchCountries() async {
    try {
      final response = await get(Uri.parse('$baseUrl/Common/country'));
      final jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if(jsonResponse['error']['code']==0){
          debugPrint('Country: ${jsonResponse['payload']['data']}');
          return true;
        }
        else{
          debugPrint("Error occured in Countries: ${jsonResponse['error']['message']} Status: ${jsonResponse['error']['code']}");
          return false;
        }
      } else {
        debugPrint('Failed to load Countries. Status code: ${response.statusCode}');
       debugPrint("${jsonResponse['error']['message']}");
        return false;
      }
    } catch (e) {
      debugPrint('An error occurred in Countries: $e');
      return false;
    }
  }

  // Verify Email using OTP
  Future<bool> getOtp(dynamic data) async {
    try {
      final response = await post(
          Uri.parse('$baseUrl/Authentication/sendotp'),
          body: jsonEncode(data));
      final jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (jsonResponse['error']['code'] == 0) {
          debugPrint('Get OTP for Verify Email: ${jsonResponse['payload']['message']}');
          return true;
        } else {
          debugPrint(
              "Error occured in Get OTP for Verify Email: ${jsonResponse['error']['message']} Status: ${jsonResponse['error']['code']}");
          return false;
        }
      } else {
        debugPrint(
            'Failed to load Get OTP for Verify Email. Status code: ${response.statusCode}');
        debugPrint("${jsonResponse['error']['message']}");
        return false;
      }
    } catch (e) {
      debugPrint('An error occurred in Get OTP for Verify Email: $e');
      return false;
    }
  }

 // Verify password while registration
 Future<bool> otpVerification(dynamic data) async {
    try {
      final response = await post(
          Uri.parse('$baseUrl/Authentication/verifyotp'),
          body: jsonEncode(data));
      if (response.body.isEmpty) {
        debugPrint('Empty response body.');
        return false;
      }
      final jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (jsonResponse['error']['code'] == 0) {
          debugPrint('OTP Verification for registration: ${jsonResponse['payload']['message']}');
          return true;
        } else {
          debugPrint(
              "Error occured in OTP Verification for registration: ${jsonResponse['error']['message']} Status: ${jsonResponse['error']['code']}");
          return false;
        }
      } else {
        debugPrint(
            'Failed to load OTP Verification for registration. Status code: ${response.statusCode}');
        debugPrint("${jsonResponse['error']['message']}");
        return false;
      }
    } catch (e) {
      debugPrint('An error occurred in OTP Verification for registration: $e');
      return false;
    }
  }

  // User Registration
  Future<bool> userLogin(Map<String, dynamic> data) async {
    try {
      final response =
          await post(Uri.parse('$baseUrl/Authentication/register'), body: jsonEncode(data));
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