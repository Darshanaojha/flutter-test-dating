import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';
import '../Models/ResponseModels/GetAllCreatorsResponse.dart';
import '../constants.dart';
class GetAllCreatorsProvider extends GetConnect {
  Future<GetAllCreatorsResponse?> getAllCreators() async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');

      if (token == null || token.isEmpty) {
        failure('Error in getAllCreators', 'Token not found');
        return null;
      }
      Response response = await get(
        '$springbooturl/creator/get-all-creators',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == null || response.body == null) {
        failure('Error in getAllCreators', 'Server Failed To Respond');
        return null;
      }
      if (response.statusCode == 200) {
        return GetAllCreatorsResponse.fromJson(response.body);
      } else {
        failure(
          'Error',
          response.body.toString(),
        );
        return null;
      }
    } catch (e) {
      failure('Error in getAllCreators', e.toString());
      return null;
    }
  }
}
