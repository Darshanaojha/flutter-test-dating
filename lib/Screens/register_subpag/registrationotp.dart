import 'package:dating_application/Screens/register_subpag/register_subpage.dart';
import 'package:dating_application/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart'; 
class OTPVerificationPage extends StatefulWidget {
  const OTPVerificationPage({super.key});

  @override
  OTPVerificationPageState createState() => OTPVerificationPageState();
}

class OTPVerificationPageState extends State<OTPVerificationPage> {
  DashboardController controller = Get.put(DashboardController());
  TextEditingController phoneNumberController = TextEditingController();
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

  // Success message function
  void success(String title, String message) {
    Fluttertoast.showToast(
      msg: "$title: $message",
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  // Failure message function
  void failure(String title, String message) {
    Fluttertoast.showToast(
      msg: "$title: $message",
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Calculate responsive font size based on screen width
   double fontSize = size.width * 0.03; // Adjust multiplier as needed
    double subheadingFontSize = size.width * 0.045;
    double buttonFontSize = size.width * 0.045;

    final defaultPinTheme = PinTheme(
      width: size.width * 0.15,
      height: size.height * 0.15,
      textStyle: AppTextStyles.inputFieldText.copyWith(fontSize: fontSize), // Use dynamic font size
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
                  fontSize: subheadingFontSize, // Dynamic font size for subheading
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
                  onPressed: () {
                    if (otpController.text.length != 6) {
                      failure("Invalid OTP", "Please enter a valid 6-digit OTP.");
                      return;
                    }
                    if (backEndOtp == otpController.text) {
                      success("Success", "Your OTP is verified!");
                      Get.to(MultiStepFormPage());
                    } else {
                      failure("Wrong OTP", "Please try again.");
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
                      fontSize: fontSize, // Dynamic font size for error text
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
                        Get.to(MultiStepFormPage());
                        String mobileNumber = phoneNumberController.text.trim();
                        if (mobileNumber.isNotEmpty) {
                          controller.requestOtp(mobileNumber);
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

class DashboardController {
  var verifiyPassword;

  void requestOtp(String mobileNumber) {}
}






