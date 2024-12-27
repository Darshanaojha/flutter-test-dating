import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:dating_application/Screens/homepage/unsubscribeuser.dart';
import 'package:dating_application/Screens/login.dart';
import 'package:dating_application/Screens/userprofile/userprofilepage.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controllers/controller.dart';
import '../../Models/RequestModels/update_activity_status_request_model.dart';
import '../../constants.dart';
import '../settings/setting.dart';
import '../userprofile/membership/membershippage.dart';

class UnSubscribeNavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;
  final RxString selectedPlan = 'None'.obs;

  final List<Widget> screens = [
    Unsubscribeuser(), // Screen for unsubscribing
    UserProfilePage(), // Profile page
  ];

  // Method to navigate to the respective screen
  void navigateTo(int index) {
    selectedIndex.value = index;
    showPackagesDialog();
  }

  // Show the packages dialog
  void showPackagesDialog() {
    Get.defaultDialog(
      title: 'Subscribe to Enjoy',
      titleStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryColor,
      ),
      backgroundColor: AppColors.acceptColor,
      barrierDismissible: true,
      radius: 15.0,
      contentPadding: EdgeInsets.all(20),
      content: Column(
        children: [
          Text(
            "Choose a Subscription Plan",
            style: AppTextStyles.titleText.copyWith(
              fontSize: 18,
              color: AppColors.textColor,
            ),
          ),
        
        ],
      ),
      actions: [
        // Cancel Button
        TextButton(
          onPressed: () {
            Get.back(); // Close the dialog
          },
          child: Text(
            'Cancel',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.buttonColor,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Get.to(MembershipPage());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonColor, // Button color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: Text(
            'Confirm Subscription',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
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
                 UpdateActivityStatusRequest updateActivityStatusRequest =
                    UpdateActivityStatusRequest(status: '0');
                controller.updateactivitystatus(updateActivityStatusRequest);
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
        color: AppColors.navigationColor,
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
