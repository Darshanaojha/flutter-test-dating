import 'dart:io';
import 'package:dating_application/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../homepage/homepage.dart';
import '../navigationbar/navigationpage.dart';

class MultiStepFormPage extends StatefulWidget {
  const MultiStepFormPage({super.key});

  @override
  _MultiStepFormPageState createState() => _MultiStepFormPageState();
}

class _MultiStepFormPageState extends State<MultiStepFormPage> {

  int selectedDay = DateTime.now().day;
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  String name = '';
  String? gender;
  String description = ''; 

  int currentPage = 1;
  final PageController _pageController =
      PageController(); // Create a PageController instance

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Adjust text sizes, padding, and spacing dynamically based on screen size
    double padding = isPortrait ? 16.0 : 24.0;
    double fontSize = screenWidth < 400 ? 18 : 20;
    double buttonFontSize = screenWidth < 400 ? 16 : 18;
    double buttonHeight = screenHeight < 600 ? 48 : 56;

    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                "$currentPage of 14",
                style: TextStyle(
                  fontSize: isPortrait ? fontSize : fontSize + 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: AppColors.primaryColor,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              children: [
                // PageView to hold different steps
                SizedBox(
                  height: screenHeight * 0.75, // Adjust height dynamically
                  child: PageView(
                    controller:
                        _pageController, // Use the PageController instance
                    onPageChanged: (pageIndex) {
                      setState(() {
                        currentPage = pageIndex + 1; // Update page number
                      });
                    },
                    children: [
                      buildBirthdayStep(),
                      buildNameStep(),
                      buildGenderStep(),
                      buildBestDescribeYouStep(),
                      buildLookingForStep(),
                      buildRelationshipStatusInterestStep(context),
                      buildInterestStep(context),
                      buildUserDescriptionStep(fontSize),
                      buildPhotosOfUser(fontSize),
                      buildPermissionRequestStep(fontSize),
                      buildPaymentWidget(fontSize),
                      buildSafetyGuidelinesWidget(fontSize),
                      buildProfileSummaryPage(fontSize),
                    ],
                  ),
                ),
                // Next Button
                SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, buttonHeight),
                    foregroundColor: AppColors.textColor,
                    backgroundColor: AppColors.buttonColor, // Full width button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                  ),
                  onPressed: _nextStep, // Navigate to the next step

                  child: Text(
                    'Next',
                    style: AppTextStyles.buttonText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Step 1: Birthday Selection
  Widget buildDatePicker(String label, int min, int max, int currentValue,
      ValueChanged<int> onChanged) {
    return SizedBox(
      width: 80,
      child: TextFormField(
        initialValue: currentValue.toString(),
        cursorColor: AppColors.cursorColor,
        style: TextStyle(color: AppColors.textColor),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.textColor),
          fillColor: AppColors.formFieldColor,
          contentPadding: EdgeInsets.symmetric(horizontal: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.textColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.textColor),
          ),
        ),
        keyboardType: TextInputType.number,
        onChanged: (value) {
          int intValue = int.tryParse(value) ?? currentValue;
          if (intValue >= min && intValue <= max) {
            onChanged(intValue);
          }
        },
      ),
    );
  }

  Widget buildBirthdayStep() {
    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Heading with AppTextStyles
            Text(
              "What is your date of birth?",
              style:
                  AppTextStyles.titleText, // Use titleText from AppTextStyles
            ),
            SizedBox(height: 40),

            // Subheading with AppTextStyles
            Text(
              "You must be 18+ to use this app.",
              style: AppTextStyles.bodyText.copyWith(
                color:
                    Colors.redAccent, // This text is red, using color directly
              ),
            ),
            SizedBox(height: 43),

            // Date Pickers Row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildDatePicker("Day", 1, 31, selectedDay, (value) {
                  setState(() {
                    selectedDay = value;
                  });
                }),
                SizedBox(width: 20),
                Text("",
                    style: AppTextStyles
                        .bodyText), // Empty text (with consistent styling)
                SizedBox(width: 8),
                buildDatePicker("Month", 1, 12, selectedMonth, (value) {
                  setState(() {
                    selectedMonth = value;
                  });
                }),
                SizedBox(width: 20),
                Text('',
                    style: AppTextStyles
                        .bodyText), // Empty text (with consistent styling)
                SizedBox(width: 20),
                buildDatePicker("Year", 1900, DateTime.now().year, selectedYear,
                    (value) {
                  setState(() {
                    selectedYear = value;
                  });
                }),
              ],
            ),
            SizedBox(height: 70),

            // Displaying selected date in the same style (uncommented)
            // Text(
            //   "Selected Date: ${DateFormat('d MMM yyyy').format(DateTime(selectedYear, selectedMonth, selectedDay))}",
            //   style: AppTextStyles.bodyText.copyWith(
            //     fontWeight: FontWeight.w600,
            //   ),
            // ),
            SizedBox(height: 20),

            // Next button with AppTextStyles.buttonText for consistent button text style
            // ElevatedButton(
            //   onPressed: () {
            //     DateTime selectedDate = DateTime(selectedYear, selectedMonth, selectedDay);
            //     DateTime now = DateTime.now();
            //     if (now.difference(selectedDate).inDays >= 18 * 365) {
            //       // Proceed with further steps
            //     } else {
            //       // Show an error if the age is under 18
            //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            //         content: Text(
            //           'You must be at least 18 years old to proceed.',
            //           style: AppTextStyles.bodyText, // Ensure the error message style is consistent
            //         ),
            //         backgroundColor: Colors.red,
            //       ));
            //     }
            //   },
            //   style: ElevatedButton.styleFrom(
            //     padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
            //     backgroundColor: AppColors.buttonColor, // Consistent button color
            //     foregroundColor: AppColors.textColor, // Button text color
            //   ),
            //   child: Text('Next', style: AppTextStyles.buttonText), // Consistent button text style
            // ),
          ],
        ),
      ),
    );
  }

  // Step 2: Name Input
  Widget buildNameStep() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Heading text using AppTextStyles
            Text(
              "What do we call you?",
              style: AppTextStyles.titleText.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: AppTextStyles.titleSize,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              onChanged: (value) {
                name = value;
              },
              decoration: InputDecoration(
                labelText: "Your Name",
                labelStyle: AppTextStyles.labelText.copyWith(
                  color: AppColors.textColor, // Consistent label text color
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.textColor),
                ),
                filled: true,
                fillColor: AppColors
                    .formFieldColor, // Consistent form field background color
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.textColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.textColor),
                ),
              ),
              style: AppTextStyles.inputFieldText.copyWith(
                color:
                    AppColors.textColor, // Consistent text color for the input
              ),
              cursorColor: AppColors.cursorColor, // Consistent cursor color
            ),
          ],
        ),
      ),
    );
  }

  // Step 3: Gender Selection
  Widget buildGenderStep() {
    List<String> genderOptions = ['Male', 'Female', 'Non-Binary'];
    Rx<int> selectedGenderIndex =
        Rx<int>(-1); // -1 means no option is selected initially

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Heading text using AppTextStyles
            Text(
              "Select your gender",
              style: AppTextStyles.titleText.copyWith(
                fontSize: AppTextStyles
                    .titleSize, // Use consistent font size from AppTextStyles
                fontWeight: FontWeight.bold,
                color: AppColors.textColor, // Use AppColors for text color
              ),
            ),
            SizedBox(height: 20),

            // Gender options using RadioListTile
            Obx(() {
              return Column(
                children: List.generate(genderOptions.length, (index) {
                  return RadioListTile<int>(
                    title: Text(
                      genderOptions[index],
                      style: AppTextStyles.bodyText.copyWith(
                        color: AppColors.textColor, // Use consistent text color
                      ),
                    ),
                    value: index,
                    groupValue: selectedGenderIndex.value,
                    onChanged: (int? value) {
                      selectedGenderIndex.value = value ?? -1;
                    },
                    activeColor: AppColors
                        .buttonColor, // Use AppColors for active radio button color
                  );
                }),
              );
            }),
          ],
        ),
      ),
    );
  }

  // Step 4: Describe Yourself (New Step)
  Widget buildBestDescribeYouStep() {
    // RxString to store the selected option
    RxString selectedOption = ''.obs;

    List<String> options = [
      'Pansexual',
      'Polysexual',
      'Bisexual',
      'Asexual',
      'Other'
    ];

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Heading Text using AppTextStyles
            Text(
              "Which Best Describe You",
              style: AppTextStyles.titleText.copyWith(
                fontSize: AppTextStyles
                    .titleSize, // Use AppTextStyles for consistent size
                fontWeight: FontWeight.bold,
                color: AppColors.textColor, // Use AppColors for text color
              ),
            ),
            SizedBox(height: 20),

            // Description Text using AppTextStyles
            Text(
              "Select the option that best describes your identity.",
              style: AppTextStyles.bodyText.copyWith(
                fontSize: AppTextStyles
                    .bodySize, // Use AppTextStyles for consistent size
                color:
                    AppColors.textColor, // Ensure the color is from AppColors
              ),
            ),
            SizedBox(height: 20),

            // Options using RadioListTile
            Obx(() {
              return Column(
                children: List.generate(options.length, (index) {
                  return RadioListTile<String>(
                    title: Text(
                      options[index],
                      style: AppTextStyles.bodyText.copyWith(
                        color:
                            AppColors.textColor, // Use AppColors for text color
                      ),
                    ),
                    value: options[index],
                    groupValue: selectedOption.value,
                    onChanged: (String? value) {
                      selectedOption.value = value ?? '';
                    },
                    activeColor: AppColors
                        .buttonColor, // Use AppColors for active radio button color
                    contentPadding:
                        EdgeInsets.zero, // Remove padding for a cleaner look
                  );
                }),
              );
            }),
          ],
        ),
      ),
    );
  }

// step 5 who are you looking for
  Widget buildLookingForStep() {
    // RxList for selected options
    RxList<bool> selectedOptions = [false, false, false, false, false].obs;
    List<String> options = ['Men', 'Women', 'Men+MenCouple', 'Agender', 'Both'];

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Heading Text using AppTextStyles
            Text(
              "Who are you looking for?",
              style: AppTextStyles.titleText.copyWith(
                fontSize: AppTextStyles
                    .titleSize, // Use AppTextStyles for size consistency
                fontWeight: FontWeight.bold,
                color: AppColors
                    .textColor, // Use AppColors for text color consistency
              ),
            ),
            SizedBox(height: 20),

            // Description Text using AppTextStyles
            Text(
              "Select the gender(s) you're interested in.",
              style: AppTextStyles.bodyText.copyWith(
                fontSize: AppTextStyles
                    .bodySize, // Use AppTextStyles for size consistency
                color: AppColors
                    .textColor, // Ensure text color matches the app's color scheme
              ),
            ),
            SizedBox(height: 20),

            // Checkbox options using Obx and reactive list
            Obx(() {
              return Column(
                children: List.generate(options.length, (index) {
                  return CheckboxListTile(
                    title: Text(
                      options[index],
                      style: AppTextStyles.bodyText.copyWith(
                        color: AppColors
                            .textColor, // Use AppColors for text color consistency
                      ),
                    ),
                    value: selectedOptions[index],
                    onChanged: (bool? value) {
                      selectedOptions[index] = value ?? false;
                    },
                    activeColor: AppColors
                        .buttonColor, // Use AppColors for active checkbox color
                    checkColor: Colors.white, // Use white for check mark color
                    contentPadding:
                        EdgeInsets.zero, // Remove padding for a cleaner look
                  );
                }),
              );
            }),
          ],
        ),
      ),
    );
  }

// Step 6: Gender Identity Selection
  Widget buildRelationshipStatusInterestStep(BuildContext context) {
    List<String> options = [
      'Casual',
      'In a Friendship',
      "For Fun",
      'Enjoyment',
      'Swings',
      'Serious',
      'Looking for Fun',
      'Not Interested',
      'Open to Ideas',
      'Looking for Commitment',
      'Love',
      'Casual Chat'
    ];

    RxList<bool> selectedOptions = List.filled(options.length, false).obs;
    RxList<String> selectedStatus = <String>[].obs;

    void updateSelectedStatus() {
      selectedStatus.clear();
      for (int i = 0; i < selectedOptions.length; i++) {
        if (selectedOptions[i]) {
          selectedStatus.add(options[i]);
        }
      }
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.05;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Relationship Heading
              Text(
                "Relationship",
                style: AppTextStyles.titleText.copyWith(
                  fontSize: AppTextStyles
                      .titleSize, // Use AppTextStyles for size consistency
                  fontWeight: FontWeight.bold,
                  color: AppColors
                      .textColor, // Ensure text color matches the app's color scheme
                ),
              ),
              SizedBox(height: 20),

              // Description Text
              Text(
                "Let People Know What You are into. You can add or edit Desires as often as you want.",
                style: AppTextStyles.bodyText.copyWith(
                  fontSize: AppTextStyles.bodySize, // Consistent font size
                  color: AppColors.textColor, // Consistent color
                ),
              ),
              SizedBox(height: 20),

              // Selected Status Chips
              Obx(() {
                return selectedStatus.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "You selected:",
                            style: AppTextStyles.bodyText.copyWith(
                              fontSize: AppTextStyles.bodySize,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                          ),
                          SizedBox(height: 10),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: selectedStatus.map((status) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Chip(
                                    label: Text(status),
                                    backgroundColor: AppColors
                                        .buttonColor, // Use AppColors for chip background
                                    labelStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: AppTextStyles.bodySize - 6,
                                    ),
                                    onDeleted: () {
                                      int index = options.indexOf(status);
                                      selectedOptions[index] = false;
                                      updateSelectedStatus();
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      )
                    : Container();
              }),

              // Select Interests Heading
              Text(
                "Select your interests:",
                style: AppTextStyles.bodyText.copyWith(
                  fontSize: AppTextStyles.bodySize, // Consistent font size
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              SizedBox(height: 10),

              // Interest Chips (Selectable)
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(options.length, (index) {
                    return GestureDetector(
                      onTap: () {
                        selectedOptions[index] = !selectedOptions[index];
                        updateSelectedStatus();
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Chip(
                          label: Text(options[index]),
                          backgroundColor: selectedOptions[index]
                              ? AppColors.buttonColor
                              : AppColors
                                  .formFieldColor, // Use AppColors for selected/unselected state
                          labelStyle: TextStyle(
                            color: selectedOptions[index]
                                ? Colors.white
                                : AppColors.textColor, // Consistent text color
                            fontSize: AppTextStyles.bodySize - 6,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // Cancel Button
              Obx(() {
                return selectedStatus.isNotEmpty
                    ? Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {
                            selectedOptions.value =
                                List.filled(options.length, false);
                            updateSelectedStatus();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors
                                .deniedColor, // Consistent button color
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          child: Text(
                            'Cancel',
                            style: AppTextStyles.buttonText.copyWith(
                              fontSize: AppTextStyles.buttonSize,
                              color: AppColors.textColor,
                            ),
                          ),
                        ),
                      )
                    : Container();
              }),
            ],
          ),
        ),
      ),
    );
  }

// step 7

  Widget buildInterestStep(BuildContext context) {
    // Reactive list to store user-entered interests
    RxList<String> selectedInterests = <String>[].obs;
    TextEditingController _interestController = TextEditingController();
    FocusNode _interestFocusNode = FocusNode();

    // Check if the user has selected at least 10 interests
    bool isSelectionValid() {
      return selectedInterests.length >= 10;
    }

    // Function to handle adding a new interest
    void addInterest() {
      String newInterest = _interestController.text.trim();
      if (newInterest.isNotEmpty && !selectedInterests.contains(newInterest)) {
        selectedInterests.add(newInterest); // Add the new interest to the list
        _interestController.clear(); // Clear the input field after adding
        _interestFocusNode
            .unfocus(); // Unfocus the text field to close the keyboard
      }
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.05;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                "What are your interests?",
                style: AppTextStyles.titleText.copyWith(
                  fontSize: AppTextStyles.titleSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors
                      .textColor, // Consistent text color from AppColors
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Enter your interests one by one. Select at least 10.",
                style: AppTextStyles.bodyText.copyWith(
                  fontSize: AppTextStyles.bodySize - 2,
                  color: AppColors.textColor
                      .withOpacity(0.7), // Consistent text color
                ),
              ),
              SizedBox(height: 20),

              // Input field to add a new interest
              TextField(
                controller: _interestController,
                focusNode: _interestFocusNode,
                decoration: InputDecoration(
                  labelText: "Enter interest",
                  labelStyle: TextStyle(color: AppColors.textColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.textColor),
                  ),
                  filled: true,
                  fillColor: AppColors
                      .formFieldColor, // Background color for the input
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.textColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.textColor),
                  ),
                ),
                style: TextStyle(color: AppColors.textColor), // Text color
                cursorColor: AppColors.textColor, // Cursor color
                onSubmitted: (_) {
                  addInterest(); // Add interest when the "Enter" key is pressed
                },
              ),
              SizedBox(height: 20),

              // Button to add the interest to the list
              ElevatedButton(
                onPressed: addInterest,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      AppColors.buttonColor, // Consistent button color
                  foregroundColor: AppColors.textColor,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  'Add Interest',
                  style: AppTextStyles.buttonText.copyWith(
                    fontSize: AppTextStyles.buttonSize,
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Reactive display of selected interests
              Obx(() {
                return selectedInterests.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Your Interest:",
                            style: AppTextStyles.bodyText.copyWith(
                              fontSize: AppTextStyles.bodySize,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                          ),
                          SizedBox(height: 10),
                          SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: selectedInterests.map((interest) {
                                return Chip(
                                  label: Text(interest),
                                  backgroundColor: AppColors
                                      .buttonColor, // Consistent chip background color
                                  labelStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: AppTextStyles.bodySize - 6,
                                  ),
                                  onDeleted: () {
                                    selectedInterests.remove(
                                        interest); // Remove the interest from the list
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      )
                    : Container();
              }),

              // Optionally, add a "Continue" button based on the selected interests count
              Obx(() {
                return isSelectionValid()
                    ? Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {
                            // Proceed with the next action (e.g., navigate to the next screen)
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors
                                .acceptColor, // Consistent button color for continue
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          child: Text(
                            'Continue',
                            style: AppTextStyles.buttonText.copyWith(
                              fontSize: AppTextStyles.buttonSize,
                              color: AppColors.textColor,
                            ),
                          ),
                        ),
                      )
                    : Container();
              }),
            ],
          ),
        ),
      ),
    );
  }

// step 8

  Widget buildUserDescriptionStep(double fontSize) {
    // Reactive variable for storing the description text
    RxString userDescription = ''.obs;

    // Function to handle description change
    void onDescriptionChanged(String value) {
      userDescription.value = value;
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double fontSizeResponsive = screenWidth * 0.05;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Tell Us About You",
                style: AppTextStyles.titleText.copyWith(
                  fontSize: AppTextStyles.titleSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor, // Consistent text color
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Describe yourself in 250 words or less.",
                style: AppTextStyles.bodyText.copyWith(
                  fontSize: AppTextStyles.bodySize - 2,
                  color: AppColors.textColor,
                ),
              ),
              SizedBox(height: 20),

              // Description input field
              TextField(
                onChanged: onDescriptionChanged,
                maxLength: 250,
                maxLines: 6, // Allow the user to input a multiline description
                decoration: InputDecoration(
                  labelText: "Your Description",
                  labelStyle: TextStyle(color: AppColors.textColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.textColor),
                  ),
                  filled: true,
                  fillColor:
                      AppColors.formFieldColor, // Consistent form field color
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.textColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.textColor),
                  ),
                ),
                style: TextStyle(color: AppColors.textColor),
                cursorColor: AppColors.cursorColor, // Consistent cursor color
                textInputAction: TextInputAction.done,
              ),
              SizedBox(height: 20),

              // Character count display
              Obx(() {
                return Text(
                  '${userDescription.value.length} / 250 characters',
                  style: AppTextStyles.bodyText.copyWith(
                    fontSize: AppTextStyles.bodySize - 2,
                    color: userDescription.value.length > 250
                        ? Colors.red
                        : AppColors.textColor,
                  ),
                );
              }),
              SizedBox(height: 20),

              // Submit button (Commented out for now, can be re-enabled as needed)
              // Obx(() {
              //   return ElevatedButton(
              //     onPressed: userDescription.value.isNotEmpty && userDescription.value.length <= 250
              //         ? () {
              //             // Handle the submission of the description
              //             print("User Description: ${userDescription.value}");
              //           }
              //         : null, // Disable button if description is empty or too long
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: userDescription.value.isNotEmpty && userDescription.value.length <= 250
              //           ? AppColors.buttonColor
              //           : Colors.grey, // Button color based on validation
              //       padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              //     ),
              //     child: Text(
              //       'Submit',
              //       style: AppTextStyles.buttonText.copyWith(
              //         fontSize: AppTextStyles.buttonSize,
              //       ),
              //     ),
              //   );
              // }),
            ],
          ),
        ),
      ),
    );
  }

// photos
  Widget buildPhotosOfUser(double fontSize) {
    RxList<File?> _images = RxList<File?>();

    Future<void> _pickImage(int index, ImageSource source) async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        _images[index] =
            File(pickedFile.path); // Update the image at the specified index
      }
    }

    // Request camera permission
    Future<void> _requestCameraPermission() async {
      var status = await Permission.camera.request();
      if (status.isDenied) {
        Get.snackbar('', "Camera permission denied");
      }
    }

    // Request gallery permission
    Future<void> _requestGalleryPermission() async {
      var status = await Permission.photos.request();
      if (status.isDenied) {
        Get.snackbar("", "Gallery permission denied");
      }
    }

    return Scaffold(
      body: Obx(() {
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 images per row
            crossAxisSpacing: 20.0,
            mainAxisSpacing: 40.0,
          ),
          itemCount: _images.length + 1,
          itemBuilder: (context, index) {
            if (index == _images.length) {
              return Center(
                child: ElevatedButton(
                  onPressed: () {
                    _images.add(null);
                  },
                  child: Icon(
                    Icons.add_a_photo,
                    size: 60,
                    color: Colors.grey.shade600,
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(16),
                  ),
                ),
              );
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _images[index] != null
                          ? GestureDetector(
                              onTap: () {
                                // Show dialog when the image is tapped
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Pick an image'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              _pickImage(
                                                  index, ImageSource.camera);
                                            },
                                            child: const Icon(Icons.camera_alt),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              _pickImage(
                                                  index, ImageSource.gallery);
                                            },
                                            child: const Icon(Icons.photo),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Image.file(
                                _images[index]!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : GestureDetector(
                              onTap: () {
                                // Show dialog when the placeholder icon is tapped
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Pick an image'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              _pickImage(
                                                  index, ImageSource.camera);
                                            },
                                            child: const Icon(Icons.camera_alt),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              _pickImage(
                                                  index, ImageSource.gallery);
                                            },
                                            child: const Icon(Icons.photo),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Icon(
                                Icons.image,
                                size: 40,
                                color: Colors.grey.shade600,
                              ),
                            ),
                    ),
                  ],
                ),
              );
            }
          },
        );
      }),
    );
  }

  // step 10
  Widget buildPermissionRequestStep(double fontSize) {
    // Observable to track the user's responses to permissions
    RxBool notificationGranted = false.obs;
    RxBool locationGranted = false.obs;

    // Function to show dialog
    Future<void> showPermissionDialog(
        BuildContext context, String permissionType) async {
      // Show the dialog to confirm permission action (Accept / Deny)
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // Prevent closing dialog by tapping outside
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              permissionType == 'notification'
                  ? "Notification Permission"
                  : "Location Permission",
              style: AppTextStyles.titleText.copyWith(
                fontSize: fontSize,
                color: AppColors.textColor, // Consistent text color
              ),
            ),
            content: Text(
              permissionType == 'notification'
                  ? "Do you allow the app to send notifications?"
                  : "Do you allow the app to access your location?",
              style: AppTextStyles.bodyText.copyWith(
                fontSize: fontSize - 2,
                color: AppColors.textColor, // Consistent text color
              ),
            ),
            actions: <Widget>[
              // Deny button
              TextButton(
                onPressed: () {
                  // Update the corresponding permission as denied
                  if (permissionType == 'notification') {
                    notificationGranted.value = false;
                  } else if (permissionType == 'location') {
                    locationGranted.value = false;
                  }
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text(
                  'Deny',
                  style: AppTextStyles.bodyText.copyWith(
                    color: Colors.red,
                    fontSize: fontSize,
                  ),
                ),
              ),
              // Accept button
              TextButton(
                onPressed: () {
                  // Update the corresponding permission as granted
                  if (permissionType == 'notification') {
                    notificationGranted.value = true;
                  } else if (permissionType == 'location') {
                    locationGranted.value = true;
                  }
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text(
                  'Accept',
                  style: AppTextStyles.bodyText.copyWith(
                    color: Colors.green,
                    fontSize: fontSize,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    return Column(
      children: [
        // Heading Card
        Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "Permissions",
                  style: AppTextStyles.titleText.copyWith(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                SizedBox(height: 10),

                // Additional text after heading
                Text(
                  "Do we have permission to access the following?",
                  style: AppTextStyles.bodyText.copyWith(
                    fontSize: fontSize - 2,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 20),

        // Notification Permission Section
        GestureDetector(
          onTap: () {
            // Show dialog when the card is tapped
            showPermissionDialog(context, 'notification');
          },
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Notification Icon
                  Icon(
                    Icons.notifications,
                    color: AppColors.iconColor, // Consistent icon color
                    size: fontSize,
                  ),
                  SizedBox(width: 10),
                  // Notification Text
                  Expanded(
                    child: Text(
                      "We need permission to send you notifications.",
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: fontSize - 2,
                        color: AppColors.textColor,
                      ),
                    ),
                  ),
                  // Grant/Deny Status (text)
                  Obx(() {
                    return Text(
                      notificationGranted.value ? 'Granted' : 'Tap to Grant',
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: fontSize - 2,
                        color: notificationGranted.value
                            ? AppColors.buttonColor
                            : AppColors.formFieldColor,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 20),

        // Location Permission Section
        GestureDetector(
          onTap: () {
            // Show dialog when the card is tapped
            showPermissionDialog(context, 'location');
          },
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Location Icon
                  Icon(
                    Icons.location_on,
                    color: AppColors.iconColor, // Consistent icon color
                    size: fontSize,
                  ),
                  SizedBox(width: 10),
                  // Location Text
                  Expanded(
                    child: Text(
                      "We need permission to access your location.",
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: fontSize - 2,
                        color: AppColors.textColor,
                      ),
                    ),
                  ),
                  // Grant/Deny Status (text)
                  Obx(() {
                    return Text(
                      locationGranted.value ? 'Granted' : 'Tap to Grant',
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: fontSize - 2,
                        color: locationGranted.value
                            ? AppColors.buttonColor
                            : AppColors.formFieldColor,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 20),

        // Optional Next Button (Enabled only if both permissions are granted)
        // Obx(() {
        //   return ElevatedButton(
        //     onPressed: notificationGranted.value && locationGranted.value
        //         ? () {
        //             // Handle the next step or permission submission
        //             print("Permissions Granted: Notification and Location");
        //           }
        //         : null, // Disable button if permissions are not granted
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: notificationGranted.value && locationGranted.value
        //           ? AppColors.buttonColor
        //           : Colors.grey, // Button color based on permissions
        //       padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        //     ),
        //     child: Text(
        //       'Next',
        //       style: AppTextStyles.buttonText.copyWith(
        //         fontSize: fontSize,
        //       ),
        //     ),
        //   );
        // }),
      ],
    );
  }

// step: 11
  Widget buildPaymentWidget(double fontSize) {
    // Observable to track the selected plan
    RxString selectedPlan = 'None'.obs;

    // Function to show confirmation dialog
    Future<void> showPaymentConfirmationDialog(
        BuildContext context, String planType, String amount) async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // Prevent closing dialog by tapping outside
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Confirm Subscription",
              style: AppTextStyles.titleText.copyWith(
                fontSize: fontSize,
                color: AppColors.textColor, // Consistent text color
              ),
            ),
            content: Text(
              "Do you want to subscribe to the $planType plan for $amount?",
              style: AppTextStyles.bodyText.copyWith(
                fontSize: fontSize - 2,
                color: AppColors.textColor, // Consistent text color
              ),
            ),
            actions: <Widget>[
              // Deny button
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text(
                  'Cancel',
                  style: AppTextStyles.bodyText.copyWith(
                    color: AppColors.deniedColor,
                    fontSize: fontSize,
                  ),
                ),
              ),
              // Accept button
              TextButton(
                onPressed: () {
                  // Update the selected plan and close the dialog
                  selectedPlan.value = planType;
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text(
                  'Subscribe',
                  style: AppTextStyles.bodyText.copyWith(
                    color: AppColors.acceptColor,
                    fontSize: fontSize,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    return Column(
      children: [
        // Heading Card
        Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "Subscription Plans",
                  style: AppTextStyles.titleText.copyWith(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor, // Consistent text color
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Choose a plan that suits you!",
                  style: AppTextStyles.bodyText.copyWith(
                    fontSize: fontSize - 2,
                    color: AppColors.textColor, // Consistent text color
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 20),

        // Monthly Plan Section
        GestureDetector(
          onTap: () {
            // Show confirmation dialog when the card is tapped
            showPaymentConfirmationDialog(context, 'Monthly', '₹99/month');
          },
          child: Stack(
            clipBehavior: Clip.none, // Allow widget to overflow (banner above)
            children: [
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.orange, // Set card background color to orange
                child: Padding(
                  padding: const EdgeInsets.all(24.0), // Increased padding
                  child: Row(
                    children: [
                      // Monthly Icon
                      Icon(
                        Icons.calendar_today,
                        color: AppColors.iconColor, // Consistent icon color
                        size: fontSize,
                      ),
                      SizedBox(width: 10),
                      // Monthly Plan Text
                      Expanded(
                        child: Text(
                          "Monthly Plan - ₹99/month",
                          style: AppTextStyles.bodyText.copyWith(
                            fontSize: fontSize - 2,
                            color: AppColors.textColor, // Consistent text color
                          ),
                        ),
                      ),
                      // Plan Status (text)
                      Obx(() {
                        return Text(
                          selectedPlan.value == 'Monthly'
                              ? 'Selected'
                              : 'Select',
                          style: AppTextStyles.bodyText.copyWith(
                            fontSize: fontSize - 2,
                            color: selectedPlan.value == 'Monthly'
                                ? AppColors.buttonColor
                                : AppColors.formFieldColor,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              // Discount Percentage Banner (positioned at top-right corner)
              Positioned(
                top: 4, // Slightly higher position
                right: 2, // Position at the top-right corner
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                  decoration: BoxDecoration(
                    color: Colors.red, // Set the background color to red
                    borderRadius: BorderRadius.circular(12), // Curved corners
                  ),
                  child: Text(
                    '20% OFF', // Display the discount percentage
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize - 6, // Smaller font size
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),

        // Quarterly Plan Section
        GestureDetector(
          onTap: () {
            // Show confirmation dialog when the card is tapped
            showPaymentConfirmationDialog(
                context, 'Quarterly', '₹599/3 months');
          },
          child: Stack(
            clipBehavior: Clip.none, // Allow widget to overflow (banner above)
            children: [
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.orange, // Set card background color to orange
                child: Padding(
                  padding: const EdgeInsets.all(24.0), // Increased padding
                  child: Row(
                    children: [
                      // Quarterly Icon
                      Icon(
                        Icons.calendar_view_day,
                        color: AppColors.iconColor, // Consistent icon color
                        size: fontSize,
                      ),
                      SizedBox(width: 10),
                      // Quarterly Plan Text
                      Expanded(
                        child: Text(
                          "Quarterly Plan - ₹599/3 months",
                          style: AppTextStyles.bodyText.copyWith(
                            fontSize: fontSize - 2,
                            color: AppColors.textColor, // Consistent text color
                          ),
                        ),
                      ),
                      // Plan Status (text)
                      Obx(() {
                        return Text(
                          selectedPlan.value == 'Quarterly'
                              ? 'Selected'
                              : 'Select',
                          style: AppTextStyles.bodyText.copyWith(
                            fontSize: fontSize - 2,
                            color: selectedPlan.value == 'Quarterly'
                                ? AppColors.buttonColor
                                : AppColors.formFieldColor,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              // Discount Percentage Banner (positioned at top-right corner)
              Positioned(
                top: 4, // Slightly higher position
                right: 2, // Position at the top-right corner
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                  decoration: BoxDecoration(
                    color: Colors.red, // Set the background color to red
                    borderRadius: BorderRadius.circular(12), // Curved corners
                  ),
                  child: Text(
                    '15% OFF', // Display the discount percentage
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize - 6, // Smaller font size
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),

        // Yearly Plan Section
        GestureDetector(
          onTap: () {
            // Show confirmation dialog when the card is tapped
            showPaymentConfirmationDialog(context, 'Yearly', '₹999/year');
          },
          child: Stack(
            clipBehavior: Clip.none, // Allow widget to overflow (banner above)
            children: [
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.orange, // Set card background color to orange
                child: Padding(
                  padding: const EdgeInsets.all(24.0), // Increased padding
                  child: Row(
                    children: [
                      // Yearly Icon
                      Icon(
                        Icons.calendar_today,
                        color: AppColors.iconColor, // Consistent icon color
                        size: fontSize,
                      ),
                      SizedBox(width: 10),
                      // Yearly Plan Text
                      Expanded(
                        child: Text(
                          "Yearly Plan - ₹999/year",
                          style: AppTextStyles.bodyText.copyWith(
                            fontSize: fontSize - 2,
                            color: AppColors.textColor, // Consistent text color
                          ),
                        ),
                      ),
                      // Plan Status (text)
                      Obx(() {
                        return Text(
                          selectedPlan.value == 'Yearly'
                              ? 'Selected'
                              : 'Select',
                          style: AppTextStyles.bodyText.copyWith(
                            fontSize: fontSize - 2,
                            color: selectedPlan.value == 'Yearly'
                                ? AppColors.buttonColor
                                : AppColors.formFieldColor,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              // Discount Percentage Banner (positioned at top-right corner)
             Positioned(
                top: 4, // Slightly higher position
                right: 2, // Position at the top-right corner
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                  decoration: BoxDecoration(
                    color: Colors.red, // Set the background color to red
                    borderRadius: BorderRadius.circular(12), // Curved corners
                  ),
                  child: Text(
                    '35% OFF', // Display the discount percentage
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize - 6, // Smaller font size
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),

        // Proceed Button (only enabled if a plan is selected)
        Obx(() {
          return ElevatedButton(
            onPressed: selectedPlan.value != 'None'
                ? () {
                    // Proceed with payment logic here
                    print("Selected Plan: ${selectedPlan.value}");
                  }
                : null, // Disable button if no plan is selected
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedPlan.value != 'None'
                  ? AppColors.buttonColor
                  : Colors.grey, // Button color based on selection
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              'Proceed to Payment',
              style: AppTextStyles.buttonText.copyWith(
                fontSize: fontSize,
              ),
            ),
          );
        }),
      ],
    );
  }

// step 12
  Widget buildSafetyGuidelinesWidget(double fontSize) {
    return SingleChildScrollView(
      // Wrap the whole Column with SingleChildScrollView
      child: Column(
        children: [
          // Heading Card
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    "Safety Guidelines",
                    style: AppTextStyles.titleText.copyWith(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor, // Consistent color
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Please follow these rules to ensure a safe experience.",
                    style: AppTextStyles.bodyText.copyWith(
                      fontSize: fontSize - 2,
                      color: AppColors.textColor, // Consistent color
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),

          // Safety Guidelines List
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Safety Guideline Item 1
                  Row(
                    children: [
                      Icon(
                        Icons.warning,
                        color: AppColors.iconColor, // Consistent icon color
                        size: fontSize,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Never share personal information like your address or bank details.",
                          style: AppTextStyles.bodyText.copyWith(
                            fontSize: fontSize - 2,
                            color: AppColors.textColor, // Consistent color
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),

                  // Safety Guideline Item 2
                  Row(
                    children: [
                      Icon(
                        Icons.warning,
                        color: AppColors.iconColor, // Consistent icon color
                        size: fontSize,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Always meet in public places for your first date.",
                          style: AppTextStyles.bodyText.copyWith(
                            fontSize: fontSize - 2,
                            color: AppColors.textColor, // Consistent color
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),

                  // Safety Guideline Item 3
                  Row(
                    children: [
                      Icon(
                        Icons.warning,
                        color: AppColors.iconColor, // Consistent icon color
                        size: fontSize,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Respect boundaries and report any inappropriate behavior.",
                          style: AppTextStyles.bodyText.copyWith(
                            fontSize: fontSize - 2,
                            color: AppColors.textColor, // Consistent color
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),

                  // Safety Guideline Item 4
                  Row(
                    children: [
                      Icon(
                        Icons.warning,
                        color: AppColors.iconColor, // Consistent icon color
                        size: fontSize,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Do not send money or gifts to people you meet online.",
                          style: AppTextStyles.bodyText.copyWith(
                            fontSize: fontSize - 2,
                            color: AppColors.textColor, // Consistent color
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),

                  // Safety Guideline Item 5
                  Row(
                    children: [
                      Icon(
                        Icons.warning,
                        color: AppColors.iconColor, // Consistent icon color
                        size: fontSize,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "If you feel unsafe, immediately contact local authorities.",
                          style: AppTextStyles.bodyText.copyWith(
                            fontSize: fontSize - 2,
                            color: AppColors.textColor, // Consistent color
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),

          // Acknowledge Button
          ElevatedButton(
            onPressed: () {
              print("User acknowledged safety guidelines.");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonColor, // Consistent button color
              foregroundColor:
                  AppColors.textColor, // Consistent button text color
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              'Acknowledge',
              style: AppTextStyles.buttonText.copyWith(
                fontSize: fontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

// step 13
  Widget buildProfileSummaryPage(double fontSize) {
    return SingleChildScrollView(
      // Wrap everything in a scrollable view
      child: Column(
        children: [
          // Heading Card
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    "Profile Summary",
                    style: AppTextStyles.titleText.copyWith(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor, // Consistent color
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Review your profile and preferences before starting your journey.",
                    style: AppTextStyles.bodyText.copyWith(
                      fontSize: fontSize - 2,
                      color: AppColors.textColor, // Consistent color
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),

          // Profile Picture Section
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: fontSize * 1.5,
                    backgroundImage: AssetImage(
                        'assets/profile_picture.jpg'), // Example image
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Name: Jane Doe",
                          style: AppTextStyles.titleText.copyWith(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor, // Consistent color
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Age: 25",
                          style: AppTextStyles.bodyText.copyWith(
                            fontSize: fontSize - 2,
                            color: AppColors.textColor, // Consistent color
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),

          // Preferences Section
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Your Preferences:",
                    style: AppTextStyles.titleText.copyWith(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor, // Consistent color
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Interested in: Men & Women",
                    style: AppTextStyles.bodyText.copyWith(
                      fontSize: fontSize - 2,
                      color: AppColors.textColor, // Consistent color
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Looking for: Long-Term Relationship",
                    style: AppTextStyles.bodyText.copyWith(
                      fontSize: fontSize - 2,
                      color: AppColors.textColor, // Consistent color
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Location: New York",
                    style: AppTextStyles.bodyText.copyWith(
                      fontSize: fontSize - 2,
                      color: AppColors.textColor, // Consistent color
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Hobbies: Traveling, Reading, Photography",
                    style: AppTextStyles.bodyText.copyWith(
                      fontSize: fontSize - 2,
                      color: AppColors.textColor, // Consistent color
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),

          // Subscription Status Section
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.star,
                    color: AppColors.accentColor, // Consistent accent color
                    size: fontSize,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "You are subscribed to the Quarterly Plan (599 INR).",
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: fontSize - 2,
                        color: AppColors.textColor, // Consistent color
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),

          // Safety Guidelines Acknowledgement Section
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green, // Safety check icon color
                    size: fontSize,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "You have acknowledged the safety guidelines.",
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: fontSize - 2,
                        color: AppColors.textColor, // Consistent color
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 30),

          ElevatedButton(
            onPressed: () {
              print("User is ready to start browsing matches.");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonColor, // Consistent button color
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.edit,
                  color: AppColors.iconColor, // Use constant icon color
                ),
                SizedBox(width: 8),
                Text(
                  'Edit',
                  style: AppTextStyles.buttonText, // Use constant text style
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationRow(String label, String value, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.blueAccent, size: 24),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            "$label: $value",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  void _nextStep() {
    if (currentPage == 1) {
      _pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    } else if (currentPage == 2) {
      // If on page 2 (name), go to page 3 (gender)
      _pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    } else if (currentPage == 3) {
      // If on page 3 (gender), go to page 4 (describe yourself)
      _pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    } else if (currentPage == 4) {
      // If on page 4 (describe yourself), go to page 5 (confirmation)
      _pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    } else if (currentPage == 5) {
      _pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    } else if (currentPage == 6) {
      _pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    } else if (currentPage == 7) {
      _pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    } else if (currentPage == 8) {
      _pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    } else if (currentPage == 9) {
      _pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    } else if (currentPage == 10) {
      _pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    } else if (currentPage == 11) {
      _pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    } else if (currentPage == 12) {
      _pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Form Submitted'),
          content: Text('Your details have been submitted successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
               
              },
              child: Text('OK'),
            ),
            TextButton(onPressed: (){Get.to(HomePage());}, child: Text('Next'))
          ],
        ),
      );
    }
  }
}
