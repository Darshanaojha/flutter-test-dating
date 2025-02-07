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
        email:  controller.userRegistrationRequest.email,
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
                child: Container(
                    decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment(0.8, 1),
                colors: <Color>[
                  Color(0xff1f005c),
                  Color(0xff5b0060),
                  Color(0xff870160),
                  Color(0xffac255e),
                  Color(0xffca485c),
                  Color(0xffe16b5c),
                  Color(0xfff39060),
                  Color(0xffffb56b),
                ],
              ),
              borderRadius: BorderRadius.circular(
                  30), // You can adjust the border radius here
            ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                      backgroundColor: Colors.transparent,
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
                        Get.snackbar('otp entered is',registrationOtpVerificationRequest.otp.toString() );
                      controller
                          .otpVerificationForRegistration(
                              registrationOtpVerificationRequest)
                          .then((value) {
                        if (value) {
                          success("Success", "OTP verified!");
                          
                       
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
