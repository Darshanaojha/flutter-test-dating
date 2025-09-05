import 'package:cached_network_image/cached_network_image.dart';
import 'package:dating_application/Screens/auth.dart';
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

  Widget buildPage(String image, String title, String description, int index) {
    List<List<Color>> gradients = [
      [Color(0xff1f005c), Color(0xff5b0060), Color(0xff870160)],
      [Color(0xffac255e), Color(0xffca485c), Color(0xffe16b5c)],
      [Color(0xffe16b5c), Color(0xfff39060), Color(0xffffb56b)],
      [
        Color(0xff1f005c),
        Color(0xff5b0060),
        Color(0xff870160),
        Color(0xffac255e)
      ],
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: gradients[index % gradients.length],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (index == 0 || index == 2) ...[
            Text(title, style: _titleStyle()),
            CachedNetworkImage(
              imageUrl: image,
              height: 250,
              fit: BoxFit.contain,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
            Text(description, style: _textStyle()),
          ] else ...[
            Text(description, style: _textStyle()),
            CachedNetworkImage(
              imageUrl: image,
              height: 250,
              fit: BoxFit.contain,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
            Text(title, style: _titleStyle()),
          ]
        ],
      ),
    );
  }

  TextStyle _titleStyle() {
    return const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
  }

  TextStyle _textStyle() {
    return const TextStyle(
      fontSize: 18,
      color: Colors.white,
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
                return buildPage(
                    slider.image!, slider.title!, 'Sample description', index);
              },
              onPageChangeCallback: (int lpage) {
                setState(() {
                  page = lpage;
                });
              },
              waveType: WaveType.liquidReveal,
              liquidController: liquidController,
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: TextButton(
                  onPressed: () {
                    Get.to(CombinedAuthScreen());

                    liquidController.animateToPage(
                      page: controller.sliderData.length - 1,
                      duration: 700,
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.1),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Proceed"),
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
                      page: liquidController.currentPage + 1 >=
                              controller.sliderData.length
                          ? 0
                          : liquidController.currentPage + 1,
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.1),
                    foregroundColor: Colors.white,
                  ),
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
