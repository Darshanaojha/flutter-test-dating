import 'package:dating_application/Screens/chatmessagespage/chatmessagepage.dart';
import 'package:dating_application/Screens/likespages/userlikespage.dart';
import 'package:dating_application/Screens/settings/setting.dart';
import 'package:dating_application/Screens/userprofile/userprofilepage.dart';
import 'package:get/get.dart';
import '../homepage/homepage.dart';
import '../login.dart';
import '../navigationbar/navigationpage.dart';
import '../register.dart';
import '../splash.dart';

final routes=[
  
        GetPage(name: '/', page: () => Splash()),
        GetPage(name: '/login', page: () => Login()),
        GetPage(name: '/register', page: ()=>Register()),
        GetPage(name: '/homepage', page: ()=>HomePage()),
        GetPage(name:'/navigationbar', page: ()=>NavigationBottomBar()),
        GetPage(name: '/settings', page: ()=>SettingsPage()),
        GetPage(name: '/likes', page: ()=>LikesPage()),
        GetPage(name: '/messages', page: ()=>ChatHistoryPage()),
        GetPage(name: '/profile', page: ()=>ProfilePage())
        // Add other routes here
      
];