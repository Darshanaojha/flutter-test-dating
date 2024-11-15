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
                        buildTextField("Name", nameController),

                        // Email Field
                        buildTextField("Email", emailController),

                        // Mobile Field
                        buildTextField("Mobile", mobileController),

                        // Address Field
                        buildTextField("Address", addressController),

                        // Password Field
                        buildTextField("Password", passwordController,
                            obscureText: true),

                        // Confirm Password Field
                        buildTextField(
                            "Confirm Password", confirmPasswordController,
                            obscureText: true),

                        // Country Dropdown
                        buildDropdown("Country", countries, selectedCountry,
                            (value) {
                          setState(() {
                            selectedCountry = value;
                          });
                        }),

                        // State Dropdown
                        buildDropdown("State", states, selectedState, (value) {
                          setState(() {
                            selectedState = value;
                          });
                        }),

                        // City Field
                        buildTextField("City", cityController),

                        // Fetch Lat/Long Button
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: ElevatedButton(
                            onPressed: fetchLatLong,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 30),
                              backgroundColor: AppColors
                                  .buttonColor, // Use AppColors.buttonColor
                              foregroundColor: Colors.white,
                            ),
                            child: Text("Fetch Latitude & Longitude",
                                style: AppTextStyles.buttonText),
                          ),
                        ),

                        // Show Latitude and Longitude only if fetched
                        if (isLatLongFetched) ...[
                          buildTextField("Latitude", latitudeController,
                              enabled: false),
                          buildTextField("Longitude", longitudeController,
                             enabled: false),
                        ],

                        // Submit Button
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              // Check if password and confirm password match
                              if (passwordController.text !=
                                  confirmPasswordController.text) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text("Passwords do not match!"),
                                ));
                                return;
                              }

                              // Process form submission
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text("Form submitted successfully!"),
                              ));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: 14, horizontal: 30),
                            backgroundColor: AppColors
                                .buttonColor, // Use AppColors.buttonColor
                            foregroundColor: Colors.white,
                          ),
                          child:
                              Text("Submit", style: AppTextStyles.buttonText),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Get.to(OTPVerificationPage());
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: 14, horizontal: 30),
                            backgroundColor: AppColors
                                .buttonColor, // Use AppColors.buttonColor
                          ),
                          child: Text('Next', style: AppTextStyles.buttonText),
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
    TextEditingController controller, {
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
        style: AppTextStyles
            .inputFieldText, // Use AppTextStyles for text color and font
        cursorColor: AppColors.textColor, // Set cursor color to white
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              AppTextStyles.labelText, // Use AppTextStyles for label styling
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color: AppColors.textColor), // Set border color to white
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color:
                    AppColors.textColor), // Set focused border color to white
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color:
                    AppColors.textColor), // Set enabled border color to white
          ),
          fillColor: AppColors.formFieldColor, // Set background color
          filled: true, // Ensure the background is filled
        ),
      ),
    );
  }

  Widget buildDropdown(
    String label,
    List<String> items,
    String? selectedValue,
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
              style: AppTextStyles.textStyle,
            ),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              AppTextStyles.labelText, // Use AppTextStyles for label styling

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
        ),
        style: AppTextStyles
            .inputFieldText, // Use AppTextStyles for dropdown text styling
        dropdownColor:
            AppColors.secondaryColor, // Set dropdown background color
      ),
    );
  }
}