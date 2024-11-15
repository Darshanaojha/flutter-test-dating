import 'package:flutter/material.dart';
import 'package:get/get.dart'; 
import '../Controllers/controller.dart';
import '../RequestModels/login.dart';
import '../constants.dart';
import 'register_subpag/registerdetails.dart'; 

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> with TickerProviderStateMixin {
  Controller controller = Get.put(Controller());
  final _formKey = GlobalKey<FormState>();
  late LoginRequest _loginRequest;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _loginRequest = LoginRequest(email: '', password: '');

    _animationController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    )..forward();

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        color: AppColors.primaryColor,
        child: Center(
          child: FadeTransition(
            opacity: _fadeInAnimation,
            child: Container(
              width: size.width * 0.9,
              height: size.height * 0.7,
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      _buildTextField('Email', (value) {
                        _loginRequest.email = value;
                      }, TextInputType.emailAddress, size),
                      _buildPasswordField('Password', (value) {
                        _loginRequest.password = value;
                      }, size),
                      SizedBox(height: size.height * 0.05),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          foregroundColor: AppColors.textColor,
                          backgroundColor: AppColors.buttonColor, 
                          padding: EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 32.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text('Login', style: AppTextStyles.buttonText),
                      ),
                      SizedBox(height: size.height * 0.02),
                      _buildForgotPasswordButton(),
                      _buildRegisterButton(size),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label, Function(String) onSaved, TextInputType type, Size size) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        keyboardType: type,
        cursorColor: AppColors.cursorColor,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.textColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.textColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.textColor),
          ),
          fillColor: AppColors.formFieldColor,
          filled: true,
        ),
        onSaved: (value) => onSaved(value!),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField(
    String label, Function(String) onSaved, Size size) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        obscureText: true,
        cursorColor: AppColors.cursorColor,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.textColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.textColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.textColor),
          ),
          fillColor: AppColors.formFieldColor,
          filled: true,
        ),
        onSaved: (value) => onSaved(value!),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return TextButton(
      onPressed: () {
        Get.to(() => ForgotPasswordScreen());
      },
      child: Text(
        'Forgot Password?',
        style: AppTextStyles.buttonText,
      ),
    );
  }

  // Register Button
  Widget _buildRegisterButton(Size size) {
    return Column(
      children: [
        SizedBox(height: size.height * 0.02),
        TextButton(
          onPressed: () {
            Get.to(RegisterProfilePage());
          },
          child: Text(
            'Don\'t have an account? Register here',
            style: AppTextStyles.buttonText,
          ),
        ),
      ],
    );
  }
}

// Forgot Password Screen
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
      ),
      body: Center(
        child: Text('Forgot Password screen content here'),
      ),
    );
  }
}

