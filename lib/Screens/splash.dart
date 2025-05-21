import 'dart:async';
import 'package:dating_application/Controllers/controller.dart';
import 'package:dating_application/Models/RequestModels/update_activity_status_request_model.dart';
import 'package:dating_application/Screens/navigationbar/navigationpage.dart';
import 'package:dating_application/Screens/navigationbar/unsubscribenavigation.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../Models/RequestModels/update_lat_long_request_model.dart';
import '../Providers/fcmService.dart';
import '../constants.dart';
import 'introsliderpages/introsliderswipepage.dart';
import 'login.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> opacityAnimation;
  late Animation<double> scaleAnimation;
  Controller controller = Get.put(Controller());
  bool _isLoading = true;
  bool isSeenUser = false;
  StreamSubscription? _linkSubscription;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..forward();

    opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeIn),
    );

    scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeInOut),
    );

    intialize();
  }

  intialize() async {
    try {
      EncryptedSharedPreferences preferences =
          EncryptedSharedPreferences.getInstance();

      String? token = preferences.getString('token');
      debugPrint("Token: $token");
      bool? value = preferences.getBoolean('isSeenUser');
      if (value == null || value == false) {
        controller.fetchAllIntroSlider().then((value) {
          if (value == true) {
            preferences.setBoolean('isSeenUser', true);

            Get.offAll(() => IntroSlidingPages());
          } else {
            failure('Error', 'Failed to fetch the intro slider');
          }
        });
        return;
      }
      // await controller.fetchAllHeadlines();
      await controller.fetchSafetyGuidelines();
      await controller.fetchAllPackages();
      await controller.fetchlang();
      await controller.fetchDesires();
      await controller.fetchGenders();
      await controller.fetchCountries();
      String? packageStatus;
      if (token == null || token.isEmpty) {
        Get.offAll(() => Login());
      } else {
        await controller.userSuggestions();
        await controller.fetchallfavourites();
        await controller.reportReason();
        await controller.fetchalluserconnections();
        await controller.fetchAllverificationtype();
        await controller.fetchProfileUserPhotos();
        await controller.fetchAllFaq();
        await controller.userSuggestions();
        await controller.fetchAllsubscripted();
        await controller.likesuserpage();
        await controller.fetchallpingrequestmessage();
        await controller.fetchAllAddOn();
        await controller.allOrders();
        await controller.allTransactions();
        await controller.gettotalpoint();
        await controller.getpointdetailsamount();
        await controller.fetchProfile().then((_) {
          packageStatus = controller.userData.first.packageStatus;
          if (packageStatus != null && packageStatus!.isNotEmpty) {
            if (packageStatus == "1") {
              FCMService().subscribeToTopic("subscribed");
              FCMService().subscribeToTopic(controller.userData.first.id);
              FCMService().subscribeToTopic("alluser");
              Get.offAll(() => NavigationBottomBar());
            } else {
              FCMService().subscribeToTopic("unsubscribed");
              FCMService().subscribeToTopic(controller.userData.first.id);
              FCMService().subscribeToTopic("alluser");
              Get.offAll(() => Unsubscribenavigation());
            }
          }
        });
      }
      Position position = await _getUserLocation();
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks.first;

      UpdateLatLongRequest updateLatLongRequest = UpdateLatLongRequest(
        latitude: position.latitude.toString(),
        longitude: position.longitude.toString(),
        city: place.locality ?? 'Unknown',
        address: place.name ?? 'Unknown',
      );
      controller.updatelatlong(updateLatLongRequest);

      UpdateActivityStatusRequest updateActivityStatusRequest =
          UpdateActivityStatusRequest(status: '1');
      controller.updateactivitystatus(updateActivityStatusRequest);
    } catch (e) {
      failure("Error", e.toString());
      Get.offAll(() => Login());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Position> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        throw 'Location permission denied';
      }
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        color: AppColors.primaryColor,
        child: Center(
          child: _isLoading
              ? SpinKitCircle(
                  size: 150,
                  color: AppColors.progressColor,
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeTransition(
                      opacity: opacityAnimation,
                      child: ScaleTransition(
                        scale: scaleAnimation,
                        child: Text(
                          "FlamR",
                          style: GoogleFonts.raleway(
                            fontSize: mQuery.width * 0.08,
                            color: AppColors.textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    FadeTransition(
                      opacity: opacityAnimation,
                      child: ScaleTransition(
                        scale: scaleAnimation,
                        child: Text(
                          "Application",
                          style: GoogleFonts.raleway(
                            fontSize: mQuery.width * 0.04,
                            color: AppColors.textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
