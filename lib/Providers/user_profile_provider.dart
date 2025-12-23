import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';
import '../Models/ResponseModels/user_upload_images_response_model.dart';
import '../constants.dart';
class UserProfileProvider extends GetConnect {
  Future<UserUploadImagesResponse?> fetchProfileUserPhotos(String id) async {
    print("id in fetchProfileUserPhotos: $id");
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');
      print("token in fetchProfileUserPhotos: $token");
      if (token == null || token.isEmpty) {
        failure('Error in fetchProfileUserPhotos', 'Token not found');
        return null;
      }
      Response response = await get(
        '$baseurl/Profile/userphotos/$id',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      print("response body in fetchProfileUserPhotos: ${response.body}");
      if (response.statusCode == null || response.body == null) {
        failure('Error in fetchProfileUserPhotos', 'Server Failed To Respond');
        return null;
      }

      if (response.statusCode == 200) {
        // Safely check if response.body is a Map
        if (response.body is! Map<String, dynamic>) {
          failure('Error in user photo', 'Invalid response format: expected Map, got ${response.body.runtimeType}');
          return null;
        }
        
        final Map<String, dynamic> body = response.body as Map<String, dynamic>;
        
        // Safely check error structure
        if (body['error'] is! Map<String, dynamic>) {
          failure('Error in user photo', 'Invalid error format: expected Map, got ${body['error']?.runtimeType}');
          return null;
        }
        
        final Map<String, dynamic> error = body['error'] as Map<String, dynamic>;
        
        if (error['code'] == 0) {
          try {
            final result = UserUploadImagesResponse.fromJson(body);
            // Debug: Check image data quality
            if (result.payload?.data?.images != null) {
              print('📸 Fetched ${result.payload!.data!.images.length} images');
              for (int i = 0; i < result.payload!.data!.images.length; i++) {
                final img = result.payload!.data!.images[i];
                print('📸 Image $i: length=${img.length}, starts with: ${img.substring(0, img.length > 20 ? 20 : img.length)}...');
                // Check if it's a valid base64 or URL
                if (img.startsWith('http')) {
                  print('📸 Image $i: Network URL');
                } else if (img.length > 50) {
                  print('📸 Image $i: Base64 (${img.length} chars)');
                } else {
                  print('⚠️ Image $i: Suspiciously short (${img.length} chars) - might be corrupted');
                }
              }
            }
            return result;
          } catch (e) {
            failure('Error in user photo', 'Failed to parse response: $e');
            return null;
          }
        } else {
          final errorMessage = error['message']?.toString() ?? 'Unknown error';
          failure('Error in fetchProfileUserPhotos', errorMessage);
          return null;
        }
      } else {
        // failure('Error in fetchProfileUserPhotos', response.body.toString());
        return null;
      }
    } catch (e) {
      failure('Error in user photo', e.toString());
      return null;
    }
  }
}