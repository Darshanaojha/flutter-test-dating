import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dating_application/Controllers/controller.dart';
import 'package:dating_application/Models/RequestModels/estabish_connection_request_model.dart';
import 'package:dating_application/Models/ResponseModels/ProfileResponse.dart';
import 'package:dating_application/Screens/chatmessagespage/ContactListScreen.dart';
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
  final bool isUnsubscribed;
  const HomePage({super.key, this.isUnsubscribed = false});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  Controller controller = Get.put(Controller());
  double getResponsiveFontSize(double scale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * scale;
  }

  bool _showLikeAnimation = false;
  bool _showDislikeAnimation = false;
  bool _showFavouriteAnimation = false;

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
  bool _isFabMenuOpen = false;
  late AnimationController _animationController;
  late AnimationController _lottieAnimationController;
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
    print("❗ Page opened: initState called");

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _lottieAnimationController = AnimationController(vsync: this);

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
    await controller.fetchProfile();
    await controller.userSuggestions();
    for (int i = 0; i < controller.userSuggestionsList.length; i++) {
      swipeItems.add(_createSwipeItem(controller.userSuggestionsList[i]));
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
      DateTime birthDate = DateFormat('MM/dd/yyyy').parse(dob);
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

  // Update the SwipeItem creation method
  SwipeItem _createSwipeItem(SuggestedUser user) {
    return SwipeItem(
      content: user,
      likeAction: () async {
        if (await checkInteractionAllowed()) {
          setState(() {
            _showLikeAnimation = true;
          });
          if (user.userId != null) {
            print("Pressed like button for user: ${user.name}");
            controller.profileLikeRequest.likedBy = user.userId.toString();
            final response =
                await controller.profileLike(controller.profileLikeRequest);
            if (response != null && response.payload.connection) {
              _showMatchDialog(user);
            }
          } else {
            print("User ID is null");
            failure('Error', "Error: User ID is null.");
          }
        }
      },
      nopeAction: () async {
        if (await checkInteractionAllowed()) {
          setState(() {
            _showDislikeAnimation = true;
          });
          if (user.userId != null) {
            controller.dislikeProfileRequest.id = user.userId.toString();
            controller.dislikeprofile(controller.dislikeProfileRequest);
            print("User ${user.name} was 'nope'd");
          } else {
            print("User ID is null on nope");
          }
        }
      },
      superlikeAction: () async {
        if (await checkInteractionAllowed()) {
          setState(() {
            _showFavouriteAnimation = true;
          });
          if (user.userId != null) {
            controller.markFavouriteRequestModel.favouriteId =
                user.userId.toString();
            print("id ${user.userId}");
            controller.markasfavourite(controller.markFavouriteRequestModel);
          } else {
            failure('Error', "Error: User ID is null.");
          }
        }
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _lottieAnimationController.dispose();
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
              child: CachedNetworkImage(
                imageUrl: imagePath,
                fit: BoxFit.contain,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>
                    Image.asset('assets/images/logo_redefined.png'),
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
    double iconSize = screenWidth * 0.05;
    double buttonWidth = screenWidth * 0.22;
    double buttonHeight = screenHeight * 0.01;

    bool isSelected = selectedFilter.value == button;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.015),
      child: AnimatedScale(
        scale: isSelected ? 1.08 : 1.0,
        duration: Duration(milliseconds: 200),
        child: Container(
          height: screenHeight * 0.05,
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
      swipeItems.add(_createSwipeItem(user));
    }

    matchEngine = MatchEngine(swipeItems: swipeItems);
  }

  void _showMatchDialog(SuggestedUser matchedUser) {
    // Ensure there's user data available for the current user
    if (controller.userData.isEmpty) {
      failure('Error', 'Current user data is not available.');
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MatchDialog(
          currentUser: controller.userData.first,
          matchedUser: matchedUser,
        );
      },
    );
  }

  // Add this method to check before any interaction
  Future<bool> checkInteractionAllowed() async {
    return await controller.canUserInteract(context);
  }

  // Modify your profile loading to limit to 10 for unverified users
  List<UserData> getDisplayProfiles() {
    if (!controller.isVerified) {
      return controller.userData.take(10).toList();
    }
    return controller.userData;
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
                      child:
                          Lottie.asset("assets/animations/LoveIsBlind.json"));
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
                      height: MediaQuery.of(context).size.height * 0.07,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
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
                                debugPrint(
                                    'Favourites : ${controller.favourite.length}');
                              },
                            ),
                            buildFilterButton(context, 0, 'NearBy',
                                FontAwesome.map_location_dot_solid, (value) {
                              setState(() {
                                selectedFilter.value = 0;
                                rebuildSwipeItemsForFilter(0);
                              });
                              debugPrint(
                                  'NearBy : ${controller.userNearByList.length}');
                            }),
                            buildFilterButton(
                                context, 1, 'Highlighted', FontAwesome.star,
                                (value) {
                              setState(() {
                                selectedFilter.value = 1;
                                rebuildSwipeItemsForFilter(1);
                              });
                              debugPrint(
                                  'Highlighted : ${controller.userHighlightedList.length}');
                            }),
                            buildFilterButton(context, 3, 'HookUp',
                                FontAwesome.heart_pulse_solid, (value) {
                              setState(() {
                                selectedFilter.value = 3;
                                rebuildSwipeItemsForFilter(3);
                              });
                              debugPrint(
                                  'HookUp : ${controller.hookUpList.length}');
                            }),
                          ],
                        ),
                      ),
                    ),

                    //  Cards Area - Takes 80% of screen height responsively
                    Expanded(
                      child: Opacity(
                        opacity: _showLikeAnimation ||
                                _showDislikeAnimation ||
                                _showFavouriteAnimation
                            ? 0.0
                            : 1.0,
                        child: Obx(() {
                          final currentList =
                              controller.getCurrentList(selectedFilter.value);

                          return Center(
                            child: FractionallySizedBox(
                              widthFactor: 0.95,
                              heightFactor: 0.98,
                              child: currentList.isEmpty
                                  ? Center(child: Text('No users available.'))
                                  : SwipeCards(
                                      matchEngine: matchEngine,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        if (index >= currentList.length) {
                                          return Center(
                                              child:
                                                  Text("No users available"));
                                        }

                                        final SuggestedUser user =
                                            currentList[index];
                                        isLastCard =
                                            index == currentList.length - 1;

                                        return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            child: GestureDetector(
                                              onTap: widget.isUnsubscribed
                                                  ? () {
                                                      controller
                                                          .showPackagesDialog();
                                                    }
                                                  : null,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: AppColors
                                                        .gradientBackgroundList,
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(32),
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
                                                padding:
                                                    const EdgeInsets.all(2),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: AppColors
                                                          .reversedGradientColor,
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: buildCardLayoutAll(
                                                      context,
                                                      user,
                                                      size,
                                                      isLastCard),
                                                ),
                                              ),
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
                      ),
                    )
                  ],
                );
              },
            ),
            if (_showLikeAnimation)
              Center(
                child: Lottie.asset(
                  'assets/animations/Liked.json',
                  controller: _lottieAnimationController,
                  width: 200,
                  height: 200,
                  repeat: false,
                  onLoaded: (composition) {
                    _lottieAnimationController
                      ..duration = composition.duration
                      ..forward().whenComplete(() {
                        if (mounted) {
                          setState(() {
                            _showLikeAnimation = false;
                          });
                          _lottieAnimationController.reset();
                        }
                      });
                  },
                ),
              ),
            if (_showDislikeAnimation)
              Center(
                child: Lottie.asset(
                  'assets/animations/Disliked.json',
                  controller: _lottieAnimationController,
                  width: 200,
                  height: 200,
                  repeat: false,
                  onLoaded: (composition) {
                    _lottieAnimationController
                      ..duration = composition.duration
                      ..forward().whenComplete(() {
                        if (mounted) {
                          setState(() {
                            _showDislikeAnimation = false;
                          });
                          _lottieAnimationController.reset();
                        }
                      });
                  },
                ),
              ),
            if (_showFavouriteAnimation)
              Center(
                child: Lottie.asset(
                  'assets/animations/Favourite.json',
                  controller: _lottieAnimationController,
                  width: 200,
                  height: 200,
                  repeat: false,
                  onLoaded: (composition) {
                    _lottieAnimationController
                      ..duration = composition.duration
                      ..forward().whenComplete(() {
                        if (mounted) {
                          setState(() {
                            _showFavouriteAnimation = false;
                          });
                          _lottieAnimationController.reset();
                        }
                      });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildCardLayoutAll(
      BuildContext context, SuggestedUser user, Size size, bool isLastCard) {
    List<String> images = user.images;
    String lookingForText = user.lookingFor == "1"
        ? "Serious Relationship, "
        : user.lookingFor == "2"
            ? "Hookup, "
            : "Unknown, ";

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
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.gradientBackgroundList,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  // Profile Image with curved borders
                  SizedBox.expand(
                    child: Stack(
                      children: [
                        PageView.builder(
                          scrollDirection: Axis.vertical,
                          controller: _imagePageController,
                          itemCount: images.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                          itemBuilder: (BuildContext context, int index) {
                            if (images.isEmpty) {
                              return SizedBox(
                                width: size.width * 0.5,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.asset(
                                    'assets/images/logo_redefined.png',
                                    fit: BoxFit.none,
                                  ),
                                ),
                              );
                            }
                            return GestureDetector(
                              onTap: () =>
                                  showFullImageDialog(context, images[index]),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: CachedNetworkImage(
                                  imageUrl: images[index],
                                  placeholder: (context, url) => Center(
                                      child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) {
                                    return Image.asset(
                                        'assets/images/logo_redefined.png',
                                        fit: BoxFit.contain);
                                  },
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                            );
                          },
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
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: size.height * 0.18,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black38,
                            Colors.black54
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Location top-left
                  if (user.city != null && user.city!.isNotEmpty)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 14, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              // "${user.city ?? ''} ${user.distance ?? ''}",
                              user.city ?? '',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Name & Title bottom-left
                  Positioned(
                    left: 16,
                    bottom: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "${user.name ?? 'NA'}, ${calculateAge(user.dob ?? 'Unknown Date')}",
                              style: AppTextStyles.headingText.copyWith(
                                fontSize: size.width * 0.055,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (user.accountVerificationStatus == '1')
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Icon(
                                  Icons.verified,
                                  color: AppColors.lightGradientColor,
                                  size: getResponsiveFontSize(0.045),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              lookingForText,
                              style: AppTextStyles.bodyText.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: size.width * 0.035,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              (user.interest != null &&
                                      user.interest!.isNotEmpty)
                                  ? user.interest!.split(',').first.trim()
                                  : '',
                              style: AppTextStyles.bodyText.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: size.width * 0.035,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          user.genderName ?? 'Not Specified',
                          style: AppTextStyles.bodyText.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: size.width * 0.035,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.13),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'View More',
                            style: AppTextStyles.bodyText.copyWith(
                              color: Colors.white,
                              fontSize: size.width * 0.03,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () {
                        showmessageBottomSheet(user.userId.toString());
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  ),
                  Positioned(
                    bottom: 24,
                    right: 16,
                    child: Column(
                      children: [
                        if (_isFabMenuOpen)
                          Column(
                            children: [
                              FloatingActionButton(
                                backgroundColor: AppColors.darkGradientColor,
                                onPressed: () async {
                                  if (await checkInteractionAllowed()) {
                                    matchEngine.currentItem?.nope();
                                    setState(() {
                                      _isFabMenuOpen = false;
                                    });
                                  }
                                },
                                child: Icon(Icons.close, color: Colors.white),
                              ),
                              SizedBox(height: 12),
                              FloatingActionButton(
                                backgroundColor: AppColors.mediumGradientColor,
                                onPressed: () async {
                                  if (await checkInteractionAllowed()) {
                                    matchEngine.currentItem?.superLike();
                                    setState(() {
                                      _isFabMenuOpen = false;
                                    });
                                  }
                                },
                                child: Icon(Icons.star, color: Colors.white),
                              ),
                              SizedBox(height: 12),
                              FloatingActionButton(
                                backgroundColor: AppColors.lightGradientColor,
                                onPressed: () async {
                                  if (await checkInteractionAllowed()) {
                                    matchEngine.currentItem?.like();
                                    setState(() {
                                      _isFabMenuOpen = false;
                                    });
                                  }
                                },
                                child: Icon(Icons.favorite, color: Colors.red),
                              ),
                              SizedBox(height: 12),
                            ],
                          ),
                        FloatingActionButton(
                          backgroundColor: AppColors.mediumGradientColor,
                          onPressed: () {
                            setState(() {
                              _isFabMenuOpen = !_isFabMenuOpen;
                            });
                          },
                          child: Icon(_isFabMenuOpen
                              ? Icons.check
                              : Icons.keyboard_arrow_up_outlined),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
  }
}

class MatchDialog extends StatelessWidget {
  final UserData currentUser;
  final SuggestedUser matchedUser;

  const MatchDialog({
    super.key,
    required this.currentUser,
    required this.matchedUser,
  });

  @override
  Widget build(BuildContext context) {
    // Auto-close the dialog after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: AppColors.gradientBackgroundList,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/animations/hearth_match_lottie.json',
              height: 100,
              repeat: false,
            ),
            const SizedBox(height: 10),
            Text(
              "It's a Match!",
              style: AppTextStyles.headingText
                  .copyWith(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 10),
            Text(
              "You and ${matchedUser.name} liked each other!",
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyText
                  .copyWith(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // _buildProfileImage(currentUser.images.isNotEmpty ? currentUser.images.first : null),
                // const SizedBox(width: 20),
                _buildProfileImage(matchedUser.images.isNotEmpty
                    ? matchedUser.images.first
                    : null),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                Get.to(() => ContactListScreen());
              },
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text("Chat Now"),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(String? imageUrl) {
    return CircleAvatar(
      radius: 50,
      backgroundColor: Colors.white24,
      backgroundImage:
          imageUrl != null ? CachedNetworkImageProvider(imageUrl) : null,
      child: imageUrl == null
          ? ClipOval(
              child: Image.asset(
                'assets/images/logo_redefined.png',
                fit: BoxFit.contain,
                width: 100,
                height: 100,
              ),
            )
          : null,
    );
  }
}
