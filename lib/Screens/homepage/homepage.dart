import 'package:dating_application/Controllers/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  Controller controller = Get.put(Controller());

  double getResponsiveFontSize(double scale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * scale; // Adjust this scale for different text elements
  }

  bool isLiked = false;
  bool isDisliked = false;
  bool isShare = false;
  bool isLoading = true;
  int messageCount = 0;
  final TextEditingController messageController = TextEditingController();
  final FocusNode messageFocusNode = FocusNode();
  final PageController _imagePageController = PageController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    messageFocusNode.dispose();
    super.dispose();
  }

  void incrementPing() {
    setState(() {
      messageCount++;
    });
  }

  void _showFullImageDialog(BuildContext context, String imagePath) {
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

  void shareUserProfile() {
    final String profileUrl = 'https://example.com/user-profile';
    final String profileDetails =
        "Check out this profile:\nJohn Doe\nAge: 25\nGender: Male\n$profileUrl";
    Share.share(profileDetails);
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

  void showmessageBottomSheet() {
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
                controller: messageController,
                cursorColor: AppColors.cursorColor,
                focusNode: messageFocusNode,
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
                  if (messageController.text.isNotEmpty) {
                    setState(() {
                      messageCount--;
                    });
                    messageController.clear();
                    Get.back();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Message sent!')),
                    );
                  }
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Responsive font size calculation
    double fontSize = size.width * 0.045; // Base font size
    double bodyFontSize = size.width * 0.035;

    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            FutureBuilder(
                future: controller.userSuggestions(),
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
                  if (!snapshot.hasData || snapshot.data == null) {
                    return Center(
                      child: Text(
                        'No data available.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height,
                          child: PageView.builder(
                            // controller: _pageController,
                            itemCount: controller.userSuggestionsList.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.all(
                                  MediaQuery.of(context).size.width * 0.04,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.4,
                                      child: Stack(
                                        children: [
                                          if (isLoading)
                                            Center(
                                              child: SpinKitCircle(
                                                size: 150.0,
                                                color: AppColors.acceptColor,
                                              ),
                                            ),
                                          ListView.builder(
                                            controller: _imagePageController,
                                            scrollDirection: Axis.vertical,
                                            itemCount: controller
                                                .userSuggestionsList[index]
                                                .images
                                                .length,
                                            itemBuilder: (context, imgIndex) {
                                              return GestureDetector(
                                                onTap: () =>
                                                    _showFullImageDialog(
                                                        context,
                                                        controller
                                                            .userSuggestionsList[
                                                                index]
                                                            .images[imgIndex]),
                                                child: Container(
                                                  margin: EdgeInsets.only(
                                                      bottom: 12),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    child: Image.network(
                                                      controller
                                                          .userSuggestionsList[
                                                              index]
                                                          .images[imgIndex],
                                                      fit: BoxFit.cover,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.9,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.45,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          Positioned(
                                            bottom: 10,
                                            right: 0,
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                vertical: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.1, // Adjust vertical padding
                                              ),
                                              child: Transform.rotate(
                                                angle:
                                                    -1.5708, // -1.5708 radians = 90 degrees counterclockwise
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .center, // Centers the dots horizontally
                                                  children: [
                                                    SmoothPageIndicator(
                                                      controller:
                                                          _imagePageController,
                                                      count: controller
                                                          .userSuggestionsList[
                                                              index]
                                                          .images
                                                          .length,
                                                      effect:
                                                          ExpandingDotsEffect(
                                                        dotHeight: 10,
                                                        dotWidth: 10,
                                                        spacing: 10,
                                                        radius: 5,
                                                        dotColor: Colors.grey
                                                            .withOpacity(0.5),
                                                        activeDotColor:
                                                            AppColors
                                                                .acceptColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 16,
                                      left: 16,
                                      child: Row(
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                isLiked = !isLiked;
                                              });
                                            },
                                            icon: Icon(
                                              isLiked
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              size: 40,
                                              color: isLiked
                                                  ? Colors.red
                                                  : Colors.white,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              setState(() {
                                                isDisliked = !isDisliked;
                                              });
                                            },
                                            icon: Icon(
                                              isDisliked
                                                  ? Icons.thumb_down
                                                  : Icons
                                                      .thumb_down_alt_outlined,
                                              size: 40,
                                              color: isDisliked
                                                  ? Colors.red
                                                  : Colors.white,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {
                                              showShareProfileBottomSheet();
                                              setState(() {
                                                isShare = !isShare;
                                              });
                                            },
                                            icon: Icon(
                                              isShare
                                                  ? Icons.share
                                                  : Icons.share,
                                              size: 40,
                                              color: isShare
                                                  ? Colors.green
                                                  : Colors.white,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: showmessageBottomSheet,
                                            icon: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Icon(
                                                  Icons.chat_outlined,
                                                  size: 40,
                                                  color: AppColors.textColor,
                                                ),
                                                if (messageCount > 0)
                                                  Positioned(
                                                    top: 0,
                                                    right: 0,
                                                    child: CircleAvatar(
                                                      radius: 10,
                                                      backgroundColor:
                                                          AppColors.deniedColor,
                                                      child: Text(
                                                        '$messageCount',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: AppColors
                                                              .textColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      controller.userSuggestionsList[index]
                                              .name ??
                                          'NA',
                                      style: AppTextStyles.headingText.copyWith(
                                        fontSize: fontSize,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          '${controller.userSuggestionsList[index].dob != null ? DateTime.now().year - DateTime.parse(controller.userSuggestionsList[index].dob!).year : 'NA'} years old | ',
                                          style:
                                              AppTextStyles.bodyText.copyWith(
                                            fontSize: bodyFontSize,
                                          ),
                                        ),
                                        Text(
                                          '${controller.userSuggestionsList[index].city ?? 'NA'} | ',
                                          style:
                                              AppTextStyles.bodyText.copyWith(
                                            fontSize: bodyFontSize,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                })
          ],
        ));
  }
}
