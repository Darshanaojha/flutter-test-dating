import 'dart:async';

import 'package:dating_application/Controllers/controller.dart';
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
    setState(() {
      _animatingUserId = userId;
    });

    // Hide the animation after 2 seconds
    Timer(Duration(seconds: 2), () {
      setState(() {
        _animatingUserId = null;
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
                          razorpayController.openPayment(
                              currentAddon.amount as double,
                              currentAddon.title,
                              controller.userData.first.name,
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
                  .toList();
              final likedByCurrentUser = filteredLikesPage
                  .where((user) => user.likedByMe == 1)
                  .toList();

              if (likedByOtherUsers.isEmpty && likedByCurrentUser.isEmpty) {
                return const Center(
                  child: Text(
                    "No likes found.",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

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
                            child: SizedBox(
                              height: 40,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  buildFilterChip(
                                      'Gender', genders, selectedGenderFilters,
                                      (value) {
                                    setState(() {
                                      selectedGenderFilters = value;
                                    });
                                    applyFilters();
                                  }),
                                  buildFilterChip(
                                      'Desires', desires, selectedDesireFilters,
                                      (value) {
                                    setState(() {
                                      selectedDesireFilters = value;
                                    });
                                    applyFilters();
                                  }),
                                  buildFilterChip('Preferences', preferences,
                                      selectedPreferenceFilters, (value) {
                                    setState(() {
                                      selectedPreferenceFilters = value;
                                    });
                                    applyFilters();
                                  })
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Obx(() => Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    Icons.favorite,
                                    color: AppColors.mediumGradientColor,
                                    size: 50,
                                  ),
                                  Text(
                                    '${likeCount.value}',
                                    style: AppTextStyles.textStyle.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )),
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
                            child: Text(
                              "Liked by Others",
                              style: AppTextStyles.titleText
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: likedByOtherUsers.length,
                            itemBuilder: (context, index) {
                              var user = likedByOtherUsers[index];
                              return _buildUserCard(context, user);
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
                              child: Text(
                                "Liked by you",
                                style: AppTextStyles.bodyText
                                    .copyWith(color: Colors.white),
                                textAlign: TextAlign.right,
                              ),
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
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: likedByCurrentUser.length,
                            itemBuilder: (context, index) {
                              var user = likedByCurrentUser[index];
                              return _buildUserCard(context, user);
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

  Widget _buildUserCard(BuildContext context, LikeRequestPages user) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.gradientBackgroundList,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Card(
          elevation: 5,
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                  child: Scrollbar(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: user.images.length,
                      itemBuilder: (context, imgIndex) {
                        return Container(
                          margin: EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () {
                              showFullImageDialog(
                                  context, user.images[imgIndex]);
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                user.images[imgIndex],
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width * 0.2,
                                height:
                                    MediaQuery.of(context).size.height * 0.3,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.2,
                                    height: MediaQuery.of(context).size.height *
                                        0.3,
                                    alignment: Alignment.center,
                                    color: Colors.grey.shade200,
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: user.images.isNotEmpty
                          ? NetworkImage(user.images.first)
                          : null,
                      child: user.images.isEmpty
                          ? Icon(Icons.person, size: 20)
                          : null,
                    ),
                    SizedBox(width: 8),
                    Text(user.name.toString(),
                        style: AppTextStyles.titleText
                            .copyWith(fontSize: getResponsiveFontSize(0.03))),
                    Text(
                        (user.likedByMe == 0)
                            ? ' | Liked By ${user.name}'
                            : " | Liked By You",
                        style: AppTextStyles.bodyText
                            .copyWith(fontSize: getResponsiveFontSize(0.03))),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text('${getAgeFromDob(user.dob)} |',
                        style: AppTextStyles.bodyText
                            .copyWith(fontSize: getResponsiveFontSize(0.03))),
                    Text('${user.countryName} |',
                        style: AppTextStyles.bodyText
                            .copyWith(fontSize: getResponsiveFontSize(0.03))),
                    Text(user.gender,
                        style: AppTextStyles.bodyText
                            .copyWith(fontSize: getResponsiveFontSize(0.03))),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Last Seen: ${formatLastSeen(user.updated)}',
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: getResponsiveFontSize(0.03),
                      ),
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          onPressed: () async {
                            showAnimation(user.userId);
                            final originalLikedByMe =
                                optimisticLikeStatus[user.userId] ??
                                    user.likedByMe;
                            setState(() {
                              optimisticLikeStatus[user.userId] =
                                  originalLikedByMe == 0 ? 1 : 0;
                            });

                            bool success = false;
                            if (optimisticLikeStatus[user.userId] == 1) {
                              controller.profileLikeRequest.likedBy =
                                  user.userId.toString();
                              success = await controller
                                  .profileLike(controller.profileLikeRequest);
                            } else {
                              controller.homepageDislikeRequest.userId =
                                  user.userId.toString();
                              controller.homepageDislikeRequest.connectionId =
                                  user.conectionId.toString();
                              success = await controller.homepagedislikeprofile(
                                  controller.homepageDislikeRequest);
                            }

                            if (!success) {
                              setState(() {
                                optimisticLikeStatus[user.userId] =
                                    originalLikedByMe;
                              });
                              failure("Failed",
                                  "Failed to update like status. Please try again.");
                            }
                            await controller.likesuserpage();
                          },
                          icon: Icon(
                            optimisticLikeStatus[user.userId] == 1
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 30,
                            color: optimisticLikeStatus[user.userId] == 1
                                ? Colors.red
                                : Colors.white,
                          ),
                        ),
                        if (_animatingUserId == user.userId)
                          AnimatedOpacity(
                            duration: Duration(milliseconds: 500),
                            opacity:
                                _animatingUserId == user.userId ? 1.0 : 0.0,
                            child: AnimatedScale(
                              duration: Duration(milliseconds: 500),
                              scale:
                                  _animatingUserId == user.userId ? 1.5 : 0.0,
                              child: Icon(
                                Icons.favorite,
                                color: Colors.red.withOpacity(0.6),
                                size: 50,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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

      return '$age years old';
    } catch (e) {
      return 'Invalid DOB';
    }
  }

  Widget buildFilterChip(
    String label,
    List<String> options,
    List<String> initialSelection,
    Function(List<String>) onSelected,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
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
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: AppColors.activeColor, width: 2),
              ),
            ),
            onPressed: () {
              if (options.isEmpty) return;
              showBottomSheet(label, options, initialSelection, onSelected);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 2),
                Text(
                  label,
                  style: AppTextStyles.textStyle,
                ),
                SizedBox(width: 2),
                Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white,
                ),
              ],
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
