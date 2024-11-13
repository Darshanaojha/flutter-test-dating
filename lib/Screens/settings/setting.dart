import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../constants.dart'; 


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  double maxDistance = 50.0;
  RangeValues ageRange = RangeValues(18, 35); 
  final List<String> lookingFor = [];
  final TextEditingController desireController = TextEditingController();
  bool showOnlineUsers = false;
  String currentLocation = "Fetching..."; // To be updated with Geolocator
  String locationSelection = "Current Location"; // For Location Selection

  // Gender options for "Looking For"
  final List<String> genderOptions = ['Male', 'Female', 'Non-Binary'];

  // Predefined locations
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
    getCurrentLocation();  // Initial call to fetch location if possible
  }

  // Method to check and get the current location using Geolocator
  Future<void> getCurrentLocation() async {
    // Check location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Request permission if not granted
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      // If permission is denied forever, show a message
      setState(() {
        currentLocation = "Location permissions are permanently denied";
      });
    } else if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
  
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        currentLocation = "Lat: ${position.latitude}, Long: ${position.longitude}";
      });
    } else {
      // Handle other cases
      setState(() {
        currentLocation = "Unable to fetch location";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings", style: AppTextStyles.headingText),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Maximum Distance
            Text("Maximum Distance (km)", style: AppTextStyles.subheadingText),
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
            Text("Age Range", style: AppTextStyles.subheadingText),
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
            Text("Looking For", style: AppTextStyles.subheadingText),
            ...genderOptions.map((gender) {
              return CheckboxListTile(
                title: Text(gender, style: AppTextStyles.textStyle),
                value: lookingFor.contains(gender),
                onChanged: (bool? selected) {
                  setState(() {
                    if (selected == true) {
                      lookingFor.add(gender);  // Add to list if selected
                    } else {
                      lookingFor.remove(gender);  // Remove from list if unselected
                    }
                  });
                },
                activeColor: AppColors.activeColor,
              );
            }).toList(),
            SizedBox(height: 20),

            // Display selected "Looking For" options
            Text("Selected: ${lookingFor.join(", ")}", style: AppTextStyles.textStyle),
            SizedBox(height: 20),

            // My Location
            Text("My Location", style: AppTextStyles.subheadingText),
            ListTile(
              tileColor: AppColors.secondaryColor,
              title: Text(locationSelection, style: AppTextStyles.textStyle),
              trailing: Icon(Icons.arrow_drop_down, color: AppColors.accentColor),
              onTap: () async {
                // Show a dialog to select location type (current location or predefined list)
                await showLocationSelectionDialog();
              },
            ),
            SizedBox(height: 20),

            // Search By
            Text("Search By", style: AppTextStyles.subheadingText),
            TextField(
              controller: desireController,
              cursorColor: AppColors.cursorColor,
              decoration: InputDecoration(
                hintText: 'Enter your desires...',
                hintStyle: AppTextStyles.inputFieldText,
                
                 border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.formFieldColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white), // Focused border color
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white), // Enabled border color
                ),
                fillColor: AppColors.formFieldColor, // Set background color
                filled: true,
              ),
              style: AppTextStyles.inputFieldText,
            ),
            SizedBox(height: 20),

            // Recent Online Users Toggle
            Text("Show Recent Online Users", style: AppTextStyles.subheadingText),
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
                style: AppTextStyles.textStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to show location selection dialog
  Future<void> showLocationSelectionDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Location Type", style: AppTextStyles.headingText),
          backgroundColor: AppColors.secondaryColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text("Use Current Location", style: AppTextStyles.textStyle),
                value: "Current Location",
                groupValue: locationSelection,
                onChanged: (value) {
                  setState(() {
                    locationSelection = value!;
                  });
                  Navigator.pop(context);
                  getCurrentLocation(); // Fetch current location
                },
              ),
              RadioListTile<String>(
                title: Text("Select from List", style: AppTextStyles.textStyle),
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

  // Show a dialog for selecting from predefined locations
  Future<void> showLocationListDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Location", style: AppTextStyles.headingText),
          backgroundColor: AppColors.secondaryColor,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: predefinedLocations.map((location) {
              return ListTile(
                title: Text(location, style: AppTextStyles.textStyle),
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

