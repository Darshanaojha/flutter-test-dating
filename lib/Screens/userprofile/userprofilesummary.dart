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
    _fetchProfileFuture = _initializeSummaryData();
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
