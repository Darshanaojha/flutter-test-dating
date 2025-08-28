import 'dart:async';

import 'package:dating_application/Controllers/controller.dart';
import 'package:dating_application/Models/ResponseModels/profile_like_response_model.dart';
import 'package:dating_application/Screens/userprofile/userprofilesummary.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heart_overlay/heart_overlay.dart';
import 'package:lottie/lottie.dart';
import '../../Controllers/razorpaycontroller.dart';
import '../../Models/ResponseModels/get_all_addon_response_model.dart';
import '../../Models/ResponseModels/get_all_likes_pages_response.dart';
import '../../constants.dart';

import 'package:intl/intl.dart';

class LikesPage extends StatefulWidget {
  const LikesPage({super.key});

  @override
  LikesPageState createState() => LikesPageState();
}

class LikesPageState extends State<LikesPage> with TickerProviderStateMixin {
  RazorpayController razorpayController = Get.put(RazorpayController());
  List<String> selectedGender = [];
  String selectedLocation = 'All';
  final RxBool isLoading = true.obs;
  String? _animatingUserId;
  late final AnimationController _animationController;
  late final DecorationTween decorationTween;
  Controller controller = Get.put(Controller());
  List<String> genders = [];
  List<String> desires = [];
  List<String> preferences = [];
  List<String> selectedGenderFilters = []; // Initialize as empty
  List<String> selectedPreferenceFilters = []; // Initialize as empty
  List<String> selectedDesireFilters = []; // Initialize as empty
  List<LikeRequestPages> filteredLikesPage =
      []; // Will be populated by fetchData initially
  Map<String, int> optimisticLikeStatus = {};
  bool isLiked = false;
  bool isShare = false;
  bool isSms = false;
  int pingCount = 0;
  final PageController imagePageController = PageController();
  double getResponsiveFontSize(double scale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * scale;
  }

  final HeartOverlayController heartOverlayController =
      HeartOverlayController();
  final RxInt likeCount = 0.obs;

  @override
  void initState() {
    super.initState();
    fetchData();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    decorationTween = DecorationTween(
      begin: BoxDecoration(
        color: Colors.transparent, // Transparent box
        border: Border.all(style: BorderStyle.none),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x66666666), // Shadow color
            blurRadius: 10.0,
            spreadRadius: 6.0,
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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<bool> fetchData() async {
    try {
      setState(() {
        isLoading.value = true;
        filteredLikesPage.clear();
      });

      // Simulate network delay or actual API call
      await Future.delayed(const Duration(seconds: 2));

      // Fetch main data
      await controller
          .fetchAllAddOn(); // Assuming this is needed on the page too
      await controller.likesuserpage();

      // Fetch filter options
      await controller.fetchGenders();
      if (controller.genders.isNotEmpty) {
        genders
            .addAll(controller.genders.map((gender) => gender.title).toSet());
      }

      desires = controller.categories
          .expand((category) => category.desires.map((desire) => desire.title))
          .toList();

      await controller.fetchPreferences();
      preferences.addAll(controller.preferences
          .map((preference) => preference.title)
          .toSet()
          .toList());

      // IMPORTANT: Initialize filteredLikesPage with ALL fetched likes
      // and update the UI
      if (mounted) {
        setState(() {
          // Create a new list from the source to avoid modifying the original
          filteredLikesPage = List.from(controller.likespage);
          // Update like count based on the unfiltered list initially
          likeCount.value =
              controller.likespage.where((user) => user.likedByMe == 0).length;
          // Initialize the optimistic like status map
          optimisticLikeStatus.clear();
          for (var user in filteredLikesPage) {
            optimisticLikeStatus[user.userId] = user.likedByMe;
          }
          isLoading.value = false; // Set loading to false after data is ready
        });
      }

      if (controller.likespage.isEmpty) {
        print("No likes in the list");
      }
      if (controller.genders.isEmpty) {
        print("No genders in the list");
      }

      return true;
    } catch (e) {
      print("Error during data fetching: $e");
      if (mounted) {
        setState(() {
          isLoading.value = false; // Also set loading to false on error
        });
      }
      return false;
    }
    // Removed the finally block for setting isLoading to false here,
    // as it's now handled within the try and catch for more precise control.
  }

  void showAnimation(String userId) {
    print('LikesPageState: showAnimation called for userId: $userId');
    setState(() {
      _animatingUserId = userId;
      print('LikesPageState: _animatingUserId set to: $_animatingUserId');
    });

    // Hide the animation after 2 seconds
    Timer(Duration(seconds: 2), () {
      setState(() {
        _animatingUserId = null;
        print('LikesPageState: _animatingUserId cleared to: $_animatingUserId');
      });
    });
  }

  void applyFilters() {
    setState(() {
      // Start with the original, complete list of likes
      List<LikeRequestPages> tempFilteredList = List.from(controller.likespage);

      if (selectedGenderFilters.isNotEmpty) {
        tempFilteredList = tempFilteredList
            .where((user) => selectedGenderFilters.contains(user.gender))
            .toList();
      }

      if (selectedDesireFilters.isNotEmpty) {
        tempFilteredList = tempFilteredList
            .where((user) => user.desires
                .any((desire) => selectedDesireFilters.contains(desire)))
            .toList();
      }

      if (selectedPreferenceFilters.isNotEmpty) {
        tempFilteredList = tempFilteredList
            .where((user) => user.preferences.any(
                (preference) => selectedPreferenceFilters.contains(preference)))
            .toList();
      }

      // Update the displayed list and the like count
      filteredLikesPage = tempFilteredList;
      likeCount.value =
          filteredLikesPage.where((user) => user.likedByMe == 0).length;
    });
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
                  : Image.asset(
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

  RxInt selectedIndex = (-1).obs;
  RxBool selectedcard = false.obs;
  Future<void> showUpgradeBottomSheet() async {
    Get.bottomSheet(
      Padding(
        padding: const EdgeInsets.all(0.0),
        child: Container(
          color: Colors.black,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Found Add ON',
                  style: AppTextStyles.titleText.copyWith(
                    fontSize: getResponsiveFontSize(0.035),
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),

              // Card Container
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: MediaQuery.of(Get.context!).size.width,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(Get.context!).size.height * 0.6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.gradientBackgroundList,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'You can use 24 hours and enjoy the features, '
                          'and you can access earlier with premium benefits.',
                          style: AppTextStyles.bodyText.copyWith(
                            fontSize: getResponsiveFontSize(0.03),
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),

                        // Addon List
                        Expanded(
                          child: Obx(() {
                            if (controller.addon.isEmpty) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            return ListView.builder(
                              itemCount: controller.addon.length,
                              itemBuilder: (context, index) {
                                Addon currentAddon = controller.addon[index];

                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      selectedIndex.value = index;
                                      showAddonDialog(currentAddon);
                                      selectedcard = true.obs;
                                      razorpayController
                                              .orderRequestModel.amount =
                                          currentAddon.amount.toString();
                                      razorpayController.orderRequestModel
                                          .packageId = currentAddon.id;
                                      razorpayController
                                          .orderRequestModel.type = '1';
                                    },
                                    child: Obx(() {
                                      return DecoratedBoxTransition(
                                        decoration: decorationTween
                                            .animate(_animationController),
                                        child: Card(
                                          elevation:
                                              selectedIndex.value == index
                                                  ? 12
                                                  : 8,
                                          color: selectedIndex.value == index
                                              ? Colors.white
                                              : Colors.black,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Container(
                                            width: MediaQuery.of(Get.context!)
                                                    .size
                                                    .width *
                                                0.85, // Responsive width
                                            padding: const EdgeInsets.all(16.0),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.calendar_today,
                                                    color: Colors.grey,
                                                    size: 24),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    "${currentAddon.title}/${currentAddon.duration} - ₹${currentAddon.amount}",
                                                    style: AppTextStyles
                                                        .bodyText
                                                        .copyWith(
                                                      fontSize:
                                                          getResponsiveFontSize(
                                                              0.03),
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons.arrow_drop_down,
                                                      color: Colors.grey),
                                                  onPressed: () {
                                                    showAddonPointsButton(
                                                        currentAddon
                                                            .addonPoints);
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                );
                              },
                            );
                          }),
                        ),

                        const SizedBox(height: 20),
                        Obx(() {
                          bool isAnyAddonSelected = selectedIndex.value != -1;

                          return Visibility(
                            visible: isAnyAddonSelected,
                            child: OutlinedButton(
                              onPressed: () {
                                Get.back();
                                ScaffoldMessenger.of(Get.context!).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Profile upgraded! Enjoy your 24 hours of premium access.',
                                    ),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: Colors.white, width: 1.2),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 24),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Purchase Now',
                                style: AppTextStyles.buttonText
                                    .copyWith(color: Colors.white),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void showAddonDialog(Addon currentAddon) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent, // Make dialog fully custom
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.gradientBackgroundList,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Confirm Add-On Subscription',
                  style: AppTextStyles.titleText.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Do you want to subscribe to the "${currentAddon.title}" add-on for ₹${currentAddon.amount}?',
                  style: AppTextStyles.bodyText.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style:
                            AppTextStyles.bodyText.copyWith(color: Colors.red),
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () async {
                        Get.back();
                        bool? isOrderCreated = await razorpayController
                            .createOrder(razorpayController.orderRequestModel);
                        if (isOrderCreated == true) {
                          razorpayController.initRazorpay();
                          double amount =
                              double.tryParse(currentAddon.amount) ?? 0.0;
                          await razorpayController.startPayment(
                              amount,
                              currentAddon.title,
                              "Addon Purchase",
                              controller.userData.first.mobile,
                              controller.userData.first.email);
                        } else {
                          failure("Order", "Your Payment Order Is Not Created");
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.green),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Subscribe',
                        style: AppTextStyles.bodyText
                            .copyWith(color: Colors.green),
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

  void showAddonPointsButton(List<AddonPoint> addonPoints) {
    Get.bottomSheet(
      Padding(
        padding: const EdgeInsets.all(0.0),
        child: Container(
          color: Colors.black,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 40), // Top spacing

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Add-On Points',
                  style: AppTextStyles.titleText.copyWith(
                    fontSize: getResponsiveFontSize(0.03),
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 20),

              // Card wrapping list + close button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: MediaQuery.of(Get.context!).size.width,
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(Get.context!).size.height * 0.65,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.gradientBackgroundList,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: addonPoints.length,
                          itemBuilder: (context, index) {
                            AddonPoint point = addonPoints[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6.0, horizontal: 10.0),
                              child: Card(
                                color: Colors
                                    .black, // You can use a gradient if needed
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                                child: DecoratedBoxTransition(
                                  decoration: decorationTween
                                      .animate(_animationController),
                                  child: ListTile(
                                    title: Text(
                                      point.title,
                                      style: AppTextStyles.textStyle
                                          .copyWith(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10),
                        child: OutlinedButton(
                          onPressed: () {
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            //backgroundColor: AppColors.buttonColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('Close', style: AppTextStyles.buttonText),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> _onRefresh() async {
    // await Future.delayed(Duration(seconds: 2));
    fetchData();
    // await controller.likesuserpage();
  }

  String formatLastSeen(String lastSeen) {
    try {
      final dateTime = DateTime.parse(lastSeen);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 7) {
        return DateFormat('dd/MM/yyyy hh:mm a').format(dateTime);
      } else if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Stack(
          children: [
            Obx(() {
              if (isLoading.value) {
                return Center(
                  child: Lottie.asset(
                      "assets/animations/likepageanimation.json",
                      repeat: true,
                      reverse: true),
                );
              }

              final likedByOtherUsers = filteredLikesPage
                  .where((user) => user.likedByMe == 0)
                  .toList()
                ..sort((a, b) {
                  try {
                    return DateTime.parse(b.updated)
                        .compareTo(DateTime.parse(a.updated));
                  } catch (e) {
                    return 0;
                  }
                });
              final likedByCurrentUser = filteredLikesPage
                  .where((user) => user.likedByMe == 1)
                  .toList()
                ..sort((a, b) {
                  try {
                    return DateTime.parse(b.updated)
                        .compareTo(DateTime.parse(a.updated));
                  } catch (e) {
                    return 0;
                  }
                });

              // if (likedByOtherUsers.isEmpty && likedByCurrentUser.isEmpty) {
              //   return const Center(
              //     child: Text(
              //       "No likes found.",
              //       style: TextStyle(color: Colors.white),
              //     ),
              //   );
              // }

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filters and like count row (unchanged)
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: buildFilterChip('Gender', Icons.wc, genders,
                                selectedGenderFilters, (value) {
                              setState(() {
                                selectedGenderFilters = value;
                              });
                              applyFilters();
                            }),
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: buildFilterChip('Desires', Icons.favorite,
                                desires, selectedDesireFilters, (value) {
                              setState(() {
                                selectedDesireFilters = value;
                              });
                              applyFilters();
                            }),
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: buildFilterChip(
                                'Preferences',
                                Icons.tune,
                                preferences,
                                selectedPreferenceFilters, (value) {
                              setState(() {
                                selectedPreferenceFilters = value;
                              });
                              applyFilters();
                            }),
                          ),
                        ],
                      ),
                    ),

                    // Section: Liked by Others
                    if (likedByOtherUsers.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Liked by Others",
                                  style: AppTextStyles.titleText
                                      .copyWith(color: Colors.white),
                                ),
                                Obx(() => Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Icon(
                                          Icons.favorite,
                                          color: AppColors.mediumGradientColor,
                                          size: size.width * 0.085,
                                        ),
                                        Text(
                                          '${likeCount.value}',
                                          style:
                                              AppTextStyles.textStyle.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    )),
                              ],
                            ),
                          ),
                          // ListView.builder(
                          //   shrinkWrap: true,
                          //   physics: const NeverScrollableScrollPhysics(),
                          //   itemCount: likedByOtherUsers.length,
                          //   itemBuilder: (context, index) {
                          //     var user = likedByOtherUsers[index];
                          //     return _buildUserCard(context, user, false,
                          //         key: ValueKey(
                          //             'liked_by_others_${user.userId}'));
                          //   },
                          // ),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: likedByOtherUsers.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 4,
                              mainAxisSpacing: 4,
                              childAspectRatio: 0.7,
                            ),
                            itemBuilder: (context, index) {
                              var user = likedByOtherUsers[index];
                              return _buildUserCard(context, user, false,
                                  key: ValueKey(
                                      'liked_by_others_${user.userId}'));
                            },
                          ),
                        ],
                      ),

                    // Divider with "Liked by you" text at right
                    if (likedByCurrentUser.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(child: Divider(color: Colors.white54)),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text("Liked by you",
                                  style: AppTextStyles.bodyText
                                      .copyWith(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),

                    // Section: You Liked
                    if (likedByCurrentUser.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              "You Liked",
                              style: AppTextStyles.titleText
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                          // ListView.builder(
                          //   shrinkWrap: true,
                          //   physics: const NeverScrollableScrollPhysics(),
                          //   itemCount: likedByCurrentUser.length,
                          //   itemBuilder: (context, index) {
                          //     var user = likedByCurrentUser[index];
                          //     return _buildUserCard(context, user, true,
                          //         key: ValueKey('you_liked_${user.userId}'));
                          //   },
                          // ),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: likedByCurrentUser.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 0.7,
                            ),
                            itemBuilder: (context, index) {
                              var user = likedByCurrentUser[index];
                              return _buildUserCard(context, user, true,
                                  key: ValueKey(
                                      'you_liked_${user.conectionId}'));
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // Widget _buildUserCard(
  //     BuildContext context, LikeRequestPages user, bool isLiked,
  //     {Key? key}) {
  //   return UserCard(
  //     key: key,
  //     user: user,
  //     controller: controller,
  //     onImageTap: showFullImageDialog,
  //     formatLastSeen: formatLastSeen,
  //     getAgeFromDob: getAgeFromDob,
  //     getResponsiveFontSize: getResponsiveFontSize,
  //     isLiked: isLiked,
  //   );
  // }

  Widget _buildUserCard(
      BuildContext context, LikeRequestPages user, bool isLiked,
      {Key? key}) {
    return UserCard(
      key: key,
      user: user,
      controller: controller,
      onImageTap: showFullImageDialog,
      formatLastSeen: formatLastSeen,
      getAgeFromDob: getAgeFromDob,
      getResponsiveFontSize: getResponsiveFontSize,
      isLiked: isLiked,
      onShowAnimation: showAnimation,
      onLikeToggle: (userId, newLikeStatus) async {
        print(
            'LikesPage: onLikeToggle called for userId: $userId, newLikeStatus: $newLikeStatus');
        print('LikesPage: _animatingUserId before setState: $_animatingUserId');
        setState(() {
          optimisticLikeStatus[userId] = newLikeStatus;
        });
        print(
            'LikesPage: _animatingUserId after setState (optimistic): $_animatingUserId');
        await controller.likesuserpage();
        print(
            'LikesPage: _animatingUserId after likesuserpage(): $_animatingUserId');
      },
      animatingUserId: _animatingUserId,
    );
  }

  String getAgeFromDob(String dob) {
    try {
      final parts = dob.split('/');
      if (parts.length != 3) return 'Invalid DOB';

      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      final birthDate = DateTime(year, month, day);
      final today = DateTime.now();

      int age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }

      return '$age';
    } catch (e) {
      return 'Invalid DOB';
    }
  }

  Widget buildFilterChip(
    String label,
    IconData icon,
    List<String> options,
    List<String> initialSelection,
    Function(List<String>) onSelected,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.5),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment(0.8, 1),
              colors: AppColors.gradientColor,
            ),
            borderRadius: BorderRadius.circular(38),
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: AppColors.primaryColor,
              backgroundColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: AppColors.activeColor, width: 2),
              ),
            ),
            onPressed: () {
              if (options.isEmpty) return;
              showBottomSheet(label, options, initialSelection, onSelected);
            },
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: AppTextStyles.textStyle,
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showBottomSheet(
    String label,
    List<String> options,
    List<String> initialSelection,
    Function(List<String>) onSelected,
  ) {
    List<String> selectedOptions = List.from(initialSelection);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SizedBox(
          height: 600,
          child: Scrollbar(
            child: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 36.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$label Filter',
                          style:
                              AppTextStyles.headingText.copyWith(fontSize: 16),
                        ),
                        SizedBox(height: 9),
                        CheckboxListTile(
                          title: Text('All', style: AppTextStyles.textStyle),
                          value: selectedOptions.length == options.length,
                          onChanged: (isChecked) {
                            setState(() {
                              if (isChecked == true) {
                                selectedOptions = List.from(options);
                              } else {
                                selectedOptions.clear();
                              }
                            });
                          },
                          activeColor: AppColors.buttonColor,
                        ),
                        ...options.map((option) {
                          return CheckboxListTile(
                            title: Text(option, style: AppTextStyles.textStyle),
                            value: selectedOptions.contains(option),
                            onChanged: (isChecked) {
                              setState(() {
                                if (isChecked == true) {
                                  selectedOptions.add(option);
                                } else {
                                  selectedOptions.remove(option);
                                }
                              });
                            },
                            activeColor: AppColors.buttonColor,
                          );
                        }),
                        SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.mediumGradientColor,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 22),
                              ),
                              onPressed: () {
                                onSelected(selectedOptions);
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Apply",
                                style: TextStyle(fontSize: 12),
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
          ),
        );
      },
    );
  }
}

class UserCard extends StatefulWidget {
  final LikeRequestPages user;
  final Controller controller;
  final Function(BuildContext, String) onImageTap;
  final String Function(String) formatLastSeen;
  final String Function(String) getAgeFromDob;
  final double Function(double) getResponsiveFontSize;
  final bool isLiked;
  final Function(String userId, int newLikeStatus) onLikeToggle;
  final Function(String userId) onShowAnimation;
  final String? animatingUserId;

  const UserCard({
    super.key,
    required this.user,
    required this.controller,
    required this.onImageTap,
    required this.formatLastSeen,
    required this.getAgeFromDob,
    required this.getResponsiveFontSize,
    required this.isLiked,
    required this.onLikeToggle,
    required this.onShowAnimation,
    this.animatingUserId,
  });

  @override
  UserCardState createState() => UserCardState();
}

class UserCardState extends State<UserCard> with SingleTickerProviderStateMixin {
  late int _currentLikeStatus;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _currentLikeStatus = widget.user.likedByMe;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.4), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.4, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.bottomSheet(
          (widget.isLiked)
              ? UserProfileSummary(
                  userId: widget.user.conectionId.toString(),
                  imageUrls: widget.user.images,
                )
              : UserProfileSummary(
                  userId: widget.user.userId.toString(),
                  imageUrls: widget.user.images,
                ),
          isScrollControlled: true,
          backgroundColor: AppColors.primaryColor,
          enterBottomSheetDuration: Duration(milliseconds: 300),
          exitBottomSheetDuration: Duration(milliseconds: 300),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: AppColors.gradientBackgroundList,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: Colors.white,
            width: 1.0,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Background image
              Positioned.fill(
                child: widget.user.images.isNotEmpty
                    ? Image.network(
                        widget.user.images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.white70,
                          );
                        },
                      )
                    : Container(color: Colors.grey.shade300),
              ),

              // Gradient overlay for entire card bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 80,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.black.withOpacity(0.4),
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.7, 1.0],
                    ),
                  ),
                ),
              ),

              // Name, age, country (without text shadows)
              Positioned(
                bottom: 12,
                left: 8,
                right: 50, // Increased right padding to prevent overlap
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${widget.user.name}, ${widget.getAgeFromDob(widget.user.dob)}",
                      style: AppTextStyles.titleText.copyWith(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1, // Add maxLines to prevent vertical overflow
                      overflow:
                          TextOverflow.ellipsis, // Add ellipsis for overflow
                    ),
                    Text(
                      widget.user.countryName,
                      style: AppTextStyles.bodyText.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      maxLines: 1, // Add maxLines
                      overflow: TextOverflow.ellipsis, // Add ellipsis
                    ),
                  ],
                ),
              ),

              // Like/Unlike Button
              Positioned(
                bottom: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () async {
                    _animationController.forward(from: 0.0);
                    
                    final newLikeStatus = _currentLikeStatus == 0 ? 1 : 0;
                    setState(() {
                      _currentLikeStatus = newLikeStatus;
                    });

                    bool successStatus = false;
                    if (newLikeStatus == 1) {
                      widget.controller.profileLikeRequest.likedBy =
                          widget.user.userId.toString();
                      ProfileLikeResponse? response =
                          await widget.controller.profileLike(
                              widget.controller.profileLikeRequest);
                      successStatus = response != null && response.success;
                      if (successStatus) {
                        success("Liked!",
                            "You have successfully liked ${widget.user.name}. Ready to chat!");
                      }
                    } else {
                      widget.controller.homepageDislikeRequest.userId =
                          widget.user.userId.toString();
                      widget.controller.homepageDislikeRequest
                              .connectionId =
                          widget.user.conectionId.toString();
                      successStatus = await widget.controller
                          .homepagedislikeprofile(
                              widget.controller.homepageDislikeRequest);
                      if (successStatus) {
                        success("Removed Like",
                            "You have unliked ${widget.user.name}.");
                      }
                    }

                    if (!successStatus) {
                      setState(() {
                        _currentLikeStatus =
                            _currentLikeStatus == 0 ? 1 : 0;
                      });
                      failure("Failed",
                          "Failed to update like status. Please try again.");
                    }
                    widget.onLikeToggle(widget.user.userId, newLikeStatus);
                  },
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Icon(
                      _currentLikeStatus == 1
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: _currentLikeStatus == 1
                          ? AppColors.darkGradientColor
                          : Colors.white,
                      size: 25,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
