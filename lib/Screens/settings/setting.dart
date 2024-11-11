import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../constants.dart'; 


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double maxDistance = 50.0;
  RangeValues _ageRange = RangeValues(18, 35); 
  final List<String> _lookingFor = [];
  final TextEditingController _desireController = TextEditingController();
  bool _showOnlineUsers = false;
  String _currentLocation = "Fetching..."; // To be updated with Geolocator
  String _locationSelection = "Current Location"; // For Location Selection

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
    _getCurrentLocation();  // Initial call to fetch location if possible
  }

  // Method to check and get the current location using Geolocator
  Future<void> _getCurrentLocation() async {
    // Check location permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Request permission if not granted
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      // If permission is denied forever, show a message
      setState(() {
        _currentLocation = "Location permissions are permanently denied";
      });
    } else if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
  
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentLocation = "Lat: ${position.latitude}, Long: ${position.longitude}";
      });
    } else {
      // Handle other cases
      setState(() {
        _currentLocation = "Unable to fetch location";
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
              values: _ageRange,
              min: 18,
              max: 100,
              divisions: 82,
              labels: RangeLabels(
                _ageRange.start.round().toString(),
                _ageRange.end.round().toString(),
              ),
              activeColor: AppColors.activeColor,
              inactiveColor: AppColors.inactiveColor,
              onChanged: (RangeValues values) {
                setState(() {
                  _ageRange = values;
                });
              },
            ),
            SizedBox(height: 20),

            // Looking For (Checkboxes)
            Text("Looking For", style: AppTextStyles.subheadingText),
            ...genderOptions.map((gender) {
              return CheckboxListTile(
                title: Text(gender, style: AppTextStyles.textStyle),
                value: _lookingFor.contains(gender),
                onChanged: (bool? selected) {
                  setState(() {
                    if (selected == true) {
                      _lookingFor.add(gender);  // Add to list if selected
                    } else {
                      _lookingFor.remove(gender);  // Remove from list if unselected
                    }
                  });
                },
                activeColor: AppColors.activeColor,
              );
            }).toList(),
            SizedBox(height: 20),

            // Display selected "Looking For" options
            Text("Selected: ${_lookingFor.join(", ")}", style: AppTextStyles.textStyle),
            SizedBox(height: 20),

            // My Location
            Text("My Location", style: AppTextStyles.subheadingText),
            ListTile(
              tileColor: AppColors.secondaryColor,
              title: Text(_locationSelection, style: AppTextStyles.textStyle),
              trailing: Icon(Icons.arrow_drop_down, color: AppColors.accentColor),
              onTap: () async {
                // Show a dialog to select location type (current location or predefined list)
                await _showLocationSelectionDialog();
              },
            ),
            SizedBox(height: 20),

            // Search By
            Text("Search By", style: AppTextStyles.subheadingText),
            TextField(
              controller: _desireController,
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
              value: _showOnlineUsers,
              onChanged: (bool value) {
                setState(() {
                  _showOnlineUsers = value;
                });
              },
              activeColor: AppColors.acceptColor,
              title: Text(
                _showOnlineUsers ? "Online Users Visible" : "Hide Online Users",
                style: AppTextStyles.textStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to show location selection dialog
  Future<void> _showLocationSelectionDialog() async {
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
                groupValue: _locationSelection,
                onChanged: (value) {
                  setState(() {
                    _locationSelection = value!;
                  });
                  Navigator.pop(context);
                  _getCurrentLocation(); // Fetch current location
                },
              ),
              RadioListTile<String>(
                title: Text("Select from List", style: AppTextStyles.textStyle),
                value: "Select from List",
                groupValue: _locationSelection,
                onChanged: (value) {
                  setState(() {
                    _locationSelection = value!;
                  });
                  Navigator.pop(context);
                  _showLocationListDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Show a dialog for selecting from predefined locations
  Future<void> _showLocationListDialog() async {
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
                    _currentLocation = location;
                    _locationSelection = location;
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

