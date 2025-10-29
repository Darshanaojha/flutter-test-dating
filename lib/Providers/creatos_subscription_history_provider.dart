import 'package:get/get.dart';
import 'package:dating_application/constants.dart';
import 'package:dating_application/Models/ResponseModels/creators_subscription_history_response.dart';
import 'package:encrypt_shared_preferences/provider.dart';


class CreatorsSubscriptionHistoryProvider extends GetConnect {
  Future<CreatorSubscriptionHistoryResponse?>
      fetchCreatorsSubscriptionHistory() async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');

      if (token != null && token.isNotEmpty) {
        final response = await get(
          '$springbooturl/creator/creator-sub-history',
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == null || response.body == null) {
          failure('Error in fetchCreatorsSubscriptionHistory', 'Server Failed To Respond');
          return null;
        }

        if (response.statusCode == 200) {
          return CreatorSubscriptionHistoryResponse.fromJson(response.body);
        } else {
          failure('Error in fetchCreatorsSubscriptionHistory', response.body.toString());
          return null;
        }
      } else {
        failure('Error in fetchCreatorsSubscriptionHistory', 'Token not found');
        return null;
      }
    } catch (e) {
      failure('Error in fetchCreatorsSubscriptionHistory', e.toString());
      return null;
    }
  }
}
