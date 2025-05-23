import 'package:dating_application/Controllers/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swipe_cards/draggable_card.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:intl/intl.dart';

import '../../Models/ResponseModels/user_suggestions_response_model.dart';

class MySwipePage extends StatefulWidget {
  const MySwipePage({super.key});

  @override
  MySwipePageState createState() => MySwipePageState();
}

class MySwipePageState extends State<MySwipePage> {
  final List<SwipeItem> _swipeItems = [];
  late MatchEngine _matchEngine;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final List<String> _names = ["Red", "Blue", "Green", "Yellow", "Orange"];
  final List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange
  ];
  Controller controller = Get.put(Controller());

  @override
  void initState() {
    super.initState();
    // Initialize SwipeItems and MatchEngine
    for (int i = 0; i < _names.length; i++) {
      _swipeItems.add(SwipeItem(
        content: _names[i],
        likeAction: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Liked ${_names[i]}"),
            duration: Duration(milliseconds: 500),
          ));
        },
        nopeAction: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Nope ${_names[i]}"),
            duration: Duration(milliseconds: 500),
          ));
        },
        superlikeAction: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Superliked ${_names[i]}"),
            duration: Duration(milliseconds: 500),
          ));
        },
        onSlideUpdate: (SlideRegion? region) async {
          print("Region: $region");
        },
      ));
    }

    // Initialize match engine with swipeable items
    _matchEngine = MatchEngine(swipeItems: _swipeItems);
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
      print('Error parsing date: $e');
      return 'Age not available';
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Inside swipe page build");
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Swipe Cards Example'),
      ),
      body: Container(
        child: Column(
          children: [
            SizedBox(
              height: 550,
              child: SwipeCards(
                matchEngine: _matchEngine,
                itemBuilder: (BuildContext context, int index) {
                  final size = MediaQuery.of(context).size;
                  SuggestedUser user;
                  if (controller.userNearByList.isEmpty ||
                      index >= controller.userNearByList.length) {
                    return Center(child: Text("No users available"));
                  } else {
                    user = controller.userNearByList[index];
                  }
                  if (controller.userHighlightedList.isEmpty ||
                      index >= controller.userHighlightedList.length) {
                    return Center(
                        child: Text("No highlighted users available"));
                  } else {
                    user = controller.userHighlightedList[index];
                  }
                  if (controller.favourite.isEmpty ||
                      index >= controller.favourite.length) {
                    return Center(child: Text("No favourites available"));
                  } else {
                    user = controller.convertFavouriteToSuggestedUser(
                        controller.favourite[index]);
                  }
                  if (controller.hookUpList.isEmpty ||
                      index >= controller.hookUpList.length) {
                    return Center(child: Text("No HookUp available"));
                  } else {
                    user = controller.hookUpList[index];
                  }
                  return Container(
                    alignment: Alignment.center,
                    color: _colors[index],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _names[index],
                          style: TextStyle(fontSize: 40, color: Colors.white),
                        ),
                        Text(
                          calculateAge(user.dob),
                          style: TextStyle(fontSize: size.width * 0.03),
                        ),
                      ],
                    ),
                  );
                },
                onStackFinished: () {
                  setState(() {
                    if (_swipeItems.isNotEmpty) {
                      final lastItem = _swipeItems.last;
                      _swipeItems.removeLast();
                      _swipeItems.insert(0, lastItem);
                      _matchEngine = MatchEngine(swipeItems: _swipeItems);
                    }

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Stack Finished, Last Card Reinserted"),
                      duration: Duration(milliseconds: 500),
                    ));
                  });
                },
                itemChanged: (SwipeItem item, int index) {
                  print("Item: ${item.content}, Index: $index");
                },
                upSwipeAllowed: true,
                fillSpace: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _matchEngine.currentItem!.nope();
                    },
                    child: Text("Nope"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _matchEngine.currentItem!.superLike();
                    },
                    child: Text("Superlike"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _matchEngine.currentItem!.like();
                    },
                    child: Text("Like"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
