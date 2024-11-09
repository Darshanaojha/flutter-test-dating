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
class AppColors {
  static const Color primaryColor = Colors.black;

  static const Color secondaryColor = Color(0xFF1C1C1C);
  static const Color textColor = Colors.white;
  static const Color accentColor = Colors.black;
  static const Color cursorColor = Colors.white;
  static const Color acceptColor = Colors.green;
  static const Color deniedColor = Colors.red;
  static const Color iconColor = Colors.blue;
  static const Color buttonColor = Colors.blue;
  static const Color formFieldColor =
      Color.fromARGB(255, 85, 84, 84);
  static const Color inactiveColor = Colors.green;

  final Color successColor = Colors.green.withOpacity(0.3);
  final Color successBorderColor = Colors.green;
  final Color errorColor = Colors.red.withOpacity(0.3);
  final Color errorBorderColor = Colors.red;
}


class AppTextStyles {
  // Base font family (you can change this to a custom font or use a system font)
  static const String baseFontFamily = 'Lato';

  // Font Sizes
  static const double headingSize = 32.0;        // For headings
  static const double subheadingSize = 24.0;     // For subheadings or section titles
  static const double titleSize = 20.0;          // For page titles or main section headers
  static const double bodySize = 16.0;           // For body text
  static const double buttonSize = 14.0;         // For button text
  static const double labelSize = 14.0;          // For labels and small text
  static const double inputFieldSize = 16.0;     // For input fields
  static const double textSize = 12.0; 

  // Text Styles for different components
  static TextStyle headingText = GoogleFonts.lato(
    fontSize: headingSize,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
   static TextStyle textStyle = GoogleFonts.lato(
    fontSize: textSize,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle subheadingText = GoogleFonts.lato(
    fontSize: subheadingSize,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle titleText = GoogleFonts.lato(
    fontSize: titleSize,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle bodyText = GoogleFonts.lato(
    fontSize: bodySize,
    fontWeight: FontWeight.normal,
    color: Colors.white,
  );

  static TextStyle buttonText = GoogleFonts.lato(
    fontSize: buttonSize,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  static TextStyle labelText = GoogleFonts.lato(
    fontSize: labelSize,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );

  static TextStyle inputFieldText = GoogleFonts.lato(
    fontSize: inputFieldSize,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );
   // Error Text Style
  static TextStyle errorText = GoogleFonts.lato(
    fontSize: bodySize,
    fontWeight: FontWeight.bold,
    color: Colors.red, // Red color for error text
  );
  // You can define custom styles here too
  static TextStyle customTextStyle({double fontSize = 16.0, FontWeight fontWeight = FontWeight.normal, Color color = Colors.black}) {
    return GoogleFonts.lato(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
}

final TextStyle ConstantTitleStyle = GoogleFonts.lato(
  color: Colors.black,
  fontSize: 16,
  fontWeight: FontWeight.bold,
);

final TextStyle ConstantMessageStyle = GoogleFonts.lato(
  color: Colors.black,
  fontSize: 14,
);

final Color successColor = Colors.green.withOpacity(0.3);
final Color successBorderColor = Colors.green;
final Color errorColor = Colors.red.withOpacity(0.3);
final Color errorBorderColor = Colors.red;
final Color textColor = Colors.white;
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

// class FirebaseConstants {
//   static const String apiKey = '';
//   static const String appId = '';
//   static const String messagingSenderId = '';
//   static const String projectId = '';
//   static const String storageBucket = '';

//   static const FirebaseOptions firebaseOptions = FirebaseOptions(
//     apiKey: apiKey,
//     appId: appId,
//     messagingSenderId: messagingSenderId,
//     projectId: projectId,
//     storageBucket: storageBucket,
//   );
// }
