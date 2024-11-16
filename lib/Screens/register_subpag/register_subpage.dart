import 'dart:io';
import 'package:dating_application/Controllers/controller.dart';
import 'package:dating_application/Models/ResponseModels/get_all_benifites_response_model.dart';
import 'package:dating_application/Models/ResponseModels/get_all_gender_from_response_model.dart';
import 'package:dating_application/Models/ResponseModels/get_all_headlines_response_model.dart';
import 'package:dating_application/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../navigationbar/navigationpage.dart';

class MultiStepFormPage extends StatefulWidget {
  const MultiStepFormPage({super.key});

  @override
  MultiStepFormPageState createState() => MultiStepFormPageState();
}

class MultiStepFormPageState extends State<MultiStepFormPage> {
  int selectedDay = DateTime.now().day;
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  String name = '';
  String? gender;
  String description = '';

  int currentPage = 1;
  final PageController pageController = PageController();

  final controller = Get.find<Controller>();
  List<Gender> genderOptions = [];
  RxList<bool> selectedOptions = <bool>[].obs;

  Future<void> fetchBenefits() async {
    await controller.fetchBenefits();
  }

  Future<void> fetchGuidelines() async {
    await controller.fetchSafetyGuidelines();
  }

  Future<void> fetchPreferences() async {
    final success = await controller.fetchPreferences();
    if (success) {
      selectedOptions.value =
          List<bool>.filled(controller.preferences.length, false);
    }
  }

  Future<void> fetchGenders() async {
    final success = await controller.fetchGenders();
    if (success) {
      setState(() {
        genderOptions = controller.genders;
      });
    }
  }

  List<Headline> headlines = [];

  Future<void> fetchHeadlines() async {
    final success = await controller.fetchHeadlines();
    if (success) {
      setState(() {
        headlines = controller.headlines;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchGenders();
    fetchPreferences();
    fetchGuidelines();
    fetchBenefits();
    fetchHeadlines();
  }

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
    //double buttonFontSize = screenWidth < 400 ? 16 : 18;
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
                        pageController, // Use the PageController instance
                    onPageChanged: (pageIndex) {
                      setState(() {
                        currentPage = pageIndex + 1; // Update page number
                      });
                    },
                    children: [
                      buildBirthdayStep(screenSize),
                      buildNameStep(screenSize),
                      buildGenderStep(screenSize),
                      buildBestDescribeYouStep(screenSize),
                      buildLookingForStep(screenSize),
                      buildRelationshipStatusInterestStep(context, screenSize),
                      buildInterestStep(context, screenSize),
                      buildUserDescriptionStep(screenSize),
                      buildPhotosOfUser(screenSize),
                      buildPermissionRequestStep(screenSize),
                      buildPaymentWidget(screenSize),
                      buildSafetyGuidelinesWidget(screenSize),
                      buildProfileSummaryPage(screenSize),
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
                  onPressed: nextStep, // Navigate to the next step

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

  Widget buildBirthdayStep(Size screenSize) {
    final screenSize = MediaQuery.of(context).size; // Get screen size

    // Use a base font size and scale it based on the screen width
    double titleFontSize =
        screenSize.width * 0.05; // 7% of screen width for title
    double subHeadingFontSize =
        screenSize.width * 0.045; // 4.5% of screen width for subheading
    double datePickerFontSize =
        screenSize.width * 0.05; // 5% of screen width for date picker labels

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
              style: AppTextStyles.titleText.copyWith(
                fontSize: titleFontSize, // Adjust font size dynamically
              ),
            ),
            SizedBox(height: 40),

            // Subheading with AppTextStyles
            Text(
              "You must be 18+ to use this app.",
              style: AppTextStyles.bodyText.copyWith(
                color:
                    Colors.redAccent, // This text is red, using color directly
                fontSize: subHeadingFontSize, // Adjust font size dynamically
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
            ElevatedButton(
              onPressed: () {
                DateTime selectedDate =
                    DateTime(selectedYear, selectedMonth, selectedDay);
                DateTime now = DateTime.now();
                if (now.difference(selectedDate).inDays >= 18 * 365) {
                  // Proceed with further steps
                } else {
                  // Show an error if the age is under 18
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      'You must be at least 18 years old to proceed.',
                      style: AppTextStyles
                          .bodyText, // Ensure the error message style is consistent
                    ),
                    backgroundColor: Colors.red,
                  ));
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                backgroundColor:
                    AppColors.buttonColor, // Consistent button color
                foregroundColor: AppColors.textColor, // Button text color
              ),
              child: Text('Next',
                  style:
                      AppTextStyles.buttonText), // Consistent button text style
            ),
          ],
        ),
      ),
    );
  }

  // Step 2: Name Input
  Widget buildNameStep(Size screenSize) {
    // Define font sizes based on screen width
    double titleFontSize =
        screenSize.width * 0.05; // 8% of screen width for title
    double labelfontSize = screenSize.width * 0.03; // 5% for label text
    double inputTextFontSize =
        screenSize.width * 0.045; // 4.5% for input text font

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
            // Heading text with responsive font size
            Text(
              "What do we call you?",
              style: AppTextStyles.titleText.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: titleFontSize, // Dynamic font size for title
              ),
            ),
            SizedBox(height: 20),

            // Name input field with dynamic font size for label and text
            TextField(
              onChanged: (value) {
                name = value;
              },
              decoration: InputDecoration(
                labelText: "Your Name",
                labelStyle: AppTextStyles.labelText.copyWith(
                  fontSize: labelfontSize, // Responsive label font size
                  color: AppColors.textColor, // Consistent label color
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.textColor),
                ),
                filled: true,
                fillColor: AppColors.formFieldColor,
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
                fontSize: inputTextFontSize, // Responsive text font size
                color: AppColors.textColor,
              ),
              cursorColor: AppColors.cursorColor, // Consistent cursor color
            ),
          ],
        ),
      ),
    );
  }

  // Step 3: Gender Selection
  Widget buildGenderStep(Size screenSize) {
    final Rx<Gender?> selectedGender =
        Rx<Gender?>(null); // Initially no gender is selected

    // Define font sizes based on screen width for responsiveness
    double titleFontSize =
        screenSize.width * 0.05; // 5% of screen width for the title
    double optionFontSize = screenSize.width * 0.03; // 3% for options text

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          // Ensure everything is centered
          child: Column( // Center contents horizontally
            children: [
              // Heading text with responsive font size
              Text(
                "Select your Gender",
                style: AppTextStyles.titleText.copyWith(
                  fontSize:
                      titleFontSize, // Responsive font size for the heading
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor, // Consistent text color
                ),
              ),
              const SizedBox(height: 20),

              // Gender options using RadioListTile
              Obx(() {
                return Expanded(
                  // Allow the gender options to take the remaining space
                  child: SingleChildScrollView(
                    // In case the options overflow
                    child: Column(
                      children: genderOptions.map((gender) {
                        return RadioListTile<Gender?>(
                          title: Text(
                            gender
                                .title, // Assumes `Gender` has a `title` property
                            style: AppTextStyles.bodyText.copyWith(
                              fontSize:
                                  optionFontSize, // Responsive font size for options
                              color:
                                  AppColors.textColor, // Consistent text color
                            ),
                          ),
                          value: gender, // The gender object as the radio value
                          groupValue:
                              selectedGender.value, // Tracks the selected value
                          onChanged: (Gender? value) {
                            selectedGender.value =
                                value; // Update the selected gender
                          },
                          activeColor: AppColors
                              .buttonColor, // Active radio button color
                        );
                      }).toList(),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // Step 4: Describe Yourself (New Step)
  Widget buildBestDescribeYouStep(Size screenSize) {
    // RxString to store the selected option
    RxString selectedOption = ''.obs;

    List<String> options = [
      'Pansexual',
      'Polysexual',
      'Bisexual',
      'Asexual',
      'Other'
    ];

    // Calculate font sizes based on screen width
    double titleFontSize =
        screenSize.width * 0.05; // 8% of screen width for title
    double descriptionfontSize = screenSize.width * 0.03; // 5% for description
    double optionfontSize = screenSize.width * 0.03; // 5% for options text

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
            // Heading Text using responsive font size
            Text(
              "Which Best Describe You",
              style: AppTextStyles.titleText.copyWith(
                fontSize: titleFontSize, // Responsive font size for title
                fontWeight: FontWeight.bold,
                color: AppColors.textColor, // Consistent text color
              ),
            ),
            SizedBox(height: 20),

            // Description Text using responsive font size
            Text(
              "Select the option that best describes your identity.",
              style: AppTextStyles.bodyText.copyWith(
                fontSize:
                    descriptionfontSize, // Responsive font size for description
                color: AppColors.textColor, // Consistent text color
              ),
            ),
            SizedBox(height: 20),

            // Options using RadioListTile with responsive font size
            Obx(() {
              return Column(
                children: List.generate(options.length, (index) {
                  return RadioListTile<String>(
                    title: Text(
                      options[index],
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize:
                            optionfontSize, // Responsive font size for options
                        color: AppColors.textColor, // Consistent text color
                      ),
                    ),
                    value: options[index],
                    groupValue: selectedOption.value,
                    onChanged: (String? value) {
                      selectedOption.value = value ?? '';
                    },
                    activeColor:
                        AppColors.buttonColor, // Consistent active color
                    contentPadding: EdgeInsets.zero, // Clean up extra padding
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
  Widget buildLookingForStep(Size screenSize) {
    // Calculate font sizes based on screen width
    double titleFontSize =
        screenSize.width * 0.05; // 5% of screen width for title
    double descriptionFontSize = screenSize.width * 0.03; // 3% for description
    double optionFontSize = screenSize.width * 0.03; // 3% for options text

    return Obx(() {
      if (controller.preferences.isEmpty) {
        return Center(
          child: CircularProgressIndicator(),
        );
      }

      return Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Heading Text
              Center(
                child: Text(
                  "Who are you looking for?",
                  style: AppTextStyles.titleText.copyWith(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              // Description Text
              Center(
                child: Text(
                  "Select the preferences you're interested in.",
                  style: AppTextStyles.bodyText.copyWith(
                    fontSize: descriptionFontSize,
                    color: AppColors.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              // Checkbox options for preferences
              Column(
                children: List.generate(controller.preferences.length, (index) {
                  final preference = controller.preferences[index];
                  return Obx(() {
                    return CheckboxListTile(
                      title: Text(
                        preference.title,
                        style: AppTextStyles.bodyText.copyWith(
                          fontSize: optionFontSize,
                          color: AppColors.textColor,
                        ),
                      ),
                      value: selectedOptions[index],
                      onChanged: (bool? value) {
                        selectedOptions[index] = value ?? false;
                      },
                      activeColor: AppColors.buttonColor,
                      checkColor: Colors.white,
                      contentPadding: EdgeInsets.zero,
                    );
                  });
                }),
              ),
            ],
          ),
        ),
      );
    });
  }

// Step 6: Gender Identity Selection
  Widget buildRelationshipStatusInterestStep(
      BuildContext context, Size screenSize) {
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

    // Calculate responsive font sizes based on screen width
    double screenWidth = screenSize.width;
    double titleFontSize = screenWidth * 0.05; // 8% of screen width for title
    double bodyFontSize =
        screenWidth * 0.03; // 3% of screen width for body text
    double chipFontSize = screenWidth * 0.03; // 4.5% for chip text

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
                  fontSize: titleFontSize, // Responsive title font size
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              SizedBox(height: 20),

              // Description Text
              Text(
                "Let people know what you are into. You can add or edit desires as often as you want.",
                style: AppTextStyles.bodyText.copyWith(
                  fontSize: bodyFontSize, // Responsive body font size
                  color: AppColors.textColor,
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
                              fontSize: bodyFontSize,
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
                                    backgroundColor: AppColors.buttonColor,
                                    labelStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize:
                                          chipFontSize, // Responsive font size for chips
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
                  fontSize:
                      bodyFontSize, // Responsive font size for interest heading
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
                              : AppColors.formFieldColor,
                          labelStyle: TextStyle(
                            color: selectedOptions[index]
                                ? Colors.white
                                : AppColors.textColor,
                            fontSize:
                                chipFontSize, // Responsive font size for chips
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
                            backgroundColor: AppColors.deniedColor,
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
  Widget buildInterestStep(BuildContext context, Size screenSize) {
    RxList<String> selectedInterests = <String>[].obs;
    TextEditingController interestController = TextEditingController();
    FocusNode interestFocusNode = FocusNode();

    // Check if the user has selected at least 10 interests
    bool isSelectionValid() {
      return selectedInterests.length >= 10;
    }

    // Function to handle adding a new interest
    void addInterest() {
      String newInterest = interestController.text.trim();
      if (newInterest.isNotEmpty && !selectedInterests.contains(newInterest)) {
        selectedInterests.add(newInterest); // Add the new interest to the list
        interestController.clear(); // Clear the input field after adding
        interestFocusNode
            .unfocus(); // Unfocus the text field to close the keyboard
      }
    }

    // Calculate responsive font sizes based on screen width
    double screenWidth = screenSize.width;
    double titleFontSize = screenWidth * 0.05; // 8% of screen width for title
    double bodyFontSize =
        screenWidth * 0.03; // 5% of screen width for body text
    double chipFontSize = screenWidth * 0.045; // 4.5% for chip text
    double inputFontSize = screenWidth * 0.045; // 4.5% for input text
    double buttonFontSize = screenWidth * 0.045; // 4.5% for button text

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
                  fontSize: titleFontSize, // Responsive title font size
                  fontWeight: FontWeight.bold,
                  color: AppColors
                      .textColor, // Consistent text color from AppColors
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Enter your interests one by one. Select at least 10.",
                style: AppTextStyles.bodyText.copyWith(
                  fontSize: bodyFontSize, // Responsive body font size
                  color: AppColors.textColor
                      .withOpacity(0.7), // Consistent text color
                ),
              ),
              SizedBox(height: 20),

              // Input field to add a new interest
              TextField(
                controller: interestController,
                focusNode: interestFocusNode,
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
                style: TextStyle(
                    color: AppColors.textColor,
                    fontSize: inputFontSize), // Responsive input text
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
                    fontSize: buttonFontSize, // Responsive button font size
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
                              fontSize:
                                  bodyFontSize, // Responsive font size for selected interests heading
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
                                    fontSize:
                                        chipFontSize, // Responsive font size for chips
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
                              fontSize:
                                  buttonFontSize, // Responsive button font size
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
  Widget buildUserDescriptionStep(Size screenSize) {
    // Reactive variable for storing the description text
    RxString userDescription = ''.obs;

    // Function to handle description change
    void onDescriptionChanged(String value) {
      userDescription.value = value;
    }

    double screenWidth = screenSize.width;

    // Calculate responsive font sizes based on screen width
    double titleFontSize = screenWidth * 0.05; // 8% of screen width for title
    double bodyFontSize =
        screenWidth * 0.03; // 5% of screen width for body text
    double inputFontSize = screenWidth * 0.025; // 4.5% for input text
    double buttonFontSize =
        screenWidth * 0.045; // 4.5% for button text (if enabled)

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
              // Title
              Text(
                "Tell Us About You",
                style: AppTextStyles.titleText.copyWith(
                  fontSize: titleFontSize, // Responsive title font size
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor, // Consistent text color
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Describe yourself in 250 words or less.",
                style: AppTextStyles.bodyText.copyWith(
                  fontSize: bodyFontSize, // Responsive body font size
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
                style: TextStyle(
                    color: AppColors.textColor,
                    fontSize: inputFontSize), // Responsive input font size
                cursorColor: AppColors.cursorColor, // Consistent cursor color
                textInputAction: TextInputAction.done,
              ),
              SizedBox(height: 20),

              // Character count display
              Obx(() {
                return Text(
                  '${userDescription.value.length} / 250 characters',
                  style: AppTextStyles.bodyText.copyWith(
                    fontSize:
                        bodyFontSize, // Responsive body font size for character count
                    color: userDescription.value.length > 250
                        ? Colors.red
                        : AppColors.textColor,
                  ),
                );
              }),
              SizedBox(height: 20),

              // Submit button (if enabled, or you can uncomment the code to enable it)
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
              //         fontSize: buttonFontSize, // Responsive button font size
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
  Widget buildPhotosOfUser(Size screenSize) {
    RxList<File?> images = RxList<File?>();

    // Function to pick an image from camera or gallery
    Future<void> pickImage(int index, ImageSource source) async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        images[index] =
            File(pickedFile.path); // Update the image at the specified index
      }
    }

    // Request camera permission
    Future<void> requestCameraPermission() async {
      var status = await Permission.camera.request();
      if (status.isDenied) {
        Get.snackbar('', "Camera permission denied");
      }
    }

    // Request gallery permission
    Future<void> requestGalleryPermission() async {
      var status = await Permission.photos.request();
      if (status.isDenied) {
        Get.snackbar("", "Gallery permission denied");
      }
    }

    double screenWidth = screenSize.width;

    // Calculate responsive font sizes based on screen width
    double iconSize =
        screenWidth * 0.12; // 12% of screen width for icon size in the button
    double dialogButtonFontSize =
        screenWidth * 0.04; // 4% of screen width for button text in the dialog
    double imageContainerSize =
        screenWidth * 0.4; // 40% of the screen width for image container size

    return Scaffold(
      body: Obx(() {
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 images per row
            crossAxisSpacing: 20.0,
            mainAxisSpacing: 40.0,
          ),
          itemCount: images.length + 1,
          itemBuilder: (context, index) {
            if (index == images.length) {
              return Center(
                child: ElevatedButton(
                  onPressed: () {
                    images.add(null); // Add a new null image slot
                  },
                  child: Icon(
                    Icons.add_a_photo,
                    size: iconSize, // Responsive icon size
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
                      width: imageContainerSize,
                      height: imageContainerSize,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: images[index] != null
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
                                              pickImage(
                                                  index, ImageSource.camera);
                                            },
                                            child: const Icon(Icons.camera_alt),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              pickImage(
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
                                images[index]!,
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
                                              pickImage(
                                                  index, ImageSource.camera);
                                            },
                                            child: const Icon(Icons.camera_alt),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              pickImage(
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
                                size: iconSize, // Responsive icon size
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
  Widget buildPermissionRequestStep(Size screenSize) {
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
                fontSize: screenSize.width * 0.05,
                color: AppColors.textColor,
              ),
            ),
            content: Text(
              permissionType == 'notification'
                  ? "Do you allow the app to send notifications?"
                  : "Do you allow the app to access your location?",
              style: AppTextStyles.bodyText.copyWith(
                fontSize: screenSize.width * 0.04,
                color: AppColors.textColor,
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
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
                    fontSize: screenSize.width * 0.04, // Responsive font size
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
                    fontSize: screenSize.width * 0.04, // Responsive font size
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    // Calculate responsive font size for various text elements
    double fontSize =
        screenSize.width * 0.03; // Base font size (5% of screen width)

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
                    fontSize: fontSize - 2, // Slightly smaller font size
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
                    size: fontSize, // Responsive icon size
                  ),
                  SizedBox(width: 10),
                  // Notification Text
                  Expanded(
                    child: Text(
                      "We need permission to send you notifications.",
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: fontSize - 2, // Slightly smaller font size
                        color: AppColors.textColor,
                      ),
                    ),
                  ),
                  // Grant/Deny Status (text)
                  Obx(() {
                    return Text(
                      notificationGranted.value ? 'Granted' : 'Tap to Grant',
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: fontSize - 2, // Slightly smaller font size
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
                    size: fontSize, // Responsive icon size
                  ),
                  SizedBox(width: 10),
                  // Location Text
                  Expanded(
                    child: Text(
                      "We need permission to access your location.",
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: fontSize - 2, // Slightly smaller font size
                        color: AppColors.textColor,
                      ),
                    ),
                  ),
                  // Grant/Deny Status (text)
                  Obx(() {
                    return Text(
                      locationGranted.value ? 'Granted' : 'Tap to Grant',
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: fontSize - 2, // Slightly smaller font size
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
  Widget buildPaymentWidget(Size screenSize) {
    // Observable to track the selected plan
    RxString selectedPlan = 'None'.obs;
    RxString selectedService =
        'None'.obs; // Default to 'None' for placeholder text

    // Calculate responsive font size based on screen width
    double fontSize = screenSize.width *
        0.03; // Base font size (can adjust 0.05 for different scaling)

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
                fontSize: fontSize - 2, // Slightly smaller for content text
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

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  "What We Offer",
                  style: AppTextStyles.titleText.copyWith(
                    fontSize: fontSize,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() {
                  RxString selectedBenefit = 'None'.obs;

                  // Dropdown widget
                  return Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.formFieldColor),
                    ),
                    child: DropdownButton<String>(
                      value: selectedBenefit.value == 'None'
                          ? null
                          : selectedBenefit.value,
                      hint: Text(
                        "Click to know what we offer",
                        style: AppTextStyles.bodyText.copyWith(
                          fontSize: fontSize -
                              6, // Slightly smaller font for the hint
                          color: AppColors.textColor.withOpacity(0.6),
                        ),
                      ),
                      icon: Icon(Icons.arrow_drop_down,
                          color: AppColors.iconColor),
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          selectedBenefit.value = newValue;
                        }
                      },
                      items: controller.benefits
                          .map<DropdownMenuItem<String>>((Benefit benefit) {
                        return DropdownMenuItem<String>(
                          value: benefit.title,
                          child: Text(
                            benefit.title,
                            style: AppTextStyles.bodyText.copyWith(
                              fontSize: fontSize -
                                  6, // Slightly smaller font for dropdown items
                              color: AppColors.textColor,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                })
              ],
            ),
          ),
          SizedBox(height: 20),
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
                      color: AppColors.textColor,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Choose a plan that suits you!",
                    style: AppTextStyles.bodyText.copyWith(
                      fontSize:
                          fontSize - 2, // Slightly smaller font for description
                      color: AppColors.textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              showPaymentConfirmationDialog(context, 'Monthly', '₹99/month');
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.orange,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: AppColors.iconColor,
                          size: fontSize,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Monthly Plan - ₹99/month",
                            style: AppTextStyles.bodyText.copyWith(
                              fontSize: fontSize - 2,
                              color: AppColors.textColor,
                            ),
                          ),
                        ),
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
                Positioned(
                  top: 4,
                  right: 2,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '20% OFF',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSize - 6,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              showPaymentConfirmationDialog(
                  context, 'Quarterly', '₹599/3 months');
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.orange,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_view_day,
                          color: AppColors.iconColor,
                          size: fontSize,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Quarterly Plan - ₹599/3 months",
                            style: AppTextStyles.bodyText.copyWith(
                              fontSize: fontSize - 2,
                              color: AppColors.textColor,
                            ),
                          ),
                        ),
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
                Positioned(
                  top: 4,
                  right: 2,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '15% OFF',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSize - 6,
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
              showPaymentConfirmationDialog(context, 'Yearly', '₹999/year');
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.orange,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: AppColors.iconColor,
                          size: fontSize,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Yearly Plan - ₹999/year",
                            style: AppTextStyles.bodyText.copyWith(
                              fontSize: fontSize - 2,
                              color: AppColors.textColor,
                            ),
                          ),
                        ),
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
                Positioned(
                  top: 4,
                  right: 2,
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '35% OFF',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSize - 6,
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
                    : Colors.grey,
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
      ),
    );
  }

// step 12
  Widget buildSafetyGuidelinesWidget(Size screenSize) {
    return Obx(() {
      if (controller.safetyGuidelines.isEmpty) {
        return Center(
          child: CircularProgressIndicator(),
        );
      }

      double fontSize = screenSize.width * 0.03;

      return Column(
        children: [
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
                  // Heading
                  Center(
                    child: Text(
                      "Safety Guidelines",
                      style: AppTextStyles.titleText.copyWith(
                        fontSize: fontSize - 2,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Display each safety guideline
                  ...controller.safetyGuidelines.map((guideline) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: buildConfirmationRow(
                        guideline.title,
                        guideline.description,
                        Icons.shield,
                        screenSize,
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget buildConfirmationRow(
      String label, String value, IconData icon, Size screenSize) {
    // Calculate responsive font size
    double fontSize = screenSize.width * 0.03; // Adjust multiplier as needed

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icon with responsive size
        Icon(
          icon,
          color: Colors.blueAccent,
          size: fontSize,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            "$label: $value",
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

// step 13
  Widget buildProfileSummaryPage(Size screenSize) {
    // Calculate responsive font size based on screen width
    double fontSize =
        screenSize.width * 0.03; // You can adjust 0.05 to fit the design needs

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
                    radius: fontSize * 1.5, // Scaled radius based on font size
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
                  style: AppTextStyles.buttonText.copyWith(
                    fontSize:
                        fontSize, // Apply the responsive font size to the button text
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void nextStep() {
    if (currentPage == 1) {
      pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    } else if (currentPage == 2) {
      // If on page 2 (name), go to page 3 (gender)
      pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    } else if (currentPage == 3) {
      // If on page 3 (gender), go to page 4 (describe yourself)
      pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    } else if (currentPage == 4) {
      // If on page 4 (describe yourself), go to page 5 (confirmation)
      pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    } else if (currentPage == 5) {
      pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    } else if (currentPage == 6) {
      pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    } else if (currentPage == 7) {
      pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    } else if (currentPage == 8) {
      pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    } else if (currentPage == 9) {
      pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    } else if (currentPage == 10) {
      pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    } else if (currentPage == 11) {
      pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    } else if (currentPage == 12) {
      pageController.nextPage(
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
            TextButton(
                onPressed: () {
                  Get.to(NavigationBottomBar());
                },
                child: Text('Next'))
          ],
        ),
      );
    }
  }
}
