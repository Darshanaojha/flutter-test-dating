import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Models/RequestModels/update_emailid_otp_verification_request_model.dart';
import '../../../Providers/update_email_verification_provider.dart';
import '../../../constants.dart';
import '../../homepage/homepage.dart';

class EmailOtpVerificationPage extends StatefulWidget {
  const EmailOtpVerificationPage({super.key});

  @override
  EmailOtpVerificationPageState createState() => EmailOtpVerificationPageState();
}
class EmailOtpVerificationPageState extends State<EmailOtpVerificationPage> {
  final otpController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String? otpError;

  final updateEmailVerificationProvider = UpdateEmailVerificationProvider();

  double getResponsiveFontSize(double scale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * scale;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Enter OTP",
          style: AppTextStyles.headingText.copyWith(fontSize: getResponsiveFontSize(0.03)),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Please enter the OTP sent to your email address.",
                style: AppTextStyles.bodyText.copyWith(fontSize: getResponsiveFontSize(0.03)),
              ),
              SizedBox(height: 32),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    // OTP field
                    TextFormField(
                      controller: otpController,
                      style: AppTextStyles.inputFieldText.copyWith(fontSize: getResponsiveFontSize(0.03)),
                      decoration: InputDecoration(
                        labelText: 'OTP',
                        labelStyle: AppTextStyles.labelText.copyWith(fontSize: getResponsiveFontSize(0.03)),
                        fillColor: AppColors.formFieldColor,
                        filled: true,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primaryColor),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        errorText: otpError,
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 6,  
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "OTP is required";
                        }
                        if (value.length != 6) {
                          return "OTP must be 6 digits long";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 32),

                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: verifyOTP,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonColor,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Verify OTP",
                          style: AppTextStyles.buttonText.copyWith(fontSize: getResponsiveFontSize(0.03)),
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
    );
  }

  void verifyOTP() async {
    setState(() {
      otpError = null;  
    });

    if (formKey.currentState!.validate()) {

      final String email = Get.arguments['email'];

      final otpVerificationRequest = UpdateEmailVerificationRequest(
        newEmail: email,
        otp: otpController.text,
      );

      try {

        final response = await updateEmailVerificationProvider.verifyEmailOtp(otpVerificationRequest);

        if (response != null) {
          success("Success", 'OTP verified successfully!');
          Get.to(HomePage());
        } else {
          failure("Error", "Failed to verify OTP. Please try again.");
        }
      } catch (e) {
        failure("Error", "An error occurred: $e");
      }
    }
  }
}
