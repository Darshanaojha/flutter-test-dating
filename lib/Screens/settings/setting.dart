import 'package:dating_application/Controllers/controller.dart';
import 'package:dating_application/Screens/settings/appinfopages/appinfopagestart.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import 'ContaintCreator/creatorPlansScreen.dart';
import 'MoodSwings/MoodSwings.dart';
import 'changepassword/changepasswordnewpassword.dart';
import 'updateemailid/updateemailidpage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
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
  RxBool HookUpMode = false.obs;
  RxBool visibility_status = true.obs;
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
    getCurrentLocation();
    _loadSpotlightStatus();
  }

  Future<void> _loadSpotlightStatus() async {
    EncryptedSharedPreferences prefs =
        await EncryptedSharedPreferences.getInstance();
    bool isSpotlight = prefs.getBoolean('spotlightUser') ?? false;
    spotlightUser.value = isSpotlight;
  }

  Future<void> saveSpotlightStatus(bool value) async {
    EncryptedSharedPreferences prefs =
        await EncryptedSharedPreferences.getInstance();
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
    EncryptedSharedPreferences prefs =
        await EncryptedSharedPreferences.getInstance();
    await prefs.setBoolean('incognativeMode', value);
    Get.snackbar("Incognative Mode Save ", value.toString());
  }

  _onSwitchChnagedIncognative(bool value) {
    saveIncognativeStatus(value);
    setState(() {
      incognativeMode.value = value;
    });
  }

  Future<void> saveHookUpStatus(bool value) async {
    EncryptedSharedPreferences prefs =
        await EncryptedSharedPreferences.getInstance();
    await prefs.setBoolean('HookUpMode', value);
    Get.snackbar("HookUp Save ", value.toString());
  }

  _onSwitchChnagedHookUp(bool value) {
    saveHookUpStatus(value);
    setState(() {
      HookUpMode.value = value;
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: AppTextStyles.headingText.copyWith(
            fontSize: getResponsiveFontSize(0.035),
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.white),
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

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ListView(
              children: [
                // 🔥 Distance Setting Card
                SettingsCard(
                  icon: Icons.location_on,
                  title: "Maximum Distance (km)",
                  child: Slider(
                    value: maxDistance,
                    min: 0,
                    max: 500,
                    divisions: 50,
                    label: "${maxDistance.round()} km",
                    activeColor: AppColors.activeColor,
                    inactiveColor: AppColors.inactiveColor,
                    onChanged: (value) {
                      setState(() {
                        maxDistance = value;
                        controller.appSettingRequest.rangeKm = value.toString();
                      });
                    },
                  ),
                ),

                // 🔥 Age Range Slider
                SettingsCard(
                  icon: Icons.favorite_border,
                  title: "Age Range",
                  child: RangeSlider(
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
                      setState(() {
                        ageRange = values;
                        controller.appSettingRequest.minimumAge =
                            values.start.round().toString();
                        controller.appSettingRequest.maximumAge =
                            values.end.round().toString();
                      });
                    },
                  ),
                ),

                SizedBox(height: 20),

                // 🌟 Apply Button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      controller.appsetting(controller.appSettingRequest);
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.check_circle_outline),
                    label: Text("Apply Settings"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.buttonColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 36),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),

                SizedBox(height: 24),

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
                  onChanged: _onSwitchChnagedIncognative,
                ),
                _buildPrivacyToggle(
                  title: "HookUp Mode",
                  icon: Icons.whatshot,
                  value: HookUpMode.value,
                  labelOn: "HookUp Active 🔥",
                  labelOff: "HookUp Inactive",
                  onChanged: _onSwitchChnagedHookUp,
                ),

                SizedBox(height: screenHeight * 0.04),

                // 😎 Mood Section (Expandable)
                GestureDetector(
                  onTap: () => setState(() => isExpanded = !isExpanded),
                  child: Card(
                    color: Colors.deepPurpleAccent.withOpacity(0.85),
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 400),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.emoji_emotions, color: Colors.amberAccent),
                          SizedBox(width: 12),
                          Text(
                            'Selected Mood',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: screenHeight * 0.02),
                GestureDetector(
                  onTap: () {
                    Get.to(PricingPage());
                  },
                  child: Card(
                    color: Colors.deepPurpleAccent.withOpacity(0.85),
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 400),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.emoji_symbols_outlined,
                              color: Colors.amberAccent),
                          SizedBox(width: 12),
                          Text(
                            'Become Containt Creator',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingsButton(
      {required String label,
      required IconData icon,
      required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 4,
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
            Icon(icon, color: AppColors.primaryColor, size: 28),
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
                Icon(icon, color: AppColors.primaryColor, size: 24),
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
