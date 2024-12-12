import 'package:cached_network_image/cached_network_image.dart';
import 'package:dating_application/Controllers/controller.dart';
import 'package:dating_application/Screens/homepage/swaping.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:swipe_cards/draggable_card.dart';
import 'package:swipe_cards/swipe_cards.dart';
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
    return screenWidth * scale;
  }

  RxString selectedFilter = 'All'.obs;
  RxString filterType = 'All'.obs;
  bool isLiked = false;
  bool isDisliked = false;
  bool isSuperLiked = false;
  bool isShare = false;
  int nearby = 0;
  int yourfavirout = 10;
  bool isLoading = true;
  int messageCount = 0;
  final TextEditingController messageController = TextEditingController();
  final FocusNode messageFocusNode = FocusNode();
  final PageController _imagePageController = PageController();
  List<SwipeItem> swipeItems = [];
  late MatchEngine matchEngine;
  late Future<bool> _fetchSuggestion;
  @override
  void initState() {
    super.initState();
    matchEngine = MatchEngine();

    _fetchSuggestion = initializeApp();
  }

  Future<bool> initializeApp() async {
    if (!await controller.userSuggestions()) return false;

    if (controller.userSuggestionsList.isEmpty) {
      print("No user suggestions found.");
      return false;
    }

    for (int i = 0; i < controller.userSuggestionsList.length; i++) {
      swipeItems.add(SwipeItem(
        content: controller.userSuggestionsList[i].userId,
        likeAction: () {
          // Ensure likeModel is properly initialized
          controller.likeModel.likedBy =
              controller.userSuggestionsList[i].userId;
          controller.postLike(controller.likeModel);
          success('Hey Boy', "Liked ${controller.userSuggestionsList[i].name}");
        },
        nopeAction: () {
          success('OOPS', "Nope ${controller.userSuggestionsList[i].name}");
        },
        superlikeAction: () {
          controller.markFavouriteRequestModel.favouriteId =
              controller.userSuggestionsList[i].userId;
          controller.markasfavourite(controller.markFavouriteRequestModel);
          success(
              'Bravo', "Superliked ${controller.userSuggestionsList[i].name}");
        },
        onSlideUpdate: (SlideRegion? region) async {
          print("Region: $region");
        },
      ));
    }

    matchEngine = MatchEngine(swipeItems: swipeItems);
    if (matchEngine.currentItem != null) {
      matchEngine.currentItem?.nope();
    }

    return true;
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

  void showFullImageDialog(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black.withOpacity(0.9),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Center(
              child: Image.network(
                imagePath,
                fit: BoxFit.contain,
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
              SizedBox(
                width: screenWidth - 32,
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
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          shareUserProfile();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.activeColor,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Share",
                          style: AppTextStyles.buttonText.copyWith(
                            fontSize: getResponsiveFontSize(0.03),
                            fontWeight: FontWeight.w500,
                            color: AppColors.textColor,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.inactiveColor,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: AppTextStyles.buttonText.copyWith(
                            fontSize: getResponsiveFontSize(0.03),
                            fontWeight: FontWeight.w500,
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
        );
      },
      isScrollControlled: true,
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

  Widget buildFilterChip(String label, IconData icon, Function(String) onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: FilterChip(
        label: Row(
          children: [
            Icon(icon, size: 20, color: Colors.white),
            SizedBox(width: 8),
            Text(label, style: TextStyle(color: Colors.white)),
          ],
        ),
        onSelected: (selected) {
          onTap(label);
        },
        selectedColor: Colors.blue,
        backgroundColor: AppColors.FilterChipColor,
        shape: StadiumBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double fontSize = size.width * 0.045;
    double bodyFontSize = size.width * 0.035;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Stack(
          children: [
            FutureBuilder(
              future: _fetchSuggestion,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: SpinKitCircle(
                      size: 150.0,
                      color: Colors.blue,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, color: Colors.red, size: 50),
                        SizedBox(height: 10),
                        Text(
                          'Error loading user photos: ${snapshot.error}',
                          style: TextStyle(color: Colors.red),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isLoading = true;
                            });
                          },
                          child: Text('Retry'),
                        ),
                      ],
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

                return Column(
                  children: [
                    Container(
                      height: 80,
                      padding: EdgeInsets.all(8),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            buildFilterChip('All', Icons.all_inclusive,
                                (value) {
                              setState(() {
                                selectedFilter.value = 'All';
                              });
                              applyFilter('All');
                              Get.snackbar(
                                  'All',
                                  controller.userSuggestionsList.length
                                      .toString());
                            }),
                            buildFilterChip('Nearby', Icons.location_on,
                                (value) {
                              setState(() {
                                selectedFilter.value = 'Nearby';
                              });
                              applyFilter('Nearby');
                              Get.snackbar('NearBy',
                                  controller.userNearByList.length.toString());
                            }),
                            buildFilterChip('Highlighted', Icons.star, (value) {
                              setState(() {
                                selectedFilter.value = 'Highlighted';
                              });
                              applyFilter('Highlighted');
                              Get.snackbar(
                                  'Highlighted',
                                  controller.userHighlightedList.length
                                      .toString());
                            }),
                            buildFilterChip('Favorites', Icons.favorite,
                                (value) {
                              setState(() {
                                selectedFilter.value = 'Favorites';
                              });
                              applyFilter('Favorites');
                              Get.snackbar('userfavourite',
                                  controller.favourite.length.toString());
                            }),
                            ElevatedButton(
                              onPressed: () {
                                Get.to(MySwipePage());
                                Get.snackbar(
                                    'usersuggestion',
                                    controller.userSuggestionsList.length
                                        .toString());
                                Get.snackbar(
                                    'highlighted',
                                    controller.userHighlightedList.length
                                        .toString());
                                Get.snackbar(
                                    'usernearbylist',
                                    controller.userNearByList.length
                                        .toString());
                                Get.snackbar('userfavourite',
                                    controller.favourite.length.toString());
                              },
                              child: Text('Demo'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SafeArea(
                      child: SizedBox(
                        height: size.height * 0.7 -
                            MediaQuery.of(context).viewInsets.bottom,
                        child: SwipeCards(
                          matchEngine: matchEngine,
                          itemBuilder: (BuildContext context, int index) {
                            var user = controller.userSuggestionsList[index];

                            String filterType = selectedFilter.value;
                            return buildFilteredCard(context, user, size,
                                fontSize, bodyFontSize, filterType);
                          },
                          onStackFinished: () {
                            failure('Finished', "Stack Finished");
                          },
                          itemChanged: (SwipeItem item, int index) {
                            print("Item: ${item.content}, Index: $index");
                          },
                          upSwipeAllowed: true,
                          fillSpace: true,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void applyFilter(String filter) {
    setState(() {
      controller.userSuggestionsList.clear();

      if (filter == 'All') {
        controller.userSuggestionsList.addAll(controller.userSuggestionsList);
      } else if (filter == 'Nearby') {
        controller.userSuggestionsList.addAll(controller.userNearByList);
      } else if (filter == 'Highlighted') {
        controller.userSuggestionsList.addAll(controller.userHighlightedList);
      } else if (filter == 'Favorites') {
        // controller.userSuggestionsList.addAll(controller.favourite);
      }
    });
  }

  Widget buildFilteredCard(BuildContext context, user, Size size,
      double fontSize, double bodyFontSize, String filterType) {
    String additionalInfo = '';

    switch (filterType) {
      case "All":
        additionalInfo = 'All';
      case 'Nearby':
        additionalInfo = 'Nearby';
        break;
      case 'Highlighted':
        additionalInfo = 'Highlighted';
        break;
      case 'Favorites':
        additionalInfo = 'Favorites';
        break;
      default:
        additionalInfo = 'All';
    }

    return buildCardLayoutAll(context, user, size, fontSize, bodyFontSize,
        additionalInfo: additionalInfo);
  }

  Widget buildSwipeCard(BuildContext context, int index, double fontSize,
      double bodyFontSize, String filterType) {
    final size = MediaQuery.of(context).size;

    switch (filterType) {
      case "All":
        return buildCardLayoutAll(
            context,
            controller.userSuggestionsList[index],
            size,
            fontSize,
            bodyFontSize);
      case 'Nearby':
        return buildNearbyCard(context, controller.userNearByList[index], size,
            fontSize, bodyFontSize);
      case 'Highlighted':
        return buildHighlightedCard(
            context,
            controller.userHighlightedList[index],
            size,
            fontSize,
            bodyFontSize);
      case 'Favorites':
        return buildFavoritesCard(
            context, controller.favourite[index], size, fontSize, bodyFontSize);
      default:
        return buildDefaultCard(context, controller.userSuggestionsList[index],
            size, fontSize, bodyFontSize);
    }
  }

  Widget buildDefaultCard(BuildContext context, user, Size size,
      double fontSize, double bodyFontSize) {
    return buildCardLayoutAll(context, user, size, fontSize, bodyFontSize);
  }

  Widget buildNearbyCard(BuildContext context, user, Size size, double fontSize,
      double bodyFontSize) {
    return buildCardLayoutNearBy(context, user, size, fontSize, bodyFontSize,
        additionalInfo: 'Nearby');
  }

  Widget buildHighlightedCard(BuildContext context, user, Size size,
      double fontSize, double bodyFontSize) {
    return buildCardLayoutHighlighted(
        context, user, size, fontSize, bodyFontSize,
        additionalInfo: 'Highlighted');
  }

  Widget buildFavoritesCard(BuildContext context, user, Size size,
      double fontSize, double bodyFontSize) {
    return buildCardLayoutAll(context, user, size, fontSize, bodyFontSize,
        additionalInfo: 'Favorites');
  }

  Widget buildCardLayoutAll(
    BuildContext context,
    user,
    Size size,
    double fontSize,
    double bodyFontSize, {
    String? additionalInfo,
  }) {
    var images = controller.userSuggestionsList.isNotEmpty
        ? controller.userSuggestionsList[0].images ?? []
        : [];

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: size.height * 0.4,
            child: Stack(
              children: [
                SafeArea(
                  child: ListView.builder(
                    itemCount: images.length,
                    itemBuilder: (BuildContext context, int index) {
                      images = controller.userSuggestionsList[index].images;
                      if (images.isEmpty) {
                        return Center(child: Text('No Images Available'));
                      }
                      return GestureDetector(
                        onTap: () =>
                            showFullImageDialog(context, images[index]),
                        child: Container(
                          margin: EdgeInsets.only(bottom: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: CachedNetworkImage(
                              imageUrl: images[index],
                              placeholder: (context, url) =>
                                  Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) {
                                print("Failed to load image from URL: $url");
                                return Icon(Icons.error, color: Colors.red);
                              },
                              fit: BoxFit.cover,
                              width: size.width * 0.9,
                              height: size.height * 0.45,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: size.height * 0.1),
                    child: Transform.rotate(
                      angle: -1.5708,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SmoothPageIndicator(
                            controller: _imagePageController,
                            count: images.length,
                            effect: ExpandingDotsEffect(
                              dotHeight: 10,
                              dotWidth: 10,
                              spacing: 10,
                              radius: 5,
                              dotColor: Colors.grey.withOpacity(0.5),
                              activeDotColor: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    isLiked = !isLiked;
                  });
                },
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 40,
                  color: isLiked ? Colors.red : Colors.white,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    isShare = !isShare;
                  });
                },
                icon: Icon(
                  isShare ? Icons.share : Icons.share,
                  size: 40,
                  color: isShare ? Colors.green : Colors.white,
                ),
              ),
              IconButton(
                onPressed: showmessageBottomSheet,
                icon: Icon(Icons.messenger_outline, size: 40),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            user.name ?? 'NA',
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Text(
                '${DateTime.now().year - DateFormat('dd/MM/yyyy').parse(controller.userData.first.dob).year} Years Old || ',
                style: TextStyle(fontSize: bodyFontSize),
              ),
              Text(
                '${user.city ?? 'NA'}',
                style: TextStyle(fontSize: bodyFontSize),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    matchEngine.currentItem?.nope();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.NopeColor),
                  child: Text("Nope",
                      style: AppTextStyles.buttonText
                          .copyWith(fontSize: getResponsiveFontSize(0.03))),
                ),
                ElevatedButton(
                  onPressed: () {
                    matchEngine.currentItem?.superLike();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.FavouriteColor),
                  child: Text("Favourite",
                      style: AppTextStyles.buttonText
                          .copyWith(fontSize: getResponsiveFontSize(0.03))),
                ),
                ElevatedButton(
                  onPressed: () {
                    matchEngine.currentItem?.like();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.LikeColor),
                  child: Text("Like",
                      style: AppTextStyles.buttonText
                          .copyWith(fontSize: getResponsiveFontSize(0.03))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCardLayoutNearBy(
    BuildContext context,
    user,
    Size size,
    double fontSize,
    double bodyFontSize, {
    String? additionalInfo,
  }) {
    var images = controller.userNearByList.isNotEmpty
        ? controller.userNearByList[0].images ?? []
        : [];

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: size.height * 0.4,
            child: Stack(
              children: [
                SafeArea(
                  child: ListView.builder(
                    itemCount: images.length,
                    itemBuilder: (BuildContext context, int index) {
                      images = controller.userNearByList[index].images;
                      if (images.isEmpty) {
                        return Center(child: Text('No Images Available'));
                      }
                      return GestureDetector(
                        onTap: () =>
                            showFullImageDialog(context, images[index]),
                        child: Container(
                          margin: EdgeInsets.only(bottom: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: CachedNetworkImage(
                              imageUrl: images[index],
                              placeholder: (context, url) =>
                                  Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) {
                                print("Failed to load image from URL: $url");
                                return Icon(Icons.error, color: Colors.red);
                              },
                              fit: BoxFit.cover,
                              width: size.width * 0.9,
                              height: size.height * 0.45,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: size.height * 0.1),
                    child: Transform.rotate(
                      angle: -1.5708,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SmoothPageIndicator(
                            controller: _imagePageController,
                            count: images.length,
                            effect: ExpandingDotsEffect(
                              dotHeight: 10,
                              dotWidth: 10,
                              spacing: 10,
                              radius: 5,
                              dotColor: Colors.grey.withOpacity(0.5),
                              activeDotColor: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    isLiked = !isLiked;
                  });
                },
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 40,
                  color: isLiked ? Colors.red : Colors.white,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    isShare = !isShare;
                  });
                },
                icon: Icon(
                  isShare ? Icons.share : Icons.share,
                  size: 40,
                  color: isShare ? Colors.green : Colors.white,
                ),
              ),
              IconButton(
                onPressed: showmessageBottomSheet,
                icon: Icon(Icons.messenger_outline, size: 40),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            controller.userNearByList.first.name ?? 'NA',
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Text(
                '${DateTime.now().year - DateFormat('dd/MM/yyyy').parse(controller.userNearByList.first.dob.toString()).year} Years Old || ',
                style: TextStyle(fontSize: bodyFontSize),
              ),
              Text(
                '${controller.userNearByList.first.city ?? 'NA'}',
                style: TextStyle(fontSize: bodyFontSize),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    matchEngine.currentItem?.nope();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.NopeColor),
                  child: Text("Nope",
                      style: AppTextStyles.buttonText
                          .copyWith(fontSize: getResponsiveFontSize(0.03))),
                ),
                ElevatedButton(
                  onPressed: () {
                    matchEngine.currentItem?.superLike();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.FavouriteColor),
                  child: Text("Favourite",
                      style: AppTextStyles.buttonText
                          .copyWith(fontSize: getResponsiveFontSize(0.03))),
                ),
                ElevatedButton(
                  onPressed: () {
                    matchEngine.currentItem?.like();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.LikeColor),
                  child: Text("Like",
                      style: AppTextStyles.buttonText
                          .copyWith(fontSize: getResponsiveFontSize(0.03))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCardLayoutHighlighted(
    BuildContext context,
    user,
    Size size,
    double fontSize,
    double bodyFontSize, {
    String? additionalInfo,
  }) {
    var images = controller.userHighlightedList.isNotEmpty
        ? controller.userHighlightedList[0].images ?? []
        : [];

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: size.height * 0.4,
            child: Stack(
              children: [
                SafeArea(
                  child: ListView.builder(
                    itemCount: images.length,
                    itemBuilder: (BuildContext context, int index) {
                      images = controller.userHighlightedList[index].images;
                      if (images.isEmpty) {
                        return Center(child: Text('No Images Available'));
                      }
                      return GestureDetector(
                        onTap: () =>
                            showFullImageDialog(context, images[index]),
                        child: Container(
                          margin: EdgeInsets.only(bottom: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: CachedNetworkImage(
                              imageUrl: images[index],
                              placeholder: (context, url) =>
                                  Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) {
                                print("Failed to load image from URL: $url");
                                return Icon(Icons.error, color: Colors.red);
                              },
                              fit: BoxFit.cover,
                              width: size.width * 0.9,
                              height: size.height * 0.45,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: size.height * 0.1),
                    child: Transform.rotate(
                      angle: -1.5708,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SmoothPageIndicator(
                            controller: _imagePageController,
                            count: images.length,
                            effect: ExpandingDotsEffect(
                              dotHeight: 10,
                              dotWidth: 10,
                              spacing: 10,
                              radius: 5,
                              dotColor: Colors.grey.withOpacity(0.5),
                              activeDotColor: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    isLiked = !isLiked;
                  });
                },
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 40,
                  color: isLiked ? Colors.red : Colors.white,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    isShare = !isShare;
                  });
                },
                icon: Icon(
                  isShare ? Icons.share : Icons.share,
                  size: 40,
                  color: isShare ? Colors.green : Colors.white,
                ),
              ),
              IconButton(
                onPressed: showmessageBottomSheet,
                icon: Icon(Icons.messenger_outline, size: 40),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            controller.userHighlightedList.first.name ?? 'NA',
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Text(
                '${DateTime.now().year - DateFormat('dd/MM/yyyy').parse(controller.userHighlightedList.first.dob.toString()).year} Years Old || ',
                style: TextStyle(fontSize: bodyFontSize),
              ),
              Text(
                '${controller.userHighlightedList.first.city ?? 'NA'}',
                style: TextStyle(fontSize: bodyFontSize),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    matchEngine.currentItem?.nope();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.NopeColor),
                  child: Text("Nope",
                      style: AppTextStyles.buttonText
                          .copyWith(fontSize: getResponsiveFontSize(0.03))),
                ),
                ElevatedButton(
                  onPressed: () {
                    matchEngine.currentItem?.superLike();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.FavouriteColor),
                  child: Text("Favourite",
                      style: AppTextStyles.buttonText
                          .copyWith(fontSize: getResponsiveFontSize(0.03))),
                ),
                ElevatedButton(
                  onPressed: () {
                    matchEngine.currentItem?.like();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.LikeColor),
                  child: Text("Like",
                      style: AppTextStyles.buttonText
                          .copyWith(fontSize: getResponsiveFontSize(0.03))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
