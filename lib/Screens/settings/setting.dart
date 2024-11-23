import 'package:dating_application/Screens/settings/appinfopages/appinfopagestart.dart';
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
    return screenWidth * scale; // Adjust this scale for different text elements
  }

  final TextEditingController desireController = TextEditingController();
  bool showOnlineUsers = false;
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
      body: Padding(
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
                });
              },
            ),
            SizedBox(height: 20),

            // Looking For (Checkboxes)
            Text("Looking For",
                style: AppTextStyles.subheadingText
                    .copyWith(fontSize: getResponsiveFontSize(0.03))),
            ...genderOptions.map((gender) {
              return CheckboxListTile(
                title: Text(gender,
                    style: AppTextStyles.textStyle
                        .copyWith(fontSize: getResponsiveFontSize(0.03))),
                value: lookingFor.contains(gender),
                onChanged: (bool? selected) {
                  setState(() {
                    if (selected == true) {
                      lookingFor.add(gender); // Add to list if selected
                    } else {
                      lookingFor
                          .remove(gender); // Remove from list if unselected
                    }
                  });
                },
                activeColor: AppColors.activeColor,
              );
            }),
            SizedBox(height: 20),
            Text("Selected: ${lookingFor.join(", ")}",
                style: AppTextStyles.textStyle
                    .copyWith(fontSize: getResponsiveFontSize(0.03))),
            SizedBox(height: 20),

            Text("My Location",
                style: AppTextStyles.subheadingText
                    .copyWith(fontSize: getResponsiveFontSize(0.04))),
            ListTile(
              tileColor: AppColors.secondaryColor,
              title: Text(locationSelection,
                  style: AppTextStyles.textStyle
                      .copyWith(fontSize: getResponsiveFontSize(0.03))),
              trailing:
                  Icon(Icons.arrow_drop_down, color: AppColors.accentColor),
              onTap: () async {
                await showLocationSelectionDialog();
              },
            ),
            SizedBox(height: 20),
            Text("Search By",
                style: AppTextStyles.subheadingText
                    .copyWith(fontSize: getResponsiveFontSize(0.03))),
            TextField(
              controller: desireController,
              cursorColor: AppColors.cursorColor,
              decoration: InputDecoration(
                hintText: 'Enter your desires...',
                hintStyle: AppTextStyles.inputFieldText
                    .copyWith(fontSize: getResponsiveFontSize(0.03)),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.formFieldColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                fillColor: AppColors.formFieldColor,
                filled: true,
              ),
              style: AppTextStyles.inputFieldText,
            ),
            SizedBox(height: 20),
            Text("Show Recent Online Users",
                style: AppTextStyles.subheadingText
                    .copyWith(fontSize: getResponsiveFontSize(0.03))),
            SwitchListTile(
              value: showOnlineUsers,
              onChanged: (bool value) {
                setState(() {
                  showOnlineUsers = value;
                });
              },
              activeColor: AppColors.acceptColor,
              title: Text(
                showOnlineUsers ? "Online Users Visible" : "Hide Online Users",
                style: AppTextStyles.textStyle
                    .copyWith(fontSize: getResponsiveFontSize(0.03)),
              ),
            ),
            SizedBox(height: 20),

            // Change Password Button
            ElevatedButton(
              onPressed: () {
                Get.to(ChangePasswordPage());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
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
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Apply Settings",
                style: AppTextStyles.buttonText
                    .copyWith(fontSize: getResponsiveFontSize(0.03)),
              ),
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
