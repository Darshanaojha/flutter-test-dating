import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

const $baseUrl = "http://localhost/datingApplication/admin/";
const $registerUrl = "Authentication/register";
const $loginUrl = "Authentication/login";
const $profileUrl = "Authentication/profile";


// Base URLs
// const String $baseUrl = "http://localhost/datingApplication/admin/";
// const String $registerUrl = "Authentication/register";
// const String $loginUrl = "Authentication/login";
// const String $profileUrl = "Authentication/profile";

// Global Text Styles
final TextStyle ConstantTitleStyle = GoogleFonts.lato(
  color: Colors.black,
  fontSize: 16,
  fontWeight: FontWeight.bold,
);

final TextStyle ConstantMessageStyle = GoogleFonts.lato(
  color: Colors.black,
  fontSize: 14,
);

// Global Colors
final Color successColor = Colors.green.withOpacity(0.3);
final Color successBorderColor = Colors.green;
final Color errorColor = Colors.red.withOpacity(0.3);
final Color errorBorderColor = Colors.red;
final Color textColor = Colors.black;


void showCustomSnackBar(String title, String message, bool isSuccess) {
  Get.snackbar(
    '',
    '',
    titleText: Text(
      title,
      style: ConstantTitleStyle, 
    ),
    messageText: Text(
      message,
      style: ConstantMessageStyle,  
    ),
    colorText: textColor, 
    backgroundColor: isSuccess ? successColor : errorColor,  
    borderColor: isSuccess ? successBorderColor : errorBorderColor, 
    borderWidth: 2,
  );
}

void showSuccessSnackBar(title, message) {
  Get.snackbar(
    '',
    '',
    titleText: Text(
      title,
      style: GoogleFonts.lato(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
    messageText: Text(
      message,
      style: GoogleFonts.lato(
        color: Colors.black,
        fontSize: 14,
      ),
    ),
    colorText: Colors.black,
    backgroundColor: Colors.green.withOpacity(0.3),
    borderColor: Colors.green,
    borderWidth: 2,
  );
}

void showFailedSnackBar(title, message) {
  Get.snackbar(
    '',
    '',
    titleText: Text(
      title,
      style: GoogleFonts.lato(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
    messageText: Text(
      message,
      style: GoogleFonts.lato(
        color: Colors.black,
        fontSize: 14,
      ),
    ),
    colorText: Colors.black,
    backgroundColor: Colors.red.withOpacity(0.3),
    borderColor: Colors.red,
    borderWidth: 2,
  );
}
