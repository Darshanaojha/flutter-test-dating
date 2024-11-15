import 'package:dating_application/Screens/register_subpag/registrationotp.dart';
import 'package:dating_application/constants.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';

class RegisterProfilePage extends StatefulWidget {
  const RegisterProfilePage({super.key});

  @override
  RegisterProfilePageState createState() => RegisterProfilePageState();
}

class RegisterProfilePageState extends State<RegisterProfilePage>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController cityController = TextEditingController();

  List<String> countries = ["India", "USA", "UK"];
  List<String> states = ["Maharashtra", "California", "London"];
  String? selectedCountry;
  String? selectedState;
  bool isLatLongFetched = false;

  late AnimationController animationController;
  late Animation<double> fadeInAnimation;

  @override
  void initState() {
    super.initState();
    selectedCountry = countries[0];
    selectedState = states[0];

    animationController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    )..forward();

    fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  Future<void> fetchLatLong() async {
    try {
      List<Location> locations =
          await locationFromAddress(addressController.text);
      if (locations.isNotEmpty) {
        setState(() {
          latitudeController.text = locations.first.latitude.toString();
          longitudeController.text = locations.first.longitude.toString();
          isLatLongFetched = true; // Mark Lat/Long as fetched
        });
      } else {
        showErrorDialog('No location found for the provided address');
      }
    } catch (e) {
      showErrorDialog('Error fetching location: $e');
    }
  }

  // Show error dialog
  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error', style: AppTextStyles.headingText),
        content: Text(message, style: AppTextStyles.bodyText),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK', style: AppTextStyles.bodyText),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    // Calculate the responsive font size
    double fontSize = screenSize.width * 0.03; // You can adjust this multiplier as needed

    return Scaffold(
      body: Container(
        color: AppColors.primaryColor, // Set primary background color
        child: Center(
          child: FadeTransition(
            opacity: fadeInAnimation,
            child: Container(
              width: screenSize.width * 0.95,
              height: screenSize.height * 0.85,
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(isPortrait ? 16.0 : 24.0),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        // Name Field
                        buildTextField("Name", nameController, fontSize),

                        // Email Field
                        buildTextField("Email", emailController, fontSize),

                        // Mobile Field
                        buildTextField("Mobile", mobileController, fontSize),

                        // Address Field
                        buildTextField("Address", addressController, fontSize),

                        // Password Field
                        buildTextField("Password", passwordController, fontSize,
                            obscureText: true),

                        // Confirm Password Field
                        buildTextField("Confirm Password", confirmPasswordController,
                            fontSize, obscureText: true),

                        // Country Dropdown
                        buildDropdown("Country", countries, selectedCountry, fontSize, (value) {
                          setState(() {
                            selectedCountry = value;
                          });
                        }),

                        // State Dropdown
                        buildDropdown("State", states, selectedState, fontSize, (value) {
                          setState(() {
                            selectedState = value;
                          });
                        }),

                        // City Field
                        buildTextField("City", cityController, fontSize),

                        // Fetch Lat/Long Button
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: ElevatedButton(
                            onPressed: fetchLatLong,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                              backgroundColor: AppColors.buttonColor,
                              foregroundColor: Colors.white,
                            ),
                            child: Text("Fetch Latitude & Longitude", style: AppTextStyles.buttonText.copyWith(fontSize: fontSize)),
                          ),
                        ),

                        // Show Latitude and Longitude only if fetched
                        if (isLatLongFetched) ...[
                          buildTextField("Latitude", latitudeController, fontSize, enabled: false),
                          buildTextField("Longitude", longitudeController, fontSize, enabled: false),
                        ],

                        // Submit Button
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              // Check if password and confirm password match
                              if (passwordController.text != confirmPasswordController.text) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text("Passwords do not match!"),
                                ));
                                return;
                              }

                              // Process form submission
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("Form submitted successfully!"),
                              ));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                            backgroundColor: AppColors.buttonColor,
                            foregroundColor: Colors.white,
                          ),
                          child: Text("Submit", style: AppTextStyles.buttonText.copyWith(fontSize: fontSize)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Get.to(OTPVerificationPage());
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                            backgroundColor: AppColors.buttonColor,
                          ),
                          child: Text('Next', style: AppTextStyles.buttonText.copyWith(fontSize: fontSize)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
    String label,
    TextEditingController controller,
    double fontSize, {
    bool obscureText = false,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        enabled: enabled,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label is required';
          }
          return null;
        },
        style: AppTextStyles.inputFieldText.copyWith(fontSize: fontSize), // Responsive font size
        cursorColor: AppColors.textColor,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.labelText.copyWith(fontSize: fontSize),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.textColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.textColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.textColor),
          ),
          fillColor: AppColors.formFieldColor,
          filled: true,
        ),
      ),
    );
  }

  Widget buildDropdown(
    String label,
    List<String> items,
    String? selectedValue,
    double fontSize,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: AppTextStyles.textStyle.copyWith(fontSize: fontSize),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.labelText.copyWith(fontSize: fontSize),
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
        ),
        style: AppTextStyles.inputFieldText.copyWith(fontSize: fontSize),
        dropdownColor: AppColors.secondaryColor,
      ),
    );
  }
}
