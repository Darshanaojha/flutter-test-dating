import 'package:dating_application/constants.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../Controllers/controller.dart';
import '../../Models/RequestModels/registration_otp_verification_request_model.dart';
import 'registerdetails.dart';
class OTPVerificationPage extends StatefulWidget {
  const OTPVerificationPage({super.key});

  @override
  OTPVerificationPageState createState() => OTPVerificationPageState();
}

class OTPVerificationPageState extends State<OTPVerificationPage> {
  Controller controller = Get.put(Controller());

  String? backEndOtp = '';
  String? email = '';
  bool isOtpValid = true;  // Flag to track OTP validity

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
    EncryptedSharedPreferences prefs =
        EncryptedSharedPreferences.getInstance();
    setState(() {
      backEndOtp = prefs.getString('registrationotp');
      email = prefs.getString('registrationemail');
    });
    if (email != null) {
      registrationOtpVerificationRequest = RegistrationOtpVerificationRequest(
        email: email!,
        otp: '',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    double fontSize = size.width * 0.03;
    double subheadingFontSize = size.width * 0.045;
    double buttonFontSize = size.width * 0.035;

    final defaultPinTheme = PinTheme(
      width: size.width * 0.15,
      height: size.height * 0.15,
      textStyle: AppTextStyles.inputFieldText.copyWith(fontSize: fontSize),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.textColor),
        borderRadius: BorderRadius.circular(20),
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: size.width * 0.08),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: size.width * 0.2,
                backgroundImage: const NetworkImage(""),
                backgroundColor: AppColors.textColor,
              ),
              SizedBox(height: size.height * 0.02),
              Text(
                "Enter OTP To Confirm the Password",
                style: AppTextStyles.subheadingText.copyWith(
                  color: Colors.white,
                  fontSize: subheadingFontSize,
                ),
              ),
              SizedBox(height: size.height * 0.03),
              Pinput(
                length: 6,
                onChanged: (value) {
                  registrationOtpVerificationRequest.otp = value;
                  // Reset OTP validity status when user starts typing
                  setState(() {
                    isOtpValid = true; // Reset OTP validity to valid
                  });
                },
                showCursor: true,
                defaultPinTheme: defaultPinTheme,
              ),
              SizedBox(height: size.height * 0.04),
              SizedBox(
                width: double.infinity,
                height: size.height * 0.055,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                    backgroundColor: AppColors.buttonColor,
                    foregroundColor: AppColors.textColor,
                  ),
                  onPressed: () async {
                    if (registrationOtpVerificationRequest.otp.length != 6) {
                      setState(() {
                        isOtpValid = false; // OTP is invalid
                      });
                      failure("Invalid OTP", "Please enter a valid 6-digit OTP.");
                      return;
                    }

                    controller
                        .otpVerificationForRegistration(
                            registrationOtpVerificationRequest)
                        .then((value) {
                      if (value) {
                        success("Success", "OTP verified!");
                        Get.to(RegisterProfilePage());
                      } else {
                        setState(() {
                          isOtpValid = false; // OTP verification failed
                        });
                        failure("Error", "OTP verification failed. Please try again.");
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
              SizedBox(height: size.height * 0.04),
              Column(
                children: [
                  if (!isOtpValid) // Only show if OTP is invalid
                    Text(
                      "The OTP you entered is incorrect. Please click on 'Regenerate OTP' to generate a new OTP.",
                      style: AppTextStyles.errorText.copyWith(
                        fontSize: fontSize,
                      ),
                    ),
                  SizedBox(height: size.height * 0.04),
                  if (!isOtpValid) // Show Regenerate OTP button only when OTP is invalid
                    SizedBox(
                      width: double.infinity,
                      height: size.height * 0.055,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                          backgroundColor: AppColors.buttonColor,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                       
                          controller.getOtpForRegistration(controller.registrationOTPRequest);
                          registrationOtpVerificationRequest.otp = '';  // Clear OTP input

                       
                          setState(() {
                            registrationOtpVerificationRequest.otp = ''; // Clear OTP input
                            isOtpValid = true; // Reset OTP validity when regenerating
                          });
                        },
                        child: Text(
                          "Regenerate OTP",
                          style: AppTextStyles.buttonText
                              .copyWith(fontSize: buttonFontSize),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
