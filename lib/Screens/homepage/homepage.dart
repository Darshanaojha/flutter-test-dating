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
  int MessageType = 1;
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  final TextEditingController messageController = TextEditingController();
  final FocusNode messageFocusNode = FocusNode();
  final PageController _imagePageController = PageController();
  List<SwipeItem> swipeItems = [];
  late MatchEngine matchEngine;
  late Future<bool> _fetchSuggestion;
  late HeartOverlayController heartOverlayController;
  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * 3.1415927).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    heartOverlayController = HeartOverlayController();
    super.initState();
    matchEngine = MatchEngine();

    _fetchSuggestion = initializeApp();
    initialize();
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
      SuggestedUser lastUserNearby =
          controller.getCurrentList(0).last as SuggestedUser;
      lastUsersMap['nearBy'] = jsonEncode(lastUserNearby.toJson());
    }

    // Save last user for 'highlighted' list
    if (controller.getCurrentList(1).isNotEmpty) {
      SuggestedUser lastUserHighlighted =
          controller.getCurrentList(1).last as SuggestedUser;
      lastUsersMap['highlighted'] = jsonEncode(lastUserHighlighted.toJson());
    }

    // Save last user for 'favourite' list
    if (controller.getCurrentList(2).isNotEmpty) {
      SuggestedUser lastUserFavourite =
          controller.getCurrentList(2).last as SuggestedUser;
      lastUsersMap['favourite'] = jsonEncode(lastUserFavourite.toJson());
    }

    // Save last user for 'hookup' list
    if (controller.getCurrentList(3).isNotEmpty) {
      SuggestedUser lastUserHookUp =
          controller.getCurrentList(3).last as SuggestedUser;
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
        likeAction: () {
          matchEngine = MatchEngine(swipeItems: swipeItems);
          if (controller.userSuggestionsList[i].userId != null) {
            print(
                "Pressed like button for user: ${controller.userSuggestionsList[i].name}");
            setState(() {
              controller.profileLikeRequest.likedBy =
                  controller.userSuggestionsList[i].userId.toString();
            });
            controller.profileLike(controller.profileLikeRequest);
          } else {
            print("User ID is null");
            failure('Error', "Error: User ID is null.");
          }
        },
        nopeAction: () {
          print(
              "Pressed dislike button for user: ${controller.userSuggestionsList[i].name}");
          matchEngine = MatchEngine(swipeItems: swipeItems);
          setState(() {
            controller.dislikeProfileRequest.id =
                controller.userSuggestionsList[i].id.toString();
          });
          controller.dislikeprofile(controller.dislikeProfileRequest);
          print("User ${controller.userSuggestionsList[i].name} was 'nope'd");
        },
        superlikeAction: () {
          matchEngine = MatchEngine(swipeItems: swipeItems);
          if (controller.userSuggestionsList[i].userId != null) {
            controller.markFavouriteRequestModel.favouriteId =
                controller.userSuggestionsList[i].userId;
            controller.markasfavourite(controller.markFavouriteRequestModel);
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
      return '$age Years Old';
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

  Widget buildFilterButton(
    BuildContext context,
    int button,
    String label,
    IconData icon,
    Function(String) onTap,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double fontSize = screenWidth * 0.025; // Example: 25 for 1000px width
    double iconSize = screenWidth * 0.06; // Example: 60 for 1000px width
    double buttonWidth = screenWidth * 0.22; // 22% of screen
    double buttonHeight = screenHeight * 0.06; // 6% of screen height

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.015),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment(0.8, 1),
            colors: AppColors.gradientBackgroundList,
          ),
          borderRadius: BorderRadius.circular(30),
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
                angle: selectedFilter.value == button
                    ? _rotationAnimation.value
                    : 0,
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
            style: TextStyle(fontSize: fontSize, color: AppColors.textColor),
          ),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.transparent,
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
    );
  }

  void rebuildSwipeItemsForFilter(int filterIndex) {
    swipeItems.clear();
    List<SuggestedUser> currentList =
        controller.getCurrentList(filterIndex).cast<SuggestedUser>();
    for (var user in currentList) {
      swipeItems.add(SwipeItem(
        content: user, // <-- This must be the full SuggestedUser object!
        likeAction: () {
          matchEngine = MatchEngine(swipeItems: swipeItems);
          if (user.userId != null) {
            print("Pressed like button for user: ${user.name}");
            setState(() {
              controller.profileLikeRequest.likedBy = user.userId.toString();
            });
            controller.profileLike(controller.profileLikeRequest);
          } else {
            print("User ID is null");
            failure('Error', "Error: User ID is null.");
          }
        },
        nopeAction: () {
          print("Pressed dislike button for user: ${user.name}");
          matchEngine = MatchEngine(swipeItems: swipeItems);
          setState(() {
            controller.dislikeProfileRequest.id = user.id.toString();
          });
          controller.dislikeprofile(controller.dislikeProfileRequest);
          print("User ${user.name} was 'nope'd");
        },
        superlikeAction: () {
          matchEngine = MatchEngine(swipeItems: swipeItems);
          if (user.userId != null) {
            controller.markFavouriteRequestModel.favouriteId = user.userId;
            controller.markasfavourite(controller.markFavouriteRequestModel);
          } else {
            failure('Error', "Error: User ID is null.");
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
                          "assets/animations/handloadinganimation.json"));
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
                                rebuildSwipeItemsForFilter(-1);
                              });
                            }),
                            buildFilterButton(
                                context, 2, 'Favourite', FontAwesome.heart,
                                (value) {
                              setState(() {
                                selectedFilter.value = 2;
                              });
                              Get.snackbar('User Favourite',
                                  controller.favourite.length.toString());
                            }),
                            buildFilterButton(context, 0, 'NearBy',
                                FontAwesome.map_location_dot_solid, (value) {
                              setState(() {
                                selectedFilter.value = 0;
                              });
                              Get.snackbar('NearBy',
                                  controller.userNearByList.length.toString());
                            }),
                            buildFilterButton(
                                context, 1, 'Highlighted', FontAwesome.star,
                                (value) {
                              setState(() {
                                selectedFilter.value = 1;
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
                              });
                              Get.snackbar('HookUp',
                                  controller.hookUpList.length.toString());
                            }),
                          ],
                        ),
                      ),
                    ),
                    selectedFilter.value == 0
                        ? SafeArea(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: size.height * 0.7 -
                                      MediaQuery.of(context).viewInsets.bottom,
                                  child: controller
                                              .getCurrentList(
                                                  selectedFilter.value)
                                              .isEmpty &&
                                          lastUser != null
                                      ? buildCardLayoutAll(
                                          context, lastUser!, size, isLastCard)
                                      : SwipeCards(
                                          matchEngine: matchEngine,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            final size =
                                                MediaQuery.of(context).size;
                                            final filterIndex = selectedFilter
                                                .value; // Use your filter state
                                            final List<SuggestedUser>
                                                currentList =
                                                controller.getListByFilter(
                                                    filterIndex);

                                            if (currentList.isEmpty ||
                                                index >= currentList.length) {
                                              return Center(
                                                  child: Text(
                                                      "No users available"));
                                            }
                                            final user = currentList[index];

                                            return Container(
                                              alignment: Alignment.center,
                                              color: Colors.white,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(user.name ?? "No Name",
                                                      style: TextStyle(
                                                          fontSize: 24)),
                                                  Text(getAgeFromDob(user.dob),
                                                      style: TextStyle(
                                                          fontSize: 16)),
                                                  Text(user.city ?? "No City"),
                                                  // Add more user info as needed
                                                ],
                                              ),
                                            );
                                          },
                                          upSwipeAllowed: true,
                                          leftSwipeAllowed: true,
                                          rightSwipeAllowed: true,
                                          fillSpace: true,
                                          onStackFinished: () async {
                                            isSwipeFinished = true;
                                            if (controller
                                                .getCurrentList(
                                                    selectedFilter.value)
                                                .isNotEmpty) {
                                              lastUser = controller
                                                  .getCurrentList(
                                                      selectedFilter.value)
                                                  .last as SuggestedUser?;
                                              await _storeLastUserForAllLists(
                                                  lastUser!);
                                            }
                                            failure(
                                                'Finished', "Stack Finished");
                                          },
                                          itemChanged:
                                              (SwipeItem item, int index) {
                                            print(
                                                "Item: ${item.content}, Index: $index");
                                          },
                                        ),
                                ),
                              ],
                            ),
                          )
                        : selectedFilter.value == 1
                            ? SafeArea(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: size.height * 0.7 -
                                          MediaQuery.of(context)
                                              .viewInsets
                                              .bottom,
                                      child: controller
                                                  .getCurrentList(
                                                      selectedFilter.value)
                                                  .isEmpty &&
                                              lastUser != null
                                          ? buildCardLayoutAll(context,
                                              lastUser!, size, isLastCard)
                                          : SwipeCards(
                                              matchEngine: matchEngine,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                print("index is $index");
                                                SuggestedUser user = controller
                                                            .userHighlightedList
                                                            .isEmpty ||
                                                        index >=
                                                            controller
                                                                .userHighlightedList
                                                                .length
                                                    ? SuggestedUser()
                                                    : controller
                                                            .userHighlightedList[
                                                        index];

                                                print(user.toJson().toString());
                                                isLastCard = index ==
                                                    controller
                                                            .getCurrentList(
                                                                selectedFilter
                                                                    .value)
                                                            .length -
                                                        1;

                                                return Container(
                                                  decoration: BoxDecoration(
                                                    color: isLastCard
                                                        ? Colors.grey[300]
                                                        : const Color.fromARGB(
                                                            255, 109, 79, 197),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            32),
                                                    border: Border.all(
                                                      color: isLastCard
                                                          ? Colors.grey
                                                          : const Color
                                                              .fromARGB(
                                                              255, 1, 76, 151),
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
                                                  child: buildCardLayoutAll(
                                                    context,
                                                    user,
                                                    size,
                                                    isLastCard,
                                                  ),
                                                );
                                              },
                                              upSwipeAllowed: true,
                                              leftSwipeAllowed: true,
                                              rightSwipeAllowed: true,
                                              fillSpace: true,
                                              onStackFinished: () async {
                                                isSwipeFinished = true;
                                                if (controller
                                                    .getCurrentList(
                                                        selectedFilter.value)
                                                    .isNotEmpty) {
                                                  lastUser = controller
                                                      .getCurrentList(
                                                          selectedFilter.value)
                                                      .last as SuggestedUser?;
                                                  await _storeLastUserForAllLists(
                                                      lastUser!);
                                                }
                                                failure('Finished',
                                                    "Stack Finished");
                                              },
                                              itemChanged:
                                                  (SwipeItem item, int index) {
                                                print(
                                                    "Item: ${item.content}, Index: $index");
                                              },
                                            ),
                                    ),
                                  ],
                                ),
                              )
                            : SafeArea(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: size.height * 0.7 -
                                          MediaQuery.of(context)
                                              .viewInsets
                                              .bottom,
                                      child: controller
                                                  .getCurrentList(
                                                      selectedFilter.value)
                                                  .isEmpty &&
                                              lastUser != null
                                          ? buildCardLayoutAll(context,
                                              lastUser!, size, isLastCard)
                                          : SwipeCards(
                                              matchEngine: matchEngine,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                SuggestedUser user = controller
                                                        .favourite.isEmpty
                                                    ? SuggestedUser()
                                                    : controller
                                                        .convertFavouriteToSuggestedUser(
                                                            controller
                                                                    .favourite[
                                                                index]);
                                                //    if (controller
                                                //         .favourite.isNotEmpty &&
                                                //     index <
                                                //         controller
                                                //             .favourite.length) {
                                                //   SuggestedUser user = controller
                                                //           .favourite.isEmpty
                                                //       ? SuggestedUser()
                                                // : controller
                                                //     .convertFavouriteToSuggestedUser(
                                                //         controller
                                                //                 .favourite[
                                                //             index]);
                                                // } else {
                                                //   return Center(
                                                //       child: Text(
                                                //     "No Favourites Available",
                                                //     style: AppTextStyles
                                                //         .buttonText,
                                                //   ));
                                                // }

                                                isLastCard = index ==
                                                    controller
                                                            .getCurrentList(
                                                                selectedFilter
                                                                    .value)
                                                            .length -
                                                        1;

                                                return Container(
                                                  decoration: BoxDecoration(
                                                    color: isLastCard
                                                        ? Colors.grey[300]
                                                        : const Color.fromARGB(
                                                            255, 109, 79, 197),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            32),
                                                    border: Border.all(
                                                      color: isLastCard
                                                          ? Colors.grey
                                                          : const Color
                                                              .fromARGB(
                                                              255, 1, 76, 151),
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
                                                  child: buildCardLayoutAll(
                                                    context,
                                                    user,
                                                    size,
                                                    isLastCard,
                                                  ),
                                                );
                                              },
                                              upSwipeAllowed: true,
                                              leftSwipeAllowed: true,
                                              rightSwipeAllowed: true,
                                              fillSpace: true,
                                              onStackFinished: () async {
                                                isSwipeFinished = true;
                                                if (controller
                                                    .getCurrentList(
                                                        selectedFilter.value)
                                                    .isNotEmpty) {
                                                  lastUser = controller
                                                      .getCurrentList(
                                                          selectedFilter.value)
                                                      .last as SuggestedUser?;
                                                  await _storeLastUserForAllLists(
                                                      lastUser!);
                                                }
                                                failure('Finished',
                                                    "Stack Finished");
                                              },
                                              itemChanged:
                                                  (SwipeItem item, int index) {
                                                print(
                                                    "Item: ${item.content}, Index: $index");
                                              },
                                            ),
                                    ),
                                  ],
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

  Widget buildCardLayoutAll(
      BuildContext context, SuggestedUser user, Size size, bool isLastCard) {
    print(user);
    List<String> images = user.images;
    List<String> interests = (user.interest ?? '')
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return user.id == ''
        ? Text("No users available")
        : Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment(0.8, 1),
                colors: AppColors.gradientBackgroundList,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.only(bottom: 20.0), // to avoid clipping
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Images
                    SizedBox(
                      height: size.height * 0.35,
                      child: Stack(
                        children: [
                          SafeArea(
                            child: SizedBox(
                              height: 450,
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
                                              BorderRadius.circular(15),
                                          child: CachedNetworkImage(
                                            imageUrl: images[index],
                                            placeholder: (context, url) => Center(
                                                child:
                                                    CircularProgressIndicator()),
                                            errorWidget: (context, url, error) {
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
                        ],
                      ),
                    ),
                    SizedBox(height: size.height * 0.04),
                    // User Name, Age, City
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.name ?? 'NA',
                              style: AppTextStyles.headingText.copyWith(
                                fontSize: size.width * 0.05,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (user.city != null && user.city!.isNotEmpty)
                            Row(
                              children: [
                                Icon(Icons.location_on,
                                    color: Colors.white70, size: 18),
                                SizedBox(width: 4),
                                Text(
                                  user.city!,
                                  style: AppTextStyles.bodyText.copyWith(
                                    color: Colors.white70,
                                    fontSize: size.width * 0.035,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 4),
                      child: Row(
                        children: [
                          Text(
                            calculateAge(user.dob ?? 'Unknown Date'),
                            style: AppTextStyles.bodyText.copyWith(
                              color: Colors.white,
                              fontSize: size.width * 0.04,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Interests
                    if (interests.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: interests
                              .take(4)
                              .map((interest) => Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.13),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.white24),
                                    ),
                                    child: Text(
                                      interest,
                                      style: AppTextStyles.bodyText.copyWith(
                                        color: Colors.white,
                                        fontSize: size.width * 0.032,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    // Action Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30.0),
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
                    // Connect Button
                    GestureDetector(
                      onTap: () {
                        showmessageBottomSheet(user.userId.toString());
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: AppColors.reversedGradientColor,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.deepPurple.withOpacity(0.2),
                                blurRadius: 12,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 28, vertical: 14),
                          child: Text(
                            "Connect",
                            style: AppTextStyles.buttonText.copyWith(
                              color: Colors.white,
                              fontSize: getResponsiveFontSize(0.03),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
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
