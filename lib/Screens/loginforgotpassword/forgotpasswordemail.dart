
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants.dart';
import 'forgotpasswordotp.dart';

class EmailInputPage extends StatefulWidget {
  const EmailInputPage({super.key});

  @override
  EmailInputPageState createState() => EmailInputPageState();
}

class EmailInputPageState extends State<EmailInputPage> {
  final formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  String email = '';

  // Function to validate email format
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email address';
    }
    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regExp = RegExp(pattern);
    if (!regExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.03; // Adjust font size based on screen width

    return Scaffold(
      appBar: AppBar(
        title: Text('Email Input', style: AppTextStyles.headingText),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1, vertical: 30),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'Enter your email address to proceed.',
                style: AppTextStyles.bodyText.copyWith(fontSize: fontSize),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              
              Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: emailController,
                      style: AppTextStyles.inputFieldText.copyWith(fontSize: fontSize),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: AppTextStyles.labelText.copyWith(fontSize: fontSize),
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
                      validator: validateEmail,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 20),

                    // Submit Button
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          setState(() {
                            email = emailController.text;
                          });
                          // Handle the email submission here, e.g., navigate to another page or display success
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Email Submitted: $email')),
                          );
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
                      Get.to(OTPInputPage());
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
