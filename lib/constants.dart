import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

String get baseurl => "http://$ipAddress/dating_backend_springboot/admin";
String get ip => "http://$ipAddress/dating_backend_springboot/";
// String get baseurl => "http://$ipAddress";
// String get ip => "http://$ipAddress/";
String get springbooturl => "http://$ipSpringAddress:8080";
// String ipAddress = "150.241.245.210";
//String ipSpringAddress = "150.241.245.210";
String ipSpringAddress = "192.168.1.4";
// String ipAddress = "guidebooky-hezekiah-nonoperative.ngrok-free.dev";
String ipAddress = "192.168.1.4";
const String appName = "cajed.in";

const encryptionkey = "flamrpisyst2024!";
const secretkey = "ArqamzSnehaSadiq@flamrdating2024";

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
  static Color acceptColor = const Color.fromARGB(255, 255, 255, 255);
  static Color deniedColor = const Color.fromARGB(255, 195, 167, 165);
  static Color iconColor = const Color.fromARGB(255, 253, 174, 47);
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
  // static LinearGradient gradientBackground = LinearGradient(
  //   begin: Alignment.topLeft,
  //   end: Alignment(0.8, 1),
  //   colors: <Color>[
  //     Color(0xff1f005c),
  //     Color(0xff5b0060),
  //     Color(0xff870160),
  //     Color(0xffac255e),
  //     Color(0xffca485c),
  //     Color(0xffe16b5c),
  //     Color(0xfff39060),
  //     Color(0xffffb56b),
  //   ],
  // );

  // static List<Color> gradientColor = <Color>[
  //   Color(0xff1f005c),
  //   Color(0xff5b0060),
  //   Color(0xff870160),
  //   Color(0xffac255e),
  //   Color(0xffca485c),
  //   Color(0xffe16b5c),
  //   Color(0xfff39060),
  //   Color(0xffffb56b),
  // ];
  // static LinearGradient gradientBackground = LinearGradient(
  //   begin: Alignment.topLeft,
  //   end: Alignment(0.8, 1),
  //   colors: <Color>[
  //     Color.fromARGB(255, 255, 149, 0),
  //     Color.fromARGB(255, 254, 139, 15),
  //     Color.fromARGB(255, 254, 146, 30),
  //     Color.fromARGB(255, 255, 152, 42),
  //     Color.fromARGB(255, 253, 158, 56),
  //     Color.fromARGB(255, 255, 168, 76),
  //     Color.fromARGB(255, 255, 161, 114),
  //     Color(0xffffb56b),
  //   ],
  // );

  // static List<Color> gradientBackgroundList = <Color>[
  //   Color(0xFF441752), // Darkest purple
  //   Color.fromARGB(255, 74, 28, 88),
  //   Color.fromARGB(255, 78, 37, 91),
  //   Color.fromARGB(255, 102, 81, 152),
  //   Color.fromARGB(255, 107, 87, 152),
  //   Color.fromARGB(255, 113, 96, 153),
  //   Color(0xFF8174A0),
  //   Color(0xFFA888B5),
  //   Color(0xFFEFB6C8),
  // ];

  static List<Color> gradientBackgroundList = <Color>[
    Color(0xFF331E3F), // darkest purple
    Color(0xFF4A2655), // dark violet
    Color(0xFF562B63), // deep violet
    Color(0xFF703A7E), // purple
    Color(0xFF895294), // medium-light purple
  ];

  static LinearGradient get appBarGradient => LinearGradient(
        colors: gradientBackgroundList,
        begin: Alignment.topLeft,
        end: Alignment(0.8, 1),
      );

  static var shader = LinearGradient(colors: gradientBackgroundList)
      .createShader(const Rect.fromLTWH(0, 0, 200, 40));

  // static List<Color> gradientColor = <Color>[
  //   Color(0xFF441752), // Darkest purple
  //   Color.fromARGB(255, 74, 28, 88),
  //   Color.fromARGB(255, 78, 37, 91),
  //   Color.fromARGB(255, 102, 81, 152),
  //   Color.fromARGB(255, 107, 87, 152),
  //   Color.fromARGB(255, 113, 96, 153),
  //   Color(0xFF8174A0),
  //   Color(0xFFA888B5),
  //   Color(0xFFEFB6C8),
  // ];

  static List<Color> gradientColor = <Color>[
    Color(0xFF2f1c3c), // darkest purple
    Color(0xFF51295f), // dark violet
    Color(0xFF61316f), // deep violet
    Color(0xFF895295), // purple
    Color(0xFF915f9f), // purple
    Color(0xFFA073AE), // medium-light purple
  ];

  static List<Color> reversedGradientColor = <Color>[
    Color(0xFFB06BB8), // lighter purple accent
    Color(0xFF914599), // medium-dark purple
    Color(0xFF7B3680), // rich dark purple
    Color(0xFF6C2A6D), // deep violet (darker than before)
    Color(0xFF5E235F), // darkest purple
  ];

  // static List<Color> reversedGradientColor = <Color>[
  //   Color(0xFFEFB6C8),
  //   Color(0xFFA888B5),
  //   Color(0xFF8174A0),
  //   Color.fromARGB(255, 113, 96, 153),
  //   Color.fromARGB(255, 107, 87, 152),
  //   Color.fromARGB(255, 102, 81, 152),
  //   Color.fromARGB(255, 78, 37, 91),
  //   Color.fromARGB(255, 74, 28, 88),
  //   Color(0xFF441752),
  // ];

  static Color darkGradientColor = Color(0xFF441752); // Darkest purple
  static Color mediumGradientColor = Color(0xFFA888B5); // Medium purple
  static Color lightGradientColor = Color(0xFFEFB6C8); // Lightest pink

  // static List<Color> gradientColor = <Color>[
  //   Color(0xff1f005c),
  //   Color(0xff5b0060),
  //   Color(0xff870160),
  //   Color(0xffac255e),
  //   Color(0xffca485c),
  //   Color(0xffe16b5c),
  //   Color(0xfff39060),
  //   Color(0xffffb56b),
  // ];
}

class AppTextStyles {
  static const double headingSize = 32.0;
  static const double subheadingSize = 24.0;
  static const double titleSize = 17.0;
  static const double bodySize = 16.0;
  static const double buttonSize = 12.0;
  static const double labelSize = 14.0;
  static const double inputFieldSize = 16.0;
  static const double textSize = 14.0;

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
    fontSize: textSize - 2,
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
  debugPrint("Success: $title, $message");
  Get.snackbar(
    '',
    '',
    titleText: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.gradientBackgroundList,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.raleway(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          if (message.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(
              message,
              style: GoogleFonts.raleway(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                height: 1.3,
              ),
            ),
          ],
        ],
      ),
    ),
    messageText: SizedBox.shrink(),
    colorText: Colors.white,
    backgroundColor: Colors.transparent,
    borderRadius: 16.0,
    snackPosition: SnackPosition.TOP,
    margin: EdgeInsets.all(16),
    padding: EdgeInsets.zero,
    duration: Duration(seconds: 3),
    animationDuration: Duration(milliseconds: 400),
    boxShadows: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 8,
        offset: Offset(0, 4),
      ),
    ],
    isDismissible: true,
    dismissDirection: DismissDirection.horizontal,
    forwardAnimationCurve: Curves.easeOutBack,
    reverseAnimationCurve: Curves.easeInBack,
  );
}

void failure(title, message) {
  debugPrint("Failure: $title, $message");
  Get.snackbar(
    '',
    '',
    titleText: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.gradientBackgroundList,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.raleway(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          if (message.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(
              message,
              style: GoogleFonts.raleway(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                height: 1.3,
              ),
            ),
          ],
        ],
      ),
    ),
    messageText: SizedBox.shrink(),
    colorText: Colors.white,
    backgroundColor: Colors.transparent,
    borderRadius: 16.0,
    snackPosition: SnackPosition.TOP,
    margin: EdgeInsets.all(16),
    padding: EdgeInsets.zero,
    duration: Duration(seconds: 3),
    animationDuration: Duration(milliseconds: 400),
    boxShadows: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 8,
        offset: Offset(0, 4),
      ),
    ],
    isDismissible: true,
    dismissDirection: DismissDirection.horizontal,
    forwardAnimationCurve: Curves.easeOutBack,
    reverseAnimationCurve: Curves.easeInBack,
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
  // static const String RAZORPAYKEYID = "rzp_test_27Thf113vIC8Np";
  // static const String RAZORPAYKEYSECRET = "XSyj935cHFhXwXF6JdmFK8QA";
  static const String RAZORPAYKEYID = "rzp_live_lqdEPFltHtYYIS";
  static const String RAZORPAYKEYSECRET = "DJqvCl24zHwSeWK340FRAxyd";
}

class Transactionsuccess {
  static const String SUCCESS = '1';
  static const String PENDING = '2';
  static const String FAIL = '3';
}

class AgoraConstants {
  static const String AGORAAPPID = "634e7bd12a274233873a7fc98f721c64";
}
