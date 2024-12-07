import 'package:dating_application/Screens/routings/routes.dart';
import 'package:dating_application/constants.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

import 'Models/RequestModels/update_activity_status_request_model.dart';
import 'Providers/fcmService.dart';
import 'Screens/userprofile/editprofile/edituserprofile.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    await EncryptedSharedPreferences.initialize(encryptionkey);
    await Firebase.initializeApp(
      options: FirebaseConstants.firebaseOptions,
    );

    final fcmService = FCMService();
    await fcmService.setupNotifications();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    runApp(const MainApp());
  } catch (e) {
    failure('Error', 'Error in the main method');
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  MainAppState createState() => MainAppState();
}

class MainAppState extends State<MainApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    EncryptedSharedPreferences.initialize(encryptionkey);
    Firebase.initializeApp(
      options: FirebaseConstants.firebaseOptions,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      UpdateActivityStatusRequest updateOfflineRequest =
          UpdateActivityStatusRequest(status: '0');
      controller.updateactivitystatus(updateOfflineRequest);
    } else if (state == AppLifecycleState.resumed) {
      UpdateActivityStatusRequest updateOnlineRequest =
          UpdateActivityStatusRequest(status: '1');
      controller.updateactivitystatus(updateOnlineRequest);
    }
  }

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


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}
