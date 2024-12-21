import 'package:cached_network_image/cached_network_image.dart';
import 'package:dating_application/Controllers/controller.dart';
import 'package:dating_application/Models/RequestModels/estabish_connection_request_model.dart';
import 'package:dating_application/Screens/homepage/swaping.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:swipe_cards/draggable_card.dart';
import 'package:swipe_cards/swipe_cards.dart';
import '../../Models/ResponseModels/user_suggestions_response_model.dart';
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
    await controller.userSuggestions();

    for (int i = 0; i < controller.userSuggestionsList.length; i++) {
      swipeItems.add(SwipeItem(
        content: controller.userSuggestionsList[i].userId,
        likeAction: () {
          controller.profileLikeRequest.likedBy =
              controller.userSuggestionsList[i].userId.toString();
          controller.profileLike(controller.profileLikeRequest);
          success('Hey Boy', "Liked ${controller.userSuggestionsList[i].name}");
        },
        nopeAction: () {
          success('OOPS', "Nope ${controller.userSuggestionsList[i].name}");
        },
        superlikeAction: () {
          if (controller.userSuggestionsList[i].userId != null) {
            controller.markFavouriteRequestModel.favouriteId =
                controller.userSuggestionsList[i].userId;
            controller.markasfavourite(controller.markFavouriteRequestModel);
            success('Bravo',
                "Superliked ${controller.userSuggestionsList[i].name}");
          } else {
            failure('Error', "Error: User ID is null.");
          }
        },
        onSlideUpdate: (SlideRegion? region) async {
          print("Region: $region");
        },
      ));
    }
    matchEngine = MatchEngine(swipeItems: swipeItems);
    if (matchEngine.currentItem != null) {
      matchEngine.currentItem?.nope();
    } else {
      print('No current item to "nope"');
    }

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
              SizedBox(height: 20),
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
                },
                maxLines: 3,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (establishConnectionMessageRequest.message.isEmpty) {
                    setState(() {
                      messageCount--;
                    });
                    controller.sendConnectionMessage(
                        establishConnectionMessageRequest);
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

  Widget buildFilterButton(
      int button, String label, IconData icon, Function(String) onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton.icon(
        onPressed: () {
          setState(() {
            selectedFilter.value = button;
          });
          onTap(label);
        },
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.white),
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
                          SuggestedUser user;

                          switch (selectedFilter.value) {
                            case 0:
                              controller.userSuggestionsList.isEmpty
                                  ? user = SuggestedUser()
                                  : user =
                                      controller.userSuggestionsList[index];
                              break;
                            case 1:
                              controller.userNearByList.isEmpty
                                  ? user = SuggestedUser()
                                  : user = controller.userNearByList[index];
                              break;
                            case 2:
                              controller.userHighlightedList.isEmpty
                                  ? user = SuggestedUser()
                                  : user =
                                      controller.userHighlightedList[index];
                              break;
                            case 3:
                              controller.favourite.isEmpty
                                  ? user = SuggestedUser()
                                  : user = controller
                                      .convertFavouriteToSuggestedUser(
                                          controller.favourite[index]);
                              break;
                            default:
                              controller.userSuggestionsList.isEmpty
                                  ? user = SuggestedUser()
                                  : user =
                                      controller.userSuggestionsList[index];
                              break;
                          }

                          return buildCardLayoutAll(context, user, size);
                        },
                        onStackFinished: () {
                          setState(() {
                            isSwipeFinished = true;
                          });
                          failure('Finished', "Stack Finished");
                        },
                        itemChanged: (SwipeItem item, int index) {
                          print("Item: ${item.content}, Index: $index");
                        },
                        upSwipeAllowed: true,
                        fillSpace: true,
                      ),
                    )),
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
    BuildContext context,
    SuggestedUser user,
    Size size,
  ) {
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
                      Positioned(
                        bottom: 10,
                        right: 0,
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: size.height * 0.1),
                          child: Transform.rotate(
                            angle: -1.5708,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SmoothPageIndicator(
                                  controller: _imagePageController,
                                  count: user.images.length,
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
                    SizedBox(width: 16),
                    IconButton(
                      onPressed: () {
                        showmessageBottomSheet(user.id.toString());
                      },
                      icon: Icon(Icons.messenger_outline, size: 40),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  user.name ?? 'NA',
                  style: TextStyle(
                      fontSize: size.width * 0.04, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Text(
                      calculateAge(user.dob ?? 'Unknown Date'),
                      style: TextStyle(fontSize: size.width * 0.04),
                    ),
                    Text(
                      '${user.city}',
                      style: TextStyle(fontSize: size.width * 0.04),
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
                            style: AppTextStyles.buttonText.copyWith(
                                fontSize: getResponsiveFontSize(0.03))),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // matchEngine.currentItem?.superLike();
                          if (matchEngine.currentItem != null) {
                            matchEngine.currentItem?.superLike();
                          } else {
                            print("No current item to super like");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.FavouriteColor),
                        child: Text("Favourite",
                            style: AppTextStyles.buttonText.copyWith(
                                fontSize: getResponsiveFontSize(0.03))),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          matchEngine.currentItem?.like();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.LikeColor),
                        child: Text("Like",
                            style: AppTextStyles.buttonText.copyWith(
                                fontSize: getResponsiveFontSize(0.03))),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
