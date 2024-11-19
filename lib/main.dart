import 'package:dating_application/Screens/routings/routes.dart';
import 'package:dating_application/constants.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

import 'Providers/fcmService.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    await EncryptedSharedPreferences.initialize(encryptionkey);
    // Initialize Firebase
    await Firebase.initializeApp(
      options: FirebaseConstants.firebaseOptions,
    );

    // Initialize notification services
    final fcmService = FCMService();
    await fcmService.setupNotifications();

    // Setup background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    runApp(const MainApp());
  } catch (e) {
    failure('Error', 'Error in the main method');
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FlamR',
      theme: ThemeData(
        brightness: Brightness.dark,
        appBarTheme: AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          toolbarHeight: MediaQuery.of(context).size.height * 0.1,
        ),
      ),
      initialRoute: '/',
      getPages: routes,
    );
  }
}

// Background message handler (if not already in the service)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
  // You can customize how to handle background messages here
}
