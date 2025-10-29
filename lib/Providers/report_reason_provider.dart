import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get_connect.dart';
import '../Models/ResponseModels/get_report_user_options_response_model.dart';
import '../constants.dart';
class ReportReasonProvider extends GetConnect {
  Future<ReportUserForBlockOptionsResponseModel?> reportReason() async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');

      if (token == null || token.isEmpty) {
        failure('Error in reportReason', 'Token not found');
        return null;
      }

      Response response = await get(
        '$baseurl/Chats/report_reason',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == null || response.body == null) {
        failure('Error in reportReason', 'Server Failed To Respond');
        return null;
      }
      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return ReportUserForBlockOptionsResponseModel.fromJson(response.body);
        } else {
          failure('Error in reportReason', response.body['error']['message']);
          return null;
        }
      } else {
        failure(response.statusCode, response.body['error']['message']);
        return null;
      }
    } catch (e) {
      failure('Error in reportReason', e.toString());
      return null;
    }
  }
}
