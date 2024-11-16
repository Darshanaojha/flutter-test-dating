
import 'package:dating_application/Models/RequestModels/forget_password_request_model.dart';
import 'package:dating_application/Models/ResponseModels/forget_password_response_model.dart';
import 'package:dating_application/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controllers/controller.dart';
import '../../Providers/login_provider.dart';
import 'forgotpasswordotp.dart';


class PasswordInputPage extends StatefulWidget {
  const PasswordInputPage({super.key});

  @override
  PasswordInputPageState createState() => PasswordInputPageState();
}

class PasswordInputPageState extends State<PasswordInputPage> {
  final formKey = GlobalKey<FormState>();
  Controller controller= Get.put(Controller());


  String? password;
  String? confirmPassword;
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
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
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.03; // Adjust font size based on screen width

    return Scaffold(
      appBar: AppBar(
        title: Text('Set Password', style: AppTextStyles.headingText),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1, vertical: 30),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'Set your password and confirm it.',
                style: AppTextStyles.bodyText.copyWith(fontSize: fontSize),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),

              Form(
                key: formKey,
                child: Column(
                  children: [
                    // Password Input Field
                    TextFormField(
                        cursorColor: AppColors.cursorColor,
                      controller: confirmPasswordController,
                      style: AppTextStyles.inputFieldText.copyWith(fontSize: fontSize),
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: AppTextStyles.bodyText.copyWith(fontSize: fontSize),
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
                      validator: validatePassword,
                        onChanged: (value) {
                        setState(() {
                         controller.forgetPasswordRequest.newPassword= value;  
                        });
                      },
                      onSaved: (value) {
                        controller.forgetPasswordRequest.newPassword = value.toString(); 
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      cursorColor: AppColors.cursorColor,
                      controller: confirmPasswordController,
                      style: AppTextStyles.inputFieldText.copyWith(fontSize: fontSize),
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        labelStyle: AppTextStyles.bodyText.copyWith(fontSize: fontSize),
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
                      validator: validateConfirmPassword,
                    
                        onChanged: (value) {
                        setState(() {
                        confirmPassword=value;
                        });
                      },
                      onSaved: (value) {
               
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: (){
                        controller.getOtp(controller.forgetPasswordRequest);
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
                    ElevatedButton(onPressed: (){Get.to(OTPInputPage());}, child: Text("Next"))
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

