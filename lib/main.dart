import 'package:dating_application/Screens/routings/routes.dart';
import 'package:dating_application/constants.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'Controllers/controller.dart';
import 'Models/RequestModels/update_activity_status_request_model.dart';
import 'Providers/fcmService.dart';
import 'Providers/connectivity_service.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    Get.put(Controller());

    await EncryptedSharedPreferences.initialize(encryptionkey);
    await Firebase.initializeApp(
      options: FirebaseConstants.firebaseOptions,
    ).then((_) async {
      final fcmService = FCMService();
      await fcmService.setupNotifications();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    });

    Get.put(ConnectivityService());
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

class MainAppState extends State<MainApp>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> opacityAnimation;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..forward();

    opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeIn),
    );

    scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );

    // Show the dialog after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // if (ipAddress.isEmpty || ipSpringAddress.isEmpty) {
      //   await (context
      //           .findAncestorStateOfType<MainAppState>()
      //           ?.showIpDialog(context) ??
      //       Future.value());
      // }
    });

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

  Controller controller = Get.put(Controller());
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

  Future<void> showIpDialog(BuildContext context) async {
    final ipController = TextEditingController(text: ipAddress);
    final springIpController = TextEditingController(text: ipSpringAddress);
    ipController.text = '150.241.245.210';
    springIpController.text = '192.168.1.';
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter Server IPs'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ipController,
                decoration: InputDecoration(
                  labelText: 'Backend IP Address',
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 12),
              TextField(
                controller: springIpController,
                decoration: InputDecoration(
                  labelText: 'Spring Boot IP Address',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (ipController.text.isNotEmpty &&
                    springIpController.text.isNotEmpty) {
                  ipAddress = ipController.text.trim();
                  ipSpringAddress = springIpController.text.trim();
                  Navigator.of(context).pop();
                }
              },
              child: Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: appName,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: Colors.teal,
          secondary: Colors.orange,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white, // Text and icon colors
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      ),
      initialRoute: '/',
      getPages: routes,
    );
  }
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
  // Handle background message logic here
}
