import 'package:dating_application/Screens/settings/appinfopages/faqpage.dart';
import 'package:dating_application/Screens/userprofile/accountverification/useraccountverification.dart';
import 'package:dating_application/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';
import '../../Controllers/controller.dart';
import '../../Models/RequestModels/usernameupdate_request_model.dart';
import '../settings/appinfopages/appinfopagestart.dart';
import 'GenerateReferalCode/GenerateReferalCode.dart';
import 'Orders/OrdersViewScreen.dart';
import 'Transactions/TransactionsViewScreen.dart';
import 'Wallet/WalletScreen.dart';
import 'editprofile/edituserprofile.dart';
import 'membership/userselectedplan.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  UserProfilePageState createState() => UserProfilePageState();
}

class UserProfilePageState extends State<UserProfilePage>
    with TickerProviderStateMixin {
  Controller controller = Get.put(Controller());
  bool isLoading = true;
  String userProfileCompletion = '80% Complete';
  late Future<bool> _fetchprofilepage;
  double getResponsiveFontSize(double scale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * scale;
  }

  late final DecorationTween decorationTween;
  late TextEditingController _usernameController;

  @override
  void initState() {
    super.initState();
    _fetchprofilepage = fetchAllData();
    _usernameController = TextEditingController(
      text: controller.usernameUpdateRequest.username.isNotEmpty
          ? controller.usernameUpdateRequest.username
          : (controller.userData.isNotEmpty
              ? controller.userData.first.username
              : ''),
    );

    decorationTween = DecorationTween(
      begin: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(style: BorderStyle.none),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x66666666), // Shadow color
            blurRadius: 10.0,
            spreadRadius: 3.0,
            offset: Offset(0, 6.0),
          ),
        ],
      ),
      end: BoxDecoration(
        color: Colors.transparent, // Transparent box
        border: Border.all(style: BorderStyle.none),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x66666666), // Shadow color
            blurRadius: 10.0,
            spreadRadius: 3.0,
            offset: Offset(0, 6.0),
          ),
        ],
      ),
    );
  }

  Future<bool> fetchAllData() async {
    if (!await controller.fetchProfileUserPhotos()) return false;
    if (!await controller.fetchAllsubscripted()) return false;
    if (!await controller.fetchProfile()) return false;
    return true;
  }

  Future<void> _refreshData() async {
    await Future.delayed(Duration(seconds: 2));
    await controller.fetchProfile();
    await controller.fetchProfileUserPhotos();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Stack(
          children: [
            FutureBuilder<bool>(
                future: _fetchprofilepage,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      // child: SpinKitCircle(
                      //   size: 150.0,
                      //   color: AppColors.progressColor,
                      // ),
                      child: Lottie.asset(
                          "assets/animations/handloadinganimation.json",
                          repeat: true,
                          reverse: true),
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
                  return Obx(() => SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.18,
                              child: Scrollbar(
                                child: (controller.userPhotos == null ||
                                        controller.userPhotos!.images.isEmpty)
                                    ? Center(
                                        child: Text(
                                          'No photos available.',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      )
                                    : ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: controller
                                                .userPhotos?.images.length ??
                                            0,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.all(6.0),
                                            child: GestureDetector(
                                              onTap: () => showFullImageDialog(
                                                  context,
                                                  controller.userPhotos!
                                                      .images[index]),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                child: controller
                                                        .userPhotos!
                                                        .images[index]
                                                        .isNotEmpty
                                                    ? Image.network(
                                                        controller.userPhotos
                                                                    ?.images[
                                                                index] ??
                                                            '',
                                                        fit: BoxFit.cover,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.3,
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.3,
                                                        loadingBuilder: (context,
                                                            child,
                                                            loadingProgress) {
                                                          if (loadingProgress ==
                                                              null) {
                                                            return child;
                                                          } else {
                                                            return Center(
                                                              child:
                                                                  CircularProgressIndicator(
                                                                value: loadingProgress
                                                                            .expectedTotalBytes !=
                                                                        null
                                                                    ? loadingProgress
                                                                            .cumulativeBytesLoaded /
                                                                        (loadingProgress.expectedTotalBytes ??
                                                                            1)
                                                                    : null,
                                                              ),
                                                            );
                                                          }
                                                        },
                                                        errorBuilder: (context,
                                                            error, stackTrace) {
                                                          return Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.2,
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.3,
                                                            color: Colors
                                                                .grey[300],
                                                            alignment: Alignment
                                                                .center,
                                                            child: Icon(
                                                              Icons
                                                                  .co_present_rounded,
                                                              size: 70,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          );
                                                        },
                                                      )
                                                    : Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.2,
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.3,
                                                        color: Colors.grey[300],
                                                        alignment:
                                                            Alignment.center,
                                                        child: Icon(
                                                          Icons
                                                              .co_present_rounded,
                                                          size: 50,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: AppColors.gradientBackgroundList,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        controller.usernameUpdateRequest
                                                .username.isNotEmpty
                                            ? controller
                                                .usernameUpdateRequest.username
                                            : (controller.userData.isNotEmpty
                                                ? controller
                                                    .userData.first.username
                                                : 'NA'),
                                        style: AppTextStyles.titleText.copyWith(
                                          fontSize: getResponsiveFontSize(0.04),
                                          color: Colors.white,
                                        ),
                                      ),
                                      // SizedBox(height: 8),
                                      // Text(
                                      //   'Click to change username',
                                      //   style: AppTextStyles.textStyle.copyWith(
                                      //     fontSize: getResponsiveFontSize(0.02),
                                      //     color: Colors.white70,
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.edit,
                                        size: 20, color: Colors.white),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            backgroundColor: Colors.transparent,
                                            contentPadding: EdgeInsets.zero,
                                            content: Container(
                                              padding: const EdgeInsets.all(20),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: AppColors
                                                      .gradientBackgroundList,
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Edit Username',
                                                    style: AppTextStyles
                                                        .titleText
                                                        .copyWith(
                                                      fontSize:
                                                          getResponsiveFontSize(
                                                              0.03),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 20),
                                                  SizedBox(
                                                    height: 80,
                                                    child: Scrollbar(
                                                      child:
                                                          SingleChildScrollView(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            TextField(
                                                              cursorColor:
                                                                  AppColors
                                                                      .cursorColor,
                                                              controller:
                                                                  _usernameController,
                                                              onChanged:
                                                                  (value) {
                                                                controller
                                                                    .usernameUpdateRequest
                                                                    .username = value;
                                                              },
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                              decoration:
                                                                  InputDecoration(
                                                                labelText:
                                                                    'Username',
                                                                labelStyle:
                                                                    AppTextStyles
                                                                        .labelText
                                                                        .copyWith(
                                                                  fontSize:
                                                                      getResponsiveFontSize(
                                                                          0.03),
                                                                  color: Colors
                                                                      .white70,
                                                                ),
                                                                filled: true,
                                                                fillColor: Colors
                                                                    .white
                                                                    .withOpacity(
                                                                        0.1),
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  borderSide:
                                                                      BorderSide
                                                                          .none,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 20),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      TextButton(
                                                        style: TextButton
                                                            .styleFrom(
                                                          foregroundColor:
                                                              Colors.white,
                                                          backgroundColor:
                                                              AppColors
                                                                  .inactiveColor,
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      16),
                                                        ),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text(
                                                          'Cancel',
                                                          style: AppTextStyles
                                                              .buttonText
                                                              .copyWith(
                                                            fontSize:
                                                                getResponsiveFontSize(
                                                                    0.03),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              AppColors
                                                                  .activeColor,
                                                          foregroundColor:
                                                              Colors.white,
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      20),
                                                        ),
                                                        onPressed: () async{
                                                          final updatedUsername =
                                                              controller
                                                                      .usernameUpdateRequest
                                                                      .username
                                                                      .isNotEmpty
                                                                  ? controller
                                                                      .usernameUpdateRequest
                                                                      .username
                                                                  : controller
                                                                      .userData
                                                                      .first
                                                                      .username;

                                                          controller
                                                              .updateusername(
                                                            UsernameUpdateRequest(
                                                                username:
                                                                    updatedUsername),
                                                          );
                                                          await controller.fetchProfile(); // Refresh user data from backend
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text(
                                                          'Save',
                                                          style: AppTextStyles
                                                              .buttonText
                                                              .copyWith(
                                                            fontSize:
                                                                getResponsiveFontSize(
                                                                    0.03),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 22, vertical: 16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: AppColors.gradientBackgroundList,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    controller.userData.isNotEmpty
                                        ? (() {
                                            try {
                                              String dobString = controller
                                                  .userData.first.dob
                                                  .trim();

                                              if (dobString.contains(' at ')) {
                                                dobString = dobString
                                                    .split(' at ')[0]
                                                    .trim();
                                              }

                                              // Parse using correct format: dd/MM/yyyy
                                              DateTime dob =
                                                  DateFormat('dd/MM/yyyy')
                                                      .parse(dobString);

                                              // Calculate age accurately
                                              DateTime today = DateTime.now();
                                              int age = today.year - dob.year;
                                              if (today.month < dob.month ||
                                                  (today.month == dob.month &&
                                                      today.day < dob.day)) {
                                                age--;
                                              }

                                              return '$age years old | ${controller.userData.first.genderName}';
                                            } catch (e) {
                                              print('DOB parsing error: $e');
                                              return 'NA';
                                            }
                                          })()
                                        : 'NA',
                                    style: AppTextStyles.labelText.copyWith(
                                      fontSize: getResponsiveFontSize(0.03),
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 2),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment(0.8, 1),
                                  colors: AppColors.gradientBackgroundList,
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x66666666),
                                    blurRadius: 10.0,
                                    spreadRadius: 3.0,
                                    offset: Offset(0, 6.0),
                                  ),
                                ],
                              ),
                              child: InkWell(
                                onTap: () {
                                  showVerificationDialog(context);
                                },
                                borderRadius: BorderRadius.circular(10.0),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: screenWidth * 0.045,
                                    horizontal: screenWidth * 0.045,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: controller.userData
                                                              .isNotEmpty &&
                                                          controller
                                                                  .userData
                                                                  .first
                                                                  .accountVerificationStatus ==
                                                              '1'
                                                      ? Colors.green
                                                          .withOpacity(0.15)
                                                      : Colors.red
                                                          .withOpacity(0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      screenWidth * 0.025,
                                                  vertical: screenWidth * 0.01,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      controller.userData
                                                                  .isNotEmpty &&
                                                              controller
                                                                      .userData
                                                                      .first
                                                                      .accountVerificationStatus ==
                                                                  '1'
                                                          ? Icons.verified
                                                          : Icons.error_outline,
                                                      color: controller.userData
                                                                  .isNotEmpty &&
                                                              controller
                                                                      .userData
                                                                      .first
                                                                      .accountVerificationStatus ==
                                                                  '1'
                                                          ? Colors.green
                                                          : Colors.red,
                                                      size: screenWidth * 0.045,
                                                    ),
                                                    SizedBox(
                                                        width: screenWidth *
                                                            0.015),
                                                    Text(
                                                      controller.userData
                                                                  .isNotEmpty &&
                                                              controller
                                                                      .userData
                                                                      .first
                                                                      .accountVerificationStatus ==
                                                                  '1'
                                                          ? 'Verified'
                                                          : 'Not Verified',
                                                      style: TextStyle(
                                                        fontSize:
                                                            screenWidth * 0.045,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: controller
                                                                    .userData
                                                                    .isNotEmpty &&
                                                                controller
                                                                        .userData
                                                                        .first
                                                                        .accountVerificationStatus ==
                                                                    '1'
                                                            ? Colors.green
                                                            : Colors.red,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                  width: screenWidth * 0.02),
                                              if (controller
                                                      .userData.isNotEmpty &&
                                                  controller.userData.first
                                                          .accountVerificationStatus !=
                                                      '1')
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        screenWidth * 0.02,
                                                    vertical:
                                                        screenWidth * 0.005,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        Colors.lightBlueAccent,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Text(
                                                    'Tap to verify',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize:
                                                          screenWidth * 0.03,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          SizedBox(height: screenWidth * 0.010),
                                          Text(
                                            _getAccountVerificationMessage(
                                                controller.userData.first
                                                    .accountVerificationStatus),
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.025,
                                              color: _getAccountVerificationColor(
                                                  controller.userData.first
                                                      .accountVerificationStatus),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                      AnimatedSwitcher(
                                        duration: const Duration(seconds: 1),
                                        child: controller.userData.isNotEmpty &&
                                                controller.userData.first
                                                        .accountVerificationStatus ==
                                                    '1'
                                            ? Icon(
                                                Icons.verified_user_outlined,
                                                color: Colors.green,
                                                size: screenWidth * 0.09,
                                                key: const ValueKey<int>(1),
                                              )
                                            : Icon(
                                                Icons.cancel_outlined,
                                                color: Colors.red,
                                                size: screenWidth * 0.06,
                                                key: const ValueKey<int>(0),
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 6),
                              padding: EdgeInsets.symmetric(
                                vertical: screenWidth * 0.045,
                                horizontal: screenWidth * 0.045,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: AppColors.gradientBackgroundList,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  Get.to(PlanPage());
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.card_membership,
                                      size: screenWidth * 0.075,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: screenWidth * 0.045),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Membership',
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.04,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(height: screenWidth * 0.01),
                                          Text(
                                            'View or upgrade your membership plan',
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.03,
                                              color: Colors.white
                                                  .withOpacity(0.85),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: screenWidth * 0.045,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.025, // ~16
                                vertical: screenWidth * 0.01, // ~4
                              ),
                              child: Column(
                                children: [
                                  buildSettingCard(
                                    context,
                                    title: 'Edit Profile',
                                    subtitle: 'Edit your profile details',
                                    icon: Icons.edit,
                                    onTap: () => Get.to(EditProfilePage()),
                                    screenWidth: screenWidth,
                                  ),
                                  buildSettingCard(
                                    context,
                                    title: 'Your Orders',
                                    subtitle: 'See Your All Orders',
                                    icon: Icons.plagiarism_outlined,
                                    onTap: () => Get.to(AllOrdersPage()),
                                    screenWidth: screenWidth,
                                  ),
                                  buildSettingCard(
                                    context,
                                    title: 'Transactions',
                                    subtitle: 'See Your All Transactions',
                                    icon: Icons.monetization_on_outlined,
                                    onTap: () => Get.to(AllTransactionsPage()),
                                    screenWidth: screenWidth,
                                  ),
                                  buildSettingCard(
                                    context,
                                    title: 'Your Wallets',
                                    subtitle: 'See Your All Wallets Details',
                                    icon: Icons.wallet,
                                    onTap: () => Get.to(WalletPage()),
                                    screenWidth: screenWidth,
                                  ),
                                  buildSettingCard(
                                    context,
                                    title: 'Generate Referral Code',
                                    subtitle:
                                        'Refer your friends using referral code',
                                    icon: Icons.offline_share_outlined,
                                    onTap: () => Get.to(GenerateReferralPage()),
                                    screenWidth: screenWidth,
                                  ),
                                  buildSettingCard(
                                    context,
                                    title: 'Share The Application',
                                    subtitle:
                                        'Share our application with others',
                                    icon: Icons.share,
                                    onTap: showShareProfileBottomSheet,
                                    screenWidth: screenWidth,
                                  ),
                                  buildSettingCard(
                                    context,
                                    title: 'Help',
                                    subtitle: 'Helpline support',
                                    icon: Icons.help,
                                    onTap: () => showHelpBottomSheet(context),
                                    screenWidth: screenWidth,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ));
                }),
          ],
        ),
      ),
    );
  }

  Widget buildSettingCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required double screenWidth,
  }) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: double.infinity, // forces full width inside Column
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        padding: EdgeInsets.symmetric(
          vertical: screenWidth * 0.045,
          horizontal: screenWidth * 0.035,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.gradientBackgroundList,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Row(
            children: [
              Icon(
                icon,
                size: screenWidth * 0.075,
                color: Colors.white,
              ),
              SizedBox(width: screenWidth * 0.045),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.01),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: screenWidth * 0.03,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: screenWidth * 0.045,
                color: Colors.white,
              ),
            ],
          ),
        ),
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
              child: imagePath.startsWith('http')
                  ? Image.network(
                      imagePath,
                      fit: BoxFit.contain,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 100,
                            color: Colors.grey,
                          ),
                        );
                      },
                    )
                  : Image.network(
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
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => AppInfoPage()),
                  );
                  // Get.to(AppInfoPage());
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
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment(0.8, 1),
                            colors: AppColors.gradientBackgroundList,
                          ),
                          borderRadius: BorderRadius.circular(
                              30), // You can adjust the border radius here
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            shareUserProfile();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
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
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 183, 183, 183),
                          borderRadius: BorderRadius.circular(
                              30), // You can adjust the border radius here
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
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

  String _getAccountVerificationMessage(String status) {
    switch (status) {
      case '0':
        return 'Verification Pending';
      case '1':
        return 'Your Account Is Verified Successfully';
      case '2':
        return 'Verification Rejected';
      default:
        return 'UnVerified (Please Verify)';
    }
  }

  Color _getAccountVerificationColor(String status) {
    switch (status) {
      case '0':
        return const Color.fromARGB(255, 255, 255, 255);
      case '1':
        return const Color.fromARGB(255, 255, 255, 255);
      case '2':
        return const Color.fromARGB(255, 59, 36, 1);
      default:
        return const Color.fromARGB(255, 111, 109, 109);
    }
  }

  void showVerificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.gradientBackgroundList,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Account Verification',
                    style:
                        AppTextStyles.titleText.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'To verify your account, you need to submit a photo. Choose one of the following options for your photo submission.',
                  style:
                      AppTextStyles.textStyle.copyWith(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 14),
                        minimumSize: const Size(0, 36),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.textStyle.copyWith(
                          fontSize: 14,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 14),
                        minimumSize: const Size(0, 36),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        controller.fetchAllverificationtype();
                        Navigator.of(context).pop();
                        Get.to(PhotoVerificationPage());
                      },
                      child: Text(
                        'Confirm',
                        style: AppTextStyles.textStyle.copyWith(
                          fontSize: 14,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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

// class SettingCard extends StatefulWidget {
//   final String title;
//   final String subtitle;
//   final IconData icon;
//   final VoidCallback onTap;

//   const SettingCard({
//     super.key,
//     required this.title,
//     required this.subtitle,
//     required this.icon,
//     required this.onTap,
//   });

//   @override
//   SettingCardState createState() => SettingCardState();
// }

// class SettingCardState extends State<SettingCard>
//     with TickerProviderStateMixin {
//   late final AnimationController _animationController;
//   late final DecorationTween decorationTween;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 1),
//     )..repeat(reverse: true);

//     // Create the DecorationTween with the gradient
//     decorationTween = DecorationTween(
//       begin: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment(0.8, 1),
//           colors: <Color>[
//             Color(0xff1f005c),
//             Color(0xff5b0060),
//             Color(0xff870160),
//             Color(0xffac255e),
//             Color(0xffca485c),
//             Color(0xffe16b5c),
//             Color(0xfff39060),
//             Color(0xffffb56b),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(10.0), // Border radius for rounded corners
//         boxShadow: const <BoxShadow>[
//           BoxShadow(
//             color: Color(0x66666666),
//             blurRadius: 10.0,
//             spreadRadius: 3.0,
//             offset: Offset(0, 6.0),
//           ),
//         ],
//       ),
//       end: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment(0.8, 1),
//           colors: <Color>[
//             Color(0xff1f005c),
//             Color(0xff5b0060),
//             Color(0xff870160),
//             Color(0xffac255e),
//             Color(0xffca485c),
//             Color(0xffe16b5c),
//             Color(0xfff39060),
//             Color(0xffffb56b),
//           ],
//         ),
//         borderRadius: BorderRadius.circular(10.0), // Same border radius as begin
//         boxShadow: const <BoxShadow>[
//           BoxShadow(
//             color: Color(0x66666666),
//             blurRadius: 10.0,
//             spreadRadius: 3.0,
//             offset: Offset(0, 6.0),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;

//     return SizedBox(
//       width: screenWidth * 0.9, // Decrease width to 80% of the screen width
//       height: screenHeight * 0.078,
//       child: DecoratedBoxTransition(
//         decoration: decorationTween.animate(_animationController),
//         child: Card(
//           elevation: 4,
//           color: Colors.transparent, // Set card color to transparent as the gradient is applied via decoration
//           child: ListTile(
//             title: Text(
//               widget.title,
//               style: TextStyle(
//                 fontSize: screenWidth * 0.03,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             subtitle: Text(
//               widget.subtitle,
//               style: TextStyle(fontSize: screenWidth * 0.02),
//             ),
//             trailing: Icon(widget.icon),
//             onTap: widget.onTap,
//           ),
//         ),
//       ),
//     );
//   }
// }

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
    double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      width: screenWidth * 0.9, // Decrease width to 80% of the screen width
      height: screenHeight * 0.078,
      child: Card(
        elevation: 4,
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // Rounded corners
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment(0.8, 1),
              colors: AppColors.gradientBackgroundList,
            ),
            borderRadius: BorderRadius.circular(10.0), // Rounded corners
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x66666666),
                blurRadius: 10.0,
                spreadRadius: 3.0,
                offset: Offset(0, 6.0),
              ),
            ],
          ),
          child: ListTile(
            title: Text(
              title,
              style: TextStyle(
                fontSize: screenWidth * 0.03,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(fontSize: screenWidth * 0.02),
            ),
            trailing: Icon(icon),
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}
