import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

import 'Screens/login.dart';
import 'Screens/register.dart';
import 'Screens/splash.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dating Application',
       theme: ThemeData(
         brightness: Brightness.light,
          appBarTheme: AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          toolbarHeight: MediaQuery.of(context).size.height * 0.1,
        ),
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => Splash()),
        GetPage(name: '/login', page: () => Login()),
        GetPage(name: '/register', page: ()=>Register()),
        // Add other routes here
      ],
    );
  }
}
