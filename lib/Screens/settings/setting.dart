import 'package:dating_application/Controllers/controller.dart';
import 'package:dating_application/Screens/settings/appinfopages/appinfopagestart.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import 'ContaintCreator/creatorPlansScreen.dart';
import 'changepassword/changepasswordnewpassword.dart';
import 'updateemailid/updateemailidpage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  double maxDistance = 50.0;
  RangeValues ageRange = RangeValues(18, 35);
  final List<String> lookingFor = [];
  double getResponsiveFontSize(double scale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * scale;
  }

  Controller controller = Get.put(Controller());
  final TextEditingController desireController = TextEditingController();
  bool showOnlineUsers = false;
  bool isExpanded = false;
  RxBool spotlightUser = false.obs;
  RxBool incognativeMode = false.obs;
  RxBool hookUpMode = false.obs;
  RxBool visibilityStatus = true.obs;
  String currentLocation = "Fetching...";
  String locationSelection = "Current Location";

  final List<String> genderOptions = ['Male', 'Female', 'Non-Binary'];

  final List<String> predefinedLocations = [
    "New York",
    "Los Angeles",
    "San Francisco",
    "Chicago",
    "Miami"
  ];

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    // Wait for profile data if not present
    if (controller.userData.isEmpty) {
      await controller.fetchProfile();
    }
    if (controller.userData.isNotEmpty) {
      controller.fetchProfile();
      final user = controller.userData.first;
      setState(() {
        // Distance
        maxDistance = double.tryParse(user.rangeKm ?? '50') ?? 50.0;
        // Age Range
        double minAge = double.tryParse(user.minimumAge ?? '18') ?? 18;
        double maxAge = double.tryParse(user.maximumAge ?? '35') ?? 35;
        ageRange = RangeValues(minAge, maxAge);
        // Spotlight
        spotlightUser.value = (user.accountHighlightStatus == "1");
        // Incognito
        incognativeMode.value = (user.incognativeMode == "1");
        // Hookup
        hookUpMode.value = (user.hookupStatus == "1");
      });
    }
    getCurrentLocation();
    _loadSpotlightStatus();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSpotlightStatus() async {
    EncryptedSharedPreferences prefs = EncryptedSharedPreferences.getInstance();
    bool isSpotlight = prefs.getBoolean('spotlightUser') ?? false;
    spotlightUser.value = isSpotlight;
  }

  Future<void> saveSpotlightStatus(bool value) async {
    EncryptedSharedPreferences prefs = EncryptedSharedPreferences.getInstance();
    await prefs.setBoolean('spotlightUser', value);
    Get.snackbar("save ", value.toString());
  }

  _onSwitchChanged(bool value) {
    saveSpotlightStatus(value);
    setState(() {
      spotlightUser.value = value;
      controller.highlightProfileStatusRequest.status = value ? '1' : '0';
    });

    controller.highlightProfile(controller.highlightProfileStatusRequest);
  }

  Future<void> saveIncognativeStatus(bool value) async {
    EncryptedSharedPreferences prefs = EncryptedSharedPreferences.getInstance();
    await prefs.setBoolean('incognativeMode', value);
    // Get.snackbar("Incognative Mode Save ", value.toString());
  }

  _onSwitchChangedIncognative(bool value) {
    saveIncognativeStatus(value);
    controller.updateIncognitoStatus(value ? 1 : 0);
    setState(() {
      incognativeMode.value = value;
    });
  }

  Future<void> saveHookUpStatus(bool value) async {
    EncryptedSharedPreferences prefs = EncryptedSharedPreferences.getInstance();
    await prefs.setBoolean('HookUpMode', value);
    // Get.snackbar("HookUp Save ", value.toString());
  }

  _onSwitchChnagedHookUp(bool value) {
    saveHookUpStatus(value);
    value ? controller.updateHookupStatus(1) : controller.updateHookupStatus(0);
    setState(() {
      hookUpMode.value = value;
    });
  }

  Future<void> getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        currentLocation = "Location permissions are permanently denied";
      });
    } else if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        currentLocation =
            "Lat: ${position.latitude}, Long: ${position.longitude}";
      });
    } else {
      setState(() {
        currentLocation = "Unable to fetch location";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final fontSize = getResponsiveFontSize(0.04);

    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
        centerTitle: true,
        title: Builder(
          builder: (context) {
            double fontSize = MediaQuery.of(context).size.width * 0.05;
            return Text(
              "Settings",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
                color: AppColors.textColor,
              ),
            );
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.gradientBackgroundList,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () => Get.to(AppInfoPage()),
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _loadSpotlightStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            children: [
              // 🔥 Distance Setting Card
              SettingsCard(
                icon: Icons.location_on,
                title: "Maximum Distance (km)",
                child: StatefulBuilder(
                  builder: (context, setStateSB) {
                    return Slider(
                      value: maxDistance,
                      min: 0,
                      max: 500,
                      divisions: 50,
                      label: "${maxDistance.round()} km",
                      activeColor: AppColors.activeColor,
                      inactiveColor: AppColors.inactiveColor,
                      onChanged: (value) {
                        setStateSB(() {
                          maxDistance = value;
                          controller.appSettingRequest.rangeKm =
                              value.toString();
                        });
                      },
                    );
                  },
                ),
              ),

              // 🔥 Age Range Slider
              SettingsCard(
                icon: Icons.favorite_border,
                title: "Age Range",
                child: StatefulBuilder(
                  builder: (context, setStateSB) {
                    return RangeSlider(
                      values: ageRange,
                      min: 18,
                      max: 100,
                      divisions: 82,
                      labels: RangeLabels(
                        "${ageRange.start.round()}",
                        "${ageRange.end.round()}",
                      ),
                      activeColor: AppColors.activeColor,
                      inactiveColor: AppColors.inactiveColor,
                      onChanged: (RangeValues values) {
                        setStateSB(() {
                          ageRange = values;
                          controller.appSettingRequest.minimumAge =
                              values.start.round().toString();
                          controller.appSettingRequest.maximumAge =
                              values.end.round().toString();
                        });
                      },
                    );
                  },
                ),
              ),

              SizedBox(height: 20),

              // 🌟 Apply Button
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: GradientButton(
                    onPressed: () {
                      controller.appSettingRequest.rangeKm =
                          maxDistance.round().toString();
                      controller.appSettingRequest.minimumAge =
                          ageRange.start.round().toString();
                      controller.appSettingRequest.maximumAge =
                          ageRange.end.round().toString();
                      controller.appsetting(controller.appSettingRequest);
                    },
                    borderRadius: 14,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          "Apply Settings",
                          style: AppTextStyles.buttonText.copyWith(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 28),

              // 💡 Privacy Toggles
              _buildPrivacyToggle(
                title: "Spotlight Profile",
                icon: Icons.flash_on,
                value: spotlightUser.value,
                labelOn: "You're in the spotlight 🌟",
                labelOff: "Not visible in spotlight",
                onChanged: _onSwitchChanged,
              ),
              _buildPrivacyToggle(
                title: "Incognitō Mode",
                icon: Icons.visibility_off,
                value: incognativeMode.value,
                labelOn: "You're browsing secretly 🕵️‍♂️",
                labelOff: "Others can see you",
                onChanged: _onSwitchChangedIncognative,
              ),
              _buildPrivacyToggle(
                title: "HookUp Mode",
                icon: Icons.whatshot,
                value: hookUpMode.value,
                labelOn: "HookUp Active 🔥",
                labelOff: "HookUp Inactive",
                onChanged: _onSwitchChnagedHookUp,
              ),

              SizedBox(height: screenHeight * 0.04),

              // 😎 Mood Section (Expandable)
              GestureDetector(
                onTap: () => setState(() => isExpanded = !isExpanded),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.gradientBackgroundList,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Card(
                    color: Colors.transparent,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    margin: EdgeInsets.zero,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 400),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.emoji_emotions, color: Colors.amberAccent),
                          SizedBox(width: 12),
                          Text(
                            'Selected Mood',
                            style: TextStyle(
                              fontSize: fontSize * 1.1,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.02),
              GestureDetector(
                onTap: () {
                  Get.to(PricingPage());
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.gradientBackgroundList,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Card(
                    color: Colors.transparent,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    margin: EdgeInsets.zero,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 400),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.emoji_symbols_outlined,
                              color: Colors.amberAccent),
                          SizedBox(width: 12),
                          Text(
                            'Become Content Creator',
                            style: TextStyle(
                              fontSize: fontSize * 1.1,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.02),
              // 🔐 Change Password & Email
              _buildSettingsButton(
                label: "Change Password",
                icon: Icons.lock_outline,
                onPressed: () => Get.to(ChangePasswordPage()),
              ),
              SizedBox(height: 12),
              _buildSettingsButton(
                label: "Update Email",
                icon: Icons.email_outlined,
                onPressed: () => Get.to(UpdateEmailPage()),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSettingsButton(
      {required String label,
      required IconData icon,
      required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.gradientBackgroundList,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(label, style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildPrivacyToggle({
    required String title,
    required IconData icon,
    required bool value,
    required String labelOn,
    required String labelOff,
    required Function(bool) onChanged,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.subheadingText.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
                  SizedBox(height: 4),
                  Text(
                    value ? labelOn : labelOff,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              activeColor: AppColors.navigationColor,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showLocationSelectionDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Location Type",
              style: AppTextStyles.headingText
                  .copyWith(fontSize: getResponsiveFontSize(0.03))),
          backgroundColor: AppColors.secondaryColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text("Use Current Location",
                    style: AppTextStyles.textStyle
                        .copyWith(fontSize: getResponsiveFontSize(0.03))),
                value: "Current Location",
                groupValue: locationSelection,
                onChanged: (value) {
                  setState(() {
                    locationSelection = value!;
                  });
                  Navigator.pop(context);
                  getCurrentLocation();
                },
              ),
              RadioListTile<String>(
                title: Text("Select from List",
                    style: AppTextStyles.textStyle
                        .copyWith(fontSize: getResponsiveFontSize(0.03))),
                value: "Select from List",
                groupValue: locationSelection,
                onChanged: (value) {
                  setState(() {
                    locationSelection = value!;
                  });
                  Navigator.pop(context);
                  showLocationListDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> showLocationListDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Location",
              style: AppTextStyles.headingText
                  .copyWith(fontSize: getResponsiveFontSize(0.03))),
          backgroundColor: AppColors.secondaryColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: predefinedLocations.map((location) {
              return ListTile(
                title: Text(location,
                    style: AppTextStyles.textStyle
                        .copyWith(fontSize: getResponsiveFontSize(0.03))),
                onTap: () {
                  setState(() {
                    currentLocation = location;
                    locationSelection = location;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class PrivacyToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const PrivacyToggle(
      {super.key,
      required this.label,
      required this.value,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    double getResponsiveFontSize(double scale) {
      double screenWidth = MediaQuery.of(context).size.width;
      return screenWidth * scale;
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: AppTextStyles.bodyText
                  .copyWith(fontSize: getResponsiveFontSize(0.02))),
          Transform.scale(
            scale: 0.6,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.progressColor,
              inactiveThumbColor: AppColors.progressColor,
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const SettingsCard({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 24),
                SizedBox(width: 8),
                Text(
                  title,
                  style: AppTextStyles.subheadingText.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

// GradientButton widget
class GradientButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final List<Color>? gradientColors;

  const GradientButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.borderRadius = 18,
    this.padding = const EdgeInsets.symmetric(vertical: 18),
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(borderRadius),
      onTap: onPressed,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors ?? AppColors.gradientBackgroundList,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Container(
          padding: padding,
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}
