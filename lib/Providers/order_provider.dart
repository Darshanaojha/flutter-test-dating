
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:get/get.dart';
import 'package:get/get_connect.dart';
import '../Models/RequestModels/order_request_model.dart';
import '../Models/RequestModels/transaction_request_model.dart';
import '../Models/ResponseModels/all_orders_response_model.dart';
import '../Models/ResponseModels/all_transactions_response_model.dart';
import '../Models/ResponseModels/order_response_model.dart';
import '../Models/ResponseModels/transaction_response_model.dart';
import '../constants.dart';

class OrderProvider extends GetConnect {
  Future<OrderResponseModel?> createOrder(
      OrderRequestModel orderRequestModel) async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');
      if (token == null || token == "") {
        return null;
      }
      print(orderRequestModel.toJson().toString());

      Response response = await post(
        '$baseurl/RazorpayController/createOrder',
        orderRequestModel.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      print(response.body.toString());
      if (response.statusCode == 200) {
        if (response.body['error']['code'] == 0) {
          return OrderResponseModel.fromJson(response.body);
        } else {
          failure('Error', response.body['error']['message']);
          return null;
        }
      } else {
        failure(response.statusCode, response.body['error']['message']);
        return null;
      }
    } catch (e) {
      failure("Error", e.toString());
      return null;
    }
  }

  Future<TransactionResponseModel?> transaction(
      TransactionRequestModel transactionRequestModel) async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');
      if (token == null || token.isEmpty) {
        return null;
      }

      Response response = await post(
        '$baseurl/RazorpayController/Transaction',
        transactionRequestModel.toJson(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == null || response.body == null) {
        failure('Error', 'Server Failed To Respond');
        return null;
      }
      if (response.statusCode == 200) {
        return TransactionResponseModel.fromJson(response.body);
      } else {
        failure(response.statusCode.toString(), response.body);
        return null;
      }
    } catch (e) {
      failure('Error', e.toString());
      return null;
    }
  }

  Future<AllTransactionsResponseModel?> allTransactions() async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');

      if (token == null || token.isEmpty) {
        return null;
      }
      Response response = await get(
        '$baseurl/RazorpayController/allTransactions',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        print("Response of get all Transaction: ${response.body}");
        return AllTransactionsResponseModel.fromJson(response.body);
      } else {
        failure(response.statusCode.toString(), response.body);
        return null;
      }
    } catch (e) {
      failure('Error tranasction', e.toString());
      return null;
    }
  }

  Future<AllOrdersResponseModel?> allOrders() async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();
      String? token = preferences.getString('token');
      if (token == null || token == "") {
        return null;
      }

      Response response = await get(
        '$baseurl/RazorpayController/allOrders',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      print("Rsponse of get all Orders=${response.body.toString()}");
      if (response.statusCode == 200) {
        return AllOrdersResponseModel.fromJson(response.body);
      } else {
        failure(response.statusCode, response.body['error']['message']);
        return null;
      }
    } catch (e) {
      failure("Error orders", e.toString());
      return null;
    }
  }
}
