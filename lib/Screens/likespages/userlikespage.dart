import 'package:dating_application/Controllers/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../Models/ResponseModels/get_all_addon_response_model.dart';
import '../../Models/ResponseModels/get_all_likes_pages_response.dart';
import '../../constants.dart';

class LikesPage extends StatefulWidget {
  const LikesPage({super.key});

  @override
  LikesPageState createState() => LikesPageState();
}

class LikesPageState extends State<LikesPage> {
  List<String> selectedGender = [];
  String selectedLocation = 'All';
  bool isLoading = true;

  Controller controller = Get.put(Controller());

  List<String> genders = [];
  List<String> desires = [];
  List<String> preferences = [];
  List<String> selectedPreference = [];
  List<String> selectedGenderFilters = [];
  List<String> selectedPreferenceFilters = [];
  List<String> selectedDesireFilters = [];
  List<LikeRequestPages> filteredLikesPage = [];
  bool isLiked = false;
  bool isShare = false;
  bool isSms = false;
  int pingCount = 0;
  final PageController imagePageController = PageController();
  double getResponsiveFontSize(double scale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * scale;
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<bool> fetchData() async {
    try {
      setState(() {
        isLoading = true;
      });

      await Future.delayed(Duration(seconds: 2));

      filteredLikesPage = controller.likespage;
      await controller.fetchAllAddOn();
      await controller.likesuserpage();
      if (controller.likespage.isEmpty) {
        print("No likes in the list");
      } else {
        print(controller.likespage.map((item) => item));
      }

      await controller.fetchGenders();
      if (controller.genders.isEmpty) {
        print("No genders in the list");
      } else {
        genders
            .addAll(controller.genders.map((gender) => gender.title).toSet());
        print(genders);
      }
      desires = controller.categories
          .expand(
              (category) => category.desires.map((desires) => desires.title))
          .toList();

      await controller.fetchPreferences();
      preferences.addAll(controller.preferences
          .map((preference) => preference.title)
          .toSet()
          .toList());
      print(preferences);

      return true;
    } catch (e) {
      print("Error during data fetching: $e");
      return false;
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void applyFilters() {
    setState(() {
      filteredLikesPage = controller.likespage;

      if (selectedGenderFilters.isNotEmpty) {
        filteredLikesPage = filteredLikesPage
            .where((user) => selectedGenderFilters.contains(user.gender))
            .toList();
      }

      if (selectedDesireFilters.isNotEmpty) {
        filteredLikesPage = filteredLikesPage
            .where((user) => user.desires
                .any((desire) => selectedDesireFilters.contains(desire)))
            .toList();
      }

      if (selectedPreferenceFilters.isNotEmpty) {
        filteredLikesPage = filteredLikesPage
            .where((user) => user.preferences.any(
                (preference) => selectedPreferenceFilters.contains(preference)))
            .toList();
      }
    });
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
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Found Add ON',
                  style: AppTextStyles.titleText.copyWith(
                    fontSize: getResponsiveFontSize(0.03),
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
                    fontSize: getResponsiveFontSize(0.03),
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: Obx(() {
                  if (controller.addon.isEmpty) {
                    return Center(child: CircularProgressIndicator());
                  }

                  return ListView.builder(
                    itemCount: controller.addon.length,
                    itemBuilder: (context, index) {
                      Addon currentAddon = controller.addon[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            selectedIndex.value = index;
                            showAddonDialog(currentAddon);
                            selectedcard = true.obs;
                          },
                          child: Obx(() {
                            return Card(
                              elevation: selectedIndex.value == index ? 12 : 8,
                              color: selectedIndex.value == index
                                  ? Colors.blueAccent
                                  : Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
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
                                        "${currentAddon.title}/${currentAddon.duration} - ₹${currentAddon.amount}",
                                        style: AppTextStyles.bodyText.copyWith(
                                          fontSize: getResponsiveFontSize(0.03),
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        showAddonPointsButton(
                                            currentAddon.addonPoints);
                                      },
                                    ),
                                  ],
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
              SizedBox(height: 20),
              Obx(() {
                bool isAnyAddonSelected = selectedIndex.value != -1;

                return Visibility(
                  visible: isAnyAddonSelected,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Profile upgraded! Enjoy your 24 hours of premium access.',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonColor,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          Text('Purchase Now', style: AppTextStyles.buttonText),
                    ),
                  ),
                );
              }),
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
        return AlertDialog(
          backgroundColor: Colors.black,
          title: Text(
            'Confirm Add-On Subscription',
            style: AppTextStyles.titleText.copyWith(color: Colors.white),
          ),
          content: Text(
            'Do you want to subscribe to the "${currentAddon.title}" add-on for ₹${currentAddon.amount}?',
            style: AppTextStyles.bodyText.copyWith(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text(
                'Cancel',
                style: AppTextStyles.bodyText.copyWith(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Subscribed to ${currentAddon.title}')),
                );
              },
              child: Text(
                'Subscribe',
                style: AppTextStyles.bodyText.copyWith(color: Colors.green),
              ),
            ),
          ],
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
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: addonPoints.length,
                  itemBuilder: (context, index) {
                    AddonPoint point = addonPoints[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text(
                          point.title,
                          style: AppTextStyles.bodyText
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
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
                  child: Text('Close', style: AppTextStyles.buttonText),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Likes: ${filteredLikesPage.length}',
                        style: AppTextStyles.bodyText),
                    Text('Pings: $pingCount', style: AppTextStyles.bodyText),
                  ],
                ),
              ),
              SizedBox(
                height: 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    buildFilterChip('Gender', genders, selectedGenderFilters,
                        (value) {
                      setState(() {
                        selectedGenderFilters = value;
                      });
                      applyFilters();
                    }),
                    buildFilterChip('Desires', desires, selectedDesireFilters,
                        (value) {
                      setState(() {
                        selectedDesireFilters = value;
                      });
                      applyFilters();
                    }),
                    buildFilterChip(
                        'Preferences', preferences, selectedPreferenceFilters,
                        (value) {
                      setState(() {
                        selectedPreferenceFilters = value;
                      });
                      applyFilters();
                    })
                  ],
                ),
              ),
              Expanded(
                child: filteredLikesPage.isEmpty
                    ? Center(
                        child: Lottie.asset(
                            "assets/animations/likepageanimation.json",
                            repeat: true,
                            reverse: true),
                      )
                    : ListView.builder(
                        itemCount: filteredLikesPage.length,
                        itemBuilder: (context, index) {
                          var user = filteredLikesPage[index];
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                    height: 200,
                                    child: Scrollbar(
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: user.images.length,
                                        itemBuilder: (context, imgIndex) {
                                          return Container(
                                            margin: EdgeInsets.only(right: 12),
                                            child: GestureDetector(
                                              onTap: () => showFullImageDialog(
                                                  context,
                                                  user.images[imgIndex]),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                child: Image.network(
                                                  user.images[imgIndex],
                                                  fit: BoxFit.cover,
                                                  width: 150,
                                                  height: 200,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Container(
                                                      width: 150,
                                                      height: 200,
                                                      alignment:
                                                          Alignment.center,
                                                      color:
                                                          Colors.grey.shade200,
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
                                    )),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(user.name.toString(),
                                        style: AppTextStyles.titleText.copyWith(
                                            fontSize:
                                                getResponsiveFontSize(0.04))),
                                    Text(
                                        (user.likedByMe == 0)
                                            ? ' | Liked By ${user.name}'
                                            : " | Liked By You",
                                        style: AppTextStyles.bodyText.copyWith(
                                            fontSize:
                                                getResponsiveFontSize(0.03))),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text('${user.name} years old | ',
                                        style: AppTextStyles.bodyText.copyWith(
                                            fontSize:
                                                getResponsiveFontSize(0.03))),
                                    Text('${user.countryName} | ',
                                        style: AppTextStyles.bodyText.copyWith(
                                            fontSize:
                                                getResponsiveFontSize(0.03))),
                                    Text('${user.gender} | ',
                                        style: AppTextStyles.bodyText.copyWith(
                                            fontSize:
                                                getResponsiveFontSize(0.03))),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Text('Last Seen: ${user.updated}',
                                    style: AppTextStyles.bodyText.copyWith(
                                        fontSize: getResponsiveFontSize(0.03))),
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          user.likedByMe =
                                              user.likedByMe == 0 ? 1 : 0;
                                          controller.profileLikeRequest
                                              .likedBy = user.userId.toString();
                                          controller.profileLike(
                                              controller.profileLikeRequest);
                                        });
                                      },
                                      icon: Icon(
                                        user.likedByMe == 1
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        size: 30,
                                        color: user.likedByMe == 1
                                            ? Colors.red
                                            : Colors.white,
                                      ),
                                    )
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
          Positioned(
            bottom: 16,
            right: 16,
            child: SizedBox(
              width: 160,
              height: 60,
              child: FloatingActionButton(
                onPressed: () {
                  showUpgradeBottomSheet();
                },
                backgroundColor: AppColors.buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  "Add On",
                  style: AppTextStyles.buttonText,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          if (isLoading)
            Center(
              child: SpinKitCircle(
                size: 150.0,
                color: AppColors.progressColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget buildFilterChip(
    String label,
    List<String> options,
    List<String> initialSelection,
    Function(List<String>) onSelected,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: AppColors.primaryColor,
              backgroundColor: AppColors.secondaryColor,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
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
                Text(
                  label,
                  style: AppTextStyles.bodyText,
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.activeColor,
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
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$label Filter',
                    style: AppTextStyles.headingText.copyWith(fontSize: 22),
                  ),
                  SizedBox(height: 16),
                  CheckboxListTile(
                    title: Text('All', style: AppTextStyles.bodyText),
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
                      title: Text(option, style: AppTextStyles.bodyText),
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
                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonColor,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    ),
                    onPressed: () {
                      onSelected(selectedOptions);
                      Navigator.pop(context);
                    },
                    child: Text("Apply"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
