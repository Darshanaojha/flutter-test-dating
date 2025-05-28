import 'dart:async';

import 'package:dating_application/Controllers/controller.dart';
import 'package:dating_application/Models/ResponseModels/get_all_country_response_model.dart';
import 'package:dating_application/Screens/register_subpag/register_subpage.dart';
import 'package:dating_application/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';

class RegisterProfilePage extends StatefulWidget {
  const RegisterProfilePage({super.key});

  @override
  RegisterProfilePageState createState() => RegisterProfilePageState();
}

class RegisterProfilePageState extends State<RegisterProfilePage>
    with TickerProviderStateMixin {
  final controller = Get.find<Controller>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? selectedState;
  RxBool isLatLongFetched = false.obs;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  late AnimationController animationController;
  late Animation<double> fadeInAnimation;

  Country selectedCountry = Country(
      id: '', name: '', countryCode: '', status: '', created: '', updated: '');
  TextEditingController confirmPassword = TextEditingController();
  Timer? debounce;
  @override
  void initState() {
    super.initState();

    controller.fetchCountries();

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
    debounce?.cancel();
    super.dispose();
  }

  Future<void> fetchLatLong() async {
    try {
      print(controller.userRegistrationRequest.city);
      List<Location> locations =
          await locationFromAddress(controller.userRegistrationRequest.city);
      print(locations.first.toString());
      if (locations.isNotEmpty) {
        print('not empty');
        controller.userRegistrationRequest.latitude =
            locations.first.latitude.toString();
        controller.userRegistrationRequest.longitude =
            locations.first.longitude.toString();
        isLatLongFetched.value = true;
        print('set to true');
      } else {
        showErrorDialog('No location found for the provided address..');
      }
    } catch (e) {
      print('location error -> ${e.toString()}');
      showErrorDialog('Error fetching location: $e');
    }
  }

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
    // Match login page font size
    double fontSize = MediaQuery.of(context).size.width * 0.03;
    double fieldHeight = 60; // Increased height for input fields

    return Scaffold(
      body: Container(
        color: AppColors.primaryColor,
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
                        buildTextFieldNameEmailMobile(
                          "Name",
                          controller.userRegistrationRequest.name.isNotEmpty
                              ? controller.userRegistrationRequest.name
                              : null,
                          (value) {
                            controller.userRegistrationRequest.name = value;
                          },
                          (value) {
                            controller.userRegistrationRequest.name = value;
                          },
                          fontSize,
                          enabled: false,
                        ),

                        buildTextFieldNameEmailMobile(
                          "Email",
                          controller.userRegistrationRequest.email.isNotEmpty
                              ? controller.userRegistrationRequest.email
                              : null,
                          (value) {
                            controller.userRegistrationRequest.email = value;
                          },
                          (value) {
                            controller.userRegistrationRequest.email = value;
                          },
                          fontSize,
                          enabled: false,
                        ),
                        buildTextFieldNameEmailMobile(
                          "Mobile",
                          controller.userRegistrationRequest.mobile.isNotEmpty
                              ? controller.userRegistrationRequest.mobile
                              : null,
                          (value) {
                            controller.userRegistrationRequest.mobile = value;
                          },
                          (value) {
                            controller.userRegistrationRequest.mobile = value;
                          },
                          fontSize,
                          isMobileField: true,
                          enabled: false,
                        ),

                        buildConsistentTextField(
                          "UserName",
                          controller.userRegistrationRequest.username,
                          (value) => controller
                              .userRegistrationRequest.username = value,
                          fontSize,
                          height: fieldHeight, // <-- pass height
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "UserName is required";
                            }
                            if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                              return "User name must only contain letters";
                            }
                            return null;
                          },
                        ),

                        buildConsistentTextField(
                          "Address",
                          controller.userRegistrationRequest.address,
                          (value) => controller
                              .userRegistrationRequest.address = value,
                          fontSize,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Address cannot be empty";
                            }
                            if (RegExp(r'^[0-9]+$').hasMatch(value)) {
                              return "Address cannot contain only numbers.";
                            }
                            if (RegExp(r'^[^\w\s]+$').hasMatch(value)) {
                              return "Address cannot contain only special characters.";
                            }
                            if (RegExp(r'(?=.*[0-9])(?=.*[^\w\s])')
                                .hasMatch(value)) {
                              return "Address cannot contain only special characters and numbers.";
                            }
                            return null;
                          },
                        ),

                        buildConsistentTextField(
                          "City",
                          null,
                          (value) {
                            setState(() {
                              controller.userRegistrationRequest.city = value;
                              if (debounce?.isActive ?? false) {
                                debounce?.cancel();
                              }
                              debounce =
                                  Timer(Duration(milliseconds: 1000), () {
                                fetchLatLong();
                              });
                            });
                          },
                          fontSize,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "City is required";
                            }
                            if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                              return "City name must only contain letters";
                            }
                            return null;
                          },
                        ),
                        // Obx(() {
                        //   if (isLatLongFetched.value) {
                        //     return Column(
                        //       children: [
                        //         buildTextFieldForLatLong(
                        //           "Latitude",
                        //           controller.userRegistrationRequest.latitude,
                        //           fontSize,
                        //           enabled: false,
                        //         ),
                        //         buildTextFieldForLatLong(
                        //           "Longitude",
                        //           controller.userRegistrationRequest.longitude,
                        //           fontSize,
                        //           enabled: false,
                        //         ),
                        //       ],
                        //     );
                        //   } else {
                        //     return Container();
                        //   }
                        // }),
                        buildPasswordField(
                          "Password",
                          null,
                          (value) {
                            controller.userRegistrationRequest.password =
                                value.toString();
                          },
                          (value) {
                            controller.userRegistrationRequest.password =
                                value.toString();
                          },
                          fontSize,
                          obscureText: obscurePassword,
                          showObscureIcon: true,
                          toggleObscure: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                        buildPasswordField(
                          "Confirm Password",
                          null,
                          (value) {
                            confirmPassword.text = value ?? '';
                          },
                          (value) {
                            confirmPassword.text = value ?? '';
                          },
                          fontSize,
                          obscureText: obscureConfirmPassword,
                          showObscureIcon: true,
                          toggleObscure: () {
                            setState(() {
                              obscureConfirmPassword = !obscureConfirmPassword;
                            });
                          },
                        ),
                        Obx(() {
                          if (controller.countries.isEmpty) {
                            return Center(
                              child: SpinKitCircle(
                                size: 50,
                                color: AppColors.progressColor,
                              ),
                            );
                          }

                          return buildConsistentDropdownField<Country>(
                            label: "Country",
                            items: controller.countries,
                            selectedValue: selectedCountry,
                            fontSize: fontSize,
                            height: fieldHeight,
                            onChanged: (Country? value) {
                              setState(() {
                                selectedCountry = value ??
                                    Country(
                                        id: '',
                                        name: '',
                                        countryCode: '',
                                        status: '',
                                        created: '',
                                        updated: '');
                                controller.userRegistrationRequest.countryId =
                                    value?.id ?? '';
                              });
                            },
                            displayValue: (Country country) => country.name,
                          );
                        }),

                        buildConsistentDropdownField<String>(
                          label: "Relationship Type",
                          items: ['1', '2'],
                          selectedValue: controller
                                  .userRegistrationRequest.lookingFor.isEmpty
                              ? null
                              : controller.userRegistrationRequest.lookingFor,
                          fontSize: fontSize,
                          onChanged: (String? value) {
                            setState(() {
                              controller.userRegistrationRequest.lookingFor =
                                  value ?? '';
                            });
                          },
                          displayValue: (String value) {
                            if (value == '1') {
                              return 'Serious Relationship';
                            } else if (value == '2') {
                              return 'Hookup';
                            }
                            return '';
                          },
                        ),

                        SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment(0.8, 1),
                                colors: AppColors.gradientColor),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                if (controller
                                        .userRegistrationRequest.password !=
                                    confirmPassword.text) {
                                  failure('Failed', 'Passwords do not match!');
                                  return;
                                }
                                Get.to(MultiStepFormPage());
                                success(
                                    'Success', 'Form submitted successfully!');
                              }
                              // Get.snackbar(
                              //     'name',
                              //     controller.userRegistrationRequest.name
                              //         .toString());
                              // Get.snackbar(
                              //     'email',
                              //     controller.userRegistrationRequest.email
                              //         .toString());
                              // Get.snackbar(
                              //     'username',
                              //     controller.userRegistrationRequest.username
                              //         .toString());
                              // Get.snackbar(
                              //     'mobile',
                              //     controller.userRegistrationRequest.mobile
                              //         .toString());
                              // Get.snackbar(
                              //     'address',
                              //     controller.userRegistrationRequest.address
                              //         .toString());
                              // Get.snackbar(
                              //     'password',
                              //     controller.userRegistrationRequest.password
                              //         .toString());
                              // Get.snackbar(
                              //     'country',
                              //     controller.userRegistrationRequest.countryId
                              //         .toString());
                              // Get.snackbar(
                              //     'city',
                              //     controller.userRegistrationRequest.city
                              //         .toString());
                              // Get.snackbar(
                              //     'latitude',
                              //     controller.userRegistrationRequest.latitude
                              //         .toString());
                              // Get.snackbar(
                              //     'longitude',
                              //     controller.userRegistrationRequest.longitude
                              //         .toString());
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 30),
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                            ),
                            child: Text("Submit",
                                style: AppTextStyles.buttonText
                                    .copyWith(fontSize: fontSize)),
                          ),
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

  Widget buildTextFieldNameEmailMobile(
    String label,
    String? initialValue,
    onChanged,
    onSaved,
    double fontSize, {
    bool obscureText = false,
    bool enabled = true,
    bool isMobileField = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        obscureText: obscureText,
        enabled: enabled,
        readOnly: true,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label is required';
          }
          if (isMobileField) {
            if (!RegExp(r'^\d+$').hasMatch(value)) {
              failure('Mobile', 'Mobile number must only contain digits');
              return 'Mobile number must only contain digits';
            }
            if (value.length != 10) {
              return 'Mobile number must be exactly 10 digits';
            }
          }
          return null;
        },
        style: AppTextStyles.inputFieldText.copyWith(
          fontSize: fontSize,
          color: enabled ? AppColors.disabled : AppColors.disabled,
        ),
        cursorColor: enabled ? AppColors.disabled : Colors.grey,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.labelText.copyWith(
            fontSize: fontSize,
            color: enabled ? AppColors.primaryColor : Colors.grey,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color: enabled ? AppColors.primaryColor : Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color:
                    enabled ? AppColors.primaryColor : AppColors.activeColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color: enabled ? AppColors.primaryColor : Colors.grey),
          ),
          fillColor:
              enabled ? AppColors.formFieldColor : AppColors.primaryColor,
          filled: true,
        ),
        initialValue: initialValue,
        onChanged: enabled ? onChanged : null,
        onSaved: onSaved,
        inputFormatters: [
          if (isMobileField) FilteringTextInputFormatter.digitsOnly,
        ],
        maxLength: isMobileField ? 10 : null,
      ),
    );
  }

  Widget buildTextField(
    String label,
    String? initialValue,
    onChanged,
    onSaved,
    double fontSize, {
    bool obscureText = false,
    bool enabled = true,
    bool isCityField = false,
    bool isusernameField = false,
    bool isaddressfield = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        obscureText: obscureText,
        enabled: enabled,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label is required';
          }
          if (isCityField && !RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
            failure('City', 'City name must only contain letters');
            return 'City name must only contain letters';
          }
          if (isusernameField && !RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
            failure('UserName', 'User name must only contain letters');
            return 'User name must only contain letters';
          }
          if (isaddressfield) {
            if (value.isEmpty) {
              failure("Invalid Address", "Address cannot be empty.");
              return "Address cannot be empty";
            }
            if (RegExp(r'^[0-9]+$').hasMatch(value)) {
              failure(
                  "Invalid Address", "Address cannot contain only numbers.");
              return "Address cannot contain only numbers.";
            }
            if (RegExp(r'^[^\w\s]+$').hasMatch(value)) {
              failure("Invalid Address",
                  "Address cannot contain only special characters.");
              return "Address cannot contain only special characters.";
            }
            if (RegExp(r'(?=.*[0-9])(?=.*[^\w\s])').hasMatch(value)) {
              failure("Invalid Address",
                  "Address cannot contain only special characters and numbers.");

              return "Address cannot contain only special characters and numbers.";
            }
          }

          return null;
        },
        style: AppTextStyles.inputFieldText.copyWith(fontSize: fontSize),
        cursorColor: AppColors.textColor,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.labelText.copyWith(fontSize: fontSize),
          filled: true,
          fillColor: AppColors.formFieldColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.textColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.activeColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.textColor),
          ),
        ),
        initialValue: initialValue,
        onChanged: onChanged,
        onSaved: onSaved,
      ),
    );
  }

  bool _validateAddress(String address) {
    if (address.isEmpty) {
      failure("Invalid Address", "Address cannot be empty.");
      return false;
    }
    if (RegExp(r'^[0-9]+$').hasMatch(address)) {
      failure("Invalid Address", "Address cannot contain only numbers.");
      return false;
    }
    if (RegExp(r'^[a-zA-Z]+$').hasMatch(address)) {
      failure("Invalid Address", "Address cannot contain only letters.");
      return false;
    }
    if (RegExp(r'^[^\w\s]+$').hasMatch(address)) {
      failure(
          "Invalid Address", "Address cannot contain only special characters.");
      return false;
    }
    if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)(?=.*[,\.\-_])[a-zA-Z0-9,\.\-_]+$')
        .hasMatch(address)) {
      failure(
        "Invalid Address",
        "Address must contain a combination of letters, numbers, and special characters (e.g., commas, periods, hyphens, and underscores).",
      );
      return false;
    }

    return true;
  }

  void validatePassword(String password) {
    if (password.length < 8) {
      failure("Password", "Password must be at least 8 characters long.");
      return;
    }

    final hasDigit = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    if (!hasDigit || !hasSpecialChar) {
      failure("Password",
          "Password must contain at least one digit and one special character.");
      return;
    }
  }

  Widget buildPasswordField(
    String label,
    String? initialValue,
    Function(String?) onChanged,
    Function(String?) onSaved,
    double fontSize, {
    bool obscureText = true,
    bool enabled = true,
    VoidCallback? toggleObscure,
    bool showObscureIcon = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        obscureText: obscureText,
        enabled: enabled,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label is required';
          }
          if (value.length < 8) {
            return '$label must be at least 8 characters long.';
          }
          final hasDigit = RegExp(r'[0-9]').hasMatch(value);
          final hasSpecialChar =
              RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);
          if (!hasDigit || !hasSpecialChar) {
            failure("Password",
                "Password must contain at least one digit and one special character.");
            return "$label Password must contain at least one digit and one special character.";
          }
          return null;
        },
        style: TextStyle(fontSize: fontSize),
        cursorColor: AppColors.cursorColor,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: fontSize, color: AppColors.textColor),
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
          suffixIcon: showObscureIcon
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textColor,
                  ),
                  onPressed: toggleObscure,
                )
              : null,
        ),
        initialValue: initialValue,
        onChanged: onChanged,
        onSaved: onSaved,
      ),
    );
  }

  Widget buildTextFieldForLatLong(
    String label,
    String value,
    double fontSize, {
    bool obscureText = false,
    bool enabled = true,
  }) {
    TextEditingController controller = TextEditingController(text: value);

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
        style: AppTextStyles.inputFieldText.copyWith(fontSize: fontSize),
        cursorColor: AppColors.textColor,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.labelText.copyWith(fontSize: fontSize),
          filled: true,
          fillColor: AppColors.formFieldColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.textColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.activeColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.textColor),
          ),
        ),
      ),
    );
  }

  String? validateSelection(dynamic value) {
    if (value == null) {
      failure('', 'Country cannot be empty');
      return 'Please select a value';
    }
    return null;
  }

  Widget buildConsistentDropdownField<T>({
    required String label,
    required List<T> items,
    required T? selectedValue,
    required double fontSize,
    required Function(T?) onChanged,
    required String Function(T) displayValue,
    double height = 60, // Match text field height
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: SizedBox(
        height: height,
        child: GestureDetector(
          onTap: () => _showBottomSheet<T>(
              items, selectedValue, onChanged, displayValue),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              labelStyle: AppTextStyles.labelText.copyWith(fontSize: fontSize),
              filled: true,
              fillColor: AppColors.formFieldColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.textColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.activeColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.textColor),
              ),
              contentPadding: EdgeInsets.symmetric(
                  vertical: 18, horizontal: 16), // Match text field padding
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedValue != null
                        ? displayValue(selectedValue)
                        : 'Select Relationship Type',
                    style: AppTextStyles.inputFieldText
                        .copyWith(fontSize: fontSize),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: AppColors.activeColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Consistent text field builder
  Widget buildConsistentTextField(
    String label,
    String? initialValue,
    Function(String) onChanged,
    double fontSize, {
    bool obscureText = false,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    double height = 60,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: SizedBox(
        height: height,
        child: TextFormField(
          initialValue: initialValue,
          obscureText: obscureText,
          enabled: enabled,
          keyboardType: keyboardType,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          style: AppTextStyles.inputFieldText.copyWith(fontSize: fontSize),
          cursorColor: AppColors.cursorColor,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: AppTextStyles.labelText.copyWith(fontSize: fontSize),
            filled: true,
            fillColor: AppColors.formFieldColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.textColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.activeColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.textColor),
            ),
            contentPadding: EdgeInsets.symmetric(
                vertical: 18, horizontal: 16), // Match dropdown padding
          ),
          onChanged: onChanged,
          validator: validator,
        ),
      ),
    );
  }

  // Method to show the bottom sheet
  void _showBottomSheet<T>(
    List<T> items,
    T? selectedValue,
    Function(T?) onChanged,
    String Function(T)? displayValue,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text("Select Country",
                  style: Theme.of(context).textTheme.bodySmall),
              SizedBox(height: 8.0),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    T item = items[index];
                    return ListTile(
                      title: Text(displayValue != null
                          ? displayValue(item)
                          : item.toString()),
                      onTap: () {
                        onChanged(item);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
