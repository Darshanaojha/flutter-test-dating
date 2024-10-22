import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

const $baseUrl = "http://localhost/datingApplication/admin/";
const $registerUrl = "Authentication/register";
const $loginUrl = "Authentication/login";
const $profileUrl = "Authentication/profile";

void showSuccessSnackBar(title, message) {
  Get.snackbar(
    '',
    '',
    titleText: Text(
      title,
      style: GoogleFonts.lato(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
    messageText: Text(
      message,
      style: GoogleFonts.lato(
        color: Colors.white,
        fontSize: 14,
      ),
    ),
    colorText: Colors.white,
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
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
    messageText: Text(
      message,
      style: GoogleFonts.lato(
        color: Colors.white,
        fontSize: 14,
      ),
    ),
    colorText: Colors.white,
    backgroundColor: Colors.red.withOpacity(0.3),
    borderColor: Colors.red,
    borderWidth: 2,
  );
}
