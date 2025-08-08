import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../../../Controllers/controller.dart';
import '../../../constants.dart';

class UserProfileSummary extends StatefulWidget {
  // optional prameter for user id
  final String? userId;
  final List<String>? imageUrls;
  const UserProfileSummary({super.key, this.userId, this.imageUrls});

  @override
  State<UserProfileSummary> createState() => _UserProfileSummaryState();
}

class _UserProfileSummaryState extends State<UserProfileSummary> {
  final Controller controller = Get.find();
  late Future<bool> _fetchProfileFuture;

  @override
  void initState() {
    super.initState();
    if (widget.userId != null) {
      print("Fetching profile for user ID: ${widget.userId}");
      _fetchProfileFuture = controller.fetchProfile(widget.userId ?? "");
    } else {
      print("Fetching profile for current user");
      _fetchProfileFuture = controller.fetchProfile();
    }
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
        double labelFontSize = fontSize * 0.95;
        double valueFontSize = fontSize * 0.85;

        return SingleChildScrollView(
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
                      _profileField(Icons.person_outline, "Nickname",
                          user.nickname, valueFontSize),
                      _profileField(Icons.person, "Username", user.username,
                          valueFontSize),
                      _profileField(
                          Icons.info_outline, "Bio", user.bio, valueFontSize),
                      _profileField(Icons.interests, "Interests", user.interest,
                          valueFontSize),
                      _profileField(
                          Icons.favorite_border,
                          "Looking For",
                          (user.lookingFor == "1")
                              ? "Serious Relationship"
                              : "Hookup",
                          valueFontSize),
                      if (desires.isNotEmpty)
                        _profileField(
                          Icons.explore,
                          "Desires",
                          desires.map((d) => d.title).join(", "),
                          valueFontSize,
                        ),
                      if (preferences.isNotEmpty)
                        _profileField(
                          Icons.tune,
                          "Preferences",
                          preferences.map((p) => p.title).join(", "),
                          valueFontSize,
                        ),
                      if (langs.isNotEmpty)
                        _profileField(
                          Icons.language,
                          "Languages",
                          langs.map((l) => l.title).join(", "),
                          valueFontSize,
                        ),
                      // _profileField(Icons.card_membership, "Package Status", user.packageStatus == "1" ? "Subscribed" : "Unsubscribed", valueFontSize),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
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

  static int _getAge(String dob) {
    try {
      final date = DateFormat('dd/MM/yyyy').parse(dob);
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
