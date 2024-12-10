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
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  List<String> states = ["Maharashtra", "California", "London"];
  String? selectedState;
  RxBool isLatLongFetched = false.obs;
  bool obscurePassword = true;

  late AnimationController animationController;
  late Animation<double> fadeInAnimation;

  Country? selectedCountry;
  final controller = Get.find<Controller>();
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
    double fontSize = screenSize.width * 0.03;

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
                              : null, // Pass null if empty
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
                              : null, // Pass null if empty
                          (value) {
                            controller.userRegistrationRequest.email = value;
                          },
                          (value) {
                            controller.userRegistrationRequest.email = value;
                          },
                          fontSize,
                          enabled: false,
                        ),
                        // Mobile Field
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

                        buildTextField("UserName", null, (value) {
                          controller.userRegistrationRequest.username = value;
                        }, (value) {
                          controller.userRegistrationRequest.username = value;
                        }, fontSize),

                        buildTextField("Address", null, (value) {
                          controller.userRegistrationRequest.address = value;
                        }, (value) {
                          controller.userRegistrationRequest.address = value;
                        }, fontSize),

                        // Password Field
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
                          obscureText: true,
                        ),

                        // Confirm Password Field
                        buildTextField("Confirm Password", null, (value) {
                          confirmPassword.text = value;
                        }, (value) {
                          confirmPassword.text = value;
                        }, fontSize, obscureText: true),

                        // Country Dropdown
                        Obx(() {
                          if (controller.countries.isEmpty) {
                            return Center(
                              child: SpinKitCircle(
                                size: 50,
                                color: AppColors.progressColor,
                              ),
                            );
                          }

                          return buildDropdown<Country>(
                            "Country",
                            controller.countries,
                            selectedCountry,
                            16.0,
                            (Country? value) {
                              controller.userRegistrationRequest.countryId =
                                  value?.id ?? '';
                            },
                            displayValue: (Country country) => country.name,
                          );
                        }),

                        DropdownButtonFormField<String>(
                          value: controller
                                  .userRegistrationRequest.lookingFor.isEmpty
                              ? null
                              : controller.userRegistrationRequest.lookingFor,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a relationship type';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Relationship Type',
                            labelStyle: AppTextStyles.labelText
                                .copyWith(fontSize: fontSize),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: AppColors.textColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: '1',
                              child: Text(
                                'Serious Relationship',
                                style: AppTextStyles.bodyText
                                    .copyWith(fontSize: fontSize),
                              ),
                            ),
                            DropdownMenuItem(
                              value: '2',
                              child: Text(
                                'Hookup',
                                style: AppTextStyles.bodyText
                                    .copyWith(fontSize: fontSize),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              controller.userRegistrationRequest.lookingFor =
                                  value;
                            }
                          },
                          iconEnabledColor: AppColors.textColor,
                          iconDisabledColor: AppColors.disabled,
                        ),
                        // City Field
                        buildTextField(
                          "City",
                          null,
                          (value) {
                            controller.userRegistrationRequest.city = value;
                            if (debounce?.isActive ?? false) {
                              debounce?.cancel();
                            }

                            debounce = Timer(Duration(milliseconds: 1000), () {
                              fetchLatLong();
                            });
                          },
                          (value) {
                            controller.userRegistrationRequest.city = value;
                          },
                          fontSize,
                          isCityField: true,
                        ),
                        Obx(() {
                          if (isLatLongFetched.value) {
                            return Column(
                              children: [
                                buildTextFieldForLatLong(
                                  "Latitude",
                                  controller.userRegistrationRequest.latitude,
                                  fontSize,
                                  enabled: false,
                                ),
                                buildTextFieldForLatLong(
                                  "Longitude",
                                  controller.userRegistrationRequest.longitude,
                                  fontSize,
                                  enabled: false,
                                ),
                              ],
                            );
                          } else {
                            return Container();
                          }
                        }),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              if (controller.userRegistrationRequest.password !=
                                  confirmPassword.text) {
                                failure('Failed', 'Passwords do not match!');
                                return;
                              }

                              String? validateSelection(dynamic value) {
                                if (value == null) {
                                  failure('', 'Country cannot be empty');
                                  return 'Please select a value';
                                }
                                return null;
                              }

                              void validatePassword(String password) {
                                if (password.length < 8) {
                                  failure("Password",
                                      "Password must be at least 8 characters long.");
                                  return;
                                }

                                final hasDigit =
                                    RegExp(r'[0-9]').hasMatch(password);
                                final hasSpecialChar =
                                    RegExp(r'[!@#$%^&*(),.?":{}|<>]')
                                        .hasMatch(password);
                                if (!hasDigit || !hasSpecialChar) {
                                  failure("Password",
                                      "Password must contain at least one digit and one special character.");
                                  return;
                                }
                              }

                              Get.to(MultiStepFormPage());
                              success(
                                  'Success', 'Form submitted successfully!');
                            }
                            Get.snackbar(
                                'name',
                                controller.userRegistrationRequest.name
                                    .toString());
                            Get.snackbar(
                                'email',
                                controller.userRegistrationRequest.email
                                    .toString());
                            Get.snackbar(
                                'email',
                                controller.userRegistrationRequest.username
                                    .toString());
                            Get.snackbar(
                                'mobile',
                                controller.userRegistrationRequest.mobile
                                    .toString());
                            Get.snackbar(
                                'address',
                                controller.userRegistrationRequest.address
                                    .toString());
                            Get.snackbar(
                                'password',
                                controller.userRegistrationRequest.password
                                    .toString());
                            Get.snackbar(
                                'country',
                                controller.userRegistrationRequest.countryId
                                    .toString());
                            Get.snackbar(
                                'city',
                                controller.userRegistrationRequest.city
                                    .toString());
                            Get.snackbar(
                                'latitude',
                                controller.userRegistrationRequest.latitude
                                    .toString());
                            Get.snackbar(
                                'longitude',
                                controller.userRegistrationRequest.longitude
                                    .toString());
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: 14, horizontal: 30),
                            backgroundColor: AppColors.buttonColor,
                            foregroundColor: Colors.white,
                          ),
                          child: Text("Submit",
                              style: AppTextStyles.buttonText
                                  .copyWith(fontSize: fontSize)),
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
                color: enabled ? AppColors.primaryColor : Colors.grey),
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

          return null;
        },
        style: AppTextStyles.inputFieldText
            .copyWith(fontSize: fontSize), // Responsive font size
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

        initialValue: initialValue,
        onChanged: onChanged,
        onSaved: onSaved,
      ),
    );
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
          
          if(value.length<8) {
            return '$label must be at least 8 characters long.';
          }

          try {
            validatePassword(value);
          } catch (e) {
            return e
                .toString(); // Returns the error message from validatePassword function
          }

          return null; // If no validation error
        },
        style: TextStyle(
            fontSize:
                fontSize), // You can replace this with your custom text style
        cursorColor: Colors.black, // Customize this to match your theme
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: fontSize),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(color: Colors.black), // Customize border color
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(color: Colors.black), // Customize border color
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(color: Colors.black), // Customize border color
          ),
          fillColor: AppColors.formFieldColor, // Customize background color
          filled: true,
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
    // Create a TextEditingController with the passed value
    TextEditingController controller = TextEditingController(text: value);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller, // Use the controller to manage the value
        obscureText: obscureText,
        enabled: enabled,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label is required';
          }
          return null;
        },
        style: AppTextStyles.inputFieldText
            .copyWith(fontSize: fontSize), // Responsive font size
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

  String? validateSelection(dynamic value) {
    if (value == null) {
      failure('', 'Country cannot be empty');
      return 'Please select a value';
    }
    return null;
  }

  Widget buildDropdown<T>(
    String label,
    List<T> items,
    T? selectedValue,
    double fontSize,
    Function(T?) onChanged, {
    String Function(T)?
        displayValue, // Helper to extract display value from items
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<T>(
        value: selectedValue, // Bind to the selected value
        items: items.map((T value) {
          return DropdownMenuItem<T>(
            value: value,
            child: Text(
              displayValue != null ? displayValue(value) : value.toString(),
              style: AppTextStyles.textStyle.copyWith(fontSize: fontSize),
            ),
          );
        }).toList(),
        onChanged: onChanged, // Use the provided onChanged callback
        validator: validateSelection,
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
