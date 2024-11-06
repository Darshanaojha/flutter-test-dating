
import 'package:dating_application/Screens/register_subpag/register_subpage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';


class RegisterProfilePage extends StatefulWidget {
  const RegisterProfilePage({super.key});

  @override
  _RegisterProfilePageState createState() => _RegisterProfilePageState();
}

class _RegisterProfilePageState extends State<RegisterProfilePage> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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

  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    selectedCountry = countries[0];
    selectedState = states[0];

    _animationController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    )..forward();

    // Create a fade-in animation
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchLatLong() async {
    try {
      List<Location> locations = await locationFromAddress(addressController.text);
      if (locations.isNotEmpty) {
        setState(() {
          latitudeController.text = locations.first.latitude.toString();
          longitudeController.text = locations.first.longitude.toString();
          isLatLongFetched = true; // Mark Lat/Long as fetched
        });
      } else {
        _showErrorDialog('No location found for the provided address');
      }
    } catch (e) {
      _showErrorDialog('Error fetching location: $e');
    }
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      // appBar: AppBar(
      //   title: Text("User Profile"),
      //   backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      // ),
      body: Container(
        color: Colors.green,
        child: Center(
          child: FadeTransition(
            opacity: _fadeInAnimation,
            child: Container(
              width: screenSize.width * 0.95,
              height: screenSize.height * 0.85,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(isPortrait ? 16.0 : 24.0),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Name Field
                        _buildTextField("Name", nameController),
        
                        // Email Field
                        _buildTextField("Email", emailController),
        
                        // Mobile Field
                        _buildTextField("Mobile", mobileController),
        
                        // Address Field
                        _buildTextField("Address", addressController),
        
                        // Password Field
                        _buildTextField("Password", passwordController, obscureText: true),
        
                        // Confirm Password Field
                        _buildTextField("Confirm Password", confirmPasswordController, obscureText: true),
        
                        // Country Dropdown
                        _buildDropdown("Country", countries, selectedCountry, (value) {
                          setState(() {
                            selectedCountry = value;
                          });
                        }),
        
                        // State Dropdown
                        _buildDropdown("State", states, selectedState, (value) {
                          setState(() {
                            selectedState = value;
                          });
                        }),
        
                        // City Field
                        _buildTextField("City", cityController),
        
                        // Fetch Lat/Long Button
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: ElevatedButton(
                            onPressed: fetchLatLong,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                              backgroundColor: const Color.fromARGB(255, 6, 7, 7),
                              foregroundColor: Colors.white,
                            ),
                            child: Text("Fetch Latitude & Longitude"),
                          ),
                        ),
        
                        // Show Latitude and Longitude only if fetched
                        if (isLatLongFetched) ...[
                          _buildTextField("Latitude", latitudeController, enabled: false),
                          _buildTextField("Longitude", longitudeController, enabled: false),
                        ],
        
                        // Submit Button
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
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
                            backgroundColor: const Color.fromARGB(255, 4, 5, 5),
                            foregroundColor: Colors.white,
                          ),
                          child: Text("Submit"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Get.to(MultiStepFormPage());
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                            backgroundColor: const Color.fromARGB(255, 4, 5, 5),
                          ),
                          child: Text('Next'),
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

  Widget _buildTextField(
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
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDropdown(
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
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }
}



