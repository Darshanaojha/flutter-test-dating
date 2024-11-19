
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controllers/controller.dart';
import '../../Models/RequestModels/forget_password_request_model.dart';
import '../../Models/RequestModels/forget_password_verification_request_model.dart';
import '../../constants.dart';
import '../login.dart';

class OTPInputPage extends StatefulWidget {
  const OTPInputPage({super.key});

  @override
  OTPInputPageState createState() => OTPInputPageState();
}

class OTPInputPageState extends State<OTPInputPage> {
  final formKey = GlobalKey<FormState>();
  List<TextEditingController> otpControllers = List.generate(6, (index) => TextEditingController());
  Controller controller = Get.find();
  String? forgetpasswordemail;
  String? forgetpassword;
  @override
  void initState() {
    super.initState();
    initialize();
  }

  initialize() async {
    EncryptedSharedPreferences prefs =
        await EncryptedSharedPreferences.getInstance();
    setState(() {
      forgetpasswordemail = prefs.getString('forgetpasswordemail');
      forgetpassword = prefs.getString('forgetpassword');
    });
    if (forgetpasswordemail != null) {
      controller.forgetPasswordVerificationRequest = ForgetPasswordVerificationRequest(
        email: forgetpasswordemail!,
        password: forgetpassword!,
        otp: ''
      );
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

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a new password';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != controller.forgetPasswordVerificationRequest.password) {
      return 'Passwords do not match';
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.03;

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
                'Enter the 6-digit OTP sent to your email.',
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
                            cursorColor: AppColors.cursorColor,
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
                            maxLength: 1, 
                            textAlign: TextAlign.center,
                            
                            validator: validateOTP,
                            onChanged: (value) {
                       
                          if (value.isNotEmpty && index < otpControllers.length - 1) {
                            FocusScope.of(context).nextFocus();
                          }
                        },
                        onSaved: (value) {
                    
                          otpControllers[index].text = value ?? '';
                        },
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: (){
                         if (formKey.currentState?.validate() ?? false) {
                          formKey.currentState?.save();
                          controller.otpVerificationForgetPassword(
                              controller.forgetPasswordVerificationRequest);
                        } else {
                          failure('otp', 'not entered');
                          return;
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
                    ElevatedButton(onPressed: (){Get.to(Login());}, child: Text("Next"))
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