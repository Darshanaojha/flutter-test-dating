import 'dart:math';
import 'package:dating_application/Screens/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import '../../Controllers/controller.dart';

class IntroSlidingPages extends StatefulWidget {
  const IntroSlidingPages({super.key});

  @override
  IntroSlidingPagesState createState() => IntroSlidingPagesState();
}

class IntroSlidingPagesState extends State<IntroSlidingPages> {
  Controller controller = Get.put(Controller());
  int page = 0;
  late LiquidController liquidController;

  @override
  void initState() {
    liquidController = LiquidController();
    super.initState();
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: <Widget>[
            LiquidSwipe.builder(
              itemCount: controller.sliderData.length,
              itemBuilder: (context, index) {
                var slider = controller.sliderData[index];
                return Container(
                  width: double.infinity,
                  color: getRandomColor(), 
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Image.network(
                        slider.image!,
                        height: 300,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          } else {
                            return const Center(child: CircularProgressIndicator());
                          }
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset('assets/placeholder_image.png');
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.all(index != 4 ? 24.0 : 0),
                      ),
                      Column(
                        children: <Widget>[
                          Text(
                            slider.title!,
                            style: TextStyle(fontSize: 24, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              positionSlideIcon: 0.8,
              slideIconWidget: const Icon(Icons.arrow_back_ios),
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
              enableLoop: false, // Disable looping for smoother flow
              ignoreUserGestureWhileAnimating: true,
            ),

            // Dot indicators at the bottom
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  Expanded(child: SizedBox()),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(controller.sliderData.length, _buildDot),
                  ),
                ],
              ),
            ),

            // Skip to End Button
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
                      foregroundColor: Colors.black),
                  child: const Text("Skip to End"),
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
                        page: liquidController.currentPage + 1 > controller.sliderData.length - 1
                            ? 0
                            : liquidController.currentPage + 1);
                  },
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.01),
                      foregroundColor: Colors.black),
                  child: const Text("Next"),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
