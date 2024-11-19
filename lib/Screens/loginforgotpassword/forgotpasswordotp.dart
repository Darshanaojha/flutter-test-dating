
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants.dart';
import 'forgotpaswordenter.dart';

class OTPInputPage extends StatefulWidget {
  const OTPInputPage({super.key});

  @override
  OTPInputPageState createState() => OTPInputPageState();
}

class OTPInputPageState extends State<OTPInputPage> {
  final formKey = GlobalKey<FormState>();
  List<TextEditingController> otpControllers = List.generate(6, (index) => TextEditingController());

  // Function to handle OTP input
  String? validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a digit';
    }
    if (!RegExp(r'^[0-9]$').hasMatch(value)) {
      return 'Enter a valid digit';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.03; // Adjust font size based on screen width

    return Scaffold(
      appBar: AppBar(
        title: Text('Enter OTP', style: AppTextStyles.headingText),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1, vertical: 30),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'Enter the 6-digit OTP sent to your email or phone.',
                style: AppTextStyles.bodyText.copyWith(fontSize: fontSize),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              
              Form(
                key: formKey,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        return SizedBox(
                          width: screenWidth * 0.12,
                          child: TextFormField(
                            controller: otpControllers[index],
                            style: AppTextStyles.inputFieldText.copyWith(fontSize: fontSize),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.formFieldColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: AppColors.primaryColor),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: AppColors.errorBorderColor),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 1, // Limit to 1 digit per input
                            textAlign: TextAlign.center,
                            validator: validateOTP,
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 20),

                    // Submit Button
                    ElevatedButton(
                      onPressed: () {
                        String otp = otpControllers.map((controller) => controller.text).join('');
                        if (formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('OTP Submitted: $otp')),
                          );
                          // Handle OTP submission logic here, such as validating with a backend or proceeding to the next screen.
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonColor,
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Submit',
                        style: AppTextStyles.buttonText.copyWith(fontSize: fontSize),
                      ),
                    ),
                    ElevatedButton(onPressed:(){
                      Get.to(PasswordInputPage());
                    } , child: Text('Next'))
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