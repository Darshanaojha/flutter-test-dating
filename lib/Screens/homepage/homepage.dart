import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dating_application/Controllers/controller.dart';
import 'package:dating_application/Models/RequestModels/estabish_connection_request_model.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:heart_overlay/heart_overlay.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:swipe_cards/swipe_cards.dart';
import '../../Models/RequestModels/update_lat_long_request_model.dart';
import '../../Models/ResponseModels/user_suggestions_response_model.dart';
import '../../Providers/WebSocketService.dart';
import '../../constants.dart';
import '../userprofile/userprofilesummary.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  Controller controller = Get.put(Controller());
  double getResponsiveFontSize(double scale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * scale;
  }

  SuggestedUser? lastUser;
  SuggestedUser? lastUserNearBy;
  SuggestedUser? lastUserHighlighted;
  SuggestedUser? lastUserFavourite;

  bool isLastCard = false;
  RxInt selectedFilter = 0.obs;
  bool isLiked = false;
  bool isDisliked = false;
  bool isSuperLiked = false;
  bool isShare = false;
  bool isSwipeFinished = false;
  int nearby = 0;
  int yourfavirout = 10;
  bool isLoading = false;
  int messageCount = 0;
  int messageType = 1;
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  final TextEditingController messageController = TextEditingController();
  final FocusNode messageFocusNode = FocusNode();
  final PageController _imagePageController = PageController();
  int _currentImageIndex = 0;
  List<SwipeItem> swipeItems = [];
  late MatchEngine matchEngine;
  late Future<bool> _fetchSuggestion;
  late HeartOverlayController heartOverlayController;
  @override
  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * 3.1415927).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    heartOverlayController = HeartOverlayController();

    matchEngine = MatchEngine();

    selectedFilter.value = -1; // Default filter is All

    _fetchSuggestion = initializeApp();

    initialize();

    _fetchSuggestion.then((_) {
      if (mounted) {
        setState(() {
          rebuildSwipeItemsForFilter(
              -1); // Build swipe cards for ALL users initially
        });
      }
    });
  }

  initialize() async {
    WebSocketService().connect(controller.token.value);

    await controller.updateStatus('online');

    // fetchLocation();
  }

  Future<void> fetchLocation() async {
    try {
      Position position = await _getUserLocation();
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks.first;

      UpdateLatLongRequest updateLatLongRequest = UpdateLatLongRequest(
        latitude: position.latitude.toString(),
        longitude: position.longitude.toString(),
        city: place.locality ?? 'Unknown',
        address: place.name ?? 'Unknown',
      );
      controller.updatelatlong(updateLatLongRequest);
    } catch (e) {
      // Show a snackbar or dialog, but do NOT throw
      Get.snackbar("Location Error",
          "Location services are disabled or permission denied.");
      // Optionally: continue loading the rest of the page
    }
  }

  Future<Position> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        throw 'Location permission denied';
      }
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> _storeLastUserForAllLists(SuggestedUser suggestedUser) async {
    final preferences = EncryptedSharedPreferences.getInstance();

    Map<String, String> lastUsersMap = {};
    if (controller.getCurrentList(0).isNotEmpty) {
      SuggestedUser lastUserNearby = controller.getCurrentList(0).last;
      lastUsersMap['nearBy'] = jsonEncode(lastUserNearby.toJson());
    }

    // Save last user for 'highlighted' list
    if (controller.getCurrentList(1).isNotEmpty) {
      SuggestedUser lastUserHighlighted = controller.getCurrentList(1).last;
      lastUsersMap['highlighted'] = jsonEncode(lastUserHighlighted.toJson());
    }

    // Save last user for 'favourite' list
    if (controller.getCurrentList(2).isNotEmpty) {
      SuggestedUser lastUserFavourite = controller.getCurrentList(2).last;
      lastUsersMap['favourite'] = jsonEncode(lastUserFavourite.toJson());
    }

    // Save last user for 'hookup' list
    if (controller.getCurrentList(3).isNotEmpty) {
      SuggestedUser lastUserHookUp = controller.getCurrentList(3).last;
      lastUsersMap['hookup'] = jsonEncode(lastUserHookUp.toJson());
    }

    // Save the entire map of last users
    await preferences.setString('lastUsersMap', jsonEncode(lastUsersMap));

    print("Saved last users for all lists: $lastUsersMap");
  }

  Future<void> _retrieveLastUsers() async {
    final preferences = EncryptedSharedPreferences.getInstance();
    String? lastUsersMapString = preferences.getString('lastUsersMap');

    if (lastUsersMapString != null) {
      // Decode the map from JSON
      Map<String, dynamic> lastUsersMap = jsonDecode(lastUsersMapString);

      setState(() {
        // Retrieve last user for 'nearBy' list
        if (lastUsersMap['nearBy'] != null) {
          Map<String, dynamic> lastUserMap = jsonDecode(lastUsersMap['nearBy']);
          lastUserNearBy = SuggestedUser.fromJson(lastUserMap);
        }

        // Retrieve last user for 'highlighted' list
        if (lastUsersMap['highlighted'] != null) {
          Map<String, dynamic> lastUserMap =
              jsonDecode(lastUsersMap['highlighted']);
          lastUserHighlighted = SuggestedUser.fromJson(lastUserMap);
        }

        // Retrieve last user for 'favourite' list
        if (lastUsersMap['favourite'] != null) {
          Map<String, dynamic> lastUserMap =
              jsonDecode(lastUsersMap['favourite']);
          lastUserFavourite = SuggestedUser.fromJson(lastUserMap);
        }
      });

      print("Last users retrieved: $lastUsersMap");
    } else {
      print('No last users found');
    }
  }

  Future<bool> initializeApp() async {
    await _retrieveLastUsers();

    await controller.userSuggestions();
    for (int i = 0; i < controller.userSuggestionsList.length; i++) {
      swipeItems.add(SwipeItem(
        content: controller.userSuggestionsList[i].userId,
        likeAction: () async {
          matchEngine = MatchEngine(swipeItems: swipeItems);
          if (controller.userSuggestionsList[i].userId != null) {
            print(
                "Pressed like button for user: ${controller.userSuggestionsList[i].name}");
            setState(() {
              controller.profileLikeRequest.likedBy =
                  controller.userSuggestionsList[i].userId.toString();
            });
            await controller.profileLike(controller.profileLikeRequest);
          } else {
            print("User ID is null");
            failure('Error', "Error: User ID is null.");
          }
        },
        nopeAction: () async {
          print(
              "Pressed dislike button for user: ${controller.userSuggestionsList[i].name}");
          matchEngine = MatchEngine(swipeItems: swipeItems);
          setState(() {
            controller.dislikeProfileRequest.id =
                controller.userSuggestionsList[i].userId.toString();
          });
          await controller.dislikeprofile(controller.dislikeProfileRequest);
          print("User ${controller.userSuggestionsList[i].name} was 'nope'd");
        },
        superlikeAction: () async {
          matchEngine = MatchEngine(swipeItems: swipeItems);
          if (controller.userSuggestionsList[i].userId != null) {
            controller.markFavouriteRequestModel.favouriteId =
                controller.userSuggestionsList[i].userId.toString();

            print("id ${controller.userSuggestionsList[i].userId}");
            await controller
                .markasfavourite(controller.markFavouriteRequestModel);
          } else {
            failure('Error', "Error: User ID is null.");
          }
        },
      ));
    }

    matchEngine = MatchEngine(swipeItems: swipeItems);

    return true;
  }

  String cleanDateString(String? date) {
    return date?.trim() ?? '';
  }

  String calculateAge(String? dob) {
    if (dob == null || dob.isEmpty || dob == 'Unknown Date') {
      return 'Age not available';
    }
    try {
      DateTime birthDate = DateFormat('dd/MM/yyyy').parse(dob);
      int age = DateTime.now().year - birthDate.year;
      if (DateTime.now().month < birthDate.month ||
          (DateTime.now().month == birthDate.month &&
              DateTime.now().day < birthDate.day)) {
        age--;
      }
      return '$age';
    } catch (e) {
      return 'Age not available';
    }
  }

  String getAgeFromDob(String? dob) {
    if (dob == null || dob.trim().isEmpty) {
      return 'Invalid DOB';
    }

    try {
      final parts = dob.trim().split('/');
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

  @override
  void dispose() {
    _animationController.dispose();
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
          backgroundColor: Colors.transparent,
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

  EstablishConnectionMessageRequest establishConnectionMessageRequest =
      EstablishConnectionMessageRequest(
          message: '', receiverId: '', messagetype: textMessage);
  void showmessageBottomSheet(String userid) {
    Get.bottomSheet(
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Send a Message', style: AppTextStyles.inputFieldText),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              TextField(
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
                onChanged: (value) {
                  establishConnectionMessageRequest.message = value;
                  establishConnectionMessageRequest.receiverId = userid;
                },
                maxLines: 3,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (establishConnectionMessageRequest.message.isEmpty) {
                    Get.snackbar("Error", "Message cannot be empty!");
                    return;
                  }
                  await controller
                      .sendConnectionMessage(establishConnectionMessageRequest);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mediumGradientColor,
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

  Widget buildFilterButton(
    BuildContext context,
    int button,
    String label,
    IconData icon,
    Function(String) onTap,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double fontSize = screenWidth * 0.025;
    double iconSize = screenWidth * 0.06;
    double buttonWidth = screenWidth * 0.22;
    double buttonHeight = screenHeight * 0.02;

    bool isSelected = selectedFilter.value == button;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.015),
      child: AnimatedScale(
        scale: isSelected ? 1.08 : 1.0,
        duration: Duration(milliseconds: 200),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment(0.8, 1),
              colors: AppColors.gradientBackgroundList,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: Offset(0, 2),
                    ),
                  ]
                : [],
            border: isSelected
                ? Border.all(color: Colors.white, width: 2)
                : Border.all(color: Colors.transparent),
          ),
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                selectedFilter.value = button;
                rebuildSwipeItemsForFilter(button);
              });
              _animationController.forward(from: 0);
              onTap(label);
            },
            icon: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: isSelected ? _rotationAnimation.value : 0,
                  child: Icon(
                    icon,
                    size: iconSize,
                    color: AppColors.textColor,
                  ),
                );
              },
            ),
            label: Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                color: AppColors.textColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              minimumSize: Size(buttonWidth, buttonHeight),
              elevation: 0,
              padding: EdgeInsets.symmetric(
                vertical: buttonHeight * 0.2,
                horizontal: buttonWidth * 0.15,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void rebuildSwipeItemsForFilter(int filterIndex) {
    swipeItems.clear();

    List<SuggestedUser> currentList = controller.getCurrentList(filterIndex);
    // print(
    //     "🔄 Rebuilding SwipeItems for Filter $filterIndex → Found: ${currentList.length}");

    // if (currentList.isEmpty) {
    //   print("⚠️ No users found for this filter");
    // }

    for (var user in currentList) {
      swipeItems.add(SwipeItem(
        content: user,
        likeAction: () {
          if (user.userId != null) {
            controller.profileLikeRequest.likedBy = user.userId.toString();
            controller.profileLike(controller.profileLikeRequest);
          } else {
            failure('Error', "User ID is null.");
          }
        },
        nopeAction: () {
          if (user.userId != null) {
            controller.dislikeProfileRequest.id = user.userId.toString();
            controller.dislikeprofile(controller.dislikeProfileRequest);
          } else {
            print("User ID is null on nope");
          }
        },
        superlikeAction: () {
          if (user.userId != null) {
            controller.markFavouriteRequestModel.favouriteId =
                user.userId.toString();

            controller.markasfavourite(controller.markFavouriteRequestModel);
          } else {
            failure('Error', "User ID is null.");
          }
        },
      ));
    }

    matchEngine = MatchEngine(swipeItems: swipeItems);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
                      child: Lottie.asset(
                          "assets/animations/LoveIsBlind.json"));
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
                    // Filter Buttons Row
                    Container(
                      height: MediaQuery.of(context).size.height * 0.08,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buildFilterButton(context, -1, 'All', Icons.people,
                                (value) {
                              setState(() {
                                selectedFilter.value = -1;

                                final allList = controller.getCurrentList(-1);
                                print(
                                    "📣 Filter ALL clicked → total ${allList.length} users");

                                if (allList.isNotEmpty) {
                                  rebuildSwipeItemsForFilter(-1);
                                } else {
                                  print("❌ Can't rebuild, list is empty.");
                                  failure('No Data',
                                      'No profiles available to show for "All".');
                                }
                              });
                            }),
                            // buildFilterButton(
                            //     context, 2, 'Favourite', FontAwesome.heart,
                            //     (value) {
                            //   setState(() {
                            //     selectedFilter.value = 2;
                            //     rebuildSwipeItemsForFilter(2);
                            //   });
                            //   Get.snackbar('User Favourite',
                            //       controller.favourite.length.toString());
                            // }),
                            buildFilterButton(
                              context,
                              2,
                              'Favourite',
                              FontAwesome.heart,
                              (value) async {
                                setState(() {
                                  selectedFilter.value = 2;
                                  isLoading = true;
                                });
                                // Fetch favourites from API
                                bool success =
                                    await controller.fetchallfavourites();
                                setState(() {
                                  isLoading = false;
                                  if (success) {
                                    rebuildSwipeItemsForFilter(2);
                                  }
                                });
                                Get.snackbar('User Favourite',
                                    controller.favourite.length.toString());
                              },
                            ),
                            buildFilterButton(context, 0, 'NearBy',
                                FontAwesome.map_location_dot_solid, (value) {
                              setState(() {
                                selectedFilter.value = 0;
                                rebuildSwipeItemsForFilter(0);
                              });
                              Get.snackbar('NearBy',
                                  controller.userNearByList.length.toString());
                            }),
                            buildFilterButton(
                                context, 1, 'Highlighted', FontAwesome.star,
                                (value) {
                              setState(() {
                                selectedFilter.value = 1;
                                rebuildSwipeItemsForFilter(1);
                              });
                              Get.snackbar(
                                  'Highlighted',
                                  controller.userHighlightedList.length
                                      .toString());
                            }),
                            buildFilterButton(context, 3, 'HookUp',
                                FontAwesome.heart_pulse_solid, (value) {
                              setState(() {
                                selectedFilter.value = 3;
                                rebuildSwipeItemsForFilter(3);
                              });
                              Get.snackbar('HookUp',
                                  controller.hookUpList.length.toString());
                            }),
                          ],
                        ),
                      ),
                    ),

                    //  Cards Area - Takes 80% of screen height responsively
                    Expanded(
                      child: Obx(() {
                        final currentList =
                            controller.getCurrentList(selectedFilter.value);

                        return Center(
                          child: FractionallySizedBox(
                            widthFactor: 0.8,
                            heightFactor: 0.8,
                            child: currentList.isEmpty && lastUser != null
                                ? buildCardLayoutAll(
                                    context, lastUser!, size, isLastCard)
                                : SwipeCards(
                                    matchEngine: matchEngine,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      if (index >= currentList.length) {
                                        return Center(
                                            child: Text("No users available"));
                                      }

                                      final SuggestedUser user =
                                          currentList[index];
                                      isLastCard =
                                          index == currentList.length - 1;

                                      return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient:
                                                  AppColors.gradientBackground,
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                              border: Border.all(
                                                color: isLastCard
                                                    ? Colors.grey
                                                    : Colors.white,
                                                width: 2,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.white
                                                      .withOpacity(0.2),
                                                  spreadRadius: 2,
                                                  blurRadius: 5,
                                                  offset: Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: buildCardLayoutAll(context,
                                                user, size, isLastCard),
                                          ));
                                    },
                                    upSwipeAllowed: true,
                                    leftSwipeAllowed: true,
                                    rightSwipeAllowed: true,
                                    fillSpace: true,
                                    onStackFinished: () async {
                                      isSwipeFinished = true;
                                      if (currentList.isNotEmpty) {
                                        lastUser = currentList.last;
                                        await _storeLastUserForAllLists(
                                            lastUser!);
                                      }
                                      failure('Finished', "Stack Finished");
                                    },
                                    itemChanged: (SwipeItem item, int index) {
                                      print(
                                          "Item: ${item.content}, Index: $index");
                                    },
                                  ),
                          ),
                        );
                      }),
                    )
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCardLayoutAll(
      BuildContext context, SuggestedUser user, Size size, bool isLastCard) {
    print(user);
    List<String> images = user.images;
    List<String> interests = (user.interest ?? '')
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // Format looking for text
    String lookingForText = user.lookingFor == "1"
        ? "Serious Relationship"
        : user.lookingFor == "2"
            ? "Hookup"
            : "Unknown";

    return user.id == ''
        ? Text("No users available")
        : GestureDetector(
            onTap: () {
              Get.bottomSheet(
                UserProfileSummary(
                  userId: user.userId.toString(),
                  imageUrls: images,
                ),
                isScrollControlled: true,
                backgroundColor: AppColors.primaryColor,
                enterBottomSheetDuration: Duration(milliseconds: 300),
                exitBottomSheetDuration: Duration(milliseconds: 300),
              );
            },
            child: Container(
              height: size.height * 1.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment(0.8, 1),
                  colors: AppColors.gradientBackgroundList,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Images
                    SizedBox(
                      height: size.height * 0.3,
                      child: Stack(
                        children: [
                          SafeArea(
                            child: SizedBox(
                              height: size.height * 0.35,
                              child: NotificationListener<ScrollNotification>(
                                onNotification: (scrollNotification) {
                                  if (scrollNotification
                                      is ScrollUpdateNotification) {
                                    // This is an approximation. For accurate calculations,
                                    // you would need the exact height of each item.
                                    final itemHeight = size.height * 0.45;
                                    if (itemHeight <= 0) return true;

                                    int index =
                                        (scrollNotification.metrics.pixels /
                                                itemHeight)
                                            .round();

                                    if (index >= images.length) {
                                      index = images.length - 1;
                                    }
                                    if (index < 0) {
                                      index = 0;
                                    }

                                    if (index != _currentImageIndex) {
                                      setState(() {
                                        _currentImageIndex = index;
                                      });
                                    }
                                  }
                                  return true;
                                },
                                child: Scrollbar(
                                  child: ListView.builder(
                                    controller: _imagePageController,
                                    itemCount: images.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      if (images.isEmpty) {
                                        return Center(
                                            child: Text('No Images Available'));
                                      }
                                      return GestureDetector(
                                        onTap: () => showFullImageDialog(
                                            context, images[index]),
                                        child: Container(
                                          margin: EdgeInsets.only(bottom: 12),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(28),
                                            child: CachedNetworkImage(
                                              imageUrl: images[index],
                                              placeholder: (context, url) => Center(
                                                  child:
                                                      CircularProgressIndicator()),
                                              errorWidget:
                                                  (context, url, error) {
                                                return Icon(
                                                    Icons.person_pin_outlined,
                                                    color: const Color.fromARGB(
                                                        255, 150, 148, 148));
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
                              ),
                            ),
                          ),
                          if (images.length > 1)
                            Positioned(
                              right: 10,
                              top: 0,
                              bottom: 0,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(images.length, (index) {
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _currentImageIndex == index
                                          ? AppColors.lightGradientColor
                                          : Colors.white.withOpacity(0.5),
                                    ),
                                  );
                                }),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // TOP ROW WITH LOCATION, NAME, AND CONNECT BUTTON
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, top: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // LEFT SIDE: AVATAR, LOCATION AND NAME
                          Expanded(
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage: images.isNotEmpty
                                      ? CachedNetworkImageProvider(images[0])
                                      : null,
                                  child: images.isEmpty
                                      ? Icon(Icons.person, size: 30)
                                      : null,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Location
                                      if (user.city != null &&
                                          user.city!.isNotEmpty)
                                        Row(
                                          children: [
                                            Icon(Icons.location_on,
                                                size: 16,
                                                color: Colors.white70),
                                            SizedBox(width: 4),
                                            Text(
                                              user.city!,
                                              style: AppTextStyles.bodyText
                                                  .copyWith(
                                                color: Colors.white70,
                                                fontSize: size.width * 0.035,
                                              ),
                                            ),
                                          ],
                                        ),
                                      // User Name and Age
                                      Row(
                                        children: [
                                          if (user.accountVerificationStatus ==
                                              '1')
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 8.0),
                                              child: Icon(
                                                Icons.verified,
                                                color: AppColors
                                                    .lightGradientColor,
                                                size: getResponsiveFontSize(
                                                    0.045),
                                              ),
                                            ),
                                          Flexible(
                                            child: Text(
                                              '${user.name ?? 'NA'}, ${calculateAge(user.dob ?? 'Unknown Date')}',
                                              style: AppTextStyles.headingText
                                                  .copyWith(
                                                fontSize: size.width * 0.05,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // RIGHT SIDE: CONNECT BUTTON
                          GestureDetector(
                            onTap: () {
                              showmessageBottomSheet(user.userId.toString());
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: AppColors.reversedGradientColor,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.deepPurple.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Text(
                                "Connect",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: getResponsiveFontSize(0.03),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // DETAILS ROW (Interests, Looking For, Sub Gender)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Interests
                          // if (interests.isNotEmpty)
                          //   Flexible(
                          //     child: Container(
                          //       padding: EdgeInsets.symmetric(
                          //           horizontal: 12, vertical: 6),
                          //       decoration: BoxDecoration(
                          //         color: Colors.white.withOpacity(0.13),
                          //         borderRadius: BorderRadius.circular(10),
                          //       ),
                          //       child: Row(
                          //         mainAxisSize: MainAxisSize.min,
                          //         children: [
                          //           Icon(Icons.tag,
                          //               size: 16, color: Colors.white70),
                          //           SizedBox(width: 6),
                          //           Flexible(
                          //             child: Text(
                          //               interests.length > 1
                          //                   ? '${interests[0]} +${interests.length - 1}'
                          //                   : interests[0],
                          //               style: AppTextStyles.bodyText.copyWith(
                          //                 color: Colors.white,
                          //                 fontSize: size.width * 0.035,
                          //                 fontWeight: FontWeight.w500,
                          //               ),
                          //               maxLines: 1,
                          //               overflow: TextOverflow.ellipsis,
                          //             ),
                          //           ),
                          //         ],
                          //       ),
                          //     ),
                          //   ),
                          // SizedBox(width: 10),
                          // Looking For
                          Flexible(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.13),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.favorite_border,
                                      size: 16, color: Colors.white70),
                                  SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      lookingForText,
                                      style: AppTextStyles.bodyText.copyWith(
                                        color: Colors.white,
                                        fontSize: size.width * 0.035,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          // Sub Gender
                          // Flexible(
                          //   child: Container(
                          //     padding: EdgeInsets.symmetric(
                          //         horizontal: 12, vertical: 6),
                          //     decoration: BoxDecoration(
                          //       color: Colors.white.withOpacity(0.13),
                          //       borderRadius: BorderRadius.circular(10),
                          //     ),
                          //     child: Row(
                          //       mainAxisSize: MainAxisSize.min,
                          //       children: [
                          //         Icon(Icons.person_outline,
                          //             size: 16, color: Colors.white70),
                          //         SizedBox(width: 6),
                          //         Flexible(
                          //           child: Text(
                          //             user.subGenderName ?? 'Unknown',
                          //             style: AppTextStyles.bodyText.copyWith(
                          //               color: Colors.white,
                          //               fontSize: size.width * 0.035,
                          //               fontWeight: FontWeight.w500,
                          //             ),
                          //             maxLines: 1,
                          //             overflow: TextOverflow.ellipsis,
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          // View More
                          Flexible(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.13),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      'View More',
                                      style: AppTextStyles.bodyText.copyWith(
                                        color: Colors.white,
                                        fontSize: size.width * 0.035,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Gender
                          Flexible(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.13),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(FontAwesome.genderless_solid,
                                      size: 16, color: Colors.white70),
                                  SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      "${user.genderName}",
                                      style: AppTextStyles.bodyText.copyWith(
                                        color: Colors.white,
                                        fontSize: size.width * 0.035,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                        ],
                      ),
                    ),

                    // Action Buttons
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Nope Button
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    matchEngine.currentItem?.nope();
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                    color: Colors.white,
                                  ),
                                  padding: EdgeInsets.all(18),
                                  child: Icon(Icons.close_rounded,
                                      color: Colors.black87, size: 36),
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                "Nope",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          // Favourite Button
                          if (selectedFilter.value != 2)
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      matchEngine.currentItem?.superLike();
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 8,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                      color: Colors.white,
                                    ),
                                    padding: EdgeInsets.all(18),
                                    child: Icon(Icons.favorite_rounded,
                                        color: Colors.black87, size: 36),
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "Favourite",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          // Like Button
                          Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    matchEngine.currentItem?.like();
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 8,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                    color: Colors.white,
                                  ),
                                  padding: EdgeInsets.all(18),
                                  child: Icon(Icons.thumb_up_rounded,
                                      color: Colors.black87, size: 36),
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                "Like",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
