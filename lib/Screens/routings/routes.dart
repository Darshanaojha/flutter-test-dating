import 'package:dating_application/Screens/chatmessagespage/ContactListScreen.dart';
import 'package:dating_application/Screens/likespages/userlikespage.dart';
import 'package:dating_application/Screens/settings/changepassword/changepasswordnewpassword.dart';
import 'package:dating_application/Screens/settings/setting.dart';
import 'package:dating_application/Screens/userprofile/membership/membershippage.dart';
import 'package:dating_application/Screens/userprofile/userprofilepage.dart';
import 'package:get/get.dart';
import '../homepage/homepage.dart';
import '../login.dart';
import '../navigationbar/navigationpage.dart';
import '../register_subpag/register_subpage.dart';
import '../register_subpag/registerdetails.dart';
import '../register_subpag/registrationotp.dart';
import '../settings/updateemailid/updateemailidpage.dart';
import '../settings/updateemailid/updateemailotpverification.dart';
import '../splash.dart';
import '../userprofile/editphoto/edituserprofilephoto.dart';
import '../userprofile/editprofile/edituserprofile.dart';

final routes = [
  GetPage(name: '/', page: () => Splash(),transition: Transition.fadeIn,),
  GetPage(name: '/login', page: () => Login(), transition: Transition.rightToLeftWithFade,),
  GetPage(name: '/register', page: () => RegisterProfilePage()),
  GetPage(name: '/subregistration', page: () => MultiStepFormPage()),
  GetPage(name: '/registrationotp', page: () => OTPVerificationPage()),
  GetPage(name: '/homepage', page: () => HomePage(), transition: Transition.rightToLeftWithFade,),
  GetPage(name: '/navigationbar', page: () => NavigationBottomBar()),
  GetPage(name: '/settings', page: () => SettingsPage()),
  GetPage(name: '/likes', page: () => LikesPage()),
  GetPage(name: '/messages', page: () => ContactListScreen()),
    //GetPage(name: '/messages', page: () => ChatHistoryPage()),

  GetPage(name: '/profile', page: () => UserProfilePage()),
  GetPage(name: '/editprofile', page: () => EditProfilePage()),
  GetPage(name: '/editphoto', page: () => EditPhotosPage()),
  GetPage(name: '/membership', page: () => MembershipPage()),
  GetPage(name: '/changepassword', page: () => ChangePasswordPage()),
  GetPage(name: '/updateemail', page: () => UpdateEmailPage()),
  GetPage(
      name: '/emailverificationotp', page: () => EmailOtpVerificationPage()),
];
