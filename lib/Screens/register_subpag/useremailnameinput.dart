import 'package:dating_application/Screens/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:lottie/lottie.dart';
import '../../Controllers/controller.dart';
import '../../constants.dart';
import '../../Providers/check_username_provider.dart';

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
  final CheckUsernameProvider checkUsernameProvider = CheckUsernameProvider();
  final TextEditingController usernameController = TextEditingController();
  
  bool _isCheckingUsername = false;
  bool _isUsernameChecked = false;
  bool _isUsernameAvailable = false;
  String? _usernameStatusMessage;

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

  @override
  void dispose() {
    usernameController.dispose();
    super.dispose();
  }

  Future<void> _checkUsernameAvailability() async {
    final username = usernameController.text.trim().toLowerCase();
    
    if (username.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a username first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Validate username format
    if (RegExp(r'[0-9!@#$%^&*(),.?":{}|<>_\-+=\[\]\\\/;`~]').hasMatch(username)) {
      Get.snackbar(
        'Invalid Username',
        'Name must not contain numbers or special characters',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isCheckingUsername = true;
      _isUsernameChecked = false;
      _isUsernameAvailable = false;
      _usernameStatusMessage = null;
    });

    try {
      final result = await checkUsernameProvider.checkUsernameAvailability(username);
      
      setState(() {
        _isCheckingUsername = false;
        if (result != null) {
          _isUsernameChecked = true;
          _isUsernameAvailable = result['available'] ?? false;
          _usernameStatusMessage = result['message'] ?? 
            (_isUsernameAvailable ? 'Username is available' : 'Username is not available');
          
          if (_isUsernameAvailable) {
            Get.snackbar(
              'Success',
              'Username is available',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Color(0xFF895294), // Medium-light purple
              colorText: Colors.white,
              duration: Duration(seconds: 2),
            );
          } else {
            Get.snackbar(
              'Unavailable',
              'This username is already taken',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange,
              colorText: Colors.white,
              duration: Duration(seconds: 2),
            );
          }
        } else {
          _isUsernameChecked = false;
          _isUsernameAvailable = false;
          _usernameStatusMessage = 'Failed to check username availability';
        }
      });
    } catch (e) {
      setState(() {
        _isCheckingUsername = false;
        _isUsernameChecked = false;
        _isUsernameAvailable = false;
        _usernameStatusMessage = 'Error checking username';
      });
      Get.snackbar(
        'Error',
        'Failed to check username availability. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
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
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: usernameController,
                      cursorColor: AppColors.cursorColor,
                      decoration: InputDecoration(
                        labelText: 'User Name',
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
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_isCheckingUsername)
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                )
                              else if (_isUsernameChecked)
                                _isUsernameAvailable
                                    ? Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(0xFFB06BB8).withValues(alpha: 0.6),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                            BoxShadow(
                                              color: Color(0xFFA073AE).withValues(alpha: 0.4),
                                              blurRadius: 12,
                                              spreadRadius: 3,
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.check_circle,
                                          color: Color(0xFFB06BB8), // Bright light purple
                                          size: 24,
                                        ),
                                      )
                                    : SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: Lottie.asset(
                                          'assets/animations/usernotavailable.json',
                                          repeat: true,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                              SizedBox(width: 4),
                              Container(
                                margin: EdgeInsets.only(right: 4),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _checkUsernameAvailability,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFF895294), // Medium-light purple
                                            Color(0xFF703A7E), // Purple
                                            Color(0xFF562B63), // Deep violet
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          // Outer glow
                                          BoxShadow(
                                            color: Color(0xFF895294).withValues(alpha: 0.5),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                            offset: Offset(0, 2),
                                          ),
                                          // 3D depth shadow
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.3),
                                            blurRadius: 6,
                                            spreadRadius: 0,
                                            offset: Offset(0, 4),
                                          ),
                                          // Inner highlight
                                          BoxShadow(
                                            color: Color(0xFFB06BB8).withValues(alpha: 0.3),
                                            blurRadius: 4,
                                            spreadRadius: -2,
                                            offset: Offset(0, -1),
                                          ),
                                        ],
                                        border: Border.all(
                                          color: Color(0xFFA073AE).withValues(alpha: 0.5),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        'Check',
                                        style: TextStyle(
                                          fontSize: fontSize * 0.85,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withValues(alpha: 0.3),
                                              blurRadius: 2,
                                              offset: Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      style: TextStyle(fontSize: fontSize, color: Colors.white),
                      validator: (value) {
                        final validationError = validateName(value);
                        if (validationError != null) {
                          return validationError;
                        }
                        if (!_isUsernameChecked) {
                          return 'Please check username availability';
                        }
                        if (!_isUsernameAvailable) {
                          return 'Username is not available';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          // Reset availability check when username changes
                          _isUsernameChecked = false;
                          _isUsernameAvailable = false;
                          _usernameStatusMessage = null;
                        });
                        controller.registrationOTPRequest.name = value.trim();
                        controller.userRegistrationRequest.username = value.trim().toLowerCase();
                      },
                    ),
                    if (_usernameStatusMessage != null && _isUsernameChecked)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, left: 12.0),
                        child: Text(
                          _usernameStatusMessage!,
                          style: TextStyle(
                            fontSize: fontSize * 0.85,
                            color: _isUsernameAvailable 
                                ? Color(0xFFB06BB8) // Bright light purple with glow effect
                                : Colors.orange,
                            shadows: _isUsernameAvailable
                                ? [
                                    Shadow(
                                      color: Color(0xFFB06BB8).withValues(alpha: 0.5),
                                      blurRadius: 4,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ),
                  ],
                ),
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
                  gradient: (_isUsernameChecked && _isUsernameAvailable)
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment(0.8, 1),
                          colors: AppColors.gradientBackgroundList,
                        )
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment(0.8, 1),
                          colors: [
                            Colors.grey.shade700,
                            Colors.grey.shade800,
                          ],
                        ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: ElevatedButton(
                  onPressed: (_isUsernameChecked && _isUsernameAvailable) ? () {
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
                  } : null,
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
                    disabledForegroundColor: Colors.grey.shade400,
                ),
                  child: Text(
                    (_isUsernameChecked && !_isUsernameAvailable)
                        ? 'Username Not Available'
                        : (!_isUsernameChecked)
                            ? 'Check Username First'
                            : 'Register',
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
