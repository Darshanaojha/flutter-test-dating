import 'package:dating_application/Screens/settings/appinfopages/faqpage.dart';
import 'package:dating_application/Screens/userprofile/accountverification/useraccountverification.dart';
import 'package:dating_application/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../Controllers/controller.dart';
import '../../Models/RequestModels/usernameupdate_request_model.dart';
import '../settings/appinfopages/appinfopagestart.dart';
import '../settings/setting.dart';
import 'editprofile/edituserprofile.dart';
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
  late Future<bool> _fetchprofilepage;
  double getResponsiveFontSize(double scale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * scale;
  }

  @override
  void initState() {
    super.initState();
    _fetchprofilepage = fetchAllData();
  }

  Future<bool> fetchAllData() async {
    if (!await controller.fetchProfileUserPhotos()) return false;
    if (!await controller.fetchAllsubscripted()) return false;
    if (!await controller.fetchProfile()) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          FutureBuilder<bool>(
              future: _fetchprofilepage,
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

                if (!snapshot.hasData ||
                    controller.userPhotos == null ||
                    controller.userPhotos!.images.isEmpty) {
                  return Center(
                    child: Text(
                      'No photos available.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 250,
                        child: Scrollbar(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount:
                                controller.userPhotos?.images.length ?? 0,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () => showFullImageDialog(context,
                                      controller.userPhotos!.images[index]),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.network(
                                      controller.userPhotos?.images[index] ??
                                          '',
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
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.usernameUpdateRequest.username
                                          .isNotEmpty
                                      ? controller
                                          .usernameUpdateRequest.username
                                      : controller.userData.first.username,
                                  style: AppTextStyles.titleText.copyWith(
                                    fontSize: getResponsiveFontSize(0.03),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Click to change username',
                                  style: AppTextStyles.textStyle.copyWith(
                                    fontSize: getResponsiveFontSize(0.02),
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(Icons.edit,
                                  size: 30, color: Colors.blue),
                              onPressed: () {
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
                                      content: SizedBox(
                                        height: 400,
                                        child: Scrollbar(
                                          child: SingleChildScrollView(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
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
                                                      setState(() {
                                                        controller
                                                            .usernameUpdateRequest
                                                            .username = value;
                                                      });
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
                                                      fillColor: AppColors
                                                          .formFieldColor,
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        borderSide:
                                                            BorderSide.none,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 20),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            foregroundColor:
                                                AppColors.textColor,
                                            backgroundColor:
                                                AppColors.inactiveColor,
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Cancel',
                                              style: AppTextStyles.buttonText
                                                  .copyWith(
                                                      fontSize:
                                                          getResponsiveFontSize(
                                                              0.03))),
                                        ),
                                        ElevatedButton(
                                          style: TextButton.styleFrom(
                                            foregroundColor:
                                                AppColors.textColor,
                                            backgroundColor:
                                                AppColors.activeColor,
                                          ),
                                          onPressed: () {
                                            UsernameUpdateRequest
                                                usernameUpdateRequest =
                                                UsernameUpdateRequest(
                                              username: controller
                                                      .usernameUpdateRequest
                                                      .username
                                                      .isNotEmpty
                                                  ? controller
                                                      .usernameUpdateRequest
                                                      .username
                                                  : controller
                                                      .userData.first.username,
                                            );
                                            controller.updateusername(
                                                usernameUpdateRequest);
                                            Navigator.of(context).pop();
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22.0),
                        child: Row(
                          children: [
                            Text(
                              controller.userData.isNotEmpty
                                  ? '${DateTime.now().year - DateFormat('dd/MM/yyyy').parse(controller.userData.first.dob).year} '
                                      ' years old | ${controller.userData.first.genderName}'
                                  : 'NA',
                              style: AppTextStyles.labelText.copyWith(
                                  fontSize: getResponsiveFontSize(0.03)),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Card(
                          elevation: 5,
                          color: controller.userData.isNotEmpty &&
                                  controller.userData.first
                                          .accountVerificationStatus ==
                                      '1'
                              ? Colors.green[50]
                              : Colors.red[50],
                          child: InkWell(
                            onTap: () {
                              showVerificationDialog(context);
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 22),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Account Verification',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: controller.userData.isNotEmpty &&
                                              controller.userData.first
                                                      .accountVerificationStatus ==
                                                  '1'
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                  controller.userData.isNotEmpty &&
                                          controller.userData.first
                                                  .accountVerificationStatus ==
                                              '1'
                                      ? Icon(Icons.verified_user_outlined,
                                          color: Colors.green)
                                      : Icon(Icons.cancel_outlined,
                                          color: Colors.red),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 22),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Card(
                            elevation: 5,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 22),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Profile Completion: $userProfileCompletion',
                                      style: AppTextStyles.labelText.copyWith(
                                          fontSize:
                                              getResponsiveFontSize(0.03))),
                                  SizedBox(height: 10),
                                  Text(
                                      'Complete your profile to unlock more features!',
                                      style: AppTextStyles.labelText.copyWith(
                                          fontSize:
                                              getResponsiveFontSize(0.03))),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Card(
                            color: Color.fromARGB(255, 11, 122, 67),
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
                                          fontSize:
                                              getResponsiveFontSize(0.03)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.all(16.0),
                      //   child: Card(
                      //     color: Colors.orange,
                      //     elevation: 5,
                      //     child: InkWell(
                      //       onTap: showMessageBottomSheet,
                      //       child: Container(
                      //         padding: EdgeInsets.all(16),
                      //         width: double.infinity,
                      //         height: 100,
                      //         child: Row(
                      //           children: [
                      //             Icon(
                      //               Icons.notifications_active,
                      //               size: 40,
                      //               color: Colors.white,
                      //             ),
                      //             SizedBox(width: 76),
                      //             Text(
                      //               'Messages',
                      //               style: AppTextStyles.titleText.copyWith(
                      //                   fontSize: getResponsiveFontSize(0.03)),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.all(16.0),
                      //   child: Card(
                      //     color: Colors.orange,
                      //     elevation: 5,
                      //     child: InkWell(
                      //       onTap: () {
                      //         showUpgradeBottomSheet(context);
                      //       },
                      //       child: Container(
                      //         padding: EdgeInsets.all(16),
                      //         width: double.infinity,
                      //         height: 100,
                      //         child: Row(
                      //           children: [
                      //             Icon(
                      //               Icons.upload,
                      //               size: 30,
                      //               color: Colors.white,
                      //             ),
                      //             SizedBox(width: 66),
                      //             Text(
                      //               'Uplift Profile',
                      //               style: AppTextStyles.titleText.copyWith(
                      //                   fontSize: getResponsiveFontSize(0.03)),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            children: [
                              // SettingCard(
                              //   title: 'My Constellation',
                              //   subtitle: 'Add partners to your constellation',
                              //   icon: Icons.arrow_forward,
                              //   onTap: () {
                              //     Get.to(AddPartnerPage());
                              //   },
                              // ),
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
                              // SettingCard(
                              //   title: 'Search Settings',
                              //   subtitle: 'Customize your search settings',
                              //   icon: Icons.search,
                              //   onTap: () {
                              //     Get.to(ShareProfilePage(
                              //       id: '1',
                              //     ));
                              //   },
                              // ),
                              SettingCard(
                                title: 'App Settings',
                                subtitle: 'Manage app preferences',
                                icon: Icons.settings,
                                onTap: () {
                                  Get.to(SettingsPage());
                                },
                              ),
                              SettingCard(
                                title: 'Share The Application',
                                subtitle: 'Share our Application with others',
                                icon: Icons.share,
                                onTap: showShareProfileBottomSheet,
                              ),
                              // SettingCard(
                              //     title: 'Magazine',
                              //     subtitle: 'abc',
                              //     icon: Icons.bolt,
                              //     onTap: () {}),
                              // SettingCard(
                              //     title: 'Our Community',
                              //     subtitle: 'community support',
                              //     icon: Icons.support,
                              //     onTap: () {}),
                              SettingCard(
                                  title: 'Help',
                                  subtitle: 'helpline',
                                  icon: Icons.help,
                                  onTap: () {
                                    showHelpBottomSheet(context);
                                  }),
                            ],
                          ),
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
            onTap: () => Navigator.of(context).pop(),
            child: Center(
              child: Image.network(
                imagePath,
                fit: BoxFit.contain,
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
              ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('App Info'),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  Get.to(AppInfoPage());
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.help_outline),
                title: Text('FAQs'),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  Get.to(FaqPage());
                },
              ),
            ],
          ),
        );
      },
    );
  }

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

  void showShareProfileBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        double screenWidth = MediaQuery.of(context).size.width;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            children: [
              SizedBox(
                width: screenWidth - 32,
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
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          shareUserProfile();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.activeColor,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Share",
                          style: AppTextStyles.buttonText.copyWith(
                            fontSize: getResponsiveFontSize(0.03),
                            fontWeight: FontWeight.w500,
                            color: AppColors.textColor,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.inactiveColor,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: AppTextStyles.buttonText.copyWith(
                            fontSize: getResponsiveFontSize(0.03),
                            fontWeight: FontWeight.w500,
                            color: AppColors.textColor,
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
      isScrollControlled: true,
    );
  }

  void showVerificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Account Verification',
            style: AppTextStyles.titleText,
            textAlign: TextAlign.center,
          ),
          content: Text(
            'To verify your account, you need to submit a photo. Choose one of the following options for your photo submission.',
            style: AppTextStyles.titleText,
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.inactiveColor,
              ),
              child: Text(
                'Cancel',
                style: AppTextStyles.titleText,
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                controller.fetchAllverificationtype();
                Navigator.of(context).pop();
                Get.to(PhotoVerificationPage());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.activeColor,
              ),
              child: Text(
                'Confirm',
                style: AppTextStyles.titleText,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        );
      },
    );
  }

  void shareUserProfile() {
    final String profileUrl = 'https://example.com/user-profile';
    final String profileDetails =
        "Check out this profile:\nJohn Doe\nAge: 25\nGender: Male\n$profileUrl";
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
              onPressed: () {},
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Found Uplift',
                style: AppTextStyles.titleText.copyWith(
                  fontSize: screenWidth * 0.04,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'You can use 24 hours and enjoy the features, '
                'and you can access earlier with premium benefits.',
                style: AppTextStyles.bodyText.copyWith(
                  fontSize: screenWidth * 0.04,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),
            Stack(
              children: [
                // The Orange Card
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.orange,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "24-hour Premium Plan - ₹299",
                            style: AppTextStyles.bodyText.copyWith(
                              fontSize: screenWidth * 0.04,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text(
                          'Selected',
                          style: AppTextStyles.bodyText.copyWith(
                            fontSize: screenWidth * 0.04,
                            color: AppColors.buttonColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 2,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '20% OFF',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
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
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

class SettingCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
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
    // double cardWidth = screenWidth * 0.85;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: SizedBox(
          child: Card(
            color: Color.fromARGB(255, 11, 122, 67),
            elevation: 5,
            child: ListTile(
              title: Text(
                title,
                style: AppTextStyles.titleText
                    .copyWith(fontSize: screenWidth * 0.04),
              ),
              subtitle: Text(subtitle,
                  style: TextStyle(fontSize: screenWidth * 0.03)),
              trailing: Icon(icon),
              onTap: onTap,
            ),
          ),
        ),
      ),
    );
  }
}
