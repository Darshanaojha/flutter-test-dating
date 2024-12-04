import 'package:flutter/material.dart';
import 'package:swipe_cards/draggable_card.dart';
import 'package:swipe_cards/swipe_cards.dart'; 


class MySwipePage extends StatefulWidget {
  const MySwipePage({super.key});

  @override
  MySwipePageState createState() => MySwipePageState();
}

class MySwipePageState extends State<MySwipePage> {
  List<SwipeItem> _swipeItems = [];
  late MatchEngine _matchEngine;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  List<String> _names = ["Red", "Blue", "Green", "Yellow", "Orange"];
  List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange
  ];

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Swipe Cards Example'),
      ),
      body: Container(
        child: Column(
          children: [
            // Swipe Cards Container
            Container(
              height: 550,
              child: SwipeCards(
                matchEngine: _matchEngine,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    alignment: Alignment.center,
                    color: _colors[index], // Background color of the card
                    child: Text(
                      _names[index],
                      style: TextStyle(fontSize: 40, color: Colors.white),
                    ),
                  );
                },
                onStackFinished: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Stack Finished"),
                    duration: Duration(milliseconds: 500),
                  ));
                },
                itemChanged: (SwipeItem item, int index) {
                  print("Item: ${item.content}, Index: $index");
                },
                upSwipeAllowed: true,
                fillSpace: true,
              ),
            ),
            // Action Buttons (Like, Dislike, Superlike)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _matchEngine.currentItem!.nope(); // Trigger 'Nope' action
                    },
                    child: Text("Nope"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _matchEngine.currentItem!.superLike(); // Trigger 'Superlike' action
                    },
                    child: Text("Superlike"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _matchEngine.currentItem!.like(); // Trigger 'Like' action
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
