import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';
import '../Models/RequestModels/homepage_dislike_request_model.dart';
import '../Models/ResponseModels/homepage_dislike_response_model.dart';
import '../constants.dart';

class HomePageDislikeProvider extends GetConnect {
  Future<HomepageDislikeResponse?> homePageDislikeProvider(
      HomepageDislikeRequest homepageDislikeRequest) async {
    try {
      EncryptedSharedPreferences preferences =
          await EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');

      if (token == null || token.isEmpty) {
        failure('Error', 'Token not found');
        return null;
      }

      print("Request to API: ${homepageDislikeRequest.toJson()}");

      Response response = await post(
        '$baseurl/profile/profile_dislike_homepage',
        homepageDislikeRequest.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      print("API Response status: ${response.statusCode}");
      print("API Response body: ${response.body}");

      if (response.statusCode == 200) {
        if (response.body != null && response.body is Map<String, dynamic>) {
          return HomepageDislikeResponse.fromJson(response.body);
        } else {
          print("Invalid response body format");
          failure('Error', 'Invalid response format received');
          return null;
        }
      } else {
        failure(
            'Error', 'API responded with status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print("An error occurred: $e");
      failure('Error', 'An error occurred: ${e.toString()}');
      return null;
    }
  }
}
