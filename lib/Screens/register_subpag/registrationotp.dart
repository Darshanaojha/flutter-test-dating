import 'package:dating_application/constants.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../Controllers/controller.dart';
import '../../Models/RequestModels/registration_otp_verification_request_model.dart';

class OTPVerificationPage extends StatefulWidget {
  const OTPVerificationPage({super.key});

  @override
  OTPVerificationPageState createState() => OTPVerificationPageState();
}

class OTPVerificationPageState extends State<OTPVerificationPage> {
  Controller controller = Get.put(Controller());

  String? backEndOtp = '';
  String? email = '';
  bool isOtpValid = true; // Flag to track OTP validity
  bool isResending = false;

  RegistrationOtpVerificationRequest registrationOtpVerificationRequest =
      RegistrationOtpVerificationRequest(
    email: '',
    otp: '',
  );

  @override
  void initState() {
    super.initState();
    initialize();
  }

  initialize() async {
    EncryptedSharedPreferences prefs = EncryptedSharedPreferences.getInstance();
    setState(() {
      backEndOtp = prefs.getString('registrationotp');
      email = prefs.getString('registrationemail');
    });
    if (email != null) {
      registrationOtpVerificationRequest = RegistrationOtpVerificationRequest(
        email: controller.userRegistrationRequest.email,
        otp: '',
      );
    }
  }

  Future<void> resendOtp() async {
    setState(() => isResending = true);
    await controller.getOtpForRegistration(controller.registrationOTPRequest);
    setState(() {
      isResending = false;
      registrationOtpVerificationRequest.otp = '';
      isOtpValid = true;
    });
    success("OTP Sent", "A new OTP has been sent to your email.");
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    double fontSize = size.width * 0.03;
    double subheadingFontSize = size.width * 0.045;
    double buttonFontSize = size.width * 0.035;

    final defaultPinTheme = PinTheme(
      width: size.width * 0.13,
      height: size.width * 0.13,
      textStyle:
          AppTextStyles.inputFieldText.copyWith(fontSize: fontSize * 1.2),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.textColor),
        borderRadius: BorderRadius.circular(16),
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        alignment: Alignment.center,
        color: AppColors.primaryColor,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: size.width * 0.16,
                  backgroundColor: AppColors.textColor,
                  child: Icon(Icons.lock_outline,
                      color: AppColors.primaryColor, size: size.width * 0.13),
                ),
                SizedBox(height: size.height * 0.03),
                Text(
                  "Verify Your Email",
                  style: AppTextStyles.headingText.copyWith(
                    color: Colors.white,
                    fontSize: subheadingFontSize * 1.1,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: size.height * 0.01),
                Text(
                  "Enter the 6-digit OTP sent to your email to complete registration.",
                  style: AppTextStyles.subheadingText.copyWith(
                    color: Colors.white70,
                    fontSize: fontSize,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: size.height * 0.03),
                Pinput(
                  length: 6,
                  onChanged: (value) {
                    registrationOtpVerificationRequest.otp = value;
                    setState(() {
                      isOtpValid = true;
                    });
                  },
                  showCursor: true,
                  defaultPinTheme: defaultPinTheme,
                ),
                SizedBox(height: size.height * 0.03),
                if (!isOtpValid)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      "The OTP you entered is incorrect. Please try again or resend OTP.",
                      style: AppTextStyles.errorText.copyWith(
                        fontSize: fontSize,
                        color: Colors.redAccent,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Row(
                    children: [
                    Expanded(
                      child: SizedBox(
                      height: size.height * 0.055,
                      child: Container(
                        decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment(0.8, 1),
                          colors: AppColors.gradientColor,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        ),
                        child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent, // Match Verify button
                          foregroundColor: AppColors.textColor, // Match Verify button
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: isResending
                          ? null
                          : () async {
                            await resendOtp();
                            },
                        child: isResending
                          ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                            )
                          : Text(
                            "Resend OTP",
                            style: AppTextStyles.buttonText
                              .copyWith(fontSize: buttonFontSize),
                            ),
                        ),
                      ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.02),
                    Expanded(
                      child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment(0.8, 1),
                        colors: AppColors.gradientColor,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: SizedBox(
                        height: size.height * 0.055,
                        child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: AppColors.textColor,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () async {
                          if (registrationOtpVerificationRequest
                              .otp.length !=
                            6) {
                          setState(() {
                            isOtpValid = false;
                          });
                          failure("Invalid OTP",
                            "Please enter a valid 6-digit OTP.");
                          return;
                          }
                          // Get.snackbar(
                          //   'OTP entered',
                          //   registrationOtpVerificationRequest.otp
                          //     .toString());
                          controller
                            .otpVerificationForRegistration(
                              registrationOtpVerificationRequest)
                            .then((value) {
                          if (value) {
                            success("Success", "OTP verified!");
                          } else {
                            setState(() {
                            isOtpValid = false;
                            });
                            failure("Error",
                              "OTP verification failed. Please try again.");
                          }
                          });
                        },
                        child: Text(
                          "Verify OTP",
                          style: AppTextStyles.buttonText
                            .copyWith(fontSize: buttonFontSize),
                        ),
                        ),
                      ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
