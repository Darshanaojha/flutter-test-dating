import 'package:dating_application/Models/RequestModels/user_registration_request_model.dart';
import 'package:dating_application/Models/ResponseModels/user_registration_response_model.dart';
import 'package:dating_application/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserRegistrationProvider extends GetConnect {
  Future<UserRegistrationResponse?> userRegistration(
      UserRegistrationRequest userRegistrationRequest) async {
    print('=======');

    debugPrint('name: ${userRegistrationRequest.name}');
    debugPrint('email: ${userRegistrationRequest.email}');
    debugPrint('mobile: ${userRegistrationRequest.mobile}');
    debugPrint('latitude: ${userRegistrationRequest.latitude}');
    debugPrint('longitude: ${userRegistrationRequest.longitude}');
    debugPrint('address: ${userRegistrationRequest.address}');
    debugPrint('password: ${userRegistrationRequest.password}');
    debugPrint('countryId: ${userRegistrationRequest.countryId}');
    debugPrint('city: ${userRegistrationRequest.city}');
    debugPrint('dob: ${userRegistrationRequest.dob}');
    debugPrint('referal: ${userRegistrationRequest.referalcode}');
    debugPrint('nickname: ${userRegistrationRequest.nickname}');
    debugPrint('gender: ${userRegistrationRequest.gender}');
    debugPrint('subGender: ${userRegistrationRequest.subGender}');
    debugPrint('preferences: ${userRegistrationRequest.preferences}');
    debugPrint('desires: ${userRegistrationRequest.desires}');
    debugPrint('interest: ${userRegistrationRequest.interest}');
    debugPrint('bio: ${userRegistrationRequest.bio}');
    debugPrint('imgcount: ${userRegistrationRequest.imgcount}');
    debugPrint('lang: ${userRegistrationRequest.lang}');
    debugPrint('photos: ${userRegistrationRequest.photos}');
    debugPrint('emailAlerts: ${userRegistrationRequest.emailAlerts}');
    debugPrint('username: ${userRegistrationRequest.username}');
    debugPrint('lookingFor: ${userRegistrationRequest.lookingFor}');
    try {
      Response response = await post(
        '$baseurl/Authentication/register',
        userRegistrationRequest.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == null || response.body == null) {
        failure('Error', 'Server Failed To Respond');
        return null;
      }

      if (response.statusCode == 200) {
        print(response.body.toString());
        if (response.body['error']['code'] == 0) {
          return UserRegistrationResponse.fromJson(response.body);
        } else {
          failure('Error', response.body['error']['message']);
          return null;
        }
      } else {
        failure('Error', response.body.toString());
        return null;
      }
    } catch (e) {
      failure('Error', e.toString());
      return null;
    }
  }
}
