import 'package:dating_application/Screens/auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

import '../../Controllers/controller.dart';
import '../../Models/RequestModels/forget_password_verification_request_model.dart';
import '../../constants.dart';

class OTPInputPage extends StatefulWidget {
  const OTPInputPage({super.key});

  @override
  OTPInputPageState createState() => OTPInputPageState();
}

class OTPInputPageState extends State<OTPInputPage> {
  final formKey = GlobalKey<FormState>();
  List<TextEditingController> otpControllers =
      List.generate(6, (index) => TextEditingController());
  Controller controller = Get.find();

  @override
  void initState() {
    super.initState();
    initialize();
  }

  initialize() async {
    if (controller.forgetPasswordRequest.email.isNotEmpty) {
      controller.forgetPasswordVerificationRequest =
          ForgetPasswordVerificationRequest(
              email: controller.forgetPasswordRequest.email,
              password: controller.forgetPasswordRequest.newPassword,
              otp: '');
    }
  }

  String? validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a digit';
    }
    if (!RegExp(r'^[0-9]$').hasMatch(value)) {
      return 'Enter a valid digit';
    }
    return null;
  }

  String getOtp() {
    return otpControllers.map((controller) => controller.text).join('');
  }

  void submitOtp() async {
    String enteredOtp = getOtp();

    if (enteredOtp.length != 6) {
      failure('Error', 'Please enter a 6-digit OTP');
      return;
    }

    if (formKey.currentState?.validate() ?? false) {
      controller.forgetPasswordVerificationRequest.otp = enteredOtp;
      bool success = await controller.otpVerificationForgetPassword(
          controller.forgetPasswordVerificationRequest);
      if (success) {
        Get.to(CombinedAuthScreen());
      } else {
        failure('Error', 'Failed to verify OTP');
      }
    } else {
      failure('Error', 'Please fill all OTP fields correctly');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.04;

    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.gradientBackgroundList,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'Forgot Password OTP',
          style: AppTextStyles.headingText.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: fontSize * 1.2,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.07, vertical: 30),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.gradientBackgroundList,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Enter the 6-digit OTP sent to your email.',
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: fontSize,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          // Modern OTP Input using Pinput
                          Pinput(
                            length: 6,
                            controller: TextEditingController(text: getOtp()),
                            defaultPinTheme: PinTheme(
                              width: 48,
                              height: 56,
                              textStyle: AppTextStyles.inputFieldText.copyWith(
                                fontSize: fontSize * 1.2,
                                color: Colors.white,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white60,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white24),
                              ),
                            ),
                            focusedPinTheme: PinTheme(
                              width: 48,
                              height: 56,
                              textStyle: AppTextStyles.inputFieldText.copyWith(
                                fontSize: fontSize * 1.2,
                                color: Colors.white,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.length != 6) {
                                return 'Enter 6 digits';
                              }
                              if (!RegExp(r'^[0-9]{6}$').hasMatch(value)) {
                                return 'Digits only';
                              }
                              return null;
                            },
                            onCompleted: (value) {
                              for (int i = 0; i < value.length; i++) {
                                otpControllers[i].text = value[i];
                              }
                            },
                            onChanged: (value) {
                              for (int i = 0; i < value.length; i++) {
                                if (i < otpControllers.length) {
                                  otpControllers[i].text = value[i];
                                }
                              }
                            },
                            keyboardType: TextInputType.number,
                            showCursor: true,
                          ),
                          SizedBox(height: 28),
                          // Gradient Submit OTP Button (Blue Variant)
                          GestureDetector(
                            onTap: submitOtp,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white,
                                    Colors.white,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.18),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  'Submit OTP',
                                  style: AppTextStyles.buttonText.copyWith(
                                    fontSize: fontSize * 0.8,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          // Gradient Resend OTP Button (Black/White Variant)
                          GestureDetector(
                            onTap: () async {
                              if (controller.forgetPasswordRequest.validate()) {
                                await controller.getOtpForgetPassword(
                                    controller.forgetPasswordRequest);
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white,
                                    Colors.white,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.13),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  'Resend OTP',
                                  style: AppTextStyles.buttonText.copyWith(
                                    fontSize: fontSize * 0.8,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
