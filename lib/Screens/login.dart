import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Controllers/controller.dart';
import '../RequestModels/login.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  Controller controller = Get.put(Controller());
  final _formKey = GlobalKey<FormState>();
  late LoginRequest _loginRequest;

  @override
  void initState() {
    super.initState();
    _loginRequest = LoginRequest(email: '', password: '');
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        centerTitle: true,
      ),
      body: Padding(
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
                onPressed: _login,
                child: Text('Login'),
              ),
            ],
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
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
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
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
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

  void _login() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Validate the email and password
      String? validationError = _loginRequest.validate();
      if (validationError != null) {
        // Display validation error
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(validationError)));
        return;
      }
      controller.login(_loginRequest);
    }
  }
}
