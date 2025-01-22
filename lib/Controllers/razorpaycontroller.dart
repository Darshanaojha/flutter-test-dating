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
import '../constants.dart';
import 'controller.dart';

class RazorpayController extends GetxController {
  late Razorpay razorpay;
  late Completer<bool> _paymentCompleter;
  Controller controller = Get.put(Controller());

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
      response.toString();
      EncryptedSharedPreferences preferences =
          await EncryptedSharedPreferences.getInstance();
      String? orderid = preferences.getString('OrderId');
      if (orderid != null) {
        transactionRequestModel.orderId = orderid;
      }
      Map<dynamic, dynamic>? responseData = response.data;
      if (responseData != null) {
        transactionRequestModel.packageId = orderRequestModel.packageId;
        transactionRequestModel.type = orderRequestModel.type;
        transactionRequestModel.razorPayOrderId = response.orderId ?? '';
        transactionRequestModel.razorPayPaymentId = response.paymentId ?? '';
        transactionRequestModel.paymentStatus =
            responseData['status'] ?? 'unknown';
        transactionRequestModel.paymentMethod =
            responseData['method'] ?? 'unknown';
        transactionRequestModel.amount =
            (double.tryParse(responseData['amount']?.toString() ?? '') ?? 0.0)
                .toString();
        transactionRequestModel.created =
            responseData['created']?.toString() ?? '';
        transactionRequestModel.updated =
            responseData['updated']?.toString() ?? '';
      }
      transaction(transactionRequestModel);

      print("Payment Success: ${response.paymentId}");
      _paymentCompleter.complete(true);
    } catch (e) {
      print("Error handling payment success: $e");
      _paymentCompleter.complete(false);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) async {
          response.toString();

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
    transactionRequestModel.orderId = orderid ?? '';
    transactionRequestModel.packageId = orderRequestModel.packageId;
    transactionRequestModel.type = orderRequestModel.type;
    transactionRequestModel.razorPayOrderId = errorMessage;
    transactionRequestModel.razorPayPaymentId = errorMessage;
    transactionRequestModel.paymentStatus = 'failed';
    transactionRequestModel.paymentMethod =
        response.error?.toString() ?? 'unknown';
    transactionRequestModel.amount =
        (double.tryParse(response.error?.toString() ?? '0.0') ?? 0.0)
            .toString();
    transactionRequestModel.status = errorMessage;
    transactionRequestModel.created = DateTime.now().toString();
    transactionRequestModel.updated = DateTime.now().toString();
    print("Transaction Failure Data: ${transactionRequestModel.toJson()}");
    transaction(transactionRequestModel);

    // Show the error dialog
    _showErrorDialog(errorMessage);
    print(
        "Error Details: Code: ${response.code}, Message: ${response.message}");
    if (response.error != null) {
      print("Error Details: ${response.error}");
    }

    _paymentCompleter.complete(false);
  }

  void _showErrorDialog(String errorMessage) {
    Get.dialog(
      AlertDialog(
        title: Text('Payment Error'),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close the dialog
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

// Function to show an error dialog (you can replace it with a SnackBar or any other UI feedback)

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("External Wallet Selected: ${response.walletName}");
    _paymentCompleter.complete(false);
  }

  OrderRequestModel orderRequestModel =
      OrderRequestModel(packageId: '', amount: '', type: '');
  Future<bool?> createOrder(OrderRequestModel orderRequestModel) async {
    try {
      OrderResponseModel? orderResponseModel =
          await OrderProvider().createOrder(orderRequestModel);
      if (orderResponseModel == null) {
        EncryptedSharedPreferences preferences =
            EncryptedSharedPreferences.getInstance();

        await preferences.setString(
            'OrderId', orderResponseModel!.payload.orderId);

        return false;
      } else {
        return true;
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
      razorPayOrderId: '',
      razorPayPaymentId: '',
      paymentStatus: '',
      paymentMethod: '',
      amount: '',
      status: '',
      created: '',
      updated: '');
  Future<bool?> transaction(
      TransactionRequestModel transactionRequestModel) async {
    try {
      TransactionResponseModel? transactionResponseModel =
          await OrderProvider().transaction(transactionRequestModel);
      if (transactionResponseModel == null) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      failure('Error', e.toString());
      return false;
    }
  }
}
