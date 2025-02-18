import 'package:dating_application/Models/RequestModels/user_registration_request_model.dart';
import 'package:dating_application/Models/ResponseModels/user_registration_response_model.dart';
import 'package:dating_application/constants.dart';
import 'package:get/get.dart';

class UserRegistrationProvider extends GetConnect {
  Future<UserRegistrationResponse?> userRegistration(
      UserRegistrationRequest userRegistrationRequest) async {
    print('=======');

    print('name: ${userRegistrationRequest.name}');
    print('email: ${userRegistrationRequest.email}');
    print('mobile: ${userRegistrationRequest.mobile}');
    print('latitude: ${userRegistrationRequest.latitude}');
    print('longitude: ${userRegistrationRequest.longitude}');
    print('address: ${userRegistrationRequest.address}');
    print('password: ${userRegistrationRequest.password}');
    print('countryId: ${userRegistrationRequest.countryId}');
    print('city: ${userRegistrationRequest.city}');
    print('dob: ${userRegistrationRequest.dob}');
    print('nickname: ${userRegistrationRequest.nickname}');
    print('gender: ${userRegistrationRequest.gender}');
    print('subGender: ${userRegistrationRequest.subGender}');
    print('preferences: ${userRegistrationRequest.preferences}');
    print('desires: ${userRegistrationRequest.desires}');
    print('interest: ${userRegistrationRequest.interest}');
    print('bio: ${userRegistrationRequest.bio}');
    print('imgcount: ${userRegistrationRequest.imgcount}');
    print('lang: ${userRegistrationRequest.lang}');
    print('photos: ${userRegistrationRequest.photos}');
    print('emailAlerts: ${userRegistrationRequest.emailAlerts}');
    print('username: ${userRegistrationRequest.username}');
    print('lookingFor: ${userRegistrationRequest.lookingFor}');
    try {
      Response response = await post(
        '$baseurl/Authentication/register',
        userRegistrationRequest.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

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
