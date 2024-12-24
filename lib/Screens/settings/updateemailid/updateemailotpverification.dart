import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Controllers/controller.dart';
import '../../../constants.dart';

class EmailOtpVerificationPage extends StatefulWidget {
  const EmailOtpVerificationPage({super.key});

  @override
  EmailOtpVerificationPageState createState() =>
      EmailOtpVerificationPageState();
}

class EmailOtpVerificationPageState extends State<EmailOtpVerificationPage> {
  Controller controller = Get.find();
  final formKey = GlobalKey<FormState>();
  String? otpError;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  initialize() async {
    EncryptedSharedPreferences prefs = EncryptedSharedPreferences.getInstance();
    controller.updateEmailVerificationRequest.newEmail =
        prefs.getString('update_email').toString();
  }

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
          style: AppTextStyles.headingText
              .copyWith(fontSize: getResponsiveFontSize(0.03)),
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
                style: AppTextStyles.bodyText
                    .copyWith(fontSize: getResponsiveFontSize(0.03)),
              ),
              SizedBox(height: 32),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    // OTP field
                    TextFormField(
                      style: AppTextStyles.inputFieldText
                          .copyWith(fontSize: getResponsiveFontSize(0.03)),
                      decoration: InputDecoration(
                        labelText: 'OTP',
                        labelStyle: AppTextStyles.labelText
                            .copyWith(fontSize: getResponsiveFontSize(0.03)),
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
                      onChanged: (value) {
                        controller.updateEmailVerificationRequest.otp = value;
                      },
                    ),
                    SizedBox(height: 32),

                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: () {
                          if (controller.updateEmailVerificationRequest
                              .validate()) {
                            controller.verifyEmailOtp(
                                controller.updateEmailVerificationRequest);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.buttonColor,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Verify OTP",
                          style: AppTextStyles.buttonText
                              .copyWith(fontSize: getResponsiveFontSize(0.03)),
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
}
