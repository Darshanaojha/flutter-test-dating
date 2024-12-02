import 'package:dating_application/Screens/settings/appinfopages/faqpage.dart';
import 'package:dating_application/Screens/shareprofilepage/shareprofilepage.dart';
import 'package:dating_application/Screens/userprofile/addpartner/addpartnerpage.dart';
import 'package:dating_application/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../Controllers/controller.dart';
import '../../Models/RequestModels/usernameupdate_request_model.dart';
import '../settings/appinfopages/appinfopagestart.dart';
import '../settings/setting.dart';
import 'editprofile/edituserprofile.dart';
import 'membership/membershippage.dart';
import 'membership/userselectedplan.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  UserProfilePageState createState() => UserProfilePageState();
}

class UserProfilePageState extends State<UserProfilePage> {
  Controller controller = Get.put(Controller());
  bool isLoading = true;
  String userProfileCompletion = '80% Complete';

  double getResponsiveFontSize(double scale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * scale;
  }

  @override
  void initState() {
    super.initState();
    controller.fetchAllsubscripted();
  }

  int calculateAge(String dob) {
    DateTime birthDate =
        DateTime.parse(dob); // Parse the date of birth string to DateTime
    DateTime now = DateTime.now();

    // Calculate the age
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--; // Subtract one if the user hasn't had their birthday yet this year
    }

    return age;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          FutureBuilder(
              future: controller.fetchProfileUserPhotos(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: SpinKitCircle(
                      size: 150.0,
                      color: AppColors.progressColor,
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading user photos: ${snapshot.error}',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      // User Photos (Horizontal Scrolling)
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: controller
                              .userPhotos!.images.length, //userPhotos.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () => showFullImageDialog(context,
                                    controller.userPhotos!.images[index]),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.network(
                                    controller.userPhotos!.images[index],
                                    fit: BoxFit.cover,
                                    width: 150,
                                    height: 200,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Title and Pencil Icon
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Display username and hint text
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.userData.isNotEmpty
                                      ? controller.userData.first.username
                                      : 'NA',
                                  style: AppTextStyles.titleText.copyWith(
                                    fontSize: getResponsiveFontSize(0.03),
                                  ),
                                ),
                                SizedBox(
                                    height:
                                        8), // Optional space between username and the small text
                                Text(
                                  'Click to change username',
                                  style: AppTextStyles.textStyle.copyWith(
                                    fontSize: getResponsiveFontSize(0.02),
                                    color: Colors
                                        .grey, // Optional: change color to make it look like a hint
                                  ),
                                ),
                              ],
                            ),

                            // Pencil icon button to open dialog for username editing
                            IconButton(
                              icon: Icon(Icons.edit,
                                  size: 30, color: Colors.blue),
                              onPressed: () {
                                // Open a dialog when the pencil icon is pressed
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(
                                        'Edit Username',
                                        style: AppTextStyles.titleText.copyWith(
                                          fontSize: getResponsiveFontSize(0.03),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      content: SingleChildScrollView(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // TextField for username editing
                                              TextField(
                                                cursorColor:
                                                    AppColors.cursorColor,
                                                controller:
                                                    TextEditingController(
                                                  text: controller
                                                          .usernameUpdateRequest
                                                          .username
                                                          .isNotEmpty
                                                      ? controller
                                                          .usernameUpdateRequest
                                                          .username
                                                      : controller.userData
                                                          .first.username,
                                                ),
                                                onChanged: (value) {
                                                  // Update the username request on text change
                                                  controller
                                                      .usernameUpdateRequest
                                                      .username = value;
                                                },
                                                decoration: InputDecoration(
                                                  labelText: 'Username',
                                                  labelStyle: AppTextStyles
                                                      .labelText
                                                      .copyWith(
                                                          fontSize:
                                                              getResponsiveFontSize(
                                                                  0.03)),
                                                  filled: true,
                                                  fillColor:
                                                      AppColors.formFieldColor,
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 20),
                                            ],
                                          ),
                                        ),
                                      ),
                                      actions: <Widget>[
                                        // Cancel button to close the dialog without saving
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            foregroundColor:
                                                AppColors.textColor,
                                            backgroundColor:
                                                AppColors.inactiveColor,
                                          ),
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Close the dialog
                                          },
                                          child: Text('Cancel',
                                              style: AppTextStyles.buttonText
                                                  .copyWith(
                                                      fontSize:
                                                          getResponsiveFontSize(
                                                              0.03))),
                                        ),
                                        // Save button to update the username
                                        ElevatedButton(
                                          style: TextButton.styleFrom(
                                            foregroundColor:
                                                AppColors.textColor,
                                            backgroundColor:
                                                AppColors.activeColor,
                                          ),
                                          onPressed: () {
                                            Get.snackbar(
                                                '',
                                                controller.usernameUpdateRequest
                                                    .username
                                                    .toString());
                                            UsernameUpdateRequest usernameUpdateRequest =
                                                UsernameUpdateRequest(
                                                    username: controller
                                                            .usernameUpdateRequest
                                                            .username
                                                            .isNotEmpty
                                                        ? controller
                                                            .usernameUpdateRequest
                                                            .username
                                                        : controller.userData
                                                            .first.username);
                                            controller.updateusername(
                                                usernameUpdateRequest);
                                            Navigator.of(context)
                                                .pop();
                                          },
                                          child: Text('Save'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      // User Info: Age & Gender
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Text(
                              controller.userData.isNotEmpty
                                  ? '${calculateAge(controller.userData.first.dob)} years old | ${controller.userData.first.gender}'
                                  : 'NA',
                              style: AppTextStyles.labelText.copyWith(
                                  fontSize: getResponsiveFontSize(0.03)),
                            ),
                          ],
                        ),
                      ),

                      // Profile Completion Card
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Profile Completion: $userProfileCompletion',
                                    style: AppTextStyles.labelText.copyWith(
                                        fontSize: getResponsiveFontSize(0.03))),
                                SizedBox(height: 10),
                                Text(
                                    'Complete your profile to unlock more features!',
                                    style: AppTextStyles.labelText.copyWith(
                                        fontSize: getResponsiveFontSize(0.03))),
                              ],
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          color: Colors.orange, // Set the color to orange
                          elevation: 5,
                          child: InkWell(
                            onTap: () {
                              
                              Get.to(PlanPage());
                        
                            },
                            child: Container(
                              padding: EdgeInsets.all(16),
                              width: double.infinity,
                              height: 100,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.card_membership,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 56),
                                  Text(
                                    'Membership',
                                    style: AppTextStyles.titleText.copyWith(
                                        fontSize: getResponsiveFontSize(0.03)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          color: Colors.orange, // Set the color to orange
                          elevation: 5,
                          child: InkWell(
                            onTap: showMessageBottomSheet,
                            child: Container(
                              padding: EdgeInsets.all(16),
                              width: double.infinity,
                              height: 100,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.notifications_active,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 76),
                                  Text(
                                    'Messages',
                                    style: AppTextStyles.titleText.copyWith(
                                        fontSize: getResponsiveFontSize(0.03)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Uplift Profile Card (orange color)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          color: Colors.orange, // Set the color to orange
                          elevation: 5,
                          child: InkWell(
                            onTap: () {
                              showUpgradeBottomSheet(context);
                            }, // Call the showUpgradeBottomSheet function
                            child: Container(
                              padding: EdgeInsets.all(16),
                              width: double.infinity,
                              height: 100,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons
                                        .upload, // You can change this icon to any other icon
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                      width:
                                          66), // Add spacing between the icon and the text
                                  Text(
                                    'Uplift Profile',
                                    style: AppTextStyles.titleText.copyWith(
                                        fontSize: getResponsiveFontSize(0.03)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Example usage in your UserProfilePage
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // My Constellation Card
                            SettingCard(
                              title: 'My Constellation',
                              subtitle: 'Add partners to your constellation',
                              icon: Icons.arrow_forward,
                              onTap: () {
                                Get.to(AddPartnerPage());
                              },
                            ),

                            // Edit Profile Card
                            SettingCard(
                              title: 'Edit Profile',
                              subtitle: 'Edit your profile details',
                              icon: Icons.edit,
                              onTap: () {
                                Get.to(EditProfilePage());
                                if (controller.userLang.isNotEmpty) {
                                  Get.snackbar(
                                      '', controller.userLang.first.title);
                                } else {
                                  Get.snackbar('', 'No language available');
                                }
                              },
                            ),

                            // Other settings cards
                            SettingCard(
                              title: 'Search Settings',
                              subtitle: 'Customize your search settings',
                              icon: Icons.search,
                              onTap: () {
                                Get.to(ShareProfilePage(
                                  id: '1',
                                ));
                                // Navigate or show settings action
                              },
                            ),
                            SettingCard(
                              title: 'App Settings',
                              subtitle: 'Manage app preferences',
                              icon: Icons.settings,
                              onTap: () {
                                Get.to(SettingsPage());
                              },
                            ),
                            SettingCard(
                              title: 'Share My Profile',
                              subtitle: 'Share your profile with others',
                              icon: Icons.share,
                              onTap: showShareProfileBottomSheet,
                            ),
                            SettingCard(
                                title: 'Magazine',
                                subtitle: 'abc',
                                icon: Icons.bolt,
                                onTap: () {}),
                            SettingCard(
                                title: 'Our Community',
                                subtitle: 'community support',
                                icon: Icons.support,
                                onTap: () {}),
                            SettingCard(
                                title: 'Help',
                                subtitle: 'helpline',
                                icon: Icons.help,
                                onTap: () {
                                  // Get.to(AppInfoPage());
                                  showHelpBottomSheet(context);
                                }),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
        ],
      ),
    );
  }

  void showFullImageDialog(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black.withOpacity(0.9),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(), // Close dialog on tap
            child: Center(
              child: Image.network(
                imagePath,
                fit: BoxFit.contain, // Adjust the image size to fit
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),
            ),
          ),
        );
      },
    );
  }

  void showHelpBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // App Info
              ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('App Info'),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  // Navigate to AppInfoPage
                  Get.to(AppInfoPage());
                },
              ),
              Divider(),
              // FAQ
              ListTile(
                leading: Icon(Icons.help_outline),
                title: Text('FAQs'),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  // Navigate to FAQ Page
                  Get.to(FaqPage());
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Card widget for feature sections like Membership, Pings, etc.
  Widget buildFeatureCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 5,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 100,
          height: 100,
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40),
              SizedBox(height: 10),
              Text(title,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  // General Card for Settings Sections (My Constellation, Edit Profile, etc.)
  Widget buildSettingCard(
      String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 5,
        child: ListTile(
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: Icon(icon),
          onTap: onTap,
        ),
      ),
    );
  }

  // Helper function for settings items like Magazine, Help, etc.
  Widget buildSettingItem(String title) {
    return ListTile(
      title: Text(title),
      onTap: () {
        // Handle item tap (navigate or show actions)
      },
    );
  }

  void showShareProfileBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        // Get screen width for responsive design
        double screenWidth = MediaQuery.of(context).size.width;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            children: [
              // Create a container with a width equal to the screen width, but with some margin for responsiveness
              SizedBox(
                width: screenWidth - 32, // Margin of 16 on both sides
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Share your profile",
                      style: AppTextStyles.titleText.copyWith(
                        fontSize: getResponsiveFontSize(0.03),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Share Button - Make button expand to full width
                    SizedBox(
                      width: double
                          .infinity, // Make the button take the full width
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Dismiss bottom sheet

                          // Share the user profile
                          shareUserProfile();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors
                              .activeColor, // Button color from AppColors
                          padding: EdgeInsets.symmetric(
                              vertical: 16), // Make button tall (height)
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Share",
                          style: AppTextStyles.buttonText.copyWith(
                            fontSize: getResponsiveFontSize(0.03),
                            fontWeight: FontWeight.w500,
                            color: AppColors.textColor, // Button text color
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Cancel Button - Make button expand to full width
                    SizedBox(
                      width: double
                          .infinity, // Make the button take the full width
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Dismiss bottom sheet
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColors.inactiveColor, // Cancel button color
                          padding: EdgeInsets.symmetric(
                              vertical: 16), // Make button tall (height)
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: AppTextStyles.buttonText.copyWith(
                            fontSize: getResponsiveFontSize(0.03),
                            fontWeight: FontWeight.w500,
                            color: AppColors.textColor, // Button text color
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      isScrollControlled:
          true, // This ensures the bottom sheet can adjust based on content
    );
  }

// Function to share the user profile
  void shareUserProfile() {
    final String profileUrl =
        'https://example.com/user-profile'; // Replace with the actual profile URL or content
    final String profileDetails =
        "Check out this profile:\nJohn Doe\nAge: 25\nGender: Male\n$profileUrl";

    // Use share_plus to share the profile link or details to other apps
    Share.share(profileDetails);
  }
}

Future<void> showMessageBottomSheet() async {
  Get.bottomSheet(
    Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Send a Message', style: AppTextStyles.inputFieldText),
            SizedBox(height: 20),
            TextField(
              // controller: _pingController,
              cursorColor: AppColors.cursorColor,
              // focusNode: _pingFocusNode,
              decoration: InputDecoration(
                labelText: 'Write your message...',
                labelStyle: AppTextStyles.labelText,
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                fillColor: AppColors.formFieldColor,
                filled: true,
                hintText: 'Type your message here...',
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // if (_pingController.text.isNotEmpty) {
                //   setState(() {
                //     _pingCount--;
                //   });
                //   _pingController.clear();
                //   Get.back();
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     SnackBar(content: Text('Ping sent!')),
                //   );
                // }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
              ),
              child: Text('Send Message', style: AppTextStyles.buttonText),
            ),
          ],
        ),
      ),
    ),
    isScrollControlled: true,
    backgroundColor: AppColors.primaryColor,
    enterBottomSheetDuration: Duration(milliseconds: 300),
    exitBottomSheetDuration: Duration(milliseconds: 300),
  );
}

Future<void> showUpgradeBottomSheet(BuildContext context) async {
  double screenWidth = MediaQuery.of(context).size.width;
  Get.bottomSheet(
    Padding(
      padding: const EdgeInsets.all(0.0),
      child: Container(
        color: Colors.black,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title of the Bottom Sheet
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Found Uplift',
                style: AppTextStyles.titleText.copyWith(
                  fontSize: screenWidth * 0.04,
                  color: Colors.white, // Set text color to white for contrast
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 10),
            // Subtitle with additional information
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'You can use 24 hours and enjoy the features, '
                'and you can access earlier with premium benefits.',
                style: AppTextStyles.bodyText.copyWith(
                  fontSize: screenWidth * 0.04,
                  color: Colors.white, // Set text color to white for contrast
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),

            // Orange Card with Icon, Text, and Discount Label
            Stack(
              children: [
                // The Orange Card
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.orange, // Set card background color to orange
                  child: Padding(
                    padding: const EdgeInsets.all(24.0), // Increased padding
                    child: Row(
                      children: [
                        // Icon for the card
                        Icon(
                          Icons.calendar_today,
                          color:
                              Colors.white, // Icon color is white for contrast
                          size: 24, // Adjust size as needed
                        ),
                        SizedBox(width: 10),
                        // Text for the card
                        Expanded(
                          child: Text(
                            "24-hour Premium Plan - ₹299", // Plan description
                            style: AppTextStyles.bodyText.copyWith(
                              fontSize: screenWidth * 0.04,
                              color: Colors.white, // White text for readability
                            ),
                          ),
                        ),
                        // Plan Status (text)
                        Text(
                          'Selected', // Status of the plan
                          style: AppTextStyles.bodyText.copyWith(
                            fontSize: screenWidth * 0.04,
                            color: AppColors
                                .buttonColor, // Color for the status text
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Positioned Discount Label (20% OFF)
                Positioned(
                  top: 4, // Slightly higher position
                  right: 2, // Position at the top-right corner
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                    decoration: BoxDecoration(
                      color: Colors.red, // Set the background color to red
                      borderRadius: BorderRadius.circular(12), // Curved corners
                    ),
                    child: Text(
                      '20% OFF', // Display the discount percentage
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.04, // Smaller font size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Purchase Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Simulate purchase process
                  Get.back();
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   SnackBar(content: Text('Profile upgraded! Enjoy your 24 hours of premium access.')),
                  // );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Purchase Now', style: AppTextStyles.buttonText),
              ),
            ),
          ],
        ),
      ),
    ),
    isScrollControlled: true, // Allow bottom sheet to have a controlled size
    backgroundColor:
        Colors.transparent, // Transparent background for the full-screen effect
  );
}

class SettingCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  // Constructor with an optional width parameter
  const SettingCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth * 0.85;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: cardWidth, // Set the responsive width
        child: Card(
          elevation: 10,
          child: ListTile(
            title: Text(
              title,
              style: AppTextStyles.titleText
                  .copyWith(fontSize: screenWidth * 0.04),
            ),
            subtitle:
                Text(subtitle, style: TextStyle(fontSize: screenWidth * 0.03)),
            trailing: Icon(icon),
            onTap: onTap, // Call the onTap function when the card is tapped
          ),
        ),
      ),
    );
  }
}
