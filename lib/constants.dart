import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
const encryptionkey = "flamrpisyst2024!";
const baseurl = "http://192.168.1.7/dating_backend_springboot/admin";
const ip = "http://192.168.1.7/dating_backend_springboot/";
const registerUrl = "Authentication/register";
const loginUrl = "Authentication/login";
const profileUrl = "Authentication/profile";

class AppColors {
  static const Color primaryColor = Colors.black;
 static const Color disabled =Colors.grey;
 
  static const Color secondaryColor = Color(0xFF1C1C1C);
  static const Color textColor = Colors.white;
  static const Color accentColor = Colors.black;
  static const Color cursorColor = Colors.white;
  static const Color acceptColor = Colors.green;
  static const Color deniedColor = Colors.red;
  static const Color iconColor = Colors.blue;
  static const Color buttonColor = Colors.blue;
  static const Color chipColor = Colors.orange;
  static const Color formFieldColor = Color.fromARGB(255, 85, 84, 84);
  static const Color inactiveColor = Colors.red;
  static const Color activeColor = Colors.green;
  static Color successColor = Colors.green.withOpacity(0.3);
  static Color successBorderColor = Colors.green;
  static Color errorColor = Colors.red.withOpacity(0.3);
  static Color errorBorderColor = Colors.red;
  static Color navigationColor = Colors.orange;
  static Color progressColor = Colors.orange;

  static var primaryTextColor;
}

class AppTextStyles {
  static const String baseFontFamily = 'raleway';
  static const double headingSize = 32.0;
  static const double subheadingSize = 24.0;
  static const double titleSize = 20.0;
  static const double bodySize = 16.0;
  static const double buttonSize = 14.0;
  static const double labelSize = 14.0;
  static const double inputFieldSize = 16.0;
  static const double textSize = 12.0;

  static TextStyle headingText = GoogleFonts.raleway(
    fontSize: headingSize,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  static TextStyle textStyle = GoogleFonts.raleway(
    fontSize: textSize,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle subheadingText = GoogleFonts.raleway(
    fontSize: subheadingSize,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle titleText = GoogleFonts.raleway(
    fontSize: titleSize,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle bodyText = GoogleFonts.raleway(
    fontSize: bodySize,
    fontWeight: FontWeight.normal,
    color: Colors.white,
  );

  static TextStyle buttonText = GoogleFonts.raleway(
    fontSize: buttonSize,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  static TextStyle labelText = GoogleFonts.raleway(
    fontSize: labelSize,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );

  static TextStyle inputFieldText = GoogleFonts.raleway(
    fontSize: inputFieldSize,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );
  static TextStyle errorText = GoogleFonts.raleway(
    fontSize: bodySize,
    fontWeight: FontWeight.bold,
    color: Colors.red,
  );
  static TextStyle customTextStyle(
      {double fontSize = 16.0,
      FontWeight fontWeight = FontWeight.normal,
      Color color = Colors.black}) {
    return GoogleFonts.raleway(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
}

final TextStyle ConstantTitleStyle = GoogleFonts.raleway(
  color: Colors.black,
  fontSize: 16,
  fontWeight: FontWeight.bold,
);

final TextStyle ConstantMessageStyle = GoogleFonts.raleway(
  color: Colors.black,
  fontSize: 14,
);

final Color successColor = Colors.green.withOpacity(0.3);
final Color successBorderColor = Colors.green;
final Color errorColor = Colors.red.withOpacity(0.3);
final Color errorBorderColor = Colors.red;
final Color textColor = Colors.white;

void success(title, message) {
  Get.snackbar(
    '',
    '',
    titleText: Text(
      title,
      style: GoogleFonts.raleway(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
    messageText: Text(
      message,
      style: GoogleFonts.raleway(
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

void failure(title, message) {
  Get.snackbar(
    '',
    '',
    titleText: Text(
      title,
      style: GoogleFonts.raleway(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
    messageText: Text(
      message,
      style: GoogleFonts.raleway(
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

class FirebaseConstants {
  static const String apiKey = 'AIzaSyC3ROuYfPMzBPPtA4f_5HsxfVilIUuxgbc';
  static const String appId = '1:837611833070:android:3cd2c487816f9828f215ff';
  static const String messagingSenderId = '837611833070';
  static const String projectId = 'datingapplication-f7813';
  static const String storageBucket = 'datingapplication-f7813.firebasestorage.app';

  static const FirebaseOptions firebaseOptions = FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    storageBucket: storageBucket,
  );
}
