import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:dating_application/Screens/homepage/unsubscribeuser.dart';
import 'package:dating_application/Screens/login.dart';
import 'package:dating_application/Screens/userprofile/userprofilepage.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controllers/controller.dart';
import '../../Models/ResponseModels/get_all_packages_response_model.dart';
import '../../constants.dart';
import '../homepage/packagestonewuser.dart';
import '../settings/setting.dart';

class UnSubscribeNavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;
  final RxString selectedPlan = 'None'.obs;
  final RxList<Package> packages = <Package>[].obs;

  final List<Widget> screens = [
    Unsubscribeuser(), // Screen for unsubscribing
    UserProfilePage(), // Profile page
  ];

  void navigateTo(int index) {
    selectedIndex.value = index;
    showPackagesDialog();
  }
  
  // Show the packages dialog
  void showPackagesDialog() {
    Get.defaultDialog(
      title: 'Subscribe to Enjoy',
      
      onCancel: () {
        Get.back();
      },
      onConfirm: () {
        PackageListWidget();

      },
    );
  }

  // Show payment confirmation dialog
  Future<void> showPaymentConfirmationDialog(BuildContext context,
      String planType, String planId, String amount) async {
    double fontSize = MediaQuery.of(context).size.width * 0.03;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent dismissal by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Confirm Subscription",
            style: AppTextStyles.titleText.copyWith(
              fontSize: fontSize,
              color: AppColors.textColor,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Do you want to subscribe to the $planType plan for $amount?",
                  style: AppTextStyles.bodyText.copyWith(
                    fontSize: fontSize - 2,
                    color: AppColors.textColor,
                  ),
                ),
                SizedBox(height: 16),
                // Other content here
                Text(
                  "Additional information about the plan can go here.",
                  style: AppTextStyles.bodyText.copyWith(
                    fontSize: fontSize - 2,
                    color: AppColors.textColor,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "Terms and conditions for the plan can also be shown here.",
                  style: AppTextStyles.bodyText.copyWith(
                    fontSize: fontSize - 2,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Cancel",
                style: AppTextStyles.buttonText.copyWith(
                  fontSize: fontSize,
                  color: AppColors.buttonColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Confirm",
                style: AppTextStyles.buttonText.copyWith(
                  fontSize: fontSize,
                  color: AppColors.buttonColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class Unsubscribenavigation extends StatefulWidget {
  const Unsubscribenavigation({super.key});

  @override
  UnsubscribenavigationState createState() => UnsubscribenavigationState();
}

class UnsubscribenavigationState extends State<Unsubscribenavigation> {
  int selectedIndex = 0;
  Controller controller = Get.put(Controller());
  double getResponsiveFontSize(BuildContext context, double scale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * scale;
  }

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<bool> initializeData() async {
    if (!await controller.fetchAllPackages()) return false;
    if (!await controller.fetchAllHeadlines()) return false;
    return true;
  }

  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout',
              style: AppTextStyles.headingText
                  .copyWith(fontSize: getResponsiveFontSize(context, 0.04))),
          content: Text('Are you sure you want to log out?',
              style: AppTextStyles.headingText
                  .copyWith(fontSize: getResponsiveFontSize(context, 0.04))),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textColor,
                backgroundColor: AppColors.primaryColor,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No',
                  style: AppTextStyles.headingText.copyWith(
                      fontSize: getResponsiveFontSize(context, 0.04))),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textColor,
                backgroundColor: AppColors.inactiveColor,
              ),
              onPressed: () {
                // Clear preferences and navigate to login
                EncryptedSharedPreferences preferences =
                    EncryptedSharedPreferences.getInstance();
                preferences.clear();
                Get.offAll(() => Login()); // Make sure Login() is defined
              },
              child: Text('Yes',
                  style: AppTextStyles.headingText.copyWith(
                      fontSize: getResponsiveFontSize(context, 0.04))),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UnSubscribeNavigationController());

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          elevation: 5,
          title: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'FlamR',
                style: AppTextStyles.headingText.copyWith(
                  fontSize: getResponsiveFontSize(context, 0.08),
                ),
              ),
            ),
          ),
          backgroundColor: AppColors.navigationColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                showLogoutDialog(context);
              },
            ),
          ],
        ),
      ),
      body: Obx(() {
        return controller.screens[controller.selectedIndex.value];
      }),
      bottomNavigationBar: CurvedNavigationBar(
        index: selectedIndex, // Use local state for selected index
        height: 60.0,
        items: const <Widget>[
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.account_circle, size: 30, color: Colors.white),
        ],
        color: AppColors.primaryColor,
        buttonBackgroundColor: AppColors.acceptColor,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 300),
        onTap: (index) {
          setState(() {
            selectedIndex = index; // Update the selected index
          });
          controller.navigateTo(index); // Call controller's navigateTo method
        },
      ),
    );
  }
}

