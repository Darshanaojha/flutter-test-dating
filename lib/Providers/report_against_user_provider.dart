import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get_connect.dart';

import '../Models/RequestModels/report_user_reason_feedback_request_model.dart';
import '../Models/ResponseModels/report_user_reason_feedback_response_model.dart';
import '../constants.dart';

class ReportUserProvider extends GetConnect {
  Future<ReportUserReasonFeedbackResponseModel?> reportAgainstUser(
      ReportUserReasonFeedbackRequestModel
          reportUserReasonFeedbackRequestModel) async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');

      if (token == null || token.isEmpty) {
        failure('Error', 'Token not found');
        return null;
      }

      Response response = await post(
        '$baseurl/Chats/report_against_user',
        reportUserReasonFeedbackRequestModel.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return ReportUserReasonFeedbackResponseModel.fromJson(response.body);
        } else {
          failure('Error', response.body['error']['message']);
          return null;
        }
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
