import 'package:dating_application/Screens/auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import 'package:encrypt_shared_preferences/provider.dart';
import '../../Controllers/controller.dart';
import '../../constants.dart';

class IntroSlidingPages extends StatefulWidget {
  const IntroSlidingPages({super.key});

  @override
  IntroSlidingPagesState createState() => IntroSlidingPagesState();
}

class IntroSlidingPagesState extends State<IntroSlidingPages> {
  Controller controller = Get.put(Controller());
  PageController pageController = PageController();
  int currentPage = 0;
  bool _isLoading = true;

  // Exact gradient colors for overlay
  Color get _gradientTop => Color(0xFF0A0812).withOpacity(0.9); // Dark purple/near black 90%
  Color get _gradientMiddle => Color(0xFFC24A9A).withOpacity(0.45); // Pinkish-purple glow 45%
  Color get _gradientBottom => Color(0xFF000000).withOpacity(0.85); // Dark purple/black 85%

  // Pink accent color
  Color get _pinkAccent => Color(0xFFF2A1D3);

  @override
  void initState() {
    super.initState();
    _loadSliderData();
  }

  Future<void> _loadSliderData() async {
    if (controller.sliderData.isEmpty) {
      setState(() {
        _isLoading = true;
      });
      await controller.fetchAllIntroSlider();
      setState(() {
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Widget _buildIntroPage(String title, int pageIndex) {
    // Get slider data for this page
    final sliderItem = pageIndex < controller.sliderData.length 
        ? controller.sliderData[pageIndex] 
        : null;
    
    // Get page-specific content
    final pageContent = _getPageContent(pageIndex);
    
    // Split title to find word to highlight
    final titleWords = title.toUpperCase().split(' ');
    String highlightedWord = 'MATCH'; // Default for dating app
    if (titleWords.any((word) => word.contains('MATCH') || word.contains('CONNECT'))) {
      highlightedWord = titleWords.firstWhere(
        (word) => word.contains('MATCH') || word.contains('CONNECT'),
        orElse: () => titleWords.isNotEmpty ? titleWords[1] : 'MATCH',
      );
    } else if (titleWords.length > 1) {
      highlightedWord = titleWords[1]; // Default to second word
    }

    return GestureDetector(
      onTap: () async {
        // On last page, navigate to auth screen on tap
        if (pageIndex == 3) {
          // Mark intro slider as seen before navigating
          final preferences = await EncryptedSharedPreferences.getInstance();
          await preferences.setBoolean('isSeenUser', true);
          // Navigate to auth/registration screen
          Get.offAll(() => CombinedAuthScreen());
        } else {
          // Otherwise, go to next page
          pageController.nextPage(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
          // LAYER 1: Full-bleed Background Image
          Positioned.fill(
            child: sliderItem?.image != null && sliderItem!.image!.isNotEmpty
                ? Image.asset(
                    sliderItem.image!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/images/pexels-pixabay-289227.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.black,
                        child: Icon(Icons.error, color: Colors.white),
                      ),
                    ),
                  )
                : Image.asset(
                    'assets/images/pexels-pixabay-289227.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.black,
                      child: Icon(Icons.error, color: Colors.white),
                    ),
                  ),
          ),

          // LAYER 2: Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _gradientTop,
                    _gradientMiddle,
                    _gradientBottom,
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // LAYER 3: Safe Content Area
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top spacing + Headline Text Block
                Padding(
                  padding: const EdgeInsets.only(left: 24.0, top: 44.0, right: 24.0),
                  child: _buildHeadlineText(title, highlightedWord),
                ),

                // Spacer to push content down
                Spacer(),

                // Content Section with description and features
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description text
                      Text(
                        pageContent['description'] ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.9),
                          height: 1.5,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: 24),
                      // Features list
                      ...pageContent['features']?.map<Widget>((feature) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: _pinkAccent.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _pinkAccent,
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                Icons.check,
                                size: 14,
                                color: _pinkAccent,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                feature,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withOpacity(0.85),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )).toList() ?? [],
                    ],
                  ),
                ),
                SizedBox(height: 24),

                // Circular Glassmorphic Info Card - connecting element (sliding from page 1 to 4)
                Expanded(
                  child: Stack(
                    children: [
                      // Feature icon circle sliding continuously from bottom-left (page 1) to top-right (page 4)
                      _buildSlidingCircle(pageIndex, pageContent['icon'] as IconData?),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildHeadlineText(String title, String highlightedWord) {
    final words = title.toUpperCase().split(' ');
    final List<TextSpan> spans = [];

    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      final isHighlighted = word == highlightedWord || word.contains(highlightedWord);

      spans.add(
        TextSpan(
          text: word,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            height: 0.95,
            color: isHighlighted ? _pinkAccent : Colors.white,
            fontFamily: 'Roboto',
          ),
        ),
      );

      if (i < words.length - 1) {
        spans.add(TextSpan(text: ' '));
      }
    }

    return RichText(
      text: TextSpan(children: spans),
      textAlign: TextAlign.left,
    );
  }

  Widget _buildSlidingCircle(int pageIndex, IconData? icon) {
    // Calculate progress from 0.0 (page 1 - bottom-left) to 1.0 (page 4 - top-right)
    final progress = pageIndex / 3.0; // 0.0, 0.33, 0.66, 1.0
    
    // Start position: bottom-left (page 1)
    final startBottom = 120.0;
    final startLeft = 30.0;
    
    // End position: top-right (page 4)
    final endTop = 120.0;
    final endRight = 30.0;
    
    // Calculate intermediate positions
    final bottom = startBottom * (1 - progress);
    final left = startLeft * (1 - progress);
    final top = endTop * progress;
    final right = endRight * progress;

    return AnimatedPositioned(
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      bottom: bottom > 0 ? bottom : null,
      left: left > 0 ? left : null,
      top: top > 0 ? top : null,
      right: right > 0 ? right : null,
      child: _buildGlassCardContent(icon),
    );
  }

  Widget _buildGlassCardContent(IconData? icon) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1), // Semi-transparent white 10%
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon or emoji
              if (icon != null)
                Icon(
                  icon,
                  size: 46,
                  color: _pinkAccent,
                )
              else
                Text(
                  '💕',
                  style: TextStyle(fontSize: 46),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Get page-specific content (description, features, icon)
  Map<String, dynamic> _getPageContent(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return {
          'description': 'Discover meaningful connections with people who share your interests and values. Swipe through profiles and find your perfect match.',
          'features': [
            'Browse verified profiles',
            'Advanced matching algorithm',
            'Safe and secure platform',
          ],
          'icon': Icons.favorite,
        };
      case 1:
        return {
          'description': 'Connect with real, verified users in your area. Build genuine relationships with people who are looking for the same things you are.',
          'features': [
            'Real-time location matching',
            'Profile verification system',
            'Privacy-focused design',
          ],
          'icon': Icons.people,
        };
      case 2:
        return {
          'description': 'Start meaningful conversations with your matches. Chat, share moments, and build lasting relationships with people you connect with.',
          'features': [
            'Instant messaging',
            'Photo and video sharing',
            'Voice and video calls',
          ],
          'icon': Icons.chat_bubble,
        };
      case 3:
        return {
          'description': 'Join thousands of happy couples who found love on our platform. Your journey to finding the perfect match starts here.',
          'features': [
            'Easy sign-up process',
            'Personalized recommendations',
            '24/7 customer support',
          ],
          'icon': Icons.rocket_launch,
        };
      default:
        return {
          'description': 'Start your journey to find meaningful connections today.',
          'features': [],
          'icon': Icons.star,
        };
    }
  }


  Widget _buildPageIndicators() {
    // Show 4 dots for 4 pages
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return _buildDot(index == currentPage);
      }),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? _pinkAccent : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || controller.sliderData.isEmpty) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    // Get titles for 4 pages (repeat if needed)
    final List<String> titles = [];
    for (int i = 0; i < 4; i++) {
      if (i < controller.sliderData.length) {
        titles.add(controller.sliderData[i].title ?? 'THE BEST WEBCAM MODELS FOR YOUR PLEASURE');
      } else {
        titles.add(controller.sliderData[0].title ?? 'THE BEST WEBCAM MODELS FOR YOUR PLEASURE');
      }
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            PageView.builder(
              controller: pageController,
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },
              itemCount: 4,
              itemBuilder: (context, index) {
                return _buildIntroPage(titles[index], index);
              },
            ),
            // Global page indicators overlay (only one instance)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 34.0),
                  child: Center(
                    child: _buildPageIndicators(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

