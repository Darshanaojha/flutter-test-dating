import 'package:dating_application/Screens/auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import 'dart:convert';
import 'dart:math' as math;
import 'package:encrypt_shared_preferences/provider.dart';
import '../../Controllers/controller.dart';
import '../../constants.dart';

class IntroSlidingPages extends StatefulWidget {
  const IntroSlidingPages({super.key});

  @override
  IntroSlidingPagesState createState() => IntroSlidingPagesState();
}

class IntroSlidingPagesState extends State<IntroSlidingPages> with TickerProviderStateMixin {
  Controller controller = Get.find<Controller>();
  late PageController pageController;
  int currentPage = 0;
  bool _isLoading = true;

  // Animation controllers
  late AnimationController _bubbleController;
  late AnimationController _pulseController;
  late AnimationController _particleController;
  late AnimationController _flickerController;
  late AnimationController _ctaGlowController;

  // Bubble position animations
  late Animation<double> _bubbleXAnimation;
  late Animation<double> _bubbleYAnimation;
  late Animation<double> _bubbleScaleAnimation;
  late Animation<double> _bubbleOpacityAnimation;
  late Animation<double> _bubbleRotationAnimation;

  // Use app theme colors
  Color get _primaryBackground => AppColors.primaryColor;
  Color get _accentNeon => AppColors.fuschia;
  Color get _highlightWhite => AppColors.textColor;
  Color get _pinkAccent => AppColors.fuschiaLight;

  // Gradient overlay colors - lighter for glass effect
  Color get _gradientTop => Colors.black.withOpacity(0.4);
  Color get _gradientBottom => Colors.black.withOpacity(0.6);

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    
    // Initialize animation controllers - smoother transitions
    _bubbleController = AnimationController(
      duration: Duration(milliseconds: 900),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 2600),
      vsync: this,
    )..repeat(reverse: true);
    
    _particleController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _flickerController = AnimationController(
      duration: Duration(milliseconds: 1400),
      vsync: this,
    )..repeat(reverse: true);

    _ctaGlowController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    // Setup bubble animations
    _setupBubbleAnimations();
    
    _loadSliderData();
  }

  void _setupBubbleAnimations() {
    // Bubble position based on current page
    _bubbleXAnimation = Tween<double>(begin: -30, end: 0).animate(
      CurvedAnimation(parent: _bubbleController, curve: Curves.easeOutCubic),
    );
    
    _bubbleYAnimation = Tween<double>(begin: 0.4, end: 0.4).animate(_bubbleController);
    _bubbleScaleAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(_bubbleController);
    _bubbleOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_bubbleController);
    _bubbleRotationAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(_bubbleController);
  }

  void _updateBubbleForPage(int page) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    switch (page) {
      case 0:
        // Slide 1: Left side, 40% height - smooth entry
        _bubbleXAnimation = Tween<double>(begin: -30, end: screenWidth * 0.15).animate(
          CurvedAnimation(parent: _bubbleController, curve: Curves.easeOutCubic),
        );
        _bubbleYAnimation = Tween<double>(begin: 0.4, end: 0.4).animate(
          CurvedAnimation(parent: _bubbleController, curve: Curves.easeOutCubic),
        );
        _bubbleScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(parent: _bubbleController, curve: Curves.easeOutCubic),
        );
        _bubbleRotationAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
          CurvedAnimation(parent: _bubbleController, curve: Curves.easeOutCubic),
        );
        break;
      case 1:
        // Slide 2: Center, heartbeat pulse
        _bubbleXAnimation = Tween<double>(begin: screenWidth * 0.15, end: screenWidth * 0.5 - 55).animate(
          CurvedAnimation(parent: _bubbleController, curve: Curves.easeInOutCubic),
        );
        _bubbleYAnimation = Tween<double>(begin: 0.4, end: 0.4).animate(
          CurvedAnimation(parent: _bubbleController, curve: Curves.easeInOutCubic),
        );
        _bubbleScaleAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
          CurvedAnimation(parent: _bubbleController, curve: Curves.easeInOutCubic),
        );
        _bubbleRotationAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
          CurvedAnimation(parent: _bubbleController, curve: Curves.easeInOutCubic),
        );
        break;
      case 2:
        // Slide 3: Upper right, with rotation
        _bubbleXAnimation = Tween<double>(begin: screenWidth * 0.5 - 55, end: screenWidth * 0.75).animate(
          CurvedAnimation(parent: _bubbleController, curve: Curves.easeInOutCubic),
        );
        _bubbleYAnimation = Tween<double>(begin: 0.4, end: 0.25).animate(
          CurvedAnimation(parent: _bubbleController, curve: Curves.easeInOutCubic),
        );
        _bubbleScaleAnimation = Tween<double>(begin: 1.25, end: 1.15).animate(
          CurvedAnimation(parent: _bubbleController, curve: Curves.easeInOutCubic),
        );
        _bubbleRotationAnimation = Tween<double>(begin: 0.0, end: 0.087).animate(
          CurvedAnimation(parent: _bubbleController, curve: Curves.easeInOutCubic),
        ); // ~5 degrees
        break;
      case 3:
        // Slide 4: Center, then burst
        _bubbleXAnimation = Tween<double>(begin: screenWidth * 0.75, end: screenWidth * 0.5 - 55).animate(
          CurvedAnimation(parent: _bubbleController, curve: Curves.easeInOutCubic),
        );
        _bubbleYAnimation = Tween<double>(begin: 0.25, end: 0.4).animate(
          CurvedAnimation(parent: _bubbleController, curve: Curves.easeInOutCubic),
        );
        _bubbleScaleAnimation = Tween<double>(begin: 1.15, end: 1.8).animate(
          CurvedAnimation(parent: _bubbleController, curve: Curves.easeInOutCubic),
        );
        _bubbleRotationAnimation = Tween<double>(begin: 0.087, end: 0.0).animate(
          CurvedAnimation(parent: _bubbleController, curve: Curves.easeInOutCubic),
        );
        break;
    }
    
    _bubbleController.forward(from: 0.0);
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
    
    // Start bubble animation for first page
    if (mounted) {
      _updateBubbleForPage(0);
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    _bubbleController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    _flickerController.dispose();
    _ctaGlowController.dispose();
    super.dispose();
  }

  Widget _buildIntroPage(String title, int pageIndex) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 700;
    
    // Get slider data for this page
    final sliderItem = pageIndex < controller.sliderData.length 
        ? controller.sliderData[pageIndex] 
        : null;
    
    // Get page-specific content
    final pageContent = _getPageContent(pageIndex);
    
    // Split title to find word to highlight
    final titleWords = title.toUpperCase().split(' ');
    String highlightedWord = 'MATCH';
    if (titleWords.any((word) => word.contains('MATCH') || word.contains('CONNECT'))) {
      highlightedWord = titleWords.firstWhere(
        (word) => word.contains('MATCH') || word.contains('CONNECT'),
        orElse: () => titleWords.isNotEmpty ? titleWords[1] : 'MATCH',
      );
    } else if (titleWords.length > 1) {
      highlightedWord = titleWords[1];
    }

    return GestureDetector(
      onTap: () async {
        if (pageIndex == 3) {
          final preferences = await EncryptedSharedPreferences.getInstance();
          await preferences.setBoolean('isSeenUser', true);
          Get.offAll(() => CombinedAuthScreen());
        } else {
          pageController.nextPage(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // LAYER 1: Background Image with Parallax
            Positioned.fill(
              child: _buildBackgroundImage(sliderItem, pageIndex),
            ),

            // LAYER 2: Gradient Overlay with Vignette
            Positioned.fill(
              child: _buildGradientOverlay(),
            ),

            // LAYER 3: Moving Bubble (only on current page)
            if (currentPage == pageIndex)
              _buildMovingBubble(pageIndex, screenSize),

            // LAYER 4: Content
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: NeverScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            // Top spacing
                            SizedBox(height: isSmallScreen ? 40 : screenSize.height * 0.12),

                            // Headline text
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenSize.width * 0.08,
                              ),
                              child: _buildHeadlineText(title, highlightedWord, screenSize),
                            ),

                            SizedBox(height: isSmallScreen ? 20 : 28),

                            // Subtext
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenSize.width * 0.08,
                              ),
                              child: Text(
                                pageContent['subtext'] ?? '',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 15 : 17,
                                  fontWeight: FontWeight.w400,
                                  color: _highlightWhite.withOpacity(0.8),
                                  height: 1.5,
                                  letterSpacing: 0.5,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 2),
                                      blurRadius: 6,
                                      color: Colors.black.withOpacity(0.6),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Spacer(),

                            // Features list (only on first 3 slides)
                            if (pageIndex < 3)
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenSize.width * 0.08,
                                  vertical: 20,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ...pageContent['features']?.map<Widget>((feature) => Padding(
                                      padding: EdgeInsets.only(bottom: isSmallScreen ? 10.0 : 12.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: isSmallScreen ? 18 : 20,
                                            height: isSmallScreen ? 18 : 20,
                                            decoration: BoxDecoration(
                                              color: _accentNeon.withOpacity(0.2),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: _accentNeon,
                                                width: 1.5,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.check,
                                              size: isSmallScreen ? 11 : 12,
                                              color: _accentNeon,
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Flexible(
                                            child: Text(
                                              feature,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: isSmallScreen ? 13 : 15,
                                                fontWeight: FontWeight.w500,
                                                color: _highlightWhite.withOpacity(0.85),
                                                height: 1.4,
                                                shadows: [
                                                  Shadow(
                                                    offset: Offset(0, 1),
                                                    blurRadius: 3,
                                                    color: Colors.black.withOpacity(0.6),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )).toList() ?? [],
                                  ],
                                ),
                              ),

                            // CTA Button (only on slide 4)
                            if (pageIndex == 3)
                              Padding(
                                padding: EdgeInsets.only(
                                  bottom: screenSize.height * 0.1,
                                  left: screenSize.width * 0.08,
                                  right: screenSize.width * 0.08,
                                ),
                                child: _buildCTAButton(),
                              ),

                            SizedBox(height: isSmallScreen ? 20 : 40),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundImage(sliderItem, int pageIndex) {
    String? imagePath = sliderItem?.image;
    
    // If no image from slider data, use default
    if (imagePath == null || imagePath.isEmpty) {
      imagePath = 'assets/images/intro1.jpg';
    }
    
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
      child: _buildImageWidget(imagePath),
    );
  }
  
  Widget _buildImageWidget(String imagePath) {
    // Check if it's a network URL
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: _primaryBackground,
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: _primaryBackground,
            child: Center(
              child: CircularProgressIndicator(
                color: _accentNeon,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      );
    }
    
    // Check if it's a base64 image
    if (imagePath.startsWith('data:image/') || imagePath.startsWith('/9j/') || imagePath.length > 100) {
      try {
        // Try to decode base64
        final base64String = imagePath.contains(',') 
            ? imagePath.split(',')[1] 
            : imagePath;
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: _primaryBackground,
          ),
        );
      } catch (e) {
        // If base64 decode fails, fall back to asset
        return Image.asset(
          'assets/images/intro1.jpg',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            color: _primaryBackground,
          ),
        );
      }
    }
    
    // Default to asset image
    return Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: _primaryBackground,
      ),
    );
  }

  Widget _buildGradientOverlay() {
    // Lighter overlay for glass effect - background should shine through
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _gradientTop,
            _gradientBottom,
          ],
          stops: [0.0, 1.0],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.2),
            ],
            stops: [0.0, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildMovingBubble(int pageIndex, Size screenSize) {
    final pulseScale = 1.0 + (_pulseController.value * 0.07) + (_flickerController.value * 0.01);
    final shouldPulse = pageIndex == 1; // Only pulse on slide 2
    
    return AnimatedBuilder(
      animation: Listenable.merge([_bubbleController, _pulseController, _flickerController]),
      builder: (context, child) {
        final x = _bubbleXAnimation.value;
        final y = _bubbleYAnimation.value * screenSize.height;
        final scale = _bubbleScaleAnimation.value * (shouldPulse ? pulseScale : 1.0);
        final opacity = _bubbleOpacityAnimation.value;
        final rotation = _bubbleRotationAnimation.value;

        // Show particles on slide 3
        final showParticles = pageIndex == 2 && _bubbleController.value > 0.5;
        
        // Burst effect on slide 4
        final shouldBurst = pageIndex == 3 && _bubbleController.value > 0.8;

        return Stack(
          children: [
            // Main bubble
            if (!shouldBurst)
              Positioned(
                left: x - (55 * scale),
                top: y - (55 * scale),
                child: Transform.rotate(
                  angle: rotation,
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: scale,
                      child: _buildBubbleWidget(),
                    ),
                  ),
                ),
              ),

            // Trailing particles (slide 3)
            if (showParticles)
              ..._buildTrailingParticles(x, y, screenSize),

            // Burst particles (slide 4)
            if (shouldBurst)
              ..._buildBurstParticles(x, y, screenSize),
          ],
        );
      },
    );
  }

  Widget _buildBubbleWidget() {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          // Outer glow
          BoxShadow(
            color: _accentNeon.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
          // Inner glow
          BoxShadow(
            color: Colors.white.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipOval(
        child: Stack(
          children: [
            // Frosted glass base layer
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.18),
                      Colors.white.withOpacity(0.08),
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.25, 0.55, 1.0],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.45),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.15),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
            
            // Frost texture overlay
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.32),
                    Colors.white.withOpacity(0.08),
                    Colors.transparent,
                    Colors.white.withOpacity(0.12),
                  ],
                  stops: [0.0, 0.3, 0.6, 1.0],
                ),
              ),
            ),
            
            // Animated highlights for dynamic sheen
            AnimatedBuilder(
              animation: _flickerController,
              builder: (context, child) {
                final shift = (_flickerController.value - 0.5) * 6;
                return Stack(
                  children: [
                    Positioned(
                      top: 15 + shift,
                      left: 15 + shift,
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withOpacity(0.85),
                              Colors.white.withOpacity(0.35),
                              Colors.transparent,
                            ],
                            stops: [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 18 - shift,
                      right: 20 - shift,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withOpacity(0.35),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            
            // Accent color glow (subtle)
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _accentNeon.withOpacity(0.18),
                    _accentNeon.withOpacity(0.08),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTrailingParticles(double x, double y, Size screenSize) {
    final particleCount = 3;
    final particles = <Widget>[];
    
    for (int i = 0; i < particleCount; i++) {
      final offset = (i + 1) * 15.0;
      final opacity = (1.0 - (i * 0.3)).clamp(0.1, 0.2);
      
      particles.add(
        Positioned(
          left: x - offset - 5,
          top: y - offset - 5,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accentNeon,
                boxShadow: [
                  BoxShadow(
                    color: _accentNeon.withOpacity(0.5),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    
    return particles;
  }

  List<Widget> _buildBurstParticles(double x, double y, Size screenSize) {
    final particleCount = 8;
    final particles = <Widget>[];
    final random = math.Random();
    
    for (int i = 0; i < particleCount; i++) {
      final angle = (i * 2 * math.pi) / particleCount;
      final distance = 60.0 + (random.nextDouble() * 60);
      final particleX = x + (math.cos(angle) * distance);
      final particleY = y + (math.sin(angle) * distance);
      final opacity = (1.0 - _bubbleController.value).clamp(0.0, 1.0);
      
      particles.add(
        Positioned(
          left: particleX - 5,
          top: particleY - 5,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _accentNeon,
                boxShadow: [
                  BoxShadow(
                    color: _accentNeon.withOpacity(0.8),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    
    return particles;
  }

  Widget _buildHeadlineText(String title, String highlightedWord, Size screenSize) {
    final isSmallScreen = screenSize.height < 700;
    final words = title.toUpperCase().split(' ');
    final List<TextSpan> spans = [];
    
    final baseFontSize = isSmallScreen ? 28.0 : 38.0;
    final fontSize = baseFontSize.clamp(24.0, 44.0).toDouble();

    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      final isHighlighted = word == highlightedWord || word.contains(highlightedWord);

      spans.add(
        TextSpan(
          text: word,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            height: 1.2,
            color: isHighlighted ? _accentNeon : _highlightWhite,
            fontFamily: 'Roboto',
            shadows: [
              Shadow(
                offset: Offset(0, 3),
                blurRadius: 12,
                color: Colors.black.withOpacity(0.8),
              ),
              Shadow(
                offset: Offset(0, 1),
                blurRadius: 6,
                color: Colors.black.withOpacity(0.6),
              ),
            ],
          ),
        ),
      );

      if (i < words.length - 1) {
        spans.add(TextSpan(text: ' '));
      }
    }

    return RichText(
      text: TextSpan(children: spans),
      textAlign: TextAlign.center,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCTAButton() {
    return AnimatedBuilder(
      animation: _ctaGlowController,
      builder: (context, child) {
        final glowIntensity = 0.5 + (_ctaGlowController.value * 0.3);
        
        return Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: LinearGradient(
              colors: [
                _accentNeon,
                _accentNeon.withOpacity(0.8),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: _accentNeon.withOpacity(glowIntensity),
                blurRadius: 20,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: _accentNeon.withOpacity(glowIntensity * 0.5),
                blurRadius: 40,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                final preferences = await EncryptedSharedPreferences.getInstance();
                await preferences.setBoolean('isSeenUser', true);
                Get.offAll(() => CombinedAuthScreen());
              },
              borderRadius: BorderRadius.circular(32),
              child: Center(
                child: Text(
                  'Join Now',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _highlightWhite,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 2),
                        blurRadius: 4,
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Map<String, dynamic> _getPageContent(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return {
          'subtext': 'Real connections start here.',
          'features': [
            'Browse verified profiles',
            'Advanced matching algorithm',
            'Safe and secure platform',
          ],
        };
      case 1:
        return {
          'subtext': 'Your desires stay yours.',
          'features': [
            'Real-time location matching',
            'Profile verification system',
            'Privacy-focused design',
          ],
        };
      case 2:
        return {
          'subtext': 'With people nearby.',
          'features': [
            'Instant messaging',
            'Photo and video sharing',
            'Voice and video calls',
          ],
        };
      case 3:
        return {
          'subtext': 'Your night begins now.',
        };
      default:
        return {
          'subtext': 'Start your journey today.',
          'features': [],
        };
    }
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final isActive = index == currentPage;
        
        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 32 : 8,
          height: 3,
          decoration: BoxDecoration(
            color: isActive ? _accentNeon : _highlightWhite.withOpacity(0.3),
            borderRadius: BorderRadius.circular(2),
            boxShadow: isActive ? [
              BoxShadow(
                color: _accentNeon.withOpacity(0.6),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ] : null,
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: _primaryBackground,
          body: Center(
            child: CircularProgressIndicator(color: _accentNeon),
          ),
        ),
      );
    }

    // Ensure we have at least 4 items for the slider
    final List<String> titles = [];
    for (int i = 0; i < 4; i++) {
      if (i < controller.sliderData.length) {
        titles.add(controller.sliderData[i].title ?? 'MATCH. FEEL. EXPLORE.');
      } else if (controller.sliderData.isNotEmpty) {
        titles.add(controller.sliderData[0].title ?? 'MATCH. FEEL. EXPLORE.');
      } else {
        titles.add('MATCH. FEEL. EXPLORE.');
      }
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: _primaryBackground,
        body: Stack(
          children: [
            PageView.builder(
              controller: pageController,
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
                _updateBubbleForPage(index);
                
                // Trigger burst on slide 4
                if (index == 3) {
                  Future.delayed(Duration(milliseconds: 400), () {
                    if (mounted) {
                      _particleController.forward();
                    }
                  });
                }
              },
              itemCount: 4,
              itemBuilder: (context, index) {
                return _buildIntroPage(titles[index], index);
              },
            ),
            // Page indicator overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height * 0.04,
                  ),
                  child: Center(
                    child: _buildPageIndicator(),
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
