import 'dart:math';
import 'package:dating_application/Screens/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import '../../Controllers/controller.dart';

class IntroSlidingPages extends StatefulWidget {
  const IntroSlidingPages({super.key});

  @override
  IntroSlidingPagestate createState() => IntroSlidingPagestate();
}

class IntroSlidingPagestate extends State<IntroSlidingPages> {
  Controller controller = Get.put(Controller());
  int page = 0;
  LiquidController liquidController = LiquidController();

  @override
  void initState() {
    super.initState();
  }

  Widget _buildDot(int index) {
    double selectedness = Curves.easeOut.transform(
      max(0.0, 1.0 - ((page) - index).abs()),
    );
    double zoom = 1.0 + (2.0 - 1.0) * selectedness;
    return SizedBox(
      width: 25.0,
      child: Center(
        child: Material(
          color: Colors.white,
          type: MaterialType.circle,
          child: SizedBox(
            width: 8.0 * zoom,
            height: 8.0 * zoom,
          ),
        ),
      ),
    );
  }

  Color getRandomColor() {
    Random random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: controller.fetchAllIntroSlider(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }
        if (controller.sliderData.isEmpty) {
          return Scaffold(
            body: Center(child: Text("No data available")),
          );
        }

        return Scaffold(
          body: Stack(
            children: <Widget>[
              LiquidSwipe.builder(
                itemCount: controller.sliderData.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: double.infinity,
                    color: getRandomColor(), 
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Hero(
                          tag: controller.sliderData[index].id!,
                          child: Image.network(
                            controller.sliderData[index].image!,
                            height: 300,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              } else {
                                return Center(
                                    child: CircularProgressIndicator());
                              }
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset('assets/placeholder_image.png');
                            },
                          ),
                        ),
                        Column(
                          children: <Widget>[
                            Text(
                              controller.sliderData[index].title!,
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
                      children: List<Widget>.generate(
                        controller.sliderData.length,
                        (index) => _buildDot(index),
                      ),
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
                      Get.to(Login());
                      liquidController.animateToPage(
                        page: controller.sliderData.length - 1,
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
              // Next Button
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: TextButton(
                    onPressed: () {
                      // Update the page index properly and jump to next page
                      int nextPage = liquidController.currentPage + 1;
                      if (nextPage >= controller.sliderData.length) {
                        nextPage = 0;  // Loop to the first page if at the end
                      }
                      liquidController.jumpToPage(page: nextPage);
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.01),
                      foregroundColor: Colors.black,
                    ),
                    child: Text("Next"),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
