import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import '../../../Controllers/controller.dart';
import '../../../Models/ResponseModels/profile_like_response_model.dart';
import '../../../Models/ResponseModels/ProfileResponse.dart';
import '../../../constants.dart';

class UserProfileSummary extends StatefulWidget {
  // optional prameter for user id
  final String? userId;
  final List<String>? imageUrls;
  final bool showLikeButton;
  final Function(bool isMatch)? onLikeSuccess;
  const UserProfileSummary({
    super.key, 
    this.userId, 
    this.imageUrls,
    this.showLikeButton = false,
    this.onLikeSuccess,
  });

  @override
  State<UserProfileSummary> createState() => _UserProfileSummaryState();
}

class _UserProfileSummaryState extends State<UserProfileSummary> with TickerProviderStateMixin {
  final Controller controller = Get.find();
  late Future<bool> _fetchProfileFuture;
  bool _isLiking = false;
  late final PageController _pageController;
  final ScrollController _glassController = ScrollController();
  int _currentPage = 0;
  bool _showHeroIndicators = true;
  bool _showHeartAnimation = false;
  AnimationController? _heartAnimationController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fetchProfileFuture = _initializeSummaryData();
    _heartAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (mounted) {
            setState(() {
              _showHeartAnimation = false;
            });
            _heartAnimationController?.reset();
          }
        }
      });
  }

  Future<void> _handleLike() async {
    print("UserProfileSummary: _handleLike called");
    if (_isLiking || widget.userId == null) {
      print("UserProfileSummary: Early return - _isLiking: $_isLiking, userId: ${widget.userId}");
      return;
    }
    
    print("UserProfileSummary: Setting _isLiking to true");
    setState(() {
      _isLiking = true;
      _showHeartAnimation = true;
    });
    
    // Start heart animation
    _heartAnimationController?.forward();

    try {
      print("UserProfileSummary: Calling profileLike with userId: ${widget.userId}");
      controller.profileLikeRequest.likedBy = widget.userId!;
      ProfileLikeResponse? response = await controller.profileLike(controller.profileLikeRequest);
      
      // Debug logging
      print("UserProfileSummary: ProfileLike Response: $response");
      if (response != null) {
        print("UserProfileSummary: Response success: ${response.success}");
        print("UserProfileSummary: Response error code: ${response.error.code}");
        print("UserProfileSummary: Response error message: ${response.error.message}");
        print("UserProfileSummary: Response connection: ${response.payload.connection}");
      } else {
        print("UserProfileSummary: Response is null");
      }
      
      if (response != null) {
        // First check if the error message indicates "already liked" - treat as success
        String errorMsg = response.error.message.toLowerCase().trim();
        print("UserProfileSummary: Checking error message: '$errorMsg'");
        print("UserProfileSummary: Error code: ${response.error.code}, Success: ${response.success}");
        
        // Check for various forms of "already liked" message
        bool isAlreadyLiked = errorMsg.contains("already liked") || 
                             errorMsg.contains("already like") ||
                             errorMsg.contains("you have already") ||
                             errorMsg.contains("have already liked");
        
        print("UserProfileSummary: isAlreadyLiked: $isAlreadyLiked");
        
        // Check if it's a successful like (error.code == 0 or success == true)
        bool isSuccessful = response.error.code == 0 || response.success == true;
        
        if (isAlreadyLiked || isSuccessful) {
          // Profile is already liked or successfully liked, treat as success
          if (isAlreadyLiked) {
            print("UserProfileSummary: Showing 'Already Liked' success message");
            success("Already Liked", "You have already liked this profile.");
          } else {
            print("UserProfileSummary: Successful like");
            bool isMatch = response.payload.connection;
            
            if (isMatch) {
              success("It's a Match!", "You both liked each other!");
            } else {
              success("Liked!", "You have successfully liked this profile.");
            }
          }
          
          // Call the callback to refresh the page (only if not already liked, or always to refresh)
          if (widget.onLikeSuccess != null) {
            print("UserProfileSummary: Calling onLikeSuccess callback");
            try {
              bool isMatch = response.payload.connection;
              await widget.onLikeSuccess!(isMatch);
              print("UserProfileSummary: onLikeSuccess callback completed successfully");
            } catch (e, stackTrace) {
              print("UserProfileSummary: Error in onLikeSuccess callback: $e");
              print("Stack trace: $stackTrace");
              // Don't show error to user since the like operation itself succeeded
            }
          }
        } else {
          // Only show error if it's actually an error (not already liked and not successful)
          print("UserProfileSummary: Showing error - code: ${response.error.code}, message: ${response.error.message}");
          String displayMsg = response.error.message.isNotEmpty 
              ? response.error.message 
              : "Failed to like the profile. Please try again.";
          failure("Failed", displayMsg);
        }
      } else {
        print("UserProfileSummary: Response is null, showing failure");
        failure("Failed", "Failed to like the profile. Please try again.");
      }
    } catch (e, stackTrace) {
      print("Exception in _handleLike: $e");
      print("Stack trace: $stackTrace");
      // Only show error if it's a real exception, not if the operation succeeded
      failure("Error", "An error occurred while liking the profile: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() {
          _isLiking = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _glassController.dispose();
    _heartAnimationController?.dispose();
    super.dispose();
  }

  Future<bool> _initializeSummaryData() async {
    print("Fetching profile photos for  ${widget.userId}");
    final profileSuccess = await (widget.userId != null
        ? controller.fetchProfile(widget.userId!)
        : controller.fetchProfile());
    if (!profileSuccess) return false;
    
    return (widget.userId != null)
        ? controller.fetchProfileUserPhotos(widget.userId!)
        : controller.fetchProfileUserPhotos();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _fetchProfileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Lottie.asset("assets/animations/homeanimation.json"),
          );
        }
        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!) {
          return const Center(
            child: Text(
              'Could not load profile. Please try again.',
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        final user = controller.userData.first;
        final desires = controller.userDesire;
        final preferences = controller.userPreferences;
        final langs = controller.userLang;

        double fontSize = MediaQuery.of(context).size.width * 0.045;
        double valueFontSize = fontSize * 0.85;
        final double heroHeight =
            MediaQuery.of(context).size.height * 0.85;

        final List<String> photos = (widget.imageUrls != null &&
                widget.imageUrls!.isNotEmpty)
            ? widget.imageUrls!
            : (controller.userPhotos != null &&
                    controller.userPhotos!.images.isNotEmpty)
                ? controller.userPhotos!.images
                : <String>[];
        final bool hasPhotos = photos.isNotEmpty;

        // New overlay experience: fixed hero background, glass content scroll.
        // Start the glass card lower so only a sliver shows before scroll.
        final double contentTop = (heroHeight - 60).clamp(120.0, heroHeight);
        final Widget bodyStack = NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (notification) {
            notification.disallowIndicator();
            return true;
          },
          child: Stack(
            children: [
              Positioned.fill(
                child: hasPhotos
                    ? ScrollConfiguration(
                        behavior: _NoGlowScrollBehavior(),
                        child: PageView.builder(
                          controller: _pageController,
                          physics: const ClampingScrollPhysics(),
                          itemCount: photos.length,
                          onPageChanged: (i) => setState(() => _currentPage = i),
                          itemBuilder: (context, index) {
                            return _buildProfileImage(
                              photos[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              borderRadius: BorderRadius.zero,
                            );
                          },
                        ),
                      )
                    : Container(color: Colors.grey.shade800),
              ),
              Positioned.fill(
              child: IgnorePointer(
                ignoring: true,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.0),
                        Colors.black.withOpacity(0.35),
                        Colors.black.withOpacity(0.65),
                        Colors.black.withOpacity(0.75),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (hasPhotos && photos.length > 1)
              Positioned(
                top: 12,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  ignoring: true,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 160),
                    opacity: _showHeroIndicators ? 1 : 0,
                    child: Row(
                      children: List.generate(photos.length, (index) {
                        final bool active = index == _currentPage;
                        return Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 1.5),
                            decoration: BoxDecoration(
                              color: active
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.35),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification.metrics.axis == Axis.vertical) {
                    final bool show = notification.metrics.pixels <= 8.0;
                    if (show != _showHeroIndicators && mounted) {
                      setState(() => _showHeroIndicators = show);
                    }
                  }
                  return false;
                },
                child: ScrollConfiguration(
                  behavior: _NoGlowScrollBehavior(),
                  child: SingleChildScrollView(
                    controller: _glassController,
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IgnorePointer(
                          ignoring: true,
                          child: SizedBox(height: contentTop),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(0.08),
                                    Colors.white.withOpacity(0.03),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.16),
                                  width: 1.2,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(
                                  MediaQuery.of(context).size.width * 0.04,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Compact header: Name + Age
                                    _buildCompactProfileHeader(user, valueFontSize),
                                    
                                    // Gender + SubGender (grouped)
                                    _buildAttributeLine(
                                      icon: Icons.wc,
                                      values: [
                                        user.genderName,
                                        user.subGenderName,
                                      ],
                                      fontSize: valueFontSize,
                                    ),
                                    
                                    // City + Looking For (grouped)
                                    _buildAttributeLine(
                                      icon: Icons.location_city,
                                      values: [
                                        user.city,
                                        (user.lookingFor == "1")
                                            ? "Serious Relationship"
                                            : "Hookup",
                                      ],
                                      fontSize: valueFontSize,
                                    ),
                                    
                                    // Bio section (if available)
                                    if (user.bio.isNotEmpty) ...[
                                      SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                                      Container(
                                        padding: EdgeInsets.all(
                                          MediaQuery.of(context).size.width * 0.03,
                                        ),
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(15.0),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.16),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          user.bio,
                                          style: AppTextStyles.bodyText.copyWith(
                                            fontSize: valueFontSize * 0.95,
                                            color: Colors.white.withOpacity(0.9),
                                          ),
                                        ),
                                      ),
                                    ],
                                    
                                    // Chip sections with headers
                                    if (user.interest.isNotEmpty)
                                      _buildChipSection(
                                        icon: Icons.interests,
                                        title: "Interests",
                                        items: user.interest
                                            .split(',')
                                            .map((e) => e.trim())
                                            .toList(),
                                        fontSize: valueFontSize,
                                      ),
                                    
                                    if (desires.isNotEmpty)
                                      _buildChipSection(
                                        icon: Icons.explore,
                                        title: "Desires",
                                        items: desires.map((d) => d.title).toList(),
                                        fontSize: valueFontSize,
                                      ),
                                    
                                    if (preferences.isNotEmpty)
                                      _buildChipSection(
                                        icon: Icons.tune,
                                        title: "Preferences",
                                        items: preferences.map((p) => p.title).toList(),
                                        fontSize: valueFontSize,
                                      ),
                                    
                                    if (langs.isNotEmpty)
                                      _buildChipSection(
                                        icon: Icons.language,
                                        title: "Languages",
                                        items: langs.map((l) => l.title).toList(),
                                        fontSize: valueFontSize,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

        // Always show like button FAB when viewing a profile (if userId is provided)
        return Scaffold(
          backgroundColor: AppColors.primaryColor,
          body: Stack(
            children: [
              bodyStack,
              // Heart animation overlay - similar to swipe right effect
              if (_showHeartAnimation)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Stack(
                      children: [
                        // Multiple hearts floating up (like swipe right animation)
                        ...List.generate(5, (index) {
                          final delay = index * 0.1;
                          
                          return _heartAnimationController != null
                              ? AnimatedBuilder(
                                  animation: _heartAnimationController!,
                                  builder: (context, child) {
                                    final adjustedValue = (_heartAnimationController!.value - delay).clamp(0.0, 1.0);
                              if (adjustedValue <= 0) return const SizedBox.shrink();
                              
                              final screenSize = MediaQuery.of(context).size;
                              final centerX = screenSize.width / 2;
                              final centerY = screenSize.height / 2;
                              
                              // Calculate position with upward movement
                              final offsetY = -adjustedValue * screenSize.height * 0.3;
                              final offsetX = (index - 2) * 30.0 * adjustedValue;
                              final scale = 0.5 + (adjustedValue * 1.5);
                              final opacity = 1.0 - adjustedValue;
                              
                              return Positioned(
                                left: centerX - 40 + offsetX,
                                top: centerY - 40 + offsetY,
                                child: Opacity(
                                  opacity: opacity,
                                  child: Transform.scale(
                                    scale: scale,
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.pink.withOpacity(0.6 * opacity),
                                            blurRadius: 20,
                                            spreadRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.favorite,
                                        color: Colors.pink.shade400,
                                        size: 60,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                                  },
                                )
                              : const SizedBox.shrink();
                        }),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          floatingActionButton: widget.userId != null
              ? FloatingActionButton(
                  onPressed: _isLiking ? null : _handleLike,
                  backgroundColor: AppColors.mediumGradientColor,
                  child: _isLiking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(
                          Icons.favorite,
                          color: Colors.white,
                        ),
                )
              : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }
    

  /// Compact profile header with name, age, and verification status
  Widget _buildCompactProfileHeader(UserData user, double fontSize) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height * 0.015,
        left: MediaQuery.of(context).size.width * 0.025,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_titleCase(user.name.isNotEmpty ? user.name : user.username)}, ${_getAge(user.dob)}',
            style: AppTextStyles.bodyText.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: fontSize + 2,
            ),
          ),
          const SizedBox(width: 6),
          (user.accountVerificationStatus == "1" || 
           user.packageStatus == "4" || 
           user.packageStatus == "1")
              ? Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.mediumGradientColor.withOpacity(0.6),
                          blurRadius: 12,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.verified,
                      color: AppColors.mediumGradientColor,
                      size: fontSize + 4,
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Icon(
                    Icons.error_outline_outlined,
                    color: Colors.yellow[700],
                    size: fontSize + 4,
                  ),
                ),
        ],
      ),
    );
  }

  /// Attribute line with icon and bullet-separated values
  Widget _buildAttributeLine({
    required IconData icon,
    required List<String> values,
    required double fontSize,
  }) {
    final nonEmptyValues = values.where((v) => v.isNotEmpty).toList();
    if (nonEmptyValues.isEmpty) return const SizedBox.shrink();

    final screenHeight = MediaQuery.of(context).size.height;
    final verticalPadding = screenHeight * 0.008;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.activeColor),
          SizedBox(width: MediaQuery.of(context).size.width * 0.025),
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: nonEmptyValues.asMap().entries.map((entry) {
                final isLast = entry.key == nonEmptyValues.length - 1;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      entry.value,
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: fontSize * 0.9,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    if (!isLast) ...[
                      SizedBox(width: 8),
                      Text(
                        '•',
                        style: TextStyle(
                          fontSize: fontSize * 0.9,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Chip section with title and wrapped chips
  Widget _buildChipSection({
    required IconData icon,
    required String title,
    required List<String> items,
    required double fontSize,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = screenHeight * 0.015;

    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              bottom: screenHeight * 0.01,
              left: MediaQuery.of(context).size.width * 0.025,
            ),
            child: Row(
              children: [
                Icon(icon, size: 22, color: AppColors.activeColor),
                SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                Text(
                  title,
                  style: AppTextStyles.bodyText.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.025,
            ),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 6.0,
              children: items.map((item) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.gradientBackgroundList,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25.0),
                    border: Border.all(
                      color: Colors.white,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: fontSize * 0.9,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _titleCase(String input) {
    if (input.isEmpty) return input;
    return input
        .split(' ')
        .map((word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  static int _getAge(String dob) {
    try {
      final date = DateFormat('MM/dd/yyyy').parse(dob);
      final now = DateTime.now();
      int age = now.year - date.year;
      if (now.month < date.month ||
          (now.month == date.month && now.day < date.day)) {
        age--;
      }
      return age;
    } catch (_) {
      return 0;
    }
  }

  Widget _buildProfileImage(
    String src, {
    BoxFit fit = BoxFit.cover,
    double? width,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(15)),
  }) {
    final bool isNetwork = src.startsWith('http://') || src.startsWith('https://');
    final Widget error = Container(
      width: 250,
      color: Colors.grey[200],
      alignment: Alignment.center,
      child: const Icon(
        Icons.broken_image,
        color: Colors.grey,
        size: 48,
      ),
    );

    if (isNetwork) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: Image.network(
          src,
          fit: fit,
          width: width ?? 250,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              width: width ?? 250,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (_, __, ___) => error,
        ),
      );
    }

    // Treat as base64 if not network.
    try {
      final String normalized = _normalizeBase64(src);
      // Validate base64 string before decoding
      if (normalized.isEmpty) {
        debugPrint('⚠️ Empty base64 string for image');
        return error;
      }
      
      final Uint8List bytes = base64Decode(normalized);
      
      // Validate decoded bytes are not empty
      if (bytes.isEmpty) {
        debugPrint('⚠️ Decoded bytes are empty for image');
        return error;
      }
      
      return ClipRRect(
        borderRadius: borderRadius,
        child: Image.memory(
          bytes,
          fit: fit,
          width: width ?? 250,
          errorBuilder: (context, errorObj, stackTrace) {
            debugPrint('⚠️ Image.memory decode error: $errorObj');
            debugPrint('⚠️ Stack trace: $stackTrace');
            debugPrint('⚠️ Base64 string length: ${normalized.length}');
            debugPrint('⚠️ Base64 preview: ${normalized.substring(0, normalized.length > 50 ? 50 : normalized.length)}...');
            return error;
          },
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('⚠️ Base64 decode exception: $e');
      debugPrint('⚠️ Stack trace: $stackTrace');
      debugPrint('⚠️ Image source preview: ${src.substring(0, src.length > 100 ? 100 : src.length)}...');
      return error;
    }
  }

  String _normalizeBase64(String input) {
    final String cleaned =
        input.contains(',') ? input.split(',').last.trim() : input.trim();
    final int remainder = cleaned.length % 4;
    if (remainder == 0) return cleaned;
    return cleaned + '=' * (4 - remainder);
  }

  Widget _GlassNamePlate({required String name, int? age}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
          ),
          child: Text(
            name,
            style: AppTextStyles.headingText.copyWith(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }
}
class _GalleryRow extends StatelessWidget {
  final List<String> sources;
  final Widget Function(String) builder;

  const _GalleryRow({
    required this.sources,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    if (sources.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: sources.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 140,
              child: builder(sources[index]),
            ),
          );
        },
      ),
    );
  }
}
