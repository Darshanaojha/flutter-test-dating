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
import 'package:swipe_cards/draggable_card.dart';
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

  Future<void> _storeLastUser(SuggestedUser lastUser) async {
    final preferences = await EncryptedSharedPreferences.getInstance();
    String lastUserString = jsonEncode(lastUser.toJson());
    await preferences.setString('last user', lastUserString);
    print("Saved last user: $lastUserString");
    // Get.snackbar("Last user saved", lastUser.name.toString());
  }

  Future<void> _retrieveLastUser() async {
    final preferences = await EncryptedSharedPreferences.getInstance();
    String? lastUserString = await preferences.getString('last user');
    // Get.snackbar("Stored lastUser", lastUserString ?? "No data found");

    if (lastUserString != null) {
      Map<String, dynamic> lastUserMap = jsonDecode(lastUserString);
      setState(() {
        lastUser = SuggestedUser.fromJson(lastUserMap);
      });
      // Get.snackbar("Last user retrieved", lastUser!.name.toString());
      print("Last User retrieved: ${lastUser!.name}");
    } else {
      print('No last user found');
      // Get.snackbar("No User", 'No last user found');
    }
  }

  Future<bool> initializeApp() async {
    await _retrieveLastUser();

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
              angle:
                  selectedFilter.value == button ? _rotationAnimation.value : 0,
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
          backgroundColor: selectedFilter.value == button
              ? AppColors.activeColor
              : AppColors.buttonColor,
          shape: StadiumBorder(),
          minimumSize: Size(100, 45),
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
                      // child: SpinKitCircle(
                      //   size: 150.0,
                      //   color: Colors.blue,
                      // ),
                      // assets/animations/homeanimation.json
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
                            buildFilterButton(0, 'All', Icons.all_inclusive,
                                (value) {
                              setState(() {
                                selectedFilter.value = 0;
                              });

                              Get.snackbar(
                                  'All',
                                  controller.userSuggestionsList.length
                                      .toString());
                            }),
                            buildFilterButton(1, 'NearBy', Icons.location_on,
                                (value) {
                              setState(() {
                                selectedFilter.value = 1;
                              });

                              Get.snackbar('NearBy',
                                  controller.userNearByList.length.toString());
                            }),
                            buildFilterButton(2, 'Highlighted', Icons.star,
                                (value) {
                              setState(() {
                                selectedFilter.value = 2;
                              });

                              Get.snackbar(
                                  'Highlighted',
                                  controller.userHighlightedList.length
                                      .toString());
                            }),
                            buildFilterButton(3, 'Favourite', Icons.favorite,
                                (value) {
                              setState(() {
                                selectedFilter.value = 3;
                              });

                              Get.snackbar('userfavourite',
                                  controller.favourite.length.toString());
                            }),
                          ],
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Column(
                        children: [
                          if (lastUser != null)
                            Text(
                              'Last User: ${lastUser!.name}',
                              style: TextStyle(fontSize: 12),
                            ),
                          SizedBox(
                            height: size.height * 0.7 -
                                MediaQuery.of(context).viewInsets.bottom,
                            child: controller.userSuggestionsList.isEmpty &&
                                    lastUser != null
                                ? buildCardLayoutAll(
                                    context,
                                    lastUser!,
                                    size,
                                    isLastCard,
                                  )
                                : SwipeCards(
                                    matchEngine: matchEngine,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      SuggestedUser user;
                                      isLastCard = index ==
                                          controller
                                                  .userSuggestionsList.length -
                                              1;

                                      switch (selectedFilter.value) {
                                        case 0:
                                          user = controller
                                                  .userSuggestionsList.isEmpty
                                              ? SuggestedUser()
                                              : controller
                                                  .userSuggestionsList[index];
                                          break;
                                        case 1:
                                          user =
                                              controller.userNearByList.isEmpty
                                                  ? SuggestedUser()
                                                  : controller
                                                      .userNearByList[index];
                                          break;
                                        case 2:
                                          user = controller
                                                  .userHighlightedList.isEmpty
                                              ? SuggestedUser()
                                              : controller
                                                  .userHighlightedList[index];
                                          break;
                                        case 3:
                                          user = controller.favourite.isEmpty
                                              ? SuggestedUser()
                                              : controller
                                                  .convertFavouriteToSuggestedUser(
                                                      controller
                                                          .favourite[index]);
                                          break;
                                        default:
                                          user = controller
                                                  .userSuggestionsList.isEmpty
                                              ? SuggestedUser()
                                              : controller
                                                  .userSuggestionsList[index];
                                          break;
                                      }

                                      return Container(
                                        decoration: BoxDecoration(
                                          color: isLastCard
                                              ? Colors.grey[300]
                                              : Colors.blue,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isLastCard
                                                ? Colors.grey
                                                : Colors.green,
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.white.withOpacity(0.2),
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
                                          .userSuggestionsList.isNotEmpty) {
                                        lastUser =
                                            controller.userSuggestionsList.last;
                                        await _storeLastUser(lastUser!);
                                      }
                                      failure('Finished', "Stack Finished");
                                    },
                                    itemChanged: (SwipeItem item, int index) {
                                      print(
                                          "Item: ${item.content}, Index: $index");
                                    },
                                  ),
                          ),
                        ],
                      ),
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
    List<String> images = user.images;

    return user.id == ''
        ? Text("No users available")
        : Container(
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
                                          return Icon(Icons.error,
                                              color: Colors.red);
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
                      ElevatedButton(
                        onPressed: () {
                          matchEngine.currentItem!.nope();
                          print("button pressed nope");
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.NopeColor),
                        child: Text("Nope",
                            style: AppTextStyles.buttonText.copyWith(
                                fontSize: getResponsiveFontSize(0.015))),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (matchEngine.currentItem != null) {
                           matchEngine.currentItem!.superLike();
                            
                          } else {
                            print("No current item to super like");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.FavouriteColor),
                        child: Text("Favourite",
                            style: AppTextStyles.buttonText.copyWith(
                                fontSize: getResponsiveFontSize(0.015))),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          print('Like pressed');
                          setState(() {
                            matchEngine.currentItem!.like();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                        child: Text(
                          "Like",
                          style: TextStyle(fontSize: getResponsiveFontSize(0.015), color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
