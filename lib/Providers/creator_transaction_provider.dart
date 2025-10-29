import 'package:get/get.dart';
import 'package:dating_application/constants.dart';
import 'package:dating_application/Models/RequestModels/creator_transaction_request.dart';
import 'package:dating_application/Models/ResponseModels/creator_transaction_response.dart';
import 'package:encrypt_shared_preferences/provider.dart';
class CreatorTransactionProvider extends GetConnect {
  Future<CreatorTransactionResponse?> createTransaction(CreatorTransactionRequest request) async {
    try {
      EncryptedSharedPreferences preferences = EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');

      if (token != null && token.isNotEmpty) {
        final response = await post(
          '$springbooturl/creator/transaction',
          request.toJson(),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == null || response.body == null) {
          failure('Error in createTransaction', 'Server Failed To Respond');
          return null;
        }

        if (response.statusCode == 200) {
          return CreatorTransactionResponse.fromJson(response.body);
        } else {
          failure('Error in createTransaction', response.body.toString());
          return null;
        }
      } else {
        failure('Error in createTransaction', 'Token not found');
        return null;
      }
    } catch (e) {
      failure('Error in createTransaction', e.toString());
      return null;
    }
  }
}