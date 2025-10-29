import 'package:dating_application/Screens/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:country_code_picker/country_code_picker.dart';
import '../../Controllers/controller.dart';
import '../../constants.dart';

class UserInputPage extends StatefulWidget {
  const UserInputPage({super.key});

  @override
  UserInputPageState createState() => UserInputPageState();
}

class UserInputPageState extends State<UserInputPage>
    with SingleTickerProviderStateMixin {
  final formKey = GlobalKey<FormState>();
  final controller = Get.find<Controller>();
  late AnimationController animationController;
  late Animation<double> fadeInAnimation;

  String selectedCountryCode = '+91';

  @override
  void initState() {
    super.initState();
    controller.userRegistrationRequest.reset();
    controller.userRegistrationRequest.countryCode = selectedCountryCode;

    animationController = AnimationController(
      duration: Duration(milliseconds: 360),
      vsync: this,
    )..forward();

    fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeIn),
    );
  }


  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      failure('Name', 'Please enter your name');
      return 'Please enter your name';
    }

    // Convert to lowercase first
    value = value.toLowerCase().trim();

    // Regex: only alphabets, numbers, and underscore
    // if (!RegExp(r'^[a-z0-9_]+$').hasMatch(value)) {
    //   failure('RE-Enter',
    //       'Must contain only letters and underscore (no spaces or special characters)');
    //   return 'Must contain only letter and underscore';
    // }
    if (RegExp(r'[0-9!@#$%^&*(),.?":{}|<>_\-+=\[\]\\\/;`~]').hasMatch(value)) {
      failure(
          'RE-Enter', 'Name must not contain numbers or special characters');
      return 'Name must not contain numbers or special characters';
    }

    return null;
  }

  String? validateGmail(String? value) {
    if (value == null || value.isEmpty) {
      failure('Email', 'Please enter your email');
      return 'Please enter your email';
    }
    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regExp = RegExp(pattern);
    if (!regExp.hasMatch(value.trim())) {
      return 'Please enter a valid Gmail address';
    }
    return null;
  }

  Widget buildTextField({
    required String label,
    required Function(String) onChanged,
    required String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    double fontSize = MediaQuery.of(context).size.width * 0.03;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        cursorColor: AppColors.cursorColor,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.labelText
              .copyWith(fontSize: fontSize, color: Colors.white),
          filled: true,
          fillColor: AppColors.formFieldColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.textColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.activeColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.textColor),
          ),
          suffixIcon: suffixIcon,
        ),
        style: TextStyle(fontSize: fontSize, color: Colors.white),
        validator: validator,
        onChanged: onChanged,
        keyboardType: keyboardType,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        obscureText: obscureText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double fontSize = size.width * 0.03;

    return Container(
      color: AppColors.primaryColor,
      child: AuthCard(
        title: 'Register',
        animation: fadeInAnimation,
        maxHeight: size.height * 0.7,
        child: Form(
          key: formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              SizedBox(height: 8),
              Text(
                'Please provide your username, email, and other details.',
                style: TextStyle(
                  fontSize: fontSize,
                  color: AppColors.textColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              buildTextField(
                label: 'User Name',
                onChanged: (value) {
                  controller.registrationOTPRequest.name = value.trim();
                  controller.userRegistrationRequest.username = value.trim();
                },
                validator: validateName,
              ),
              buildTextField(
                label: 'Email',
                onChanged: (value) {
                  controller.registrationOTPRequest.email = value.trim();
                  controller.userRegistrationRequest.email = value.trim();
                },
                validator: validateGmail,
                keyboardType: TextInputType.emailAddress,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.formFieldColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.textColor),
                      ),
                      child: CountryCodePicker(
                        onChanged: (country) {
                          setState(() {
                            selectedCountryCode = country.dialCode ?? '+91';
                            controller.userRegistrationRequest.countryCode =
                                selectedCountryCode;
                          });
                        },
                        initialSelection: selectedCountryCode,
                        favorite: ['+91'],
                        textStyle: AppTextStyles.inputFieldText.copyWith(
                          fontSize: fontSize * 1, // Larger text
                          color: Colors.white,
                        ),
                        dialogTextStyle: AppTextStyles.bodyText.copyWith(
                          fontSize: fontSize * 1.15, // Larger text in dialog
                          color: Colors.white,
                        ),
                        dialogBackgroundColor: Colors.black, // Popup background
                        searchStyle: AppTextStyles.bodyText.copyWith(
                          fontSize: fontSize * 1.1,
                          color: Colors.white,
                        ),
                        searchDecoration: InputDecoration(
                          hintText: 'Search country',
                          hintStyle: TextStyle(
                              color: Colors.white70, fontSize: fontSize * 1.1),
                          filled: true,
                          fillColor: Colors.black,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.white24),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.white24),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        showCountryOnly: false,
                        showOnlyCountryWhenClosed: false,
                        alignLeft: false,
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        flagWidth: 25,
                        showFlag: true,
                        showDropDownButton: true,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        cursorColor: AppColors.cursorColor,
                        decoration: InputDecoration(
                          labelText: 'Mobile Number',
                          labelStyle: AppTextStyles.labelText.copyWith(
                            fontSize: fontSize,
                            color: Colors.white,
                          ),
                          filled: true,
                          fillColor: AppColors.formFieldColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: AppColors.textColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: AppColors.activeColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: AppColors.textColor),
                          ),
                        ),
                        style:
                            TextStyle(fontSize: fontSize, color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a mobile number';
                          } else if (value.length != 10) {
                            return 'Mobile number must be 10 digits';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        onChanged: (value) {
                          controller.registrationOTPRequest.mobile = value;
                          controller.userRegistrationRequest.mobile = value;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              buildTextField(
                label: 'Referral Code',
                onChanged: (value) {
                  controller.registrationOTPRequest.referalcode = value;
                  controller.userRegistrationRequest.referalcode = value;
                },
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(r'^[a-zA-Z0-9]{6}$').hasMatch(value)) {
                      return 'Referral code must be exactly 6 alphanumeric characters';
                    }
                  }
                  return null;
                },
                maxLength: 6,
              ),
              SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment(0.8, 1),
                    colors: AppColors.gradientBackgroundList,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      if (controller.registrationOTPRequest.validate()) {
                        controller.getOtpForRegistration(
                            controller.registrationOTPRequest);
                      }
                      // Get.snackbar('Email is',
                      //     controller.registrationOTPRequest.email.toString());
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
                    backgroundColor: Colors.transparent,
                    padding:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  child: Text(
                    'Register',
                    style:
                        AppTextStyles.buttonText.copyWith(fontSize: fontSize),
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
