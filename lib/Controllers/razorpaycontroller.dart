import 'dart:async';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
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
      // 'key': RAZORPAYKEYID,
      'amount': (totalAmount * 100).toInt(), // Amount in paise
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

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print("Payment Success: ${response.paymentId}");
    // controller.bookingUpdateController(
    //     startGarageKm: '',
    //     endGarageKm: '',
    //     startKm: '',
    //     endKm: '',
    //     toll: '',
    //     parking: '',
    //     status: ENDTRIP,
    //     notes: 'Payment successfull, Payment ID: ${response.paymentId}');
    _paymentCompleter.complete(true);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
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
            'Invalid payment options provided. Please check the payment details.';
        break;
      case Razorpay.PAYMENT_CANCELLED:
        errorMessage = 'Payment was cancelled by the user. You may try again.';
        break;
      case Razorpay.TLS_ERROR:
        errorMessage =
            'TLS Error. There might be an issue with network security or configuration.';
        break;
      case Razorpay.INCOMPATIBLE_PLUGIN:
        errorMessage =
            'Incompatible Plugin Error. Please update the Razorpay plugin or your app.';
        break;
      case Razorpay.UNKNOWN_ERROR:
        errorMessage = 'An unknown error occurred. Please try again later.';
        break;
      default:
        errorMessage = 'Unexpected error: ${response.message}';
        break;
    }

    print(
        "Error Details: Code: ${response.code}, Message: ${response.message}");

    // controller.bookingUpdateController(
    //   startGarageKm: '',
    //   endGarageKm: '',
    //   startKm: '',
    //   endKm: '',
    //   toll: '',
    //   parking: '',
    //   status: '',
    //   notes:
    //       'Payment Failed, Error Code: ${response.code}, Message: $errorMessage',
    // );

    _paymentCompleter.complete(false);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("External Wallet Selected: ${response.walletName}");
    // controller.bookingUpdateController(
    //     startGarageKm: '',
    //     endGarageKm: '',
    //     startKm: '',
    //     endKm: '',
    //     toll: '',
    //     parking: '',
    //     status: ENDTRIP,
    //     notes: 'Payment via external wallet: ${response.walletName}');
    _paymentCompleter.complete(false);
  }
}
