import 'package:dating_application/Controllers/controller.dart';
import 'package:dating_application/Screens/settings/appinfopages/appinfopagestart.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import '../../constants.dart';
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
  RxBool spotlightUser = false.obs;
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
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Settings",
            style: AppTextStyles.headingText.copyWith(
              fontSize: getResponsiveFontSize(0.03),
            ),
          ),
          backgroundColor: AppColors.primaryColor,
          actions: [
            IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: () {
                Get.to(AppInfoPage());
              },
            ),
          ],
        ),
        body: FutureBuilder<void>(
            future: _loadSpotlightStatus(),
            builder: (context, snapshot) {
              // While loading, show a loading indicator or placeholder
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    // Maximum Distance
                    Text("Maximum Distance (km)",
                        style: AppTextStyles.subheadingText
                            .copyWith(fontSize: getResponsiveFontSize(0.03))),
                    Slider(
                      value: maxDistance,
                      min: 0,
                      max: 500,
                      divisions: 50,
                      label: maxDistance.toStringAsFixed(0),
                      activeColor: AppColors.activeColor,
                      inactiveColor: AppColors.inactiveColor,
                      onChanged: (double value) {
                        setState(() {
                          maxDistance = value;
                          controller.appSettingRequest.rangeKm =
                              value.toString();
                        });
                      },
                    ),
                    SizedBox(height: 20),

// Age Range
                    Text("Age Range",
                        style: AppTextStyles.subheadingText
                            .copyWith(fontSize: getResponsiveFontSize(0.03))),
                    RangeSlider(
                      values: ageRange,
                      min: 18,
                      max: 100,
                      divisions: 82,
                      labels: RangeLabels(
                        ageRange.start.round().toString(),
                        ageRange.end.round().toString(),
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

                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        controller.appsetting(controller.appSettingRequest);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonColor,
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Apply",
                        style: AppTextStyles.buttonText
                            .copyWith(fontSize: getResponsiveFontSize(0.03)),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Text("Selected: ${lookingFor.join(", ")}",
                    //     style: AppTextStyles.textStyle
                    //         .copyWith(fontSize: getResponsiveFontSize(0.03))),
                    // SizedBox(height: 20),

                    // Text("My Location",
                    //     style: AppTextStyles.subheadingText
                    //         .copyWith(fontSize: getResponsiveFontSize(0.04))),
                    // ListTile(
                    //   tileColor: AppColors.secondaryColor,
                    //   title: Text(locationSelection,
                    //       style: AppTextStyles.textStyle
                    //           .copyWith(fontSize: getResponsiveFontSize(0.03))),
                    //   trailing:
                    //       Icon(Icons.arrow_drop_down, color: AppColors.accentColor),
                    //   onTap: () async {
                    //     await showLocationSelectionDialog();
                    //   },
                    // ),
                    SizedBox(height: 20),
                    Text("Show Spotlight",
                        style: AppTextStyles.subheadingText
                            .copyWith(fontSize: getResponsiveFontSize(0.02))),
                    PrivacyToggle(
                        label: spotlightUser.value
                            ? "Your profile Spotlight"
                            : "Not Spotlight",
                        value: spotlightUser.value,
                        onChanged: (value) {
                          _onSwitchChanged(value);
                        }),

                    SizedBox(height: 20),

                    // Change Password Button
                    ElevatedButton(
                      onPressed: () {
                        Get.to(ChangePasswordPage());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonColor,
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Change Password",
                        style: AppTextStyles.buttonText
                            .copyWith(fontSize: getResponsiveFontSize(0.03)),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Get.to(UpdateEmailPage());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonColor,
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Update Email",
                        style: AppTextStyles.buttonText
                            .copyWith(fontSize: getResponsiveFontSize(0.03)),
                      ),
                    ),
                  ],
                ),
              );
            }));
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
