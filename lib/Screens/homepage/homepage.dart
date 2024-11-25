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
  Controller controler = Get.put(Controller());
  final List<Map<String, dynamic>> users = [
    {
      'name': 'John Doe',
      'age': 25,
      'location': 'New York',
      'km': 10,
      'lastSeen': '2 hours ago',
      'desires': ['adventurous', 'gaming', 'hugging', 'playing', 'dancing'],
      'images': [
        'assets/images/image1.jpg',
        'assets/images/image1.jpg',
        'assets/images/image1.jpg'
      ],
    },
    {
      'name': 'Jane Smith',
      'age': 23,
      'location': 'Los Angeles',
      'km': 50,
      'lastSeen': '1 day ago',
      'desires': ['enjoys hiking', 'flaming', 'playing', 'beach', 'dancing'],
      'images': [
        'assets/images/image2.jpg',
        'assets/images/image2.jpg',
        'assets/images/image2.jpg'
      ],
    },
    {
      'name': 'Sam Wilson',
      'age': 28,
      'location': 'Chicago',
      'km': 100,
      'lastSeen': '3 hours ago',
      'desires': ['new places', 'spending', 'employment', 'playing', 'dancing'],
      'images': [
        'assets/images/image3.jpg',
        'assets/images/image3.jpg',
        'assets/images/image3.jpg'
      ],
    },
  ];
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
  // final PageController _pageController = PageController();
  final PageController _imagePageController = PageController();

  Future<void> loadImage() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadImage();
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
              child: Image.asset(
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
    final String profileUrl =
        'https://example.com/user-profile';
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
    double subheadingFontSize = size.width * 0.04;
    double buttonFontSize = size.width * 0.045;
    double bodyFontSize = size.width * 0.035;

    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: PageView.builder(
                      // controller: _pageController,
                      itemCount: users.length,
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
                                    MediaQuery.of(context).size.height * 0.4,
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
                                      itemCount: users[index]['images'].length,
                                      itemBuilder: (context, imgIndex) {
                                        return GestureDetector(
                                          onTap: () => _showFullImageDialog(
                                              context,
                                              users[index]['images'][imgIndex]),
                                          child: Container(
                                            margin: EdgeInsets.only(bottom: 12),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              child: Image.asset(
                                                users[index]['images']
                                                    [imgIndex],
                                                fit: BoxFit.cover,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.9,
                                                height: MediaQuery.of(context)
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
                                            mainAxisAlignment: MainAxisAlignment
                                                .center, // Centers the dots horizontally
                                            children: [
                                              SmoothPageIndicator(
                                                controller:
                                                    _imagePageController,
                                                count: users[index]['images']
                                                    .length,
                                                effect: ExpandingDotsEffect(
                                                  dotHeight: 10,
                                                  dotWidth: 10,
                                                  spacing: 10,
                                                  radius: 5,
                                                  dotColor: Colors.grey
                                                      .withOpacity(0.5),
                                                  activeDotColor:
                                                      AppColors.acceptColor,
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
                                        color:
                                            isLiked ? Colors.red : Colors.white,
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
                                            : Icons.thumb_down_alt_outlined,
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
                                                    fontWeight: FontWeight.bold,
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
                              ),
                              SizedBox(height: 16),
                              Text(
                                users[index]['name'],
                                style: AppTextStyles.headingText.copyWith(
                                  fontSize: fontSize,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${users[index]['age']} years old | ',
                                    style: AppTextStyles.bodyText.copyWith(
                                      fontSize: bodyFontSize,
                                    ),
                                  ),
                                  Text(
                                    '${users[index]['location']} | ',
                                    style: AppTextStyles.bodyText.copyWith(
                                      fontSize: bodyFontSize,
                                    ),
                                  ),
                                  Text(
                                    '${users[index]['km']} km away',
                                    style: AppTextStyles.bodyText.copyWith(
                                      fontSize: bodyFontSize,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Last Seen: ${users[index]['lastSeen']}',
                                style: AppTextStyles.bodyText.copyWith(
                                  fontSize: bodyFontSize,
                                ),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Desires:',
                                style: AppTextStyles.subheadingText.copyWith(
                                  fontSize: subheadingFontSize,
                                ),
                              ),
                              Flexible(
                                child: GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 4.0,
                                    mainAxisSpacing: 0.0,
                                  ),
                                  itemCount: users[index]['desires'].length,
                                  itemBuilder: (context, desireIndex) {
                                    return Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Chip(
                                        label: Text(
                                          users[index]['desires'][desireIndex],
                                          style:
                                              AppTextStyles.bodyText.copyWith(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                        backgroundColor: AppColors.acceptColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18),
                                        ),
                                        elevation: 4,
                                        labelPadding: EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 6.0),
                                      ),
                                    );
                                  },
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
