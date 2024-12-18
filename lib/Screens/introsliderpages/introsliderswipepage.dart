import 'dart:math';
import 'package:flutter/material.dart';
import 'package:liquid_swipe/liquid_swipe.dart';


class IntroSlidingPages extends StatefulWidget {
  const IntroSlidingPages({super.key});

  @override
  IntroSlidingPagestate createState() => IntroSlidingPagestate();
}
class IntroSlidingPagestate extends State<IntroSlidingPages> {
  int page = 0;
  late LiquidController liquidController;

  List<ItemData> data = [
    ItemData(Colors.blue, "assets/1.png", "Hi", "It's Me", "Liquid"),
    ItemData(Colors.deepPurpleAccent, "assets/2.png", "Take a", "Look At", "Liquid Swipe"),
    ItemData(Colors.green, "assets/3.png", "Liked?", "Fork!", "Give Star!"),
    ItemData(Colors.yellow, "assets/4.png", "Can be", "Used for", "Onboarding design"),
    ItemData(Colors.pink, "assets/5.png", "Example", "of a page", "with Gesture"),
    ItemData(Colors.red, "assets/6.png", "Do", "try it", "Thank you"),
  ];

  @override
  void initState() {
    liquidController = LiquidController();
    super.initState();
  }

  Widget _buildDot(int index) {
    double selectedness = Curves.easeOut.transform(
      max(0.0, 1.0 - ((page) - index).abs()),
    );
    double zoom = 1.0 + (2.0 - 1.0) * selectedness;
    return Container(
      width: 25.0,
      child: Center(
        child: Material(
          color: Colors.white,
          type: MaterialType.circle,
          child: Container(
            width: 8.0 * zoom,
            height: 8.0 * zoom,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          LiquidSwipe.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              return Container(
                width: double.infinity,
                color: data[index].color,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    // Display the image for the current page
                    Image.asset(
                      data[index].image,
                      height: 300,
                      fit: BoxFit.contain,
                    ),
                    Padding(
                      padding: EdgeInsets.all(index != 4 ? 24.0 : 0),
                    ),
                    index == 4
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 70.0),
                            child: ExampleSlider(),
                          )
                        : SizedBox.shrink(),
                    Column(
                      children: <Widget>[
                        Text(
                          data[index].text1,
                          style: TextStyle(fontSize: 24, color: Colors.white),
                        ),
                        Text(
                          data[index].text2,
                          style: TextStyle(fontSize: 24, color: Colors.white),
                        ),
                        Text(
                          data[index].text3,
                          style: TextStyle(fontSize: 24, color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
            positionSlideIcon: 0.8,
            slideIconWidget: Icon(Icons.arrow_back_ios),
            onPageChangeCallback: (int lpage) {
              setState(() {
                page = lpage;
              });
            },
            waveType: WaveType.liquidReveal,
            liquidController: liquidController,
            fullTransitionValue: 880,
            enableSideReveal: true,
            preferDragFromRevealedArea: true,
            enableLoop: true,
            ignoreUserGestureWhileAnimating: true,
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: <Widget>[
                Expanded(child: SizedBox()),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List<Widget>.generate(data.length, _buildDot),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: TextButton(
                onPressed: () {
                  liquidController.animateToPage(
                    page: data.length - 1,
                    duration: 700,
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.01),
                  foregroundColor: Colors.black,
                ),
                child: Text("Skip to End"),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: TextButton(
                onPressed: () {
                  liquidController.jumpToPage(
                    page: liquidController.currentPage + 1 > data.length - 1
                        ? 0
                        : liquidController.currentPage + 1,
                  );
                },
                child: Text("Next"),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.01),
                  foregroundColor: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ItemData {
  final Color color;
  final String image;
  final String text1;
  final String text2;
  final String text3;

  ItemData(this.color, this.image, this.text1, this.text2, this.text3);
}

class ExampleSlider extends StatefulWidget {
  const ExampleSlider({Key? key}) : super(key: key);

  @override
  State<ExampleSlider> createState() => _ExampleSliderState();
}

class _ExampleSliderState extends State<ExampleSlider> {
  double sliderVal = 0;

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: sliderVal,
      activeColor: Colors.white,
      inactiveColor: Colors.red,
      onChanged: (val) {
        setState(() {
          sliderVal = val;
        });
      },
    );
  }
}
