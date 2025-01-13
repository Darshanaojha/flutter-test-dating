import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../Controllers/controller.dart';
import '../../constants.dart';

class UserInputPage extends StatefulWidget {
  const UserInputPage({super.key});

  @override
  UserInputPageState createState() => UserInputPageState();
}

class UserInputPageState extends State<UserInputPage> {
  final formKey = GlobalKey<FormState>();
  final controller = Get.find<Controller>();

  @override
  void initState() {
    super.initState();
    initialize();
    controller.userRegistrationRequest.reset();
  }

  initialize() {}

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      failure('Name', 'Please enter your name');
      return 'Please enter your name';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      failure('RE-Enter', 'Name must contain only alphabets');
      return 'Name must contain only alphabets';
    }
    return null;
  }

  String? validateGmail(String? value) {
    if (value == null || value.isEmpty) {
      failure('Email', 'Please enter your email');
      return 'Please enter your email';
    }

    // String pattern = r'^[a-zA-Z0-9._%+-]+@gmail\.com$';
    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

    RegExp regExp = RegExp(pattern);

    if (!regExp.hasMatch(value.trim())) {
      return 'Please enter a valid Gmail address';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.02;

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
                    color: AppColors.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                TextFormField(
                  cursorColor: AppColors.cursorColor,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(
                      fontSize: fontSize,
                      color: AppColors.textColor,
                    ),
                    filled: true,
                    fillColor: AppColors.formFieldColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green, width: 2.0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 1.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  style: TextStyle(
                      fontSize: fontSize, color: AppColors.primaryColor),
                  validator: validateName,
                  onChanged: (value) {
                    controller.registrationOTPRequest.name = value;
                    controller.userRegistrationRequest.name = value;
                  },
                  onSaved: (value) {
                    controller.registrationOTPRequest.name = value ?? '';
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  cursorColor: AppColors.cursorColor,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(
                      fontSize: fontSize,
                      color: AppColors.textColor,
                    ),
                    filled: true,
                    fillColor: AppColors.formFieldColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.green, width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 1.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  style: TextStyle(
                      fontSize: fontSize, color: AppColors.primaryColor),
                  validator: validateGmail,
                  onChanged: (value) {
                    controller.registrationOTPRequest.email = value;
                    controller.userRegistrationRequest.email = value;
                    controller.registrationOTPRequest.email =
                        controller.registrationOTPRequest.email.trim();
                    controller.userRegistrationRequest.email =
                        controller.userRegistrationRequest.email.trim();
                  },
                  onSaved: (value) {
                    controller.registrationOTPRequest.email = value ?? '';
                    controller.userRegistrationRequest.email = value ?? '';
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  cursorColor: AppColors.cursorColor,
                  decoration: InputDecoration(
                    labelText: 'Mobile Number',
                    labelStyle: TextStyle(
                      fontSize: fontSize,
                      color: AppColors.textColor,
                    ),
                    filled: true,
                    fillColor: AppColors.formFieldColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.green, width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 1.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  style: TextStyle(
                      fontSize: fontSize, color: AppColors.primaryColor),
                  keyboardType:
                      TextInputType.phone, 
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(
                        10), 
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a mobile number';
                    } else if (value.length != 10) {
                      return 'Mobile number must be 10 digits';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    controller.registrationOTPRequest.mobile = value;
                    controller.userRegistrationRequest.mobile = value;
                  },
                  onSaved: (value) {
                    controller.registrationOTPRequest.mobile = value ?? '';
                  },
                ),
                SizedBox(height: 40),
                // Submit Button
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      if (controller.registrationOTPRequest.validate()) {
                        controller.getOtpForRegistration(
                            controller.registrationOTPRequest);
                      }

                      Get.snackbar('Email is',
                          controller.registrationOTPRequest.email.toString());
                    } else {
                      failure(
                        'Validation Failed',
                        'Please check your inputs and try again.',
                      );
                    }
                    Get.snackbar('',
                        controller.userRegistrationRequest.toJson().toString());
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.textColor,
                    backgroundColor: AppColors.buttonColor,
                    padding:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Submit',
                    style: TextStyle(
                        fontSize: fontSize, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
