import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

const encryptionkey = "flamrpisyst2024!";
const secretkey = "ArqamzSnehaSadiq@flamrdating2024";
const baseurl = "http://192.168.1.2/dating_backend_springboot/admin";
const ip = "http://192.168.1.2/dating_backend_springboot/";

const springbooturl = "http://192.168.1.2:8080";

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
  static Color nopeColor = Color.fromARGB(255, 144, 184, 208);
  static Color favouriteColor = Color.fromARGB(255, 97, 154, 187);
  static Color likeColor = Color.fromARGB(255, 162, 168, 162);
  static Color filterChipColor = Colors.grey;
  static Color textColor = Colors.white;
  static Color accentColor = Colors.black;
  static Color cursorColor = Colors.white;
  static Color acceptColor = const Color.fromARGB(255, 119, 120, 119);
  static Color deniedColor = const Color.fromARGB(255, 195, 167, 165);
  static Color iconColor = const Color.fromARGB(255, 0, 59, 107);
  static Color buttonColor = const Color.fromARGB(255, 0, 64, 117);
  static Color chipColor = Colors.grey;
  static Color formFieldColor = Color.fromARGB(255, 85, 84, 84);
  static Color inactiveColor = const Color.fromARGB(255, 178, 126, 122);
  static Color activeColor = const Color.fromARGB(255, 123, 124, 123);
  static Color successColor =
      const Color.fromARGB(255, 116, 158, 116).withOpacity(0.3);
  static Color successBorderColor = const Color.fromARGB(255, 106, 154, 108);
  static Color errorColor =
      const Color.fromARGB(196, 114, 8, 0).withOpacity(0.3);
  static Color errorBorderColor = const Color.fromARGB(205, 100, 8, 0);
  //static Color navigationColor =  Color.fromARGB(255, 63, 62, 62);
  static Color navigationColor = Color.fromARGB(255, 197, 173, 122);
  static Color navigationColorleft = Color.fromARGB(255, 47, 27, 27);
  static Color navigationright = Color.fromARGB(255, 115, 111, 111);
  static Color progressColor = Color(0xFFD3D3D3);
  static var primaryTextColor;
  static var shadowColor;
  static LinearGradient gradientBackground = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment(0.8, 1),
    colors: <Color>[
      Color(0xff1f005c),
      Color(0xff5b0060),
      Color(0xff870160),
      Color(0xffac255e),
      Color(0xffca485c),
      Color(0xffe16b5c),
      Color(0xfff39060),
      Color(0xffffb56b),
    ],
  );
}

class AppTextStyles {
  static const double headingSize = 32.0;
  static const double subheadingSize = 24.0;
  static const double titleSize = 17.0;
  static const double bodySize = 12.0;
  static const double buttonSize = 12.0;
  static const double labelSize = 14.0;
  static const double inputFieldSize = 16.0;
  static const double textSize = 9.0;

  static final TextStyle headingText = GoogleFonts.roboto(
    fontSize: headingSize,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static final TextStyle subheadingText = GoogleFonts.roboto(
    fontSize: subheadingSize,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static final TextStyle titleText = GoogleFonts.roboto(
    fontSize: titleSize,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static final TextStyle bodyText = GoogleFonts.roboto(
    fontSize: bodySize,
    fontWeight: FontWeight.normal,
    color: Colors.white,
  );

  static final TextStyle buttonText = GoogleFonts.roboto(
    fontSize: buttonSize,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  static final TextStyle labelText = GoogleFonts.roboto(
    fontSize: labelSize,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );

  static final TextStyle inputFieldText = GoogleFonts.roboto(
    fontSize: inputFieldSize,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );

  static final TextStyle errorText = GoogleFonts.roboto(
    fontSize: bodySize,
    fontWeight: FontWeight.bold,
    color: Colors.red,
  );

  static final TextStyle textStyle = GoogleFonts.roboto(
    fontSize: textSize,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static final TextStyle transactionTextStyle = GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle customTextStyle({
    double fontSize = 12.0,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.black,
  }) {
    return GoogleFonts.roboto(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  static TextStyle responsiveTextStyle({
    required double screenWidth,
    required double scaleFactor,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.black,
  }) {
    return GoogleFonts.roboto(
      fontSize: screenWidth * scaleFactor,
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
            color: Colors.white,
            size: 24,
          ),
          SizedBox(width: 10),
          Text(
            title,
            style: GoogleFonts.raleway(
              color: Colors.white,
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
          color: Colors.white,
          fontSize: 14,
        ),
      ),
    ),
    colorText: Colors.white,
    backgroundColor: const Color.fromARGB(255, 156, 158, 156).withOpacity(0.85),
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
            color: Colors.white,
            size: 24,
          ),
          SizedBox(width: 10),
          Text(
            title,
            style: GoogleFonts.raleway(
              color: Colors.white,
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
          color: Colors.white,
          fontSize: 14,
        ),
      ),
    ),
    colorText: Colors.white,
    backgroundColor: const Color.fromARGB(255, 192, 191, 190).withOpacity(0.85),
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
  // static const String RAZORPAYKEYID = "rzp_live_lqdEPFltHtYYIS";
  // static const String RAZORPAYKEYSECRET = "DJqvCl24zHwSeWK340FRAxyd";
}

class Transactionsuccess {
  static const String SUCCESS = '1';
  static const String PENDING = '2';
  static const String FAIL = '3';
}

class AgoraConstants {
  static const String AGORAAPPID = "634e7bd12a274233873a7fc98f721c64";
}
