import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

const encryptionkey = "flamrpisyst2024!";
const secretkey = "ArqamzSnehaSadiq@flamrdating2024";
const baseurl = "http://192.168.1.5/dating_backend_springboot/admin";
const ip = "http://192.168.1.5/dating_backend_springboot/";
const registerUrl = "Authentication/register";
const loginUrl = "Authentication/login";
const profileUrl = "Authentication/profile";

const int textMessage = 1;
const int imageMessage = 2;
const int emogiMessage = 3;

class AppColors {
  static Color primaryColor = Colors.black;
  static Color disabled = Colors.grey;
  static Color secondaryColor = Color(0xFF1C1C1C);
  static Color NopeColor = Color.fromARGB(255, 25, 147, 217);
  static Color FavouriteColor = Color.fromARGB(255, 25, 147, 217);
  static Color LikeColor = Color.fromARGB(255, 46, 212, 52);
  static Color FilterChipColor = Colors.grey;
  static Color textColor = Colors.white;
  static Color accentColor = Colors.black;
  static Color cursorColor = Colors.white;
  static Color acceptColor = Colors.green;
  static Color deniedColor = Colors.red;
  static Color iconColor = Colors.blue;
  static Color buttonColor = Colors.blue;
  static Color chipColor = Colors.grey;
  static Color formFieldColor = Color.fromARGB(255, 85, 84, 84);
  static Color inactiveColor = Colors.red;
  static Color activeColor = Colors.green;
  static Color successColor = Colors.green.withOpacity(0.3);
  static Color successBorderColor = Colors.green;
  static Color errorColor = Colors.red.withOpacity(0.3);
  static Color errorBorderColor = Colors.red;
  //static Color navigationColor =  Color.fromARGB(255, 63, 62, 62);
  static Color navigationColor = Color.fromARGB(255, 123, 83, 83);
  static Color navigationColorleft = Color.fromARGB(255, 47, 27, 27);
  static Color navigationright = Color.fromARGB(255, 115, 111, 111);
  static Color progressColor = Color(0xFFD3D3D3);
  static var primaryTextColor;

  static var shadowColor;
}

class AppTextStyles {
  static const String baseFontFamily = 'raleway';
  static const double headingSize = 32.0;
  static const double subheadingSize = 24.0;
  static const double titleSize = 17.0;
  static const double bodySize = 12.0;
  static const double buttonSize = 12.0;
  static const double labelSize = 14.0;
  static const double inputFieldSize = 16.0;
  static const double textSize = 9.0;

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
      {double fontSize = 12.0,
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
    titleText: Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Colors.black,
            size: 24,
          ),
          SizedBox(width: 10),
          Text(
            title,
            style: GoogleFonts.raleway(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
    messageText: Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Text(
        message,
        style: GoogleFonts.raleway(
          color: Colors.black,
          fontSize: 14,
        ),
      ),
    ),
    colorText: Colors.black,
    backgroundColor: Colors.green.withOpacity(0.85),
    borderColor: Colors.green.shade700,
    borderWidth: 2,
    borderRadius: 8.0,
    snackPosition: SnackPosition.TOP,
    margin: EdgeInsets.all(16),
    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    duration: Duration(seconds: 3),
    animationDuration: Duration(milliseconds: 250),
  );
}

void failure(title, message) {
  Get.snackbar(
    '',
    '',
    titleText: Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.black,
            size: 24,
          ),
          SizedBox(width: 10),
          Text(
            title,
            style: GoogleFonts.raleway(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
    messageText: Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Text(
        message,
        style: GoogleFonts.raleway(
          color: Colors.black,
          fontSize: 14,
        ),
      ),
    ),
    colorText: Colors.black,
    backgroundColor: Colors.red.withOpacity(0.85),
    borderColor: Colors.red.shade700,
    borderWidth: 2,
    borderRadius: 8.0,
    snackPosition: SnackPosition.TOP,
    margin: EdgeInsets.all(16),
    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    duration: Duration(seconds: 3),
    animationDuration: Duration(milliseconds: 250),
  );
}

class FirebaseConstants {
  static const String apiKey = 'AIzaSyC3ROuYfPMzBPPtA4f_5HsxfVilIUuxgbc';
  static const String appId = '1:837611833070:android:3cd2c487816f9828f215ff';
  static const String messagingSenderId = '837611833070';
  static const String projectId = 'datingapplication-f7813';
  static const String storageBucket =
      'datingapplication-f7813.firebasestorage.app';

  static const FirebaseOptions firebaseOptions = FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    storageBucket: storageBucket,
  );
}

class PusherConstants {
  static const String appId = "1912870";
  static const String key = "462873f11046bfe1fce0";
  static const String secret = "b20f2092482a6c3720ab";
  static const String cluster = "ap2";
}

class RazorpayKeys {
  static const String RAZORPAYKEYID = "rzp_test_27Thf113vIC8Np";
  static const String RAZORPAYKEYSECRET = "XSyj935cHFhXwXF6JdmFK8QA";
}
