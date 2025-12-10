import 'dart:async';
import 'dart:convert';
import 'dart:math';

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
import 'package:dating_application/Widgets/refresh_wrapper.dart';
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

/// Particle class for confetti effects
class Particle {
  double x;
  double y;
  final double vx;
  final double vy;
  final Color color;
  final IconData icon;
  final double size;
  double opacity;
  double rotation;
  final double rotationSpeed;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.icon,
    required this.size,
    this.opacity = 1.0,
    this.rotation = 0.0,
    required this.rotationSpeed,
  });

    void update() {
      x += vx;
      y += vy;
      rotation += rotationSpeed;
      // Faster fade for snappier feel
      opacity = (opacity - 0.025).clamp(0.0, 1.0);
    }
}

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
  List<Particle> _particles = [];
  Timer? _particleTimer;
  bool _showFlash = false;
  Color _flashColor = Colors.transparent;
  double _flashOpacity = 0.0;

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
          _createParticles('like');
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
          _createParticles('dislike');
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
          _createParticles('superlike');
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
    _particleTimer?.cancel();
    _animationController.dispose();
    _lottieAnimationController.dispose();
    messageFocusNode.dispose();
    messageController.dispose();
    _imagePageController.dispose();

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
              child: _isBase64Image(imagePath)
                  ? Builder(
                      builder: (context) {
                        try {
                          return Image.memory(
                            base64Decode(_normalizeBase64(imagePath)),
                            fit: BoxFit.contain,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                            errorBuilder: (context, error, stackTrace) {
                              print(
                                  'Base64 image decode error in full dialog: $error');
                              return Image.asset(
                                  'assets/images/cajed_logo.png');
                            },
                          );
                        } catch (e) {
                          print(
                              'Error decoding base64 in full image dialog: $e');
                          return Image.asset('assets/images/cajed_logo.png');
                        }
                      },
                    )
                  : Builder(
      builder: (context) {
                        try {
                          return CachedNetworkImage(
                            imageUrl: imagePath,
                            fit: BoxFit.contain,
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFCCB3F2),
                              ),
                            ),
                            errorWidget: (context, url, error) {
                              print(
                                  'Full image dialog CachedNetworkImage error for $url: $error');
                              return Image.asset(
                                  'assets/images/cajed_logo.png');
                            },
                            httpHeaders: {
                              'Accept': 'image/*',
                            },
                          );
                        } catch (e) {
                          print(
                              'Error loading network image in full dialog: $e');
                          return Image.asset('assets/images/cajed_logo.png');
                        }
                      },
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
                  bool messageSent = await controller
                      .sendConnectionMessage(establishConnectionMessageRequest);
                  if (messageSent) {
                    // Additional success feedback - the controller already shows success snackbar
                    // but we can close the bottom sheet here if it's still open
                    if (Get.isBottomSheetOpen ?? false) {
                    Get.back();
                    }
                  }
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
      body: RefreshWrapper(
        onRefresh: initializeApp,
        child: SafeArea(
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
                              buildFilterButton(
                                  context, -1, 'All', Icons.people, (value) {
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
                                              padding:
                                                  const EdgeInsets.symmetric(
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
                                                      end:
                                                          Alignment.bottomRight,
                                                    ),
                                              borderRadius:
                                                        BorderRadius.circular(
                                                            24),
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
                                                      const EdgeInsets.all(4.0),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: AppColors
                                                            .reversedGradientColor,
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              24),
                                                    ),
                                                    child: buildCardLayoutAll(
                                                        context,
                                                        user,
                                                        size,
                                                        isLastCard),
                                                  ),
                                            ),
                                          ),
                                        );
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
                                        itemChanged:
                                            (SwipeItem item, int index) {
                                          print(
                                              "Item: ${item.content}, Index: $index");
                                        },
                                      ),
                            ),
                          );
                        }),
                      ),
                    ],
                  );
                },
              ),
              // Confetti-style particle effects (Option 2)
              ..._particles.map((particle) => _buildParticle(particle)).toList(),
              // Screen flash overlay
              if (_showFlash)
                Positioned.fill(
                  child: AnimatedOpacity(
                    opacity: _flashOpacity,
                    duration: Duration(milliseconds: 300),
                    child: Container(
                      color: _flashColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Create particles based on swipe type
  void _createParticles(String type) {
    _particles.clear();
    final screenSize = MediaQuery.of(context).size;
    final centerX = screenSize.width / 2;
    final centerY = screenSize.height / 2;
    final random = Random(DateTime.now().millisecondsSinceEpoch);

    List<Color> colors;
    IconData icon;
    int particleCount = 50; // Increased count

    if (type == 'like') {
      // Pink/red hearts for like - burst in all directions
      colors = [
        Colors.pink.shade400,
        Colors.red.shade300,
        Color(0xFFEFB6C8), // Light pink
        Colors.pink.shade300,
        Colors.red.shade200,
        Colors.pink.shade200,
      ];
      icon = Icons.favorite;
      particleCount = 50;
      _flashColor = Colors.pink.withOpacity(0.3);
    } else if (type == 'dislike') {
      // Grey/dark colors for "passed" - clearly negative/rejection indication
      colors = [
        Colors.grey.shade700,
        Colors.grey.shade600,
        Colors.grey.shade800,
        Colors.grey.shade500,
        Colors.black87,
        Colors.grey.shade900,
      ];
      icon = Icons.close; // X mark for clear "passed" indication
      particleCount = 50;
      _flashColor = Colors.black.withOpacity(0.2);
    } else {
      // Sparkles and stars for super like - very different from like, burst upward with sparkle effect
      colors = [
        Colors.amber.shade400,
        Colors.yellow.shade300,
        Colors.amber.shade300,
        Colors.yellow.shade200,
        Colors.orange.shade300,
        Colors.amber.shade200,
      ];
      icon = Icons.auto_awesome; // Sparkle icon - very different from hearts
      particleCount = 60; // More particles for sparkle effect
      _flashColor = Colors.amber.withOpacity(0.3);
    }
    
    for (int i = 0; i < particleCount; i++) {
      double angle;
      if (type == 'like') {
        // Burst in all directions with some randomness
        angle = (i / particleCount) * 2 * pi + (random.nextDouble() - 0.5) * 0.3;
      } else if (type == 'dislike') {
        // Burst from center in all directions (changed from left-only)
        angle = (i / particleCount) * 2 * pi + (random.nextDouble() - 0.5) * 0.4;
      } else {
        // Burst upward with wider spread for sparkle effect
        angle = -pi / 2 + (random.nextDouble() - 0.5) * 1.2; // Wider spread
      }

      // Much faster speed - 10-18 pixels per frame
      final speed = 10.0 + random.nextDouble() * 8.0;
      final vx = speed * cos(angle);
      final vy = speed * sin(angle);

      // Icon selection based on type
      IconData particleIcon = icon;
      if (type == 'dislike') {
        // Mix X marks, broken hearts, and thumbs down for clear "passed" indication
        final iconChoice = random.nextDouble();
        if (iconChoice > 0.66) {
          particleIcon = Icons.heart_broken; // Broken heart
        } else if (iconChoice > 0.33) {
          particleIcon = Icons.thumb_down; // Thumbs down
        }
        // Otherwise use X mark (icon)
      } else if (type == 'superlike') {
        // Mix sparkles and stars for super like
        if (random.nextDouble() > 0.4) {
          particleIcon = Icons.star; // Star for some particles
        }
      }
      
      _particles.add(Particle(
        x: centerX + (random.nextDouble() - 0.5) * 30,
        y: centerY + (random.nextDouble() - 0.5) * 30,
        vx: vx,
        vy: vy,
        color: colors[random.nextInt(colors.length)],
        icon: particleIcon,
        size: 18.0 + random.nextDouble() * 16.0, // 18-34px range
        rotationSpeed: (random.nextDouble() - 0.5) * 0.35, // Faster rotation
      ));
    }

    // Show flash after particles start (after 200ms)
    Timer(Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _showFlash = true;
          _flashOpacity = 1.0;
        });
        // Fade out flash
        Timer(Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() {
              _flashOpacity = 0.0;
            });
            Timer(Duration(milliseconds: 200), () {
              if (mounted) {
                setState(() {
                  _showFlash = false;
                });
              }
            });
          }
        });
      }
    });

    // Animate particles
    _particleTimer?.cancel();
    _particleTimer = Timer.periodic(Duration(milliseconds: 16), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      bool hasVisibleParticles = false;
      for (var particle in _particles) {
        particle.update();
        if (particle.opacity > 0) {
          hasVisibleParticles = true;
        }
      }

      if (mounted) {
        setState(() {});
      }

      if (!hasVisibleParticles) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _particles.clear();
            _showLikeAnimation = false;
            _showDislikeAnimation = false;
            _showFavouriteAnimation = false;
          });
        }
      }
    });
  }

  /// Build individual particle widget
  Widget _buildParticle(Particle particle) {
    return Positioned(
      left: particle.x - particle.size / 2,
      top: particle.y - particle.size / 2,
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: particle.opacity,
          duration: Duration(milliseconds: 100),
          child: Transform.rotate(
            angle: particle.rotation,
            child: Container(
              width: particle.size,
              height: particle.size,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    particle.color.withOpacity(1.0),
                    particle.color.withOpacity(0.6),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: particle.color.withOpacity(0.8),
                    blurRadius: 12,
                    spreadRadius: 3,
                  ),
                  BoxShadow(
                    color: particle.color.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                particle.icon,
                color: Colors.white,
                size: particle.size * 0.65,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Helper function to check if a string is a base64 image
  bool _isBase64Image(String? image) {
    if (image == null || image.isEmpty) return false;
    // Base64 images typically start with "data:image" or are long base64 strings
    return image.startsWith('data:image') ||
        (image.length > 100 && !image.startsWith('http'));
  }

  /// Helper function to normalize base64 string (add padding if needed)
  String _normalizeBase64(String base64) {
    // Remove data URL prefix if present
    String clean = base64.contains(',') ? base64.split(',')[1] : base64;
    // Remove whitespace
    clean = clean.trim();
    // Add padding if needed (base64 strings should be divisible by 4)
    int remainder = clean.length % 4;
    if (remainder != 0) {
      clean += '=' * (4 - remainder);
    }
    return clean;
  }

  /// Sort images: base64 images first, then URLs, maintaining order within each group
  List<String> _sortImages(List<String> images, {String? profileImage}) {
    if (images.isEmpty) return images;

    List<String> sortedImages = List.from(images);

    // Option 1: Sort by type - base64 first, then URLs
    sortedImages.sort((a, b) {
      bool aIsBase64 = _isBase64Image(a);
      bool bIsBase64 = _isBase64Image(b);

      if (aIsBase64 && !bIsBase64) return -1; // base64 comes first
      if (!aIsBase64 && bIsBase64) return 1; // URLs come after
      return 0; // maintain original order within same type
    });

    // Option 2: If profile image exists and is in the list, move it to first position
    if (profileImage != null && profileImage.isNotEmpty) {
      if (sortedImages.contains(profileImage)) {
        sortedImages.remove(profileImage);
        sortedImages.insert(0, profileImage);
      } else if (_isBase64Image(profileImage) ||
          profileImage.startsWith('http')) {
        // If profile image is not in the list but is valid, add it first
        sortedImages.insert(0, profileImage);
      }
    }

    return sortedImages;
  }

  Widget buildCardLayoutAll(
      BuildContext context, SuggestedUser user, Size size, bool isLastCard) {
    // Sort images: base64 first, then URLs, with profile image at the beginning
    List<String> images =
        _sortImages(user.images, profileImage: user.profileImage);
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
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    'assets/images/cajed_logo.png',
                                    fit: BoxFit.none,
                                  ),
                                ),
                              );
                            }
                            return GestureDetector(
                              onTap: () =>
                                  showFullImageDialog(context, images[index]),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: _isBase64Image(images[index])
                                    ? Image.memory(
                                        base64Decode(
                                            _normalizeBase64(images[index])),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Image.asset(
                                              'assets/images/cajed_logo.png',
                                              fit: BoxFit.contain);
                                        },
                                      )
                                    : Builder(
                                        builder: (context) {
                                          try {
                                            return CachedNetworkImage(
                                              imageUrl: images[index],
                                              placeholder: (context, url) =>
                                                  Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                color: Color(0xFFCCB3F2),
                                              )),
                                              errorWidget:
                                                  (context, url, error) {
                                                print(
                                                    'CachedNetworkImage error for $url: $error');
                                                return Image.asset(
                                                    'assets/images/cajed_logo.png',
                                                    fit: BoxFit.contain);
                                              },
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                              httpHeaders: {
                                                'Accept': 'image/*',
                                              },
                                            );
                                          } catch (e) {
                                            print(
                                                'Error loading network image: $e');
                                            return Image.asset(
                                                'assets/images/cajed_logo.png',
                                                fit: BoxFit.contain);
                                          }
                                        },
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
    if (imageUrl == null || imageUrl.isEmpty) {
      return CircleAvatar(
        radius: 50,
        backgroundColor: Colors.white24,
        child: ClipOval(
          child: Image.asset(
            'assets/images/cajed_logo.png',
            fit: BoxFit.contain,
            width: 100,
            height: 100,
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: 50,
      backgroundColor: Colors.white24,
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          placeholder: (context, url) => Center(
            child: CircularProgressIndicator(
              color: Color(0xFFCCB3F2),
            ),
          ),
          errorWidget: (context, url, error) {
            print('Profile image error for $url: $error');
            return Image.asset(
              'assets/images/cajed_logo.png',
              fit: BoxFit.contain,
              width: 100,
              height: 100,
            );
          },
          fit: BoxFit.cover,
          width: 100,
          height: 100,
          httpHeaders: {
            'Accept': 'image/*',
          },
        ),
      ),
    );
  }
}
