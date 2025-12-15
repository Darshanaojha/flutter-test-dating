import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../../../Controllers/controller.dart';
import '../../../Models/ResponseModels/profile_like_response_model.dart';
import '../../../constants.dart';

class UserProfileSummary extends StatefulWidget {
  // optional prameter for user id
  final String? userId;
  final List<String>? imageUrls;
  final bool showLikeButton;
  final Function(bool isMatch)? onLikeSuccess;
  const UserProfileSummary({
    super.key, 
    this.userId, 
    this.imageUrls,
    this.showLikeButton = false,
    this.onLikeSuccess,
  });

  @override
  State<UserProfileSummary> createState() => _UserProfileSummaryState();
}

class _UserProfileSummaryState extends State<UserProfileSummary> {
  final Controller controller = Get.find();
  late Future<bool> _fetchProfileFuture;
  bool _isLiking = false;

  @override
  void initState() {
    super.initState();
    _fetchProfileFuture = _initializeSummaryData();
  }

  Future<void> _handleLike() async {
    print("UserProfileSummary: _handleLike called");
    if (_isLiking || widget.userId == null) {
      print("UserProfileSummary: Early return - _isLiking: $_isLiking, userId: ${widget.userId}");
      return;
    }
    
    print("UserProfileSummary: Setting _isLiking to true");
    setState(() {
      _isLiking = true;
    });

    try {
      print("UserProfileSummary: Calling profileLike with userId: ${widget.userId}");
      controller.profileLikeRequest.likedBy = widget.userId!;
      ProfileLikeResponse? response = await controller.profileLike(controller.profileLikeRequest);
      
      // Debug logging
      print("UserProfileSummary: ProfileLike Response: $response");
      if (response != null) {
        print("UserProfileSummary: Response success: ${response.success}");
        print("UserProfileSummary: Response error code: ${response.error.code}");
        print("UserProfileSummary: Response error message: ${response.error.message}");
        print("UserProfileSummary: Response connection: ${response.payload.connection}");
      } else {
        print("UserProfileSummary: Response is null");
      }
      
      if (response != null) {
        // First check if the error message indicates "already liked" - treat as success
        String errorMsg = response.error.message.toLowerCase().trim();
        print("UserProfileSummary: Checking error message: '$errorMsg'");
        print("UserProfileSummary: Error code: ${response.error.code}, Success: ${response.success}");
        
        // Check for various forms of "already liked" message
        bool isAlreadyLiked = errorMsg.contains("already liked") || 
                             errorMsg.contains("already like") ||
                             errorMsg.contains("you have already") ||
                             errorMsg.contains("have already liked");
        
        print("UserProfileSummary: isAlreadyLiked: $isAlreadyLiked");
        
        // Check if it's a successful like (error.code == 0 or success == true)
        bool isSuccessful = response.error.code == 0 || response.success == true;
        
        if (isAlreadyLiked || isSuccessful) {
          // Profile is already liked or successfully liked, treat as success
          if (isAlreadyLiked) {
            print("UserProfileSummary: Showing 'Already Liked' success message");
            success("Already Liked", "You have already liked this profile.");
          } else {
            print("UserProfileSummary: Successful like");
            bool isMatch = response.payload.connection;
            
            if (isMatch) {
              success("It's a Match!", "You both liked each other!");
            } else {
              success("Liked!", "You have successfully liked this profile.");
            }
          }
          
          // Call the callback to refresh the page (only if not already liked, or always to refresh)
          if (widget.onLikeSuccess != null) {
            print("UserProfileSummary: Calling onLikeSuccess callback");
            try {
              bool isMatch = response.payload.connection;
              await widget.onLikeSuccess!(isMatch);
              print("UserProfileSummary: onLikeSuccess callback completed successfully");
            } catch (e, stackTrace) {
              print("UserProfileSummary: Error in onLikeSuccess callback: $e");
              print("Stack trace: $stackTrace");
              // Don't show error to user since the like operation itself succeeded
            }
          }
        } else {
          // Only show error if it's actually an error (not already liked and not successful)
          print("UserProfileSummary: Showing error - code: ${response.error.code}, message: ${response.error.message}");
          String displayMsg = response.error.message.isNotEmpty 
              ? response.error.message 
              : "Failed to like the profile. Please try again.";
          failure("Failed", displayMsg);
        }
      } else {
        print("UserProfileSummary: Response is null, showing failure");
        failure("Failed", "Failed to like the profile. Please try again.");
      }
    } catch (e, stackTrace) {
      print("Exception in _handleLike: $e");
      print("Stack trace: $stackTrace");
      // Only show error if it's a real exception, not if the operation succeeded
      failure("Error", "An error occurred while liking the profile: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() {
          _isLiking = false;
        });
      }
    }
  }

  Future<bool> _initializeSummaryData() async {
    print("Fetching profile photos for  ${widget.userId}");
    final profileSuccess = await (widget.userId != null
        ? controller.fetchProfile(widget.userId!)
        : controller.fetchProfile());
    if (!profileSuccess) return false;
    
    return (widget.userId != null)
        ? controller.fetchProfileUserPhotos(widget.userId!)
        : controller.fetchProfileUserPhotos();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _fetchProfileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Lottie.asset("assets/animations/homeanimation.json"),
          );
        }
        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!) {
          return const Center(
            child: Text(
              'Could not load profile. Please try again.',
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        final user = controller.userData.first;
        final desires = controller.userDesire;
        final preferences = controller.userPreferences;
        final langs = controller.userLang;

        double fontSize = MediaQuery.of(context).size.width * 0.045;
        double valueFontSize = fontSize * 0.85;

        Widget content = SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              (widget.imageUrls != null && widget.imageUrls!.isNotEmpty)
                  ? SizedBox(
                      height: 350,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.imageUrls!.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                widget.imageUrls![index],
                                fit: BoxFit.cover,
                                width: 250,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return SizedBox(
                                    width: 250,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 250,
                                    color: Colors.grey[200],
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                      size: 48,
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : SizedBox(
                      height: 350,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.userPhotos!.images.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                controller.userPhotos!.images[index],
                                fit: BoxFit.cover,
                                width: 250,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return SizedBox(
                                    width: 250,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 250,
                                    color: Colors.grey[200],
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                      size: 48,
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
              const SizedBox(height: 18),
              Card(
                color: AppColors.secondaryColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0, left: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.username,
                              style: AppTextStyles.bodyText.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: valueFontSize,
                              ),
                            ),
                            const SizedBox(width: 4),
                            (user.accountVerificationStatus == "1")
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: Icon(
                                      Icons.verified,
                                      color: AppColors.mediumGradientColor,
                                      size: valueFontSize + 2,
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.only(top: 2.0),
                                    child: Icon(
                                      Icons.error_outline_outlined,
                                      color: Colors.yellow[700],
                                      size: valueFontSize + 2,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      if (user.bio.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 10.0),
                          padding: const EdgeInsets.all(12.0),
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.formFieldColor.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(15.0),
                            border: Border.all(
                              color: AppColors.textColor.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              user.bio,
                              style: AppTextStyles.bodyText.copyWith(
                                fontSize: valueFontSize * 0.95,
                                color: AppColors.textColor.withOpacity(0.9),
                              ),
                            ),
                          ),
                        ),
                      _profileField(
                          Icons.person, "Name", user.name, valueFontSize),
                      _profileField(Icons.person_outline, "Nickname",
                          user.nickname, valueFontSize),
                      _profileField(
                          Icons.cake,
                          "Birthday",
                          "${user.dob} (${_getAge(user.dob)} years old)",
                          valueFontSize),
                      _profileField(
                          Icons.wc, "Gender", user.genderName, valueFontSize),
                      _profileField(Icons.transgender, "Sub Gender",
                          user.subGenderName, valueFontSize),
                      _profileField(Icons.location_city, "City", user.city,
                          valueFontSize),
                      // _profileField(Icons.home, "Address", user.address, valueFontSize),
                      // _profileField(Icons.email, "Email", user.email, valueFontSize),
                      // _profileField(Icons.phone, "Mobile", user.mobile, valueFontSize),
                      // _profileField(Icons.monetization_on, "Points", user.points ?? "0", valueFontSize),
                      // _profileField(Icons.card_membership, "Package Status", user.packageStatus == "1" ? "Premium" : "Free", valueFontSize),
                      _profileField(
                          Icons.favorite_border,
                          "Looking For",
                          (user.lookingFor == "1")
                              ? "Serious Relationship"
                              : "Hookup",
                          valueFontSize),
                      // _profileField(Icons.visibility, "Last Seen", user.lastSeen ?? "Not available", valueFontSize),
                      // _profileField(Icons.whatshot, "Hookup Mode", user.hookupStatus == "1" ? "Active" : "Inactive", valueFontSize),
                      // _profileField(Icons.security, "Incognito Mode", user.incognativeMode == "1" ? "Active" : "Inactive", valueFontSize),
                      // _profileField(Icons.star, "Creator Account", user.creator == "1" ? "Yes" : "No", valueFontSize),
                      if (user.interest.isNotEmpty)
                        _profileChipsField(
                          Icons.interests,
                          "Interests",
                          user.interest
                              .split(',')
                              .map((e) => e.trim())
                              .toList(),
                          valueFontSize,
                        ),
                      if (desires.isNotEmpty)
                        _profileChipsField(
                          Icons.explore,
                          "Desires",
                          desires.map((d) => d.title).toList(),
                          valueFontSize,
                        ),
                      if (preferences.isNotEmpty)
                        _profileChipsField(
                          Icons.tune,
                          "Preferences",
                          preferences.map((p) => p.title).toList(),
                          valueFontSize,
                        ),
                      if (langs.isNotEmpty)
                        _profileChipsField(
                          Icons.language,
                          "Languages",
                          langs.map((l) => l.title).toList(),
                          valueFontSize,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );

        // Wrap in Scaffold with FAB if showLikeButton is true
        if (widget.showLikeButton) {
          return Scaffold(
            backgroundColor: AppColors.primaryColor,
            body: content,
            floatingActionButton: FloatingActionButton(
              onPressed: _isLiking ? null : _handleLike,
              backgroundColor: AppColors.mediumGradientColor,
              child: _isLiking
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(
                      Icons.favorite,
                      color: Colors.white,
                    ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          );
        }

        return content;
      },
    );
  }

  Widget _profileField(
      IconData icon, String label, String value, double valueFontSize) {
    if (value.isEmpty) return const SizedBox.shrink();
    return ListTile(
      leading: Icon(icon, size: 28, color: AppColors.activeColor),
      title: Text(label,
          style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold)),
      subtitle: Text(
        value,
        style: AppTextStyles.bodyText.copyWith(
          fontSize: valueFontSize,
          color: AppColors.textColor,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _profileChipsField(
      IconData icon, String label, List<String> items, double valueFontSize) {
    if (items.isEmpty) return const SizedBox.shrink();

    return ListTile(
      leading: Icon(icon, size: 28, color: AppColors.activeColor),
      title: Text(label,
          style: AppTextStyles.bodyText.copyWith(fontWeight: FontWeight.bold)),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: items.map((item) {
            return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.gradientBackgroundList,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25.0),
                border: Border.all(
                  color: Colors.white,
                  width: 1.5,
                ),
              ),
              child: Text(
                item,
                style: TextStyle(
                  fontSize: valueFontSize * 0.9,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  static int _getAge(String dob) {
    try {
      final date = DateFormat('MM/dd/yyyy').parse(dob);
      final now = DateTime.now();
      int age = now.year - date.year;
      if (now.month < date.month ||
          (now.month == date.month && now.day < date.day)) {
        age--;
      }
      return age;
    } catch (_) {
      return 0;
    }
  }
}
