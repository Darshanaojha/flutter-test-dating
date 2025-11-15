import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';
import '../Models/ResponseModels/ProfileResponse.dart';
import '../Models/ResponseModels/all_active_user_resposne_model.dart';
import '../Models/ResponseModels/get_all_desires_model_response.dart';
import '../constants.dart';

class HomePageProvider extends GetConnect {
  Future<DesiresResponse?> fetchDesires() async {
    try {
      Response response = await get('$baseurl/Common/all_desires');

      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return DesiresResponse.fromJson(response.body);
        } else {
          failure('Error in fetchDesires', response.body['error']['message']);
          return null;
        }
      } else {
        failure('Error in fetchDesires', response.body['error']['message']);
        return null;
      }
    } catch (e) {
      failure('Exception in fetchDesires', e.toString());
      return null;
    }
  }

  Future<UserProfileResponse?> fetchProfile([String id = ""]) async {
    try {
      EncryptedSharedPreferences preferences = EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');
      if (token == null || token.isEmpty) {
        failure('Error in fetchProfile', 'Token not found');
        return null;
      }

      Response response = await get(
        '$baseurl/Profile/profile/$id',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (id == "") print("User Profile Response: ${response.body.toString()}");
      if (response.statusCode == null || response.body == null) {
        failure('Error in fetchProfile', 'Server Failed To Respond');
        return null;
      }
      print("Profile : ${response.body.toString()}");
      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return UserProfileResponse.fromJson(response.body);
        } else {
          failure('Error in fetchProfile', response.body['error']['message']);
          return null;
        }
      } else {
        failure('Error in fetchProfile', response.body['error']['message']);
        return null;
      }
    } catch (e) {
      failure('Exception in fetchProfile', e.toString());
      return null;
    }
  }

  Future<AllActiveUsersResponse?> fetchAllActiveUsers() async {
    try {
      EncryptedSharedPreferences preferences = EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');
      if (token == null || token.isEmpty) {
        failure('Error in fetchAllActiveUsers', 'Token not found');
        return null;
      }

      Response response = await post(
        '$baseurl/Profile/fetch_all_active_user',
        null,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('ooooo: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return AllActiveUsersResponse.fromJson(response.body);
        } else {
          failure('Error in fetchAllActiveUsers', response.body['error']['message']);
          return null;
        }
      } else {
        failure('Error in fetchAllActiveUsers', response.body['error']['message']);
        return null;
      }
    } catch (e) {
      failure('Exception in fetchAllActiveUsers', e.toString());
      return null;
    }
  }
}
