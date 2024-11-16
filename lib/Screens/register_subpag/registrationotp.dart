
import 'package:dating_application/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';


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
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController otpController = TextEditingController();

  String? backEndOtp = '';  

  @override
  void initState() {
    super.initState();
    initialize();
  }

  initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    backEndOtp = prefs.getString('passwordResetOtp');
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
                controller: otpController,
                onChanged: (value) {
                  otpController.text = value.toString();
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
                    if (otpController.text.length != 6) {
                      failure("Invalid OTP", "Please enter a valid 6-digit OTP.");
                      return;
                    }

                    // If backend OTP is used for testing or as fallback
                    if (backEndOtp == otpController.text) {
                      success("Success", "Your OTP is verified!");
                      Get.to(RegisterProfilePage());
                    } else {

                      String email = 'user@example.com';
                      RegistrationOtpVerificationRequest request = RegistrationOtpVerificationRequest(
                        email: email,
                        otp: otpController.text,
                      );
                      bool successdone = await controller.otpVerification(request);
                      if (successdone) {
                        success("Success", "OTP verified!");
                      } else {
                        failure("Error", "OTP verification failed. Please try again.");
                      }
                    }
                  },
                  child: Text(
                    "Verify OTP",
                    style: AppTextStyles.buttonText.copyWith(fontSize: buttonFontSize),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.04),
              Column(
                children: [
                  Text(
                    "The OTP you entered is incorrect. Please click on 'Regenerate OTP' to generate a new OTP.",
                    style: AppTextStyles.errorText.copyWith(
                      fontSize: fontSize,
                    ),
                  ),
                  SizedBox(height: size.height * 0.04),
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
                        Get.to(RegisterProfilePage());
                        String mobileNumber = emailcontroller.text.trim();
                        if (mobileNumber.isNotEmpty) {
                         
                        } else {
                          failure("Input Error", "Please enter a valid mobile number.");
                        }
                      },
                      child: Text(
                        "Regenerate OTP",
                        style: AppTextStyles.buttonText.copyWith(fontSize: buttonFontSize),
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
