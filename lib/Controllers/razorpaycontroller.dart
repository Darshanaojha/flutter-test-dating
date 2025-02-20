import 'dart:async';
import 'package:dating_application/Models/RequestModels/transaction_request_model.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../Models/RequestModels/order_request_model.dart';
import '../Models/ResponseModels/order_response_model.dart';
import '../Models/ResponseModels/transaction_response_model.dart';
import '../Providers/order_provider.dart';
import '../Screens/navigationbar/navigationpage.dart';
import '../constants.dart';
import 'controller.dart';

class RazorpayController extends GetxController {
  late Razorpay razorpay;
  late Completer<bool> _paymentCompleter;
  Controller controller = Get.put(Controller());
  RazorpayController() {
    _paymentCompleter = Completer<bool>();
  }

  void initRazorpay() {
    razorpay = Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    razorpay.clear();
    super.dispose();
  }

  Future<bool> startPayment(double totalAmount, String name, String description,
      String contact, String email) {
    _paymentCompleter = Completer<bool>();

    openPayment(totalAmount, name, description, contact, email);

    return _paymentCompleter.future;
  }

  void openPayment(double totalAmount, String name, String description,
      String contact, String email) {
    var options = {
      'key': RazorpayKeys.RAZORPAYKEYID,
      'amount': (totalAmount * 100).toInt(),
      'name': name,
      'description': description,
      'prefill': {
        'contact': contact,
        'email': email,
      },
      'method': {
        'upi': {
          'flow': 'qr',
        }
      },
    };

    print("Opening Razorpay with options: $options");

    try {
      razorpay.open(options);
    } catch (e) {
      print("Error opening Razorpay: $e");
      _paymentCompleter.complete(false);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      print("Full Razorpay Success Response: ${response.data}");

      EncryptedSharedPreferences preferences =
          await EncryptedSharedPreferences.getInstance();
      String? orderid = preferences.getString('OrderId');
      String? razorpayorderid = preferences.getString('RazorpayOrderId');
      String? transactionId = preferences.getString('transactionId');
      String? amount = preferences.getString('amount');
      if (orderid != null) {
        transactionRequestModel.orderId = orderid;
      }
      if (razorpayorderid != null) {
        transactionRequestModel.razorpayOrderId = razorpayorderid;
      }
      if (transactionId != null) {
        transactionRequestModel.transactionId = transactionId;
      }
      if (amount != null) {
        transactionRequestModel.amount = amount;
      }

      Map<dynamic, dynamic>? responseData = response.data;
      if (responseData != null) {
        transactionRequestModel.packageId = orderRequestModel.packageId;
        transactionRequestModel.type = orderRequestModel.type;
        transactionRequestModel.message = "Success Paid";
        transactionRequestModel.razorpayPaymentId = response.paymentId ?? '';
        transactionRequestModel.transactionId = transactionId ?? '';
        transactionRequestModel.paymentStatus = Transactionsuccess.SUCCESS;
        transactionRequestModel.paymentMethod = responseData['method'] ?? '';
        transactionRequestModel.created = DateTime.now();
        transactionRequestModel.updated = DateTime.now();
      }

      await transaction(transactionRequestModel).then((value) {
        Get.offAll(NavigationBottomBar());
      });
      print(
          "transaction details= ${transactionRequestModel.toJson().toString()}");
      print("Payment Success: ${response.paymentId}");
      print("Payment Success responsebody: ${responseData.toString()}");

      _paymentCompleter.complete(true);
    } catch (e) {
      print("Error handling payment success: $e");
      _paymentCompleter.complete(false);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) async {
    print(response.toString());
    print(
        "Payment Failed: Code: ${response.code}, Message: ${response.message}");
    String errorMessage = 'Payment Failed. Please try again later.';
    switch (response.code) {
      case Razorpay.NETWORK_ERROR:
        errorMessage =
            'Network Error. Please check your internet connection and try again.';
        break;

      case Razorpay.INVALID_OPTIONS:
        errorMessage =
            'Invalid payment options provided. Please check the payment details and try again.';
        break;

      case Razorpay.PAYMENT_CANCELLED:
        errorMessage =
            'Payment was cancelled by the user. You can try the payment process again.';
        break;

      case Razorpay.TLS_ERROR:
        errorMessage =
            'TLS Error. There might be an issue with network security or configuration. Please try again.';
        break;

      case Razorpay.INCOMPATIBLE_PLUGIN:
        errorMessage =
            'Incompatible Plugin Error. Please ensure the Razorpay plugin is up-to-date.';
        break;

      case Razorpay.UNKNOWN_ERROR:
        errorMessage = 'An unknown error occurred. Please try again later.';
        break;

      default:
        errorMessage =
            'Unexpected error: ${response.message}. Please try again.';
        break;
    }
    EncryptedSharedPreferences preferences =
        await EncryptedSharedPreferences.getInstance();
    String? orderid = preferences.getString('OrderId');
    String? razorpayorderid = preferences.getString('RazorpayOrderId');
    String? transactionId = preferences.getString('transactionId');
    String? amount = preferences.getString('amount');
    transactionRequestModel.orderId = orderid ?? '';
    transactionRequestModel.packageId = orderRequestModel.packageId;
    transactionRequestModel.type = orderRequestModel.type;
    transactionRequestModel.razorpayOrderId = razorpayorderid ?? "";
    transactionRequestModel.transactionId = transactionId ?? "";
    transactionRequestModel.razorpayPaymentId = errorMessage;
    transactionRequestModel.amount = amount ?? "";
    transactionRequestModel.paymentStatus = Transactionsuccess.FAIL;
    transactionRequestModel.paymentMethod = response.error?.toString() ?? '';
    transactionRequestModel.message = errorMessage;
    transactionRequestModel.created = DateTime.now();
    transactionRequestModel.updated = DateTime.now();
    print("Transaction Failure Data: ${transactionRequestModel.toJson()}");
    await transaction(transactionRequestModel).then((value) {});
    print(
        "transaction details= ${transactionRequestModel.toJson().toString()}");
    print("Full Razorpay failure Response: ${response.toString()}");
    print(
        "Error Details: Code: ${response.code}, Message: ${response.message}");
    if (response.error != null) {
      print("Error Details: ${response.error}");
    }

    _paymentCompleter.complete(false);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("External Wallet Selected: ${response.walletName}");
    _paymentCompleter.complete(false);
  }

  OrderRequestModel orderRequestModel =
      OrderRequestModel(packageId: '', amount: '', points:'', type: '');
  Future<bool?> createOrder(OrderRequestModel orderRequestModel) async {
    try {
      OrderResponseModel? orderResponseModel =
          await OrderProvider().createOrder(orderRequestModel);

      if (orderResponseModel == null) {
        failure("Failure", "No response from the server");
        return false;
      }
      if (orderResponseModel.success) {
        var payload = orderResponseModel.payload;
        if (payload != null &&
            payload.message != null &&
            payload.orderId != null &&
            payload.transactionId != null &&
            payload.amount != null) {
          success('Success', payload.message);
          EncryptedSharedPreferences preferences =
              await EncryptedSharedPreferences.getInstance();

          await preferences.setString('OrderId', payload.orderId.toString());
          await preferences.setString(
              'RazorpayOrderId', payload.order.toString());
          await preferences.setString(
              'transactionId', payload.transactionId.toString());
          await preferences.setString('amount', payload.amount.toString());

          return true;
        } else {
          failure("Failure", "Missing required payload fields");
          return false;
        }
      } else {
        String errorMessage =
            orderResponseModel.error?.message ?? "Unknown error";
        failure("Failure", errorMessage);
        return false;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }

  TransactionRequestModel transactionRequestModel = TransactionRequestModel(
      orderId: '',
      packageId: '',
      type: '',
      razorpayOrderId: '',
      razorpayPaymentId: '',
      paymentStatus: '',
      paymentMethod: '',
      amount: '',
      points:'',
      transactionId: '',
      message: '',
      created: DateTime.now(),
      updated: DateTime.now());
  Future<bool> transaction(
      TransactionRequestModel transactionRequestModel) async {
    try {
      TransactionResponseModel? transactionResponseModel =
          await OrderProvider().transaction(transactionRequestModel);
      if (transactionResponseModel == null) {
        failure('Error', 'No response from the server');
        return false;
      }
      return true;
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }
}
