import 'dart:convert';

import 'package:dating_application/Models/RequestModels/user_registration_request_model.dart';
import 'package:dating_application/Models/ResponseModels/user_registration_response_model.dart';
import 'package:dating_application/constants.dart';
import 'package:get/get.dart';

class UserRegistrationProvider extends GetConnect {
  Future<UserRegistrationResponse?> userRegistration(
      UserRegistrationRequest userRegistrationRequest) async {
    try {
      print('Name: ${userRegistrationRequest.name}');
      print('Email: ${userRegistrationRequest.email}');
      print('Mobile: ${userRegistrationRequest.mobile}');
      print('Latitude: ${userRegistrationRequest.latitude}');
      print('Longitude: ${userRegistrationRequest.longitude}');
      print('Address: ${userRegistrationRequest.address}');
      print('Password: ${userRegistrationRequest.password}');
      print('Country ID: ${userRegistrationRequest.countryId}');
      print('State: ${userRegistrationRequest.state}');
      print('City: ${userRegistrationRequest.city}');
      print('Date of Birth: ${userRegistrationRequest.dob}');
      print('Nickname: ${userRegistrationRequest.nickname}');
      print('Gender: ${userRegistrationRequest.gender}');
      print('Sub-Gender: ${userRegistrationRequest.subGender}');
      for (var p in userRegistrationRequest.preferences) {
        print('preferences are ${p.toString()}');
      }
      for (var p in userRegistrationRequest.desires) {
        print('desires are ${p.toString()}');
      }
      for (var p in userRegistrationRequest.photos) {
        print('photos are ${p.toString()}');
      }

      print('Interest: ${userRegistrationRequest.interest}');
      print('Bio: ${userRegistrationRequest.bio}');

      print('Package ID: ${userRegistrationRequest.packageId}');
      print('Email Alerts: ${userRegistrationRequest.emailAlerts}');
      print('Username: ${userRegistrationRequest.username}');
      print('Looking For: ${userRegistrationRequest.lookingFor}');
      userRegistrationRequest.state = "1";
      userRegistrationRequest.lookingFor = "1";
      userRegistrationRequest.emailAlerts = "1";
      userRegistrationRequest.packageId = "1";
      userRegistrationRequest.interest = "timepass";

      Response response = await post(
        '$baseurl/Authentication/register',
        userRegistrationRequest.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      print(response.statusCode);
      print(response.body.toString());
      if (response.statusCode == 200) {
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
