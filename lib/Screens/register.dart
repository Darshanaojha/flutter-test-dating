import 'package:dating_application/RequestModels/register.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Controllers/controller.dart';
import '../constants.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  RegisterState createState() => RegisterState();
}

class RegisterState extends State<Register> {
  Controller controller = Get.put(Controller());
  final _formKey = GlobalKey<FormState>();
  late RegisterRequest _registerRequest;

  @override
  void initState() {
    super.initState();
    _registerRequest = RegisterRequest(
        name: '',
        email: '',
        mobile: '',
        city: '',
        state: '',
        address: '',
        gender: '',
        password: '');
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Register',
            style: GoogleFonts.lato(fontSize: size.width * 0.05)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField('Name', (value) => _registerRequest.name = value,
                  TextInputType.text, size),
              _buildTextField(
                  'Email',
                  (value) => _registerRequest.email = value,
                  TextInputType.emailAddress,
                  size),
              _buildTextField(
                  'Mobile',
                  (value) => _registerRequest.mobile = value,
                  TextInputType.phone,
                  size),
              _buildTextField('City', (value) => _registerRequest.city = value,
                  TextInputType.text, size),
              _buildTextField(
                  'State',
                  (value) => _registerRequest.state = value,
                  TextInputType.text,
                  size),
              _buildTextField(
                  'Address',
                  (value) => _registerRequest.address = value,
                  TextInputType.text,
                  size),
              _buildTextField(
                  'Gender',
                  (value) => _registerRequest.gender = value,
                  TextInputType.text,
                  size),
              _buildPasswordField('Password',
                  (value) => _registerRequest.password = value, size),
              _buildPasswordField('Confirm Password', (value) {
                if (value != _registerRequest.password) {
                  return 'Passwords do not match';
                }
                return null;
              }, size),
              SizedBox(height: size.width * 0.05),
              ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  textStyle: GoogleFonts.lato(fontSize: size.width * 0.05),
                  padding: EdgeInsets.symmetric(vertical: size.width * 0.05),
                ),
                child: const Text('Register'),
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
      padding: EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.lato(fontSize: size.width * 0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
          labelStyle: GoogleFonts.lato(fontSize: size.width * 0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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

  void _register() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String? validationError = _registerRequest.validate();
      if (validationError != null) {
        showFailedSnackBar('Error', validationError);
        return;
      }
      controller.register(_registerRequest);
    }
  }
}
