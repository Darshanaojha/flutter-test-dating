import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get_connect/connect.dart';

import '../Models/RequestModels/update_lat_long_request_model.dart';
import '../Models/ResponseModels/update_lat_long_response_model.dart';
import '../constants.dart';

class UpdateLatitudeLongitudeProvider extends GetConnect {
  Future<UpdateLatLongResponse?> updatelatlong(
      UpdateLatLongRequest reportUserReasonFeedbackRequestModel) async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');

      if (token == null || token.isEmpty) {
        failure('Error', 'Token not found');
        return null;
      }
      print(reportUserReasonFeedbackRequestModel.toJson().toString());
      Response response = await post(
        '$baseurl/Users/update_latitude_longitude',
        reportUserReasonFeedbackRequestModel.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == null || response.body == null) {
        failure('Error', 'Server Failed To Respond');
        return null;
      }
      print(response.body.toString());
      if (response.statusCode == 200) {
        return UpdateLatLongResponse.fromJson(response.body);
      } else {
        failure(response.statusCode, response.body['error']['message']);
        return null;
      }
    } catch (e) {
      failure('Error', e.toString());
      return null;
    }
  }
}
