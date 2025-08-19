import 'package:get/get.dart';
import 'package:dating_application/constants.dart';
import 'package:dating_application/Models/ResponseModels/creator_transaction_history_response.dart';
import 'package:encrypt_shared_preferences/provider.dart';
class CreatorTransactionHistoryProvider extends GetConnect {
  Future<CreatorTransactionHistoryResponse?>
      fetchCreatorTransactionHistory() async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');

      if (token != null && token.isNotEmpty) {
        final response = await get(
          '$springbooturl/creator/creator-trans-history',
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == null || response.body == null) {
          failure('Error in unknown_method', 'Server Failed To Respond');
          return null;
        }

        if (response.statusCode == 200) {
          return CreatorTransactionHistoryResponse.fromJson(response.body);
        } else {
          failure('Error in unknown_method', response.body.toString());
          return null;
        }
      } else {
        failure('Error in unknown_method', 'Token not found');
        return null;
      }
    } catch (e) {
      failure('Error in unknown_method', e.toString());
      return null;
    }
  }
}
