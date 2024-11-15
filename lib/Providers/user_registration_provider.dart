import 'package:dating_application/Models/RequestModels/user_registration_request_model.dart';
import 'package:dating_application/Models/ResponseModels/user_registration_response_model.dart';
import 'package:dating_application/constants.dart';
import 'package:get/get.dart';

class UserRegistrationProvider extends GetConnect{
  Future<UserRegistrationResponse?> userRegistration(UserRegistrationRequest userRegistrationRequest) async{
    try {
        Response response = await post(
          '$baseurl/Authentication/register',
          userRegistrationRequest,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );

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