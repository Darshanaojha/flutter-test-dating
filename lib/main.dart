import 'package:dating_application/Screens/routings/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

void main() {
  runApp(const MainApp());
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

// late UserRegistrationRequest userRegistrationRequest;
      // UserRegistrationRequest userRegistrationRequest = UserRegistrationRequest(
      //   name: '',
      //   email: '',
      //   mobile: '',
      //   latitude: '',
      //   longitude: '',
      //   address: '',
      //   password:'',
      //   countryId: '',
      //   state: '',
      //   city: '',
      //   dob: '',
      //   nickname: '',
      //   gender: '',
      //   subGender: '',
      //   preferences: [],
      //   desires: [],
      //   interest: '',
      //   bio: '',
      //   photos: [],
      //   packageId: '',
      //   emailAlerts: '',
      //   username: '',
      //   lookingFor: '',
      // );