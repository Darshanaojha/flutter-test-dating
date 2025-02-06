import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dating_application/Controllers/controller.dart';
import 'package:dating_application/Models/RequestModels/estabish_connection_request_model.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:heart_overlay/heart_overlay.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:swipe_cards/swipe_cards.dart';
import '../../Models/ResponseModels/user_suggestions_response_model.dart';
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
  }

  Future<void> _storeLastUserForAllLists(SuggestedUser suggestedUser) async {
    final preferences = await EncryptedSharedPreferences.getInstance();

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

    // Save the entire map of last users
    await preferences.setString('lastUsersMap', jsonEncode(lastUsersMap));

    print("Saved last users for all lists: $lastUsersMap");
  }

  Future<void> _retrieveLastUsers() async {
    final preferences = await EncryptedSharedPreferences.getInstance();
    String? lastUsersMapString = await preferences.getString('lastUsersMap');

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

  String calculateAge(String dob) {
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
      print('Error parsing date: $e');
      return 'Invalid Date';
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
      int button, String label, IconData icon, Function(String) onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment(0.8, 1),
            colors: <Color>[
              Color(0xff1f005c),
              Color(0xff5b0060),
              Color(0xff870160),
              Color(0xffac255e),
              Color(0xffca485c),
              Color(0xffe16b5c),
              Color(0xfff39060),
              Color(0xffffb56b),
            ],
          ),
          borderRadius: BorderRadius.circular(
              30), // You can adjust the border radius here
        ),
        child: ElevatedButton.icon(
          onPressed: () {
            setState(() {
              selectedFilter.value = button;
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
                  size: 30,
                  color: AppColors.textColor,
                ),
              );
            },
          ),
          label: Text(
            label,
            style: TextStyle(fontSize: 10, color: AppColors.textColor),
          ),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors
                .transparent, // Set to transparent since the gradient is applied on Container
            shape: StadiumBorder(),
            minimumSize: Size(100, 45),
          ),
        ),
      ),
    );
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
                      height: 80,
                      padding: EdgeInsets.all(8),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            buildFilterButton(0, 'NearBy', Icons.location_on,
                                (value) {
                              setState(() {
                                selectedFilter.value = 0;
                              });
                              Get.snackbar('NearBy',
                                  controller.userNearByList.length.toString());
                            }),
                            buildFilterButton(1, 'Highlighted', Icons.star,
                                (value) {
                              setState(() {
                                selectedFilter.value = 1;
                              });
                              Get.snackbar(
                                  'Highlighted',
                                  controller.userHighlightedList.length
                                      .toString());
                            }),
                            buildFilterButton(2, 'Favourite', Icons.favorite,
                                (value) {
                              setState(() {
                                selectedFilter.value = 2;
                              });
                              Get.snackbar('userfavourite',
                                  controller.favourite.length.toString());
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
                                            SuggestedUser user = controller
                                                .userNearByList[index];
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
                                                    ? const Color.fromARGB(
                                                        255, 16, 16, 16)
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(32),
                                                border: Border.all(
                                                  color: isLastCard
                                                      ? const Color.fromARGB(
                                                          255, 24, 24, 24)
                                                      : const Color.fromARGB(
                                                          255, 149, 151, 152),
                                                  width: 1,
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
    List<String> images = user.images;

    return user.id == ''
        ? Text("No users available")
        : Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment(0.8, 1),
                colors: <Color>[
                  Color(0xff1f005c),
                  Color(0xff5b0060),
                  Color(0xff870160),
                  Color(0xffac255e),
                  Color(0xffca485c),
                  Color(0xffe16b5c),
                  Color(0xfff39060),
                  Color(0xffffb56b),
                ],
              ),
              borderRadius: BorderRadius.circular(
                  30), // You can adjust the border radius here
            ),
            // alignment: Alignment.center,
            // decoration: BoxDecoration(
            //   color: Colors.black,
            //   borderRadius: BorderRadius.circular(15),
            // ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: size.height * 0.4,
                  child: Stack(
                    children: [
                      SafeArea(
                        child: SizedBox(
                          height: 400,
                          child: Scrollbar(
                            child: ListView.builder(
                              controller: _imagePageController,
                              itemCount: user.images.length,
                              itemBuilder: (BuildContext context, int index) {
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
                                      borderRadius: BorderRadius.circular(15),
                                      child: CachedNetworkImage(
                                        imageUrl: images[index],
                                        placeholder: (context, url) => Center(
                                            child: CircularProgressIndicator()),
                                        errorWidget: (context, url, error) {
                                          print(
                                              "Failed to load image from URL: $url");
                                          return Icon(Icons.person_pin_outlined,
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
                Row(
                  children: [
                    SizedBox(width: 12),
                    IconButton(
                      onPressed: lastUser != null
                          ? null
                          : () {
                              showmessageBottomSheet(user.userId.toString());
                            },
                      icon: Icon(Icons.messenger_outline, size: 30),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    user.name ?? 'NA',
                    style: TextStyle(
                        fontSize: size.width * 0.03,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Text(
                        calculateAge(user.dob ?? 'Unknown Date'),
                        style: TextStyle(fontSize: size.width * 0.03),
                      ),
                      Text(
                        '${user.city}',
                        style: TextStyle(fontSize: size.width * 0.03),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 28,
                              offset: Offset(2, 14),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                matchEngine.currentItem?.nope();
                              });
                              print("button pressed nope");
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/images/dislike.png',
                                  height: 60,
                                  width: 60,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Nope",
                                  style: AppTextStyles.buttonText.copyWith(
                                    fontSize: getResponsiveFontSize(0.015),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.transparent.withOpacity(0.5),
                              blurRadius: 28,
                              offset: Offset(2, 14),
                            ),
                          ],
                        ),
                        child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  matchEngine.currentItem?.superLike();
                                });
                                print("button pressed super like");
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/images/heart.png',
                                    height: 60,
                                    width: 60,
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "Favourite",
                                    style: AppTextStyles.buttonText.copyWith(
                                      fontSize: getResponsiveFontSize(0.015),
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 28,
                              offset: Offset(2, 14),
                            ),
                          ],
                        ),
                        child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  matchEngine.currentItem?.like();
                                });
                                print("button pressed like");
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/images/like.png',
                                    height: 60,
                                    width: 60,
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "Like",
                                    style: TextStyle(
                                      fontSize: getResponsiveFontSize(0.015),
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
