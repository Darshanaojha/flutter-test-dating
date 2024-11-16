import 'package:dating_application/Models/RequestModels/registration_otp_request_model.dart';
import 'package:dating_application/Screens/register_subpag/registrationotp.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Providers/registration_provider.dart';
import '../../constants.dart';

class UserInputPage extends StatefulWidget {
  const UserInputPage({super.key});

  @override
  UserInputPageState createState() => UserInputPageState();
}

class UserInputPageState extends State<UserInputPage> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  String name = '';
  String email = '';

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regExp = RegExp(pattern);
    if (!regExp.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  void submitForm() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      RegistrationOTPRequest registrationRequest = RegistrationOTPRequest(
        email: email,
        name: name,
      );

      try {
        RegistrationProvider registrationProvider = Get.find();
        var response = await registrationProvider.sendOtp(registrationRequest);

        if (response != null) {
          Get.to(OTPVerificationPage());
        } else {
          print('Error sending OTP');
        }
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.04;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Information',
          style:
              TextStyle(fontSize: fontSize * 1.2, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: screenWidth * 0.1, vertical: 30),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Text(
                  'Please provide your name and email.',
                  style: TextStyle(
                    fontSize: fontSize,
                    color: AppColors.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                TextFormField(
                  controller: nameController,
                  cursorColor: AppColors.cursorColor,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(
                        fontSize: fontSize, color: AppColors.secondaryColor),
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
                  ),
                  style: TextStyle(
                      fontSize: fontSize, color: AppColors.primaryColor),
                  validator: validateName,
                  onChanged: (value) {
                    setState(() {
                      name = value;
                    });
                  },
                  onSaved: (value) {
                    name = value ?? '';
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: emailController,
                  cursorColor: AppColors.cursorColor,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(
                        fontSize: fontSize, color: AppColors.secondaryColor),
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
                  ),
                  style: TextStyle(
                      fontSize: fontSize, color: AppColors.primaryColor),
                  validator: validateEmail,
                  onChanged: (value) {
                    setState(() {
                      email = value;
                    });
                  },
                  onSaved: (value) {
                    email = value ?? '';
                  },
                ),
                SizedBox(height: 40),

                // Submit Button
                ElevatedButton(
                  onPressed: submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonColor,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Submit',
                    style: TextStyle(
                        fontSize: fontSize, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      Get.to(OTPVerificationPage());
                    },
                    child: Text("Next"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
