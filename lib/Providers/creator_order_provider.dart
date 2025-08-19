import 'package:get/get.dart';
import 'package:dating_application/constants.dart';
import 'package:dating_application/Models/RequestModels/creator_order_request_model.dart';
import 'package:dating_application/Models/ResponseModels/creator_order_response_model.dart';
import 'package:encrypt_shared_preferences/provider.dart';
class CreatorOrderProvider extends GetConnect {
  Future<CreatorOrderResponse?> createOrder(CreatorOrderRequest request) async {
    try {
      EncryptedSharedPreferences preferences = EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');

      if (token != null && token.isNotEmpty) {
        final response = await post(
          '$springbooturl/creator/order',
          request.toJson(),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == null || response.body == null) {
          failure('Error in createOrder', 'Server Failed To Respond');
          return null;
        }

        if (response.statusCode == 200) {
          return CreatorOrderResponse.fromJson(response.body);
        } else {
          failure('Error in createOrder', response.body.toString());
          return null;
        }
      } else {
        failure('Error in createOrder', 'Token not found');
        return null;
      }
    } catch (e) {
      failure('Error in createOrder', e.toString());
      return null;
    }
  }
}