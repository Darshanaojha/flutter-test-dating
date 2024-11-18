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
          failure('Error', response.body['error']['message']);
          return null;
        }
      } else {
        failure('Error', response.body['error']['message']);
        return null;
      }
    } catch (e) {
      failure('Error', e.toString());
      return null;
    }
  }

  Future<ProfileResponse?> fetchProfile() async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');
      if (token == null || token.isEmpty) {
        failure('Error', 'Token not found');
        return null;
      }

      Response response = await get(
        '$baseUrl/Profile/profile',
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return ProfileResponse.fromJson(response.body);
        } else {
          failure('Error', response.body['error']['message']);
          return null;
        }
      } else {
        failure('Error', response.body['error']['message']);
        return null;
      }
    } catch (e) {
      failure('Error', e.toString());
      return null;
    }
  }

  Future<AllActiveUsersResponse?> fetchAllActiveUsers() async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');
      if (token == null || token.isEmpty) {
        failure('Error', 'Token not found');
        return null;
      }

      Response response = await post(
        '$baseUrl/Profile/fetch_all_active_user',
        null,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return AllActiveUsersResponse.fromJson(response.body);
        } else {
          failure('Error', response.body['error']['message']);
          return null;
        }
      } else {
        failure('Error', response.body['error']['message']);
        return null;
      }
    } catch (e) {
      failure('Error', e.toString());
      return null;
    }
  }
}
