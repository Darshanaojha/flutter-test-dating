import 'package:dating_application/Controllers/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import '../../Models/ResponseModels/get_all_desires_model_response.dart';
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
                  'Found Uplift',
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
              Stack(
                children: [
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
                            color: Colors
                                .white, 
                            size: 24, 
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "24-hour Premium Plan - ₹299", 
                              style: AppTextStyles.bodyText.copyWith(
                                fontSize: getResponsiveFontSize(0.03),
                                color:
                                    Colors.white, 
                              ),
                            ),
                          ),
                          Text(
                            'Selected',
                            style: AppTextStyles.bodyText.copyWith(
                              fontSize: getResponsiveFontSize(0.03),
                              color: AppColors
                                  .buttonColor, 
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
                        borderRadius:
                            BorderRadius.circular(12), 
                      ),
                      child: Text(
                        '20% OFF',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize:
                              getResponsiveFontSize(0.03), 
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Profile upgraded! Enjoy your 24 hours of premium access.')),
                    );
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
      backgroundColor: Colors
          .transparent,
    );
  }

  Future<bool> fetchData() async {
    try {
      setState(() {
        isLoading = true;
      });

      await Future.delayed(Duration(seconds: 2));

      filteredLikesPage = controller.likespage;

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

      final relationshipCategory = controller.categories.firstWhere(
        (category) => category.category == 'Relationship',
        orElse: () => Category(category: 'Relationship', desires: []),
      );

      final kinksCategory = controller.categories.firstWhere(
        (category) => category.category == 'Kinks',
        orElse: () => Category(category: 'Kinks', desires: []),
      );

      desires.addAll([
        ...relationshipCategory.desires.map((desire) => desire.title),
        ...kinksCategory.desires.map((desire) => desire.title),
      ]);

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

  @override
  void initState() {
    super.initState();
    fetchData();
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
                    // buildFilterChip('Location',
                    //     ['All', 'New York', 'Los Angeles', 'Chicago'], (value) {
                    //   setState(() {
                    //     selectedLocation = value!;
                    //   });
                    // }),
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
                        child: Text("No Likes in History."),
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
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: user.images.length,
                                      itemBuilder: (context, imgIndex) {
                                        return Container(
                                          margin: EdgeInsets.only(right: 12),
                                          child: GestureDetector(
                                            onTap: () => showFullImageDialog(
                                                context, user.images[imgIndex]),
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
                                    )),
                                // User Information
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(user.name,
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
                                    // Text('${user['km']} km away',
                                    //     style: AppTextStyles.bodyText.copyWith(
                                    //         fontSize: getResponsiveFontSize(0.03))),
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
                                          isLiked = !isLiked;
                                        });
                                      },
                                      icon: Icon(
                                        isLiked
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        size: 30,
                                        color:
                                            isLiked ? Colors.red : Colors.white,
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
                  "Upgrade",
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


