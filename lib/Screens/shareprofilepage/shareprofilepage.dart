import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controllers/controller.dart';
import '../../Models/RequestModels/share_profile_request_model.dart';
import '../../constants.dart';

class ShareProfilePage extends StatefulWidget {
  final String id;
  const ShareProfilePage({super.key, required this.id});

  @override
  ShareProfilePageState createState() => ShareProfilePageState();
}

class ShareProfilePageState extends State<ShareProfilePage>
    with TickerProviderStateMixin {
  Controller controller = Get.put(Controller());
  final String profileImage = 'assets/images/image1.jpg';
  final String name = 'John Doe';
  final String age = '28';
  final String gender = 'Male';
  final String bio = 'A passionate traveler and foodie who loves nature.';
  final String address = '123 Street Name';
  final String city = 'New York';
  final String state = 'NY';
  final String country = 'USA';
  final List<String> preferences = ['Yoga', 'Cooking', 'Music'];
  final List<String> languages = ['English', 'Spanish'];
  final List<String> desires = ['Travel', 'Adventure'];

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Initialize late variables with nullable types and handle them safely
  AnimationController? _borderController;
  Animation<Color?>? _borderAnimation;

  @override
  void initState() {
    super.initState();

    // Fade animation controller
    _fadeController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _fadeAnimation = Tween(begin: 0.0, end: 2.0).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
    _fadeController.forward();

    // Border color animation controller
    _borderController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _borderAnimation = ColorTween(begin: Colors.red, end: Colors.white).animate(
        CurvedAnimation(parent: _borderController!, curve: Curves.linear));

    _borderController?.repeat(reverse: true); // Repeat the border animation
  }

  initialize() async {
    await controller
        .shareProfileUser(ShareProfileRequestModel(userId: widget.id));
  }

  void showFullImage() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(profileImage,
                    fit: BoxFit.cover), // Show local image
                SizedBox(height: 40),
                Text('Full Profile Image', style: AppTextStyles.titleText),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _borderController
        ?.dispose(); // Dispose the border animation controller safely
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isLargeScreen = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text('Share Profile', style: AppTextStyles.titleText),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: showFullImage,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: CircleAvatar(
                      radius: isLargeScreen ? 90 : 60,
                      backgroundImage: AssetImage(profileImage),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Name and Age
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$name, $age',
                    style: AppTextStyles.headingText,
                  ),
                ],
              ),
              SizedBox(height: 10),

              // Gender
              Row(
                children: [
                  Icon(Icons.person,
                      color: AppColors.iconColor,
                      size: isLargeScreen ? 30 : 24),
                  SizedBox(width: 8),
                  Text(gender, style: AppTextStyles.bodyText),
                ],
              ),
              SizedBox(height: 10),

              // Bio
              Row(
                children: [
                  Icon(Icons.info_outline,
                      color: AppColors.iconColor,
                      size: isLargeScreen ? 30 : 24),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      bio,
                      style: AppTextStyles.bodyText,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Address Information
              Row(
                children: [
                  Icon(Icons.location_on,
                      color: AppColors.iconColor,
                      size: isLargeScreen ? 30 : 24),
                  SizedBox(width: 8),
                  Expanded(
                      child: Text('$address, $city, $state, $country',
                          style: AppTextStyles.bodyText,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2)),
                ],
              ),
              SizedBox(height: 20),

              // Preferences in Card Style with Animated Border
              if (preferences.isNotEmpty)
                AnimatedBuilder(
                  animation: _borderController!,
                  builder: (context, child) {
                    return Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                            color: _borderAnimation?.value ?? Colors.red,
                            width: 2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Preferences:',
                                style: AppTextStyles.subheadingText),
                            ...preferences.map((pref) => Row(
                                  children: [
                                    Icon(Icons.favorite,
                                        color: AppColors.iconColor,
                                        size: isLargeScreen ? 30 : 24),
                                    SizedBox(width: 8),
                                    Text(pref, style: AppTextStyles.bodyText),
                                  ],
                                )),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              SizedBox(height: 20),

              // Languages in Card Style with Animated Border
              if (languages.isNotEmpty)
                AnimatedBuilder(
                  animation: _borderController!,
                  builder: (context, child) {
                    return Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                            color: _borderAnimation?.value ?? Colors.red,
                            width: 2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Languages:',
                                style: AppTextStyles.subheadingText),
                            ...languages.map((lang) => Row(
                                  children: [
                                    Icon(Icons.language,
                                        color: AppColors.iconColor,
                                        size: isLargeScreen ? 30 : 24),
                                    SizedBox(width: 8),
                                    Text(lang, style: AppTextStyles.bodyText),
                                  ],
                                )),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              SizedBox(height: 20),

              // Desires in Card Style with Animated Border
              if (desires.isNotEmpty)
                AnimatedBuilder(
                  animation: _borderController!,
                  builder: (context, child) {
                    return Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                            color: _borderAnimation?.value ?? Colors.red,
                            width: 2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Desires:',
                                style: AppTextStyles.subheadingText),
                            ...desires.map((desire) => Row(
                                  children: [
                                    Icon(Icons.star_border,
                                        color: AppColors.iconColor,
                                        size: isLargeScreen ? 30 : 24),
                                    SizedBox(width: 8),
                                    Text(desire, style: AppTextStyles.bodyText),
                                  ],
                                )),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
