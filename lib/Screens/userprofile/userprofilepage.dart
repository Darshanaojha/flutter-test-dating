import 'dart:convert';
import 'package:dating_application/Screens/settings/appinfopages/faqpage.dart';
import 'package:dating_application/Screens/userprofile/Orders/OrdersViewScreen.dart';
import 'package:dating_application/Screens/userprofile/membership/userselectedplan.dart';
import 'package:dating_application/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';

import '../../Controllers/controller.dart';
import '../../Models/RequestModels/usernameupdate_request_model.dart';
import '../../Models/RequestModels/estabish_connection_request_model.dart';
import '../settings/appinfopages/appinfopagestart.dart';
import 'GenerateReferalCode/GenerateReferalCode.dart';
import 'Transactions/TransactionsViewScreen.dart';
import 'editprofile/edituserprofile.dart';

class UserProfilePage extends StatefulWidget {
  final String? userId;
  const UserProfilePage({super.key, this.userId});

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

  /// Helper function to normalize base64 string (add padding if needed)
  String _normalizeBase64(String base64) {
    // Remove data URL prefix if present
    String clean = base64.contains(',') ? base64.split(',')[1] : base64;
    // Remove whitespace
    clean = clean.trim();
    // Add padding if needed (base64 strings should be divisible by 4)
    int remainder = clean.length % 4;
    if (remainder != 0) {
      clean += '=' * (4 - remainder);
    }
    return clean;
  }

  /// Helper function to check if a string is a base64 image
  bool _isBase64Image(String? image) {
    if (image == null || image.isEmpty) return false;
    // If it starts with http, it's definitely a URL
    if (image.startsWith('http://') || image.startsWith('https://')) {
      return false;
    }
    // If it starts with /, it might be a base64 string (like /9j/ for JPEG)
    // or it could be a path - check if it's long enough to be base64
    if (image.startsWith('/') && image.length > 50) {
      // Likely base64 if it's long and starts with /9j/ (JPEG) or /iVB (PNG)
      if (image.startsWith('/9j/') || image.startsWith('/iVB')) {
        try {
          String normalized = _normalizeBase64(image);
          base64Decode(normalized);
          return true;
        } catch (e) {
          return false;
        }
      }
    }
    // Remove data URL prefix if present (e.g., "data:image/jpeg;base64,")
    String cleanImage = image.contains(',') ? image.split(',')[1] : image;
    cleanImage = cleanImage.trim();
    // Base64 strings should be reasonably long (at least 20 chars for a tiny image)
    if (cleanImage.length < 20) return false;
    // Try to normalize and decode
    try {
      String normalized = _normalizeBase64(cleanImage);
      base64Decode(normalized);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Sort images: base64 images first, then URLs, maintaining order within each group
  List<String> _sortImages(List<String> images, {String? profileImage}) {
    if (images.isEmpty) return images;
    
    List<String> sortedImages = List.from(images);
    
    // Sort by type - base64 first, then URLs
    sortedImages.sort((a, b) {
      bool aIsBase64 = _isBase64Image(a);
      bool bIsBase64 = _isBase64Image(b);
      
      if (aIsBase64 && !bIsBase64) return -1; // base64 comes first
      if (!aIsBase64 && bIsBase64) return 1;  // URLs come after
      return 0; // maintain original order within same type
    });
    
    // If profile image exists and is in the list, move it to first position
    if (profileImage != null && profileImage.isNotEmpty) {
      if (sortedImages.contains(profileImage)) {
        sortedImages.remove(profileImage);
        sortedImages.insert(0, profileImage);
      } else if (_isBase64Image(profileImage) || profileImage.startsWith('http')) {
        // If profile image is not in the list but is valid, add it first
        sortedImages.insert(0, profileImage);
      }
    }
    
    return sortedImages;
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

  bool isValidUsername(String username) {
    // Allow Unicode letters, digits, and underscores only
    final validUsernameRegExp = RegExp(r'^[\p{L}\p{M}\p{N}_]+$', unicode: true);
    return validUsernameRegExp.hasMatch(username);
  }

  Future<void> _refreshData() async {
    await Future.delayed(Duration(seconds: 2));
    await controller.fetchProfile();
    await controller.fetchProfileUserPhotos();
  }

  String _getAccountVerificationStatusText() {
    if (controller.userData.isEmpty) {
      return 'Verification Pending';
    }
    switch (controller.userData.first.packageStatus) {
      case '0':
        return 'Not Verified';
      case '1':
        return 'Account Verified';
      case '2':
        return 'Rejected';
      case '3':
        return 'Pending';
      case '4':
        return 'Account Verified';
      default:
        return 'Verification Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: RefreshIndicator(
        color: Color(0xFFCCB3F2), // Light purple color
        onRefresh: _refreshData,
        child: Stack(
        children: [
            FutureBuilder<bool>(
                future: _fetchprofilepage,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Lottie.asset(
                          "assets/animations/hearthmatch_lottie1-2.json",
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
                                    : Builder(
                                        builder: (context) {
                                          // Sort images: base64 first, then URLs
                                          List<String> sortedImages = _sortImages(
                                            controller.userPhotos!.images,
                                            profileImage: controller.userData.isNotEmpty
                                                ? controller.userData.first.profileImage
                                                : null,
                                          );
                                          
                                          return ListView.builder(
                    scrollDirection: Axis.horizontal,
                                            itemCount: sortedImages.length,
                    itemBuilder: (context, index) {
                                              final imagePath = sortedImages[index];
                      return Padding(
                                                padding: const EdgeInsets.all(6.0),
                        child: GestureDetector(
                                                  onTap: () => showFullImageDialog(
                                                      context, imagePath),
                          child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(15),
                                                    child: imagePath.isNotEmpty
                                                        ? _isBase64Image(imagePath)
                                                            ? Builder(
                                                                builder: (context) {
                                                                  try {
                                                                    String normalizedBase64 = _normalizeBase64(imagePath);
                                                                    return Image.memory(
                                                                      base64Decode(normalizedBase64),
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
                                                                      errorBuilder: (context,
                                                                          error, stackTrace) {
                                                                        print('Base64 image decode error: $error');
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
                                                                    );
                                                                  } catch (e) {
                                                                    print('Error decoding base64 image: $e');
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
                                                                      color: Colors.grey[300],
                                                                      alignment: Alignment.center,
                                                                      child: Icon(
                                                                        Icons.co_present_rounded,
                                                                        size: 70,
                                                                        color: Colors.grey,
                                                                      ),
                                                                    );
                                                                  }
                                                                },
                                                              )
                                                            : Image.network(
                                                                imagePath,
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
                                          );
                                        },
                                      ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 6),
                              padding: EdgeInsets.symmetric(
                                vertical: screenWidth * 0.015,
                                horizontal: screenWidth * 0.045,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppColors.appBarGradient,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            (controller.userData.isNotEmpty
                                                ? controller
                                                    .userData.first.username
                                                : 'NA'),
                                            style: AppTextStyles.titleText
                                                .copyWith(
                                              fontSize:
                                                  getResponsiveFontSize(0.045),
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                  ),
                ),
                                          if (controller.userData.isNotEmpty &&
                                              controller.userData.first
                                                      .packageStatus ==
                                                  '1' || controller.
                                                      userData
                                                      .first
                                                      .packageStatus == '4')
                Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0),
                                              child: Icon(
                                                Icons.verified,
                                                color: Colors.green,
                                                size: getResponsiveFontSize(
                                                    0.045),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        controller.userData.isNotEmpty
                                            ? (() {
                                                try {
                                                  String dobString = controller
                                                      .userData.first.dob
                                                      .trim();

                                                  if (dobString
                                                      .contains(' at ')) {
                                                    dobString = dobString
                                                        .split(' at ')[0]
                                                        .trim();
                                                  }

                                                  DateTime dob =
                                                      DateFormat('MM/dd/yyyy')
                                                          .parse(dobString);

                                                  DateTime today =
                                                      DateTime.now();
                                                  int age =
                                                      today.year - dob.year;
                                                  if (today.month < dob.month ||
                                                      (today.month ==
                                                              dob.month &&
                                                          today.day <
                                                              dob.day)) {
                                                    age--;
                                                  }

                                                  return '$age years old | ${controller.userData.first.genderName}';
                                                } catch (e) {
                                                  print(
                                                      'DOB parsing error: $e');
                                                  return 'NA';
                                                }
                                              })()
                                            : 'NA',
                                        style: AppTextStyles.labelText.copyWith(
                                          fontSize:
                                              getResponsiveFontSize(0.025),
                                          color: Colors.white,
                      ),
                    ),
                                    ],
                ),
                                  IconButton(
                                    icon: Icon(Icons.edit,
                                        size: screenWidth * 0.05,
                                        color: Colors.white),
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
                                                gradient:
                                                    AppColors.appBarGradient,
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
                                                              0.04),
                                                      fontWeight:
                                                          FontWeight.bold,
                              color: Colors.white,
                            ),
                                                  ),
                                                  const SizedBox(height: 20),
                            Text(
                                                    'Be creative! Your username can have only letters, numbers, or underscores (_)',
                                                    style: AppTextStyles
                                                        .titleText
                                                        .copyWith(
                                                      fontSize:
                                                          getResponsiveFontSize(
                                                              0.03),
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
                                                                        .username =
                                                                    value
                                                                        .toLowerCase()
                                                                        .trim();
                                                              },
                                                              style: const TextStyle(
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
                                                                      .white,
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
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      // Cancel Button with Gradient Text
                                                      SizedBox(
                                                        height: screenHeight *
                                                            0.055,
                                                        width:
                                                            screenWidth * 0.28,
                                                        child: ElevatedButton(
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                Colors.white,
                                                            elevation: 0,
                                                            padding:
                                                                EdgeInsets.zero,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          46),
                                                            ),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: ShaderMask(
                                                            shaderCallback:
                                                                (bounds) =>
                                                                    LinearGradient(
                                                              colors: AppColors
                                                                  .gradientBackgroundList,
                                                              begin: Alignment
                                                                  .topLeft,
                                                              end: Alignment
                                                                  .bottomRight,
                                                            ).createShader(
                                                              Rect.fromLTWH(
                                                                  0,
                                                                  0,
                                                                  bounds.width,
                                                                  bounds
                                                                      .height),
                                                            ),
                                                            blendMode:
                                                                BlendMode.srcIn,
                                                            child: Text(
                                                              'Cancel',
                                                              style:
                                                                  AppTextStyles
                                                                      .buttonText
                                                                      .copyWith(
                                                                fontSize:
                                                                    getResponsiveFontSize(
                                                                        0.03),
                                                                color: Colors
                                                                    .white, // Required for ShaderMask to work
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      // Save Button with Gradient Background
                                                      SizedBox(
                                                        height: screenHeight *
                                                            0.055,
                                                        width:
                                                            screenWidth * 0.28,
                      child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            gradient:
                                                                LinearGradient(
                                                              colors: AppColors
                                                                  .reversedGradientColor,
                                                              begin: Alignment
                                                                  .topLeft,
                                                              end: Alignment
                                                                  .bottomRight,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        46),
                                                          ),
                                                          child: ElevatedButton(
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              elevation: 0,
                                                              backgroundColor:
                                                                  Colors
                                                                      .transparent,
                                                              shadowColor: Colors
                                                                  .transparent,
                                                              padding:
                                                                  EdgeInsets
                                                                      .zero,
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            46),
                                                              ),
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              final updatedUsername =
                                                                  _usernameController
                                                                      .text
                                                                      .toLowerCase()
                                                                      .trim();

                                                              if (updatedUsername
                                                                  .isEmpty) {
                                                                failure(
                                                                    "Invalid Username",
                                                                    "Username cannot be empty.");
                                                                return;
                                                              }
                                                              if (!isValidUsername(
                                                                  updatedUsername)) {
                                                                failure(
                                                                  "Invalid Username",
                                                                  "Username can only contain letters, numbers, and underscores. No spaces or special characters allowed.",
                                                                );
                                                                return;
                                                              }

                                                              bool success =
                                                                  await controller
                                                                      .updateusername(
                                                                UsernameUpdateRequest(
                                                                    username:
                                                                        updatedUsername),
                                                              );
                                                              if (success) {
                                                                await controller
                                                                    .fetchProfile();
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              } else {
                                                                _usernameController
                                                                        .text =
                                                                    controller
                                                                        .userData
                                                                        .first
                                                                        .username;
                                                                failure(
                                                                    "Failed",
                                                                    "Failed to update username. Please try again.");
                                                              }
                                                            },
                                                            child: Text(
                                                              'Save',
                                                              style:
                                                                  AppTextStyles
                                                                      .buttonText
                                                                      .copyWith(
                                                                fontSize:
                                                                    getResponsiveFontSize(
                                                                        0.03),
                                                              ),
                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  )
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
                            // Container(
                            //   margin: const EdgeInsets.symmetric(
                            //       horizontal: 16, vertical: 6),
                            //   padding: const EdgeInsets.symmetric(
                            //       horizontal: 22, vertical: 16),
                            //   decoration: BoxDecoration(
                            //     gradient: LinearGradient(
                            //       colors: AppColors.gradientBackgroundList,
                            //       begin: Alignment.topLeft,
                            //       end: Alignment.bottomRight,
                            //     ),
                            //     borderRadius: BorderRadius.circular(16),
                            //     boxShadow: [
                            //       BoxShadow(
                            //         color: Colors.black12,
                            //         blurRadius: 8,
                            //         offset: Offset(0, 4),
                            //       ),
                            //     ],
                            //   ),
                            //   child: Row(
                            //     children: [
                            //       Text(
                            //         controller.userData.isNotEmpty
                            //             ? (() {
                            //                 try {
                            //                   String dobString = controller
                            //                       .userData.first.dob
                            //                       .trim();
                            //                   if (dobString.contains(' at ')) {
                            //                     dobString = dobString
                            //                         .split(' at ')[0]
                            //                         .trim();
                            //                   }
                            //                   // Parse using correct format: dd/MM/yyyy
                            //                   DateTime dob =
                            //                       DateFormat('dd/MM/yyyy')
                            //                           .parse(dobString);
                            //                   // Calculate age accurately
                            //                   DateTime today = DateTime.now();
                            //                   int age = today.year - dob.year;
                            //                   if (today.month < dob.month ||
                            //                       (today.month == dob.month &&
                            //                           today.day < dob.day)) {
                            //                     age--;
                            //                   }
                            //                   return '$age years old | ${controller.userData.first.genderName}';
                            //                 } catch (e) {
                            //                   print('DOB parsing error: $e');
                            //                   return 'NA';
                            //                 }
                            //               })()
                            //             : 'NA',
                            //         style: AppTextStyles.labelText.copyWith(
                            //           fontSize: getResponsiveFontSize(0.03),
                            //           color: Colors.white,
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            //SizedBox(height: 2),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 0),
                              decoration: BoxDecoration(
                                gradient: AppColors.appBarGradient,
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                    child: InkWell(
                                onTap: () {
                                  if (controller.userData.isNotEmpty &&
                                      (controller.userData.first.packageStatus ==
                                          '1' || controller
                                              .userData
                                              .first
                                              .packageStatus == '4')) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'No further action needed.Your verification is successful. You are now a trusted user on the platform.'),
                                      ),
                                    );
                                    // success('Verification',
                                    //     'No further action needed.Your verification is successful. You are now a trusted user on the platform.');
                                  } else {
                                    controller.showVerificationDialog(context);
                                  }
                                },
                                borderRadius: BorderRadius.circular(16.0),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: screenWidth * 0.025,
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
                            Icon(
                                                Icons.verified_user_outlined,
                                                size: screenWidth * 0.07,
                              color: Colors.white,
                            ),
                            SizedBox(
                                                  width: screenWidth * 0.025),
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: controller.userData
                                                              .isNotEmpty &&
                                                          controller
                                                                  .userData
                                                                  .first
                                                                  .accountVerificationStatus ==
                                                              '1'
                                                      ? AppColors
                                                          .lightGradientColor
                                                          .withOpacity(0.15)
                                                      : Colors.white
                                                          .withOpacity(0.65),
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
                                                                  '1' || controller
                                                                      .userData
                                                                      .first
                                                                      .packageStatus == '4'
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
                                                      _getAccountVerificationStatusText(),
                                                      style: TextStyle(
                                                        fontSize:
                                                            screenWidth * 0.025,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: controller
                                                                    .userData
                                                                    .isNotEmpty &&
                                                                controller
                                                                        .userData
                                                                        .first
                                                                        .packageStatus ==
                                                                    '1' || controller
                                                                        .userData
                                                                        .first
                                                                        .packageStatus == '4'
                                                            ? Colors.green
                                                            : Colors.red,
                                                      ),
                            ),
                          ],
                        ),
                      ),
                                              // SizedBox(
                                              //     width: screenWidth * 0.02),
                                              // if (controller
                                              //         .userData.isNotEmpty &&
                                              //     controller.userData.first
                                              //             .accountVerificationStatus !=
                                              //         '1')
                                              // Container(
                                              //   padding: EdgeInsets.symmetric(
                                              //     horizontal:
                                              //         screenWidth * 0.02,
                                              //     vertical:
                                              //         screenWidth * 0.005,
                                              //   ),
                                              //   decoration: BoxDecoration(
                                              //     color:
                                              //         Colors.lightBlueAccent,
                                              //     borderRadius:
                                              //         BorderRadius.circular(
                                              //             12),
                                              //   ),
                                              //   child: Text(
                                              //     'Tap to verify',
                                              //     style: TextStyle(
                                              //       color: Colors.white,
                                              //       fontSize:
                                              //           screenWidth * 0.03,
                                              //       fontWeight:
                                              //           FontWeight.w500,
                                              //     ),
                                              //   ),
                                              // ),
                                            ],
                                          ),
                                          SizedBox(height: screenWidth * 0.010),
                                          // Text(
                                          //   _getAccountVerificationMessage(
                                          //       controller.userData.first
                                          //           .accountVerificationStatus),
                                          //   style: TextStyle(
                                          //     fontSize: screenWidth * 0.025,
                                          //     color: _getAccountVerificationColor(
                                          //         controller.userData.first
                                          //             .accountVerificationStatus),
                                          //   ),
                                          //   maxLines: 1,
                                          //   overflow: TextOverflow.ellipsis,
                                          // ),
                                        ],
                                      ),
                                      // AnimatedSwitcher(
                                      //   duration: const Duration(seconds: 1),
                                      //   child: controller.userData.isNotEmpty &&
                                      //           controller.userData.first
                                      //                   .accountVerificationStatus ==
                                      //               '1'
                                      //       ? Icon(
                                      //           Icons.verified_user_outlined,
                                      //           color: Colors.green,
                                      //           size: screenWidth * 0.09,
                                      //           key: const ValueKey<int>(1),
                                      //         )
                                      //       : Icon(
                                      //           Icons.cancel_outlined,
                                      //           color: Colors.red,
                                      //           size: screenWidth * 0.06,
                                      //           key: const ValueKey<int>(0),
                                      //         ),
                                      // ),
                                    ],
                                  ),
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
                                    title: 'Membership',
                                    subtitle:
                                        'View or upgrade your membership plan',
                                    icon: Icons.card_membership,
                                    onTap: () => Get.to(PlanPage()),
                                    screenWidth: screenWidth,
                                  ),
                                  buildSettingCard(
                                    context,
                                    title: 'Subscription History',
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
                                  // buildSettingCard(
                                  //   context,
                                  //   title: 'Your Wallets',
                                  //   subtitle: 'See Your All Wallets Details',
                                  //   icon: Icons.wallet,
                                  //   onTap: () => Get.to(WalletPage()),
                                  //   screenWidth: screenWidth,
                                  // ),
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
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        padding: EdgeInsets.symmetric(
          vertical: screenWidth * 0.02,
          horizontal: screenWidth * 0.055,
        ),
        decoration: BoxDecoration(
          gradient: AppColors.appBarGradient,
          borderRadius: BorderRadius.circular(10),
        ),
        // child: InkWell(
        //   borderRadius: BorderRadius.circular(16),
        //   onTap: onTap,
        //   child: Row(
        //     children: [
        //       Icon(
        //         icon,
        //         size: screenWidth * 0.075,
        //         color: Colors.white,
        //       ),
        //       SizedBox(width: screenWidth * 0.045),
        //       Expanded(
        //         child: Column(
        //           crossAxisAlignment: CrossAxisAlignment.start,
        //           children: [
        //             Text(
        //               title,
        //               style: TextStyle(
        //                 fontSize: screenWidth * 0.04,
        //                 fontWeight: FontWeight.bold,
        //                 color: Colors.white,
        //               ),
        //             ),
        //             SizedBox(height: screenWidth * 0.01),
        //             // Text(
        //             //   subtitle,
        //             //   style: TextStyle(
        //             //     fontSize: screenWidth * 0.027,
        //             //     color: Colors.white.withOpacity(0.85),
        //             //   ),
        //             // ),
        //           ],
        //         ),
        //       ),
        //       Icon(
        //         Icons.arrow_forward_ios_rounded,
        //         size: screenWidth * 0.045,
        //         color: Colors.white,
        //       ),
        //     ],
        //   ),
        // ),

        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: screenWidth * 0.0125),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: screenWidth * 0.065,
                  color: Colors.white,
                ),
                SizedBox(width: screenWidth * 0.045),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: screenWidth * 0.038,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: screenWidth * 0.045,
                  color: AppColors.darkGradientColor,
                ),
              ],
            ),
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
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Center(
              child: _isBase64Image(imagePath)
                  ? Builder(
                      builder: (context) {
                        try {
                          String normalizedBase64 = _normalizeBase64(imagePath);
                          return Image.memory(
                            base64Decode(normalizedBase64),
                            fit: BoxFit.contain,
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            errorBuilder: (context, error, stackTrace) {
                              print('Full image dialog base64 decode error: $error');
                              return Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 100,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          );
                        } catch (e) {
                          print('Error decoding base64 in full image dialog: $e');
                          return Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 100,
                              color: Colors.grey,
                            ),
                          );
                        }
                      },
                    )
                  : Image.network(
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
                      "Share application",
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
                          gradient: AppColors.appBarGradient,
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

void shareUserProfile() {
    final String profileUrl = 'https://example.com/user-profile';
    final String profileDetails =
        "Check out this profile:\nJohn Doe\nAge: 25\nGender: Male\n$profileUrl";
  Share.share(profileDetails);
}
}

Future<void> showMessageBottomSheet(String? userId) async {
  final Controller controller = Get.find<Controller>();
  final TextEditingController messageController = TextEditingController();
  final EstablishConnectionMessageRequest establishConnectionMessageRequest =
      EstablishConnectionMessageRequest(
    receiverId: userId ?? '',
    message: '',
    messagetype: 1,
  );
  bool isSending = false;

  Get.bottomSheet(
    StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Send a Message', style: AppTextStyles.inputFieldText),
                SizedBox(height: 20),
                TextField(
                  controller: messageController,
                  cursorColor: AppColors.cursorColor,
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
                  enabled: !isSending,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isSending
                      ? null
                      : () async {
                          if (messageController.text.trim().isEmpty) {
                            failure("Message Empty", "Please write a message to send.");
                            return;
                          }
                          if (userId == null || userId.isEmpty) {
                            failure("Error", "User ID is required to send message.");
                            return;
                          }
                          setState(() {
                            isSending = true;
                          });

                          establishConnectionMessageRequest.message =
                              messageController.text.trim();
                          establishConnectionMessageRequest.receiverId = userId;

                          bool messageSent = await controller
                              .sendConnectionMessage(establishConnectionMessageRequest);

                          if (messageSent) {
                            messageController.clear();
                            // Close bottom sheet after successful send
                            if (Get.isBottomSheetOpen ?? false) {
                              Get.back();
                            }
                          }

                          setState(() {
                            isSending = false;
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonColor,
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: isSending
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text('Send Message', style: AppTextStyles.buttonText),
                ),
              ],
            ),
          ),
        );
      },
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
            gradient: AppColors.appBarGradient, // Use the shared gradient
            borderRadius: BorderRadius.circular(10.0),
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
