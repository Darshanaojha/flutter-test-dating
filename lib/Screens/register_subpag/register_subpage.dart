import 'dart:convert';
import 'dart:io';
import 'package:dating_application/Models/ResponseModels/get_all_desires_model_response.dart';
import 'package:dating_application/Screens/login.dart';
import 'package:dating_application/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../Controllers/controller.dart';
import '../../Models/RequestModels/subgender_request_model.dart';
import '../../Models/ResponseModels/get_all_gender_from_response_model.dart';

class MultiStepFormPage extends StatefulWidget {
  const MultiStepFormPage({super.key});

  @override
  MultiStepFormPageState createState() => MultiStepFormPageState();
}

class MultiStepFormPageState extends State<MultiStepFormPage> {
  final controller = Get.find<Controller>();
  RxString date = "".obs;
  DateTime selectedDate = DateTime.now();
  String name = '';
  String? gender;
  String description = '';
  RxString selectedOption = ''.obs;
  RxList<String> selectedLanguages = <String>[].obs;
  RxList<int> selectedLanguagesId = <int>[].obs;
  RxString searchQuery = ''.obs;
  final selectedGender = Rx<Gender?>(null);
  int currentPage = 1;
  final PageController pageController = PageController();
  RxList<bool> preferencesSelectedOptions = <bool>[].obs;

  RxList<bool> desireSelectedOptions = <bool>[].obs;
  RxList<String> selectedStatus = <String>[].obs;
  RxList<String> genderIds = <String>[].obs;
  RxList<String> selectedInterests = <String>[].obs;
  RxString selectedPlan = 'None'.obs;
  TextEditingController interestController = TextEditingController();

  @override
  void initState() {
    super.initState();
    intialize();
  }

  intialize() async {
    await controller.fetchBenefits();
    await controller.fetchSafetyGuidelines();
    await controller.fetchPreferences();
    await controller.fetchGenders();
    await controller.fetchAllHeadlines();
    await controller.fetchDesires();
    await controller.fetchAllPackages();
    await controller.fetchlang();
    genderIds.addAll(controller.genders.map((gender) => gender.id));
    for (String genderId in genderIds) {
      await controller.fetchSubGender(SubGenderRequest(genderId: genderId));
    }
    preferencesSelectedOptions.value =
        List<bool>.filled(controller.preferences.length, false);
  }

  @override
  void dispose() {
    resetImagesForNewUser();
    super.dispose();
  }

  List<bool> stepCompletion = List.generate(13, (index) => false);

  void markStepAsCompleted(int step) {
    setState(() {
      stepCompletion[step - 1] = true;
    });
  }

  void onPageChanged(int index) {
    if (stepCompletion[currentPage - 1]) {
      setState(() {
        currentPage = index + 1;
      });
    } else {
      pageController.jumpToPage(currentPage - 1);
    }
  }

  void onBackPressed() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
      });
      pageController.jumpToPage(currentPage - 1);
    }
  }

  Widget buildStepWidget(int step, Size screenSize) {
    switch (step) {
      case 1:
        return buildBirthdayStep(screenSize);
      case 2:
        return buildNameStep(screenSize);
      case 3:
        return buildGenderStep(screenSize);
      case 4:
        return buildBestDescribeYouStep(screenSize);
      case 5:
        return buildLookingForStep(screenSize);
      case 6:
        return buildRelationshipStatusInterestStep(context, screenSize);
      case 7:
        return buildInterestStep(context, screenSize);
      case 8:
        return buildUserLanguageStep(context);
      case 9:
        return buildUserDescriptionStep(screenSize);
      case 10:
        return buildPermissionRequestStep(screenSize);
      case 11:
        return buildPhotosOfUser(screenSize);
      case 12:
        return buildSafetyGuidelinesWidget(screenSize);
      default:
        return buildFinalStep(screenSize);
    }
  }

  Widget buildFinalStep(Size screenSize) {
    return Column(
      children: [
        Text("Final Step: Submit Form"),
        ElevatedButton(
          onPressed: nextStep,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
            backgroundColor: AppColors.buttonColor,
            foregroundColor: AppColors.textColor,
          ),
          child: Text('Submit', style: AppTextStyles.buttonText),
        ),
        // Back button
        ElevatedButton(
          onPressed: onBackPressed, // Call the onBackPressed method
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
            backgroundColor: AppColors.buttonColor,
            foregroundColor: AppColors.textColor,
          ),
          child: Text('Back', style: AppTextStyles.buttonText),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final screenWidth = screenSize.width;

    double fontSize = screenWidth < 400 ? 18 : 20;

    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text(
                  "$currentPage of 12",
                  style: TextStyle(
                    fontSize: isPortrait ? fontSize : fontSize + 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: PageView.builder(
            controller: pageController,
            onPageChanged: onPageChanged,
            // onPageChanged: (index) {
            //   setState(() {
            //     currentPage = index + 1;
            //   });
            // },
            itemCount: 14,
            itemBuilder: (context, index) {
              return buildStepWidget(index + 1, screenSize);
            },
          ),
        ),
      ),
    );
  }

  Widget buildBirthdayStep(Size screenSize) {
    double titleFontSize = screenSize.width * 0.05;
    double subHeadingFontSize = screenSize.width * 0.045;
    double datePickerFontSize = screenSize.width * 0.03;

    // Variable to store selected date

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
            Obx(() {
              return Text(
                controller.headlines.isNotEmpty
                    ? controller.headlines[0].title
                    : 'Loading headlines...',
                style: AppTextStyles.titleText.copyWith(
                  fontSize: titleFontSize,
                ),
              );
            }),
            SizedBox(height: 40),
            Obx(() {
              return Text(
                controller.headlines.isNotEmpty
                    ? controller.headlines[0].description
                    : 'Loading description...',
                style: AppTextStyles.bodyText.copyWith(
                  color: Colors.redAccent,
                  fontSize: subHeadingFontSize,
                ),
              );
            }),
            SizedBox(height: screenSize.height * 0.05),

            // Date Picker Button
            GestureDetector(
              onTap: () async {
                // Show the date picker and let the user select a date
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );

                if (pickedDate != null) {
                  setState(() {
                    selectedDate = pickedDate;
                    date.value = selectedDate.toString();

                    // Update the selected date
                  });
                }
              },
              child: Obx(() => Container(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 30),
                    decoration: BoxDecoration(
                      color: AppColors.formFieldColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.textColor),
                    ),
                    child: Text(
                      'Select Date of Birth: ${date.value.split(' ')[0]}', // Display the selected date
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: datePickerFontSize,
                        color: AppColors.textColor,
                      ),
                    ),
                  )),
            ),

            SizedBox(height: screenSize.height * 0.02),

            // Next Button
            ElevatedButton(
              onPressed: () {
                DateTime now = DateTime.now();
                int age = now.year - selectedDate.year;
                if (now.month < selectedDate.month ||
                    (now.month == selectedDate.month &&
                        now.day < selectedDate.day)) {
                  age--;
                }
                if (age < 18) {
                  failure('Failed',
                      'You must be at least 18 years old to proceed.');
                  return;
                }
                String formattedDate =
                    '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}';
                controller.userRegistrationRequest.dob = formattedDate;
                markStepAsCompleted(1);
                Get.snackbar(
                    'dob', controller.userRegistrationRequest.dob.toString());
                print(controller.userRegistrationRequest.dob.toString());
                pageController.nextPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.ease,
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                backgroundColor: controller.userRegistrationRequest.dob.isEmpty
                    ? AppColors.disabled
                    : AppColors.buttonColor,
                foregroundColor: AppColors.textColor,
              ),
              child: Text('Next', style: AppTextStyles.buttonText),
            ),
          ],
        ),
      ),
    );
  }

  // Step 2: Name Input
  Widget buildNameStep(Size screenSize) {
    double titleFontSize = screenSize.width * 0.05;
    double labelfontSize = screenSize.width * 0.03;
    double inputTextFontSize = screenSize.width * 0.045;
    TextEditingController nicknameController = TextEditingController(
      text: controller.userRegistrationRequest.nickname ?? '',
    );
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
            Text(
              controller.headlines.isNotEmpty
                  ? controller.headlines[1].title
                  : "Loading Title",
              style: AppTextStyles.titleText.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: titleFontSize,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: nicknameController,
              onChanged: (value) {
                controller.userRegistrationRequest.nickname = value;
              },
              decoration: InputDecoration(
                labelText: "Your Name",
                labelStyle: AppTextStyles.labelText.copyWith(
                  fontSize: labelfontSize,
                  color: AppColors.textColor,
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
                fontSize: inputTextFontSize,
                color: AppColors.textColor,
              ),
              cursorColor: AppColors.cursorColor,
            ),
            SizedBox(
                height: 40), // Adds space between the text field and button

            ElevatedButton(
              onPressed: controller.userRegistrationRequest.nickname.isEmpty
                  ? null
                  : () {
                      if (controller.userRegistrationRequest.nickname.isEmpty) {
                        failure('Nickname', 'Enter Your Nickname');
                        return;
                      } else {
                        markStepAsCompleted(2);
                        Get.snackbar(
                            'nickname',
                            controller.userRegistrationRequest.nickname
                                .toString());
                        pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                backgroundColor: AppColors.activeColor,
                foregroundColor: AppColors.textColor,
              ),
              child: Text(
                'Next',
                style: AppTextStyles.buttonText.copyWith(
                  fontSize: screenSize.width * 0.045,
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: onBackPressed, // Call the onBackPressed method
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                backgroundColor: AppColors.buttonColor,
                foregroundColor: AppColors.textColor,
              ),
              child: Text('Back', style: AppTextStyles.buttonText),
            ),
          ],
        ),
      ),
    );
  }

  // Step 3: Gender Selection
  Widget buildGenderStep(Size screenSize) {
    double titleFontSize = screenSize.width * 0.05;
    double optionFontSize = screenSize.width * 0.03;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              Text(
                controller.headlines.isNotEmpty
                    ? controller.headlines[2].title
                    : "Loading Title...",
                style: AppTextStyles.titleText.copyWith(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 20),
              Obx(() {
                if (controller.genders.isEmpty) {
                  return Center(
                    child: SpinKitCircle(
                      size: 90,
                      color: AppColors.progressColor,
                    ),
                  );
                }

                return Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: controller.genders.map((gender) {
                        return RadioListTile<Gender?>(
                          title: Text(
                            gender.title,
                            style: AppTextStyles.bodyText.copyWith(
                              fontSize: optionFontSize,
                              color: AppColors.textColor,
                            ),
                          ),
                          value: gender,
                          groupValue: selectedGender.value,
                          onChanged: (Gender? value) {
                            // Update selected gender using reactive Rx
                            selectedGender.value = value;

                            // Safe parsing using tryParse
                            final parsedGenderId =
                                int.tryParse(value?.id ?? '');

                            if (parsedGenderId != null) {
                              controller.userRegistrationRequest.gender =
                                  parsedGenderId.toString();
                            } else {
                              controller.userRegistrationRequest.gender = '';
                            }
                            controller.fetchSubGender(SubGenderRequest(
                                genderId: parsedGenderId.toString()));
                          },
                          activeColor: AppColors.buttonColor,
                        );
                      }).toList(),
                    ),
                  ),
                );
              }),
              SizedBox(height: 40),
              Obx(() {
                return ElevatedButton(
                  onPressed: selectedGender.value == null
                      ? null
                      : () {
                          if (selectedGender.value == null) {
                            failure('Failed',
                                'Please select an option to proceed.');
                          } else {
                            markStepAsCompleted(3);
                            Get.snackbar(
                                'gender',
                                controller.userRegistrationRequest.gender
                                    .toString());
                            pageController.nextPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.ease,
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                    backgroundColor: selectedGender.value != null
                        ? AppColors.buttonColor
                        : AppColors.activeColor,
                    foregroundColor: AppColors.textColor,
                  ),
                  child: Text(
                    'Next',
                    style: AppTextStyles.buttonText.copyWith(
                      fontSize: screenSize.width * 0.045,
                    ),
                  ),
                );
              }),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: onBackPressed, // Call the onBackPressed method
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                  backgroundColor: AppColors.buttonColor,
                  foregroundColor: AppColors.textColor,
                ),
                child: Text('Back', style: AppTextStyles.buttonText),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Step 4: Describe Yourself (New Step)
  Widget buildBestDescribeYouStep(Size screenSize) {
    double titleFontSize = screenSize.width * 0.05;
    double descriptionFontSize = screenSize.width * 0.03;
    double optionFontSize = screenSize.width * 0.03;

    return Obx(() {
      if (controller.subGenders.isEmpty) {
        return Center(
          child: SpinKitCircle(
            size: 90,
            color: AppColors.progressColor,
          ),
        );
      }

      return Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                controller.headlines.isNotEmpty
                    ? controller.headlines[3].title
                    : "Loading Title...",
                style: AppTextStyles.titleText.copyWith(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              SizedBox(height: 20),
              Text(
                controller.headlines.isNotEmpty
                    ? controller.headlines[3].description
                    : "",
                style: AppTextStyles.bodyText.copyWith(
                  fontSize: descriptionFontSize,
                  color: AppColors.textColor,
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children:
                        List.generate(controller.subGenders.length, (index) {
                      return RadioListTile<String>(
                        title: Text(
                          controller.subGenders[index].title,
                          style: AppTextStyles.bodyText.copyWith(
                            fontSize: optionFontSize,
                            color: AppColors.textColor,
                          ),
                        ),
                        value: controller.subGenders[index].id,
                        groupValue: selectedOption.value,
                        onChanged: (String? value) {
                          selectedOption.value = value ?? '';
                          controller.userRegistrationRequest.subGender =
                              value ?? '';
                        },
                        activeColor: AppColors.buttonColor,
                        contentPadding: EdgeInsets.zero,
                      );
                    }),
                  ),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: selectedOption.value.isEmpty
                    ? null // Disable button if no option is selected
                    : () {
                        // Proceed to the next step if a valid option is selected
                        markStepAsCompleted(4);
                        Get.snackbar(
                            'Sub-gender',
                            controller.userRegistrationRequest.subGender
                                .toString());
                        pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                  backgroundColor: selectedOption.value.isEmpty
                      ? AppColors.disabled // If no preference is selected
                      : AppColors.buttonColor, // If preference is selected
                  foregroundColor: AppColors.textColor,
                ),
                child: Text(
                  'Next',
                  style: AppTextStyles.buttonText.copyWith(
                    fontSize: screenSize.width * 0.045,
                  ),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: onBackPressed, // Call the onBackPressed method
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                  backgroundColor: AppColors.buttonColor,
                  foregroundColor: AppColors.textColor,
                ),
                child: Text('Back', style: AppTextStyles.buttonText),
              ),
            ],
          ),
        ),
      );
    });
  }

// step 5 who are you looking for
  Widget buildLookingForStep(Size screenSize) {
    double titleFontSize = screenSize.width * 0.05;
    double descriptionFontSize = screenSize.width * 0.03;
    double optionFontSize = screenSize.width * 0.03;

    // Ensure preferencesSelectedOptions is properly initialized
    if (preferencesSelectedOptions.isEmpty) {
      preferencesSelectedOptions.value =
          List<bool>.filled(controller.preferences.length, false);
    }

    return Obx(() {
      if (controller.preferences.isEmpty) {
        return Center(
          child: SpinKitCircle(
            size: 90,
            color: AppColors.progressColor,
          ),
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
              Center(
                child: Text(
                  controller.headlines.length > 4
                      ? controller.headlines[4].title
                      : "Loading Title...",
                  style: AppTextStyles.titleText.copyWith(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
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
              Expanded(
                child: ListView.builder(
                  itemCount: controller.preferences.length,
                  itemBuilder: (context, index) {
                    return Obx(() {
                      return CheckboxListTile(
                        title: Text(
                          controller.preferences[index].title,
                          style: AppTextStyles.bodyText.copyWith(
                            fontSize: optionFontSize,
                            color: AppColors.textColor,
                          ),
                        ),
                        value: preferencesSelectedOptions[index],
                        onChanged: (bool? value) {
                          preferencesSelectedOptions[index] = value ?? false;
                        },
                        activeColor: AppColors.buttonColor,
                        checkColor: Colors.white,
                        contentPadding: EdgeInsets.zero,
                      );
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Collect selected preferences as List<int>
                  List<int> selectedPreferences = [];
                  for (int i = 0; i < preferencesSelectedOptions.length; i++) {
                    if (preferencesSelectedOptions[i]) {
                      selectedPreferences
                          .add(int.parse(controller.preferences[i].id));
                    }
                  }

                  controller.userRegistrationRequest.preferences =
                      selectedPreferences;

                  if (selectedPreferences.isEmpty) {
                    failure('Failed', 'Please select at least one preference.');
                  } else {
                    markStepAsCompleted(
                        5); // Mark the current step as completed
                    Get.snackbar(
                        'pref',
                        controller.userRegistrationRequest.preferences
                            .toString());
                    // Move to the next page in the PageView
                    pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                  backgroundColor: preferencesSelectedOptions.isNotEmpty
                      ? AppColors.inactiveColor // If no preference is selected
                      : AppColors.buttonColor, // If preference is selected
                  foregroundColor: AppColors.textColor,
                ),
                child: Text(
                  'Next',
                  style: AppTextStyles.buttonText,
                ),
              ),
              ElevatedButton(
                onPressed: onBackPressed, // Call the onBackPressed method
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                  backgroundColor: AppColors.buttonColor,
                  foregroundColor: AppColors.textColor,
                ),
                child: Text('Back', style: AppTextStyles.buttonText),
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
    final relationshipCategory = controller.categories.firstWhere(
      (category) => category.category == 'Relationship',
      orElse: () => Category(category: 'Relationship', desires: []),
    );

    final kinksCategory = controller.categories.firstWhere(
      (category) => category.category == 'Kinks',
      orElse: () => Category(category: 'Kinks', desires: []),
    );

    List<String> options = [
      ...relationshipCategory.desires.map((desire) => desire.title),
      ...kinksCategory.desires.map((desire) => desire.title)
    ];

    RxList<bool> selectedOptions = List.filled(options.length, false).obs;

    RxList<String> selectedStatus = <String>[].obs;

    RxList<int> selectedDesireIds = <int>[].obs;

    void updateSelectedStatus() {
      selectedStatus.clear();
      selectedDesireIds.clear();

      for (int i = 0; i < selectedOptions.length; i++) {
        if (selectedOptions[i]) {
          selectedStatus.add(options[i]);
          selectedDesireIds.add(int.parse(controller.categories
              .firstWhere((category) => category.category == 'Relationship')
              .desires[i]
              .id));
        }
      }

      controller.userRegistrationRequest.desires = selectedDesireIds;
    }

    void handleChipSelection(int index) {
      selectedOptions[index] = !selectedOptions[index];
      updateSelectedStatus();
    }

    double screenWidth = screenSize.width;
    double titleFontSize = screenWidth * 0.05;
    double bodyFontSize = screenWidth * 0.03;
    double chipFontSize = screenWidth * 0.03;

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
              Text(
                controller.headlines.isNotEmpty
                    ? controller.headlines[5].title
                    : "Loading Title...",
                style: AppTextStyles.titleText.copyWith(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              SizedBox(height: 20),
              Text(
                controller.headlines.isNotEmpty
                    ? controller.headlines[5].description
                    : "",
                style: AppTextStyles.bodyText.copyWith(
                  fontSize: bodyFontSize,
                  color: AppColors.textColor,
                ),
              ),
              SizedBox(height: 20),
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
                                      fontSize: chipFontSize,
                                    ),
                                    onDeleted: () {
                                      int index = options.indexOf(status);
                                      selectedOptions[index] = false;
                                      updateSelectedStatus(); // Update after deletion
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
              Text(
                "Select your interests:",
                style: AppTextStyles.bodyText.copyWith(
                  fontSize: bodyFontSize,
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
                  children: List.generate(options.length, (index) {
                    return GestureDetector(
                      onTap: () {
                        handleChipSelection(index);
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
                            fontSize: chipFontSize,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              Obx(() {
                return selectedStatus.isNotEmpty
                    ? Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {
                            selectedOptions.value =
                                List.filled(options.length, false);
                            updateSelectedStatus(); // Reset selections
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
              Obx(() {
                return selectedStatus.isNotEmpty
                    ? Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {
                            // Mark the current step as completed
                            markStepAsCompleted(6);
                            Get.snackbar(
                                'desries',
                                controller.userRegistrationRequest.desires
                                    .toString());
                            // Move to the next page in the PageView
                            pageController.nextPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.ease,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonColor,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          child: Text(
                            'Next',
                            style: AppTextStyles.buttonText.copyWith(
                              fontSize: AppTextStyles.buttonSize,
                              color: AppColors.textColor,
                            ),
                          ),
                        ),
                      )
                    : Container();
              }),
              ElevatedButton(
                onPressed: onBackPressed, // Call the onBackPressed method
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                  backgroundColor: AppColors.buttonColor,
                  foregroundColor: AppColors.textColor,
                ),
                child: Text('Back', style: AppTextStyles.buttonText),
              ),
            ],
          ),
        ),
      ),
    );
  }

// step 7
  Widget buildInterestStep(BuildContext context, Size screenSize) {
    FocusNode interestFocusNode = FocusNode();

    bool isSelectionValid() {
      return selectedInterests.length > 0 && selectedInterests.length <= 6;
    }

    void addInterest() {
      String newInterest = interestController.text.trim();
      if (newInterest.isNotEmpty && !selectedInterests.contains(newInterest)) {
        selectedInterests.add(newInterest);
        interestController.clear();
        interestFocusNode.unfocus();
      }
    }

    void updateUserInterests() {
      controller.userRegistrationRequest.interest =
          selectedInterests.join(', ');
    }

    void onInterestChanged(String value) {
      updateUserInterests();
    }

    double screenWidth = screenSize.width;
    double titleFontSize = screenWidth * 0.05;
    double bodyFontSize = screenWidth * 0.03;
    double chipFontSize = screenWidth * 0.045;
    double inputFontSize = screenWidth * 0.045;
    double buttonFontSize = screenWidth * 0.045;

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
                controller.headlines.isNotEmpty
                    ? controller.headlines[6].title
                    : "Loading Title...",
                style: AppTextStyles.titleText.copyWith(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              SizedBox(height: 20),

              // Description
              Text(
                controller.headlines.isNotEmpty
                    ? controller.headlines[6].description
                    : "Loading Title...",
                style: AppTextStyles.bodyText.copyWith(
                  fontSize: bodyFontSize,
                  color: AppColors.textColor.withOpacity(0.7),
                ),
              ),
              SizedBox(height: 20),

              // Interest input field
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
                style: TextStyle(
                    color: AppColors.textColor, fontSize: inputFontSize),
                cursorColor: AppColors.textColor,
                onChanged: onInterestChanged,
                onSubmitted: (_) {
                  addInterest();
                },
              ),
              SizedBox(height: 20),

              // Show the entered interest immediately (Text below TextField)
              Text(
                interestController.text.isNotEmpty
                    ? "You are adding: ${interestController.text}"
                    : "",
                style: AppTextStyles.bodyText.copyWith(
                  fontSize: bodyFontSize,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textColor.withOpacity(0.7),
                ),
              ),
              SizedBox(height: 20),

              // Add Interest button
              ElevatedButton(
                onPressed: addInterest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor,
                  foregroundColor: AppColors.textColor,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  'Add Interest',
                  style: AppTextStyles.buttonText.copyWith(
                    fontSize: buttonFontSize,
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Display selected interests
              Obx(() {
                return selectedInterests.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Your Interests:",
                            style: AppTextStyles.bodyText.copyWith(
                              fontSize: bodyFontSize,
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
                                  backgroundColor: AppColors.buttonColor,
                                  labelStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: chipFontSize,
                                  ),
                                  onDeleted: () {
                                    selectedInterests.remove(interest);
                                    updateUserInterests(); // Update interests when an item is deleted
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
              Obx(() {
                return isSelectionValid()
                    ? Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {
                            // Mark the current step as completed
                            markStepAsCompleted(7);
                            Get.snackbar(
                                'intrest',
                                controller.userRegistrationRequest.interest
                                    .toString());
                            // Move to the next page in the PageView
                            pageController.nextPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.ease,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedInterests.isNotEmpty
                                ? AppColors.activeColor
                                : AppColors.inactiveColor,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          child: Text(
                            'Continue',
                            style: AppTextStyles.buttonText.copyWith(
                              fontSize: buttonFontSize,
                              color: AppColors.textColor,
                            ),
                          ),
                        ),
                      )
                    : Container();
              }),
              ElevatedButton(
                onPressed: onBackPressed, // Call the onBackPressed method
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                  backgroundColor: AppColors.buttonColor,
                  foregroundColor: AppColors.textColor,
                ),
                child: Text('Back', style: AppTextStyles.buttonText),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // languages 8
  Widget buildUserLanguageStep(BuildContext context) {
    void updateSelectedStatus() {
      selectedLanguagesId.clear();
      for (int i = 0; i < controller.language.length; i++) {
        if (selectedLanguages.contains(controller.language[i].title)) {
          selectedLanguagesId.add(int.parse(controller.language[i].id));
        }
      }
      // Update the controller with the new language IDs
      controller.userRegistrationRequest.lang = selectedLanguagesId;
    }

    void handleChipSelection(String languageTitle) {
      if (selectedLanguages.contains(languageTitle)) {
        selectedLanguages.remove(languageTitle);
      } else {
        selectedLanguages.add(languageTitle);
      }
      updateSelectedStatus();
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              return selectedLanguages.isEmpty
                  ? Center(
                      child: SpinKitCircle(
                      size: 30,
                      color: AppColors.progressColor,
                    ))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Selected Languages',
                            style: TextStyle(fontSize: 16)),
                        SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                selectedLanguages.map((filteredLanguages) {
                              return GestureDetector(
                                onTap: () {
                                  handleChipSelection(filteredLanguages);
                                },
                                child: Chip(
                                  label: Text(filteredLanguages),
                                  deleteIcon: Icon(Icons.cancel, size: 18),
                                  onDeleted: () {
                                    selectedLanguages.remove(filteredLanguages);
                                    updateSelectedStatus();
                                  },
                                  backgroundColor: Colors.blue.withOpacity(0.1),
                                  labelStyle: TextStyle(fontSize: 14),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    );
            }),
            SizedBox(height: 20),
            Text('Languages List', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Obx(() {
              var filteredLanguages = controller.language
                  .where((language) => language.title
                      .toLowerCase()
                      .contains(searchQuery.value.toLowerCase()))
                  .toList();

              return controller.language.isEmpty
                  ? Center(
                      child: SpinKitCircle(
                      size: 90,
                      color: AppColors.progressColor,
                    ))
                  : Column(
                      children: [
                        TextField(
                          cursorColor: AppColors.cursorColor,
                          onChanged: (query) {
                            searchQuery.value = query;
                          },
                          decoration: InputDecoration(
                            hintText: 'Search Languages...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  BorderSide(color: AppColors.textColor),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 16),
                          ),
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          height: 400,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: filteredLanguages.map((language) {
                                bool isSelected =
                                    selectedLanguages.contains(language.title);

                                return ChoiceChip(
                                  label: Text(language.title),
                                  selected: isSelected,
                                  selectedColor: Colors.blue,
                                  backgroundColor: Colors.grey[200],
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 14,
                                  ),
                                  onSelected: (bool selected) {
                                    handleChipSelection(language.title);
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    );
            }),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  if (selectedLanguages.isEmpty) {
                    failure('Error', 'Please select at least one language');
                    return;
                  } else {
                    print('Next button pressed');
                    print(
                        'Selected Language IDs: ${controller.userRegistrationRequest.lang}');
                    markStepAsCompleted(8);
                    Get.snackbar('lang',
                        controller.userRegistrationRequest.lang.toString());
                    pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text('Next'),
              ),
            ),
            ElevatedButton(
              onPressed: onBackPressed,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                backgroundColor: AppColors.buttonColor,
                foregroundColor: AppColors.textColor,
              ),
              child: Text('Back', style: AppTextStyles.buttonText),
            ),
          ],
        ),
      ),
    );
  }

// step 9
  Widget buildUserDescriptionStep(Size screenSize) {
    RxString userDescription = ''.obs;
    bool _isInputValid = true;
    // Function to track text changes
    void onDescriptionChanged(String value) {
      userDescription.value = value;
      controller.userRegistrationRequest.bio = value;
      _isInputValid = RegExp(r'^[a-zA-Z\s]*$').hasMatch(value);
    }

    double screenWidth = screenSize.width;
    double titleFontSize = screenWidth * 0.05;
    double bodyFontSize = screenWidth * 0.03;
    double inputFontSize = screenWidth * 0.025;
    double buttonFontSize = screenWidth * 0.045;

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
                controller.headlines.isNotEmpty
                    ? controller.headlines[7].title
                    : "Loading Title...",
                style: AppTextStyles.titleText.copyWith(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              SizedBox(height: 20),
              Text(
                controller.headlines.isNotEmpty
                    ? controller.headlines[7].description
                    : "",
                style: AppTextStyles.bodyText.copyWith(
                  fontSize: bodyFontSize,
                  color: AppColors.textColor.withOpacity(0.7),
                ),
              ),
              SizedBox(height: 20),

              // TextField for user description input
              TextField(
                onChanged: onDescriptionChanged,
                maxLength: 250, // Limit the input to 250 characters
                maxLines: 6, // Allow multiple lines for description
                decoration: InputDecoration(
                  labelText: "Your Description",
                  labelStyle: TextStyle(color: AppColors.textColor),
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
                  errorText:
                      _isInputValid ? null : 'Please enter only alphabets',
                ),
                style: TextStyle(
                  color: AppColors.textColor,
                  fontSize: inputFontSize,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'[a-zA-Z\s]')), // Only allow alphabets and spaces
                ],
                cursorColor: AppColors.cursorColor,
                textInputAction: TextInputAction.done,
              ),
              SizedBox(height: 20),

              // Character count display
              Obx(() {
                return Text(
                  '${userDescription.value.length} / 250 characters',
                  style: AppTextStyles.bodyText.copyWith(
                    fontSize: bodyFontSize,
                    color: userDescription.value.length > 250
                        ? Colors.red // Show red when over 250 characters
                        : AppColors.textColor,
                  ),
                );
              }),
              SizedBox(height: 20),

              // Submit button (enabled only when description is valid)
              Obx(() {
                return ElevatedButton(
                  onPressed: userDescription.value.isNotEmpty &&
                          userDescription.value.length <= 250
                      ? () {
                          if (userDescription.value.isEmpty) {
                            failure(
                              'Validation Error',
                              'Description cannot be empty.',
                            );
                          } else if (userDescription.value.length > 250) {
                            failure(
                              'Validation Error',
                              'Description cannot exceed 250 characters.',
                            );
                          }
                          // Mark the current step as completed
                          markStepAsCompleted(9);
                          Get.snackbar(
                              'bio',
                              controller.userRegistrationRequest.bio
                                  .toString());
                          // Move to the next page in the PageView
                          pageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );

                          // Handle the description submission here
                          // controller.register(controller.userRegistrationRequest);
                          print("User Description: ${userDescription.value}");
                        }
                      : null, // Disable button if description is empty or too long
                  style: ElevatedButton.styleFrom(
                    backgroundColor: userDescription.value.isNotEmpty &&
                            userDescription.value.length <= 250
                        ? AppColors.buttonColor
                        : Colors.grey, // Button color based on validity
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: Text(
                    'Next',
                    style: AppTextStyles.buttonText.copyWith(
                      fontSize: buttonFontSize, // Responsive button font size
                    ),
                  ),
                );
              }),
              ElevatedButton(
                onPressed: onBackPressed, // Call the onBackPressed method
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                  backgroundColor: AppColors.buttonColor,
                  foregroundColor: AppColors.textColor,
                ),
                child: Text('Back', style: AppTextStyles.buttonText),
              ),
            ],
          ),
        ),
      ),
    );
  }

  RxBool notificationGranted = false.obs;
  RxBool locationGranted = false.obs;

  // step 10
  Widget buildPermissionRequestStep(Size screenSize) {
    // Function to show the permission request dialog
    Future<void> showPermissionDialog(
        BuildContext context, String permissionType) async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // Prevent dismissing the dialog
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
                    controller.userRegistrationRequest.emailAlerts =
                        '0'; // Deny
                  } else if (permissionType == 'location') {
                    locationGranted.value = false;
                  }
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Deny',
                  style: AppTextStyles.bodyText.copyWith(
                    color: Colors.red,
                    fontSize: screenSize.width * 0.04,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (permissionType == 'notification') {
                    notificationGranted.value = true;
                    controller.userRegistrationRequest.emailAlerts =
                        '1'; // Accept
                  } else if (permissionType == 'location') {
                    locationGranted.value = true;
                  }
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Accept',
                  style: AppTextStyles.bodyText.copyWith(
                    color: Colors.green,
                    fontSize: screenSize.width * 0.04,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    // onChange callback function
    void onChange(String permissionType, bool granted) {
      if (permissionType == 'notification') {
        print(
            "Notification permission changed: ${granted ? 'Granted' : 'Denied'}");
      } else if (permissionType == 'location') {
        print("Location permission changed: ${granted ? 'Granted' : 'Denied'}");
      }
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
                  controller.headlines.isNotEmpty
                      ? controller.headlines[9].title
                      : "Loading Title...",
                  style: AppTextStyles.titleText.copyWith(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  controller.headlines.isNotEmpty
                      ? controller.headlines[9].description
                      : "",
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
        GestureDetector(
          onTap: () {
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
                  Icon(
                    Icons.notifications,
                    color: AppColors.iconColor,
                    size: fontSize,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "We need permission to send you notifications through email.",
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: fontSize - 2,
                        color: AppColors.textColor,
                      ),
                    ),
                  ),
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
        GestureDetector(
          onTap: () {
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
                  Icon(
                    Icons.location_on,
                    color: AppColors.iconColor,
                    size: fontSize,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "We need permission to access your location.",
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: fontSize - 2,
                        color: AppColors.textColor,
                      ),
                    ),
                  ),
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
        Obx(() {
          return ElevatedButton(
            onPressed: notificationGranted.value && locationGranted.value
                ? () {
                    // Mark the current step as completed
                    markStepAsCompleted(10);
                    Get.snackbar(
                        'permission',
                        controller.userRegistrationRequest.emailAlerts
                            .toString());
                    // Move to the next page in the PageView
                    pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  }
                : null, // Disable button if permissions are not granted
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  notificationGranted.value && locationGranted.value
                      ? AppColors.buttonColor
                      : Colors.grey, // Button color based on permissions
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              'Next',
              style: AppTextStyles.buttonText.copyWith(
                fontSize: fontSize,
              ),
            ),
          );
        }),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: onBackPressed, // Call the onBackPressed method
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
            backgroundColor: AppColors.buttonColor,
            foregroundColor: AppColors.textColor,
          ),
          child: Text('Back', style: AppTextStyles.buttonText),
        ),
      ],
    );
  }

  RxList<File?> images = RxList<File?>(List.filled(6, null));
  void resetImagesForNewUser() {
    images.clear();
    images.addAll(List.filled(6, null));
  }

// photos 11
  Widget buildPhotosOfUser(Size screenSize) {
    Future<void> requestCameraPermission() async {
      var status = await Permission.camera.request();
      if (status.isDenied) {
        Get.snackbar('Permission Denied', "Camera permission denied");
      }
    }

    Future<void> requestGalleryPermission() async {
      var status = await Permission.photos.request();
      if (status.isDenied) {
        Get.snackbar('Permission Denied', "Gallery permission denied");
      }
    }

    Future<void> pickImage(int index, ImageSource source) async {
      if (source == ImageSource.camera) {
        await requestCameraPermission();
      } else if (source == ImageSource.gallery) {
        await requestGalleryPermission();
      }

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        final compressedImage = await FlutterImageCompress.compressWithFile(
          imageFile.path,
          quality: 50,
        );

        if (compressedImage != null) {
          String base64Image = base64Encode(compressedImage);
          if (index < controller.userRegistrationRequest.photos.length) {
            controller.userRegistrationRequest.photos[index] = base64Image;
          } else {
            controller.userRegistrationRequest.photos.add(base64Image);
          }

          images[index] = imageFile;
        } else {
          Get.snackbar("Error", "Image compression failed");
        }
      }
    }

    void onNextButtonPressed() {
      if (controller.userRegistrationRequest.photos.length >= 3) {
        controller.userRegistrationRequest.imgcount =
            controller.userRegistrationRequest.photos.length.toString();
        markStepAsCompleted(11);
        Get.snackbar(
            'photo', controller.userRegistrationRequest.photos.toString());
        Get.snackbar(
            'photo', controller.userRegistrationRequest.imgcount.toString());
        pageController.nextPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      } else {
        Get.snackbar("Error", "Please add at least three photos.");
      }
    }

    double screenWidth = screenSize.width;
    double iconSize = screenWidth * 0.12;
    double imageContainerSize = screenWidth * 0.39;
    resetImagesForNewUser();
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.headlines.isNotEmpty
                  ? controller.headlines[8].title
                  : "Loading Title...",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              controller.headlines.isNotEmpty
                  ? controller.headlines[8].description
                  : "",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20.0,
                    mainAxisSpacing: 40.0,
                  ),
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    bool isPhotoUploaded = images[index] != null ||
                        (controller.userRegistrationRequest.photos.length >
                            index);

                    return Center(
                      child: isPhotoUploaded
                          ? Stack(
                              children: [
                                Container(
                                  width: imageContainerSize,
                                  height: imageContainerSize,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
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
                                                    pickImage(index,
                                                        ImageSource.camera);
                                                  },
                                                  child: const Row(
                                                    children: [
                                                      Icon(Icons.camera_alt),
                                                      SizedBox(width: 8),
                                                      Text("Camera"),
                                                    ],
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    pickImage(index,
                                                        ImageSource.gallery);
                                                  },
                                                  child: const Row(
                                                    children: [
                                                      Icon(Icons.photo),
                                                      SizedBox(width: 8),
                                                      Text("Gallery"),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: images[index] != null
                                        ? Image.file(
                                            images[index]!,
                                            fit: BoxFit.cover,
                                          )
                                        : (controller.userRegistrationRequest
                                                        .photos.length >
                                                    index &&
                                                controller
                                                    .userRegistrationRequest
                                                    .photos[index]
                                                    .isNotEmpty)
                                            ? Image.memory(
                                                base64Decode(controller
                                                    .userRegistrationRequest
                                                    .photos[index]),
                                                fit: BoxFit.cover,
                                              )
                                            : Container(
                                                color: Colors.grey.shade300,
                                                child: Icon(
                                                  Icons.add_a_photo,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                  ),
                                ),
                                Positioned(
                                  right: 4,
                                  top: 4,
                                  child: GestureDetector(
                                    onTap: () {
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
                                                    pickImage(index,
                                                        ImageSource.camera);
                                                  },
                                                  child: const Row(
                                                    children: [
                                                      Icon(Icons.camera_alt),
                                                      SizedBox(width: 8),
                                                      Text("Camera"),
                                                    ],
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    pickImage(index,
                                                        ImageSource.gallery);
                                                  },
                                                  child: const Row(
                                                    children: [
                                                      Icon(Icons.photo),
                                                      SizedBox(width: 8),
                                                      Text("Gallery"),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Icon(
                                      Icons.more_vert,
                                      size: 20,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ElevatedButton(
                              onPressed: () {
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
                                            child: const Row(
                                              children: [
                                                Icon(Icons.camera_alt),
                                                SizedBox(width: 8),
                                                Text("Camera"),
                                              ],
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              pickImage(
                                                  index, ImageSource.gallery);
                                            },
                                            child: const Row(
                                              children: [
                                                Icon(Icons.photo),
                                                SizedBox(width: 8),
                                                Text("Gallery"),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(12),
                              ),
                              child: Icon(
                                Icons.add_a_photo,
                                size: iconSize,
                                color: Colors.grey.shade600,
                              ),
                            ),
                    );
                  },
                );
              }),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: onNextButtonPressed,
              style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor:
                      controller.userRegistrationRequest.photos.isNotEmpty
                          ? AppColors.activeColor
                          : AppColors.inactiveColor),
              child: Text("Next",
                  style: AppTextStyles.buttonText.copyWith(
                    color: AppColors.primaryColor,
                  )),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: onBackPressed,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                backgroundColor: AppColors.buttonColor,
                foregroundColor: AppColors.textColor,
              ),
              child: Text('Back', style: AppTextStyles.buttonText),
            ),
          ],
        ),
      ),
    );
  }

// step 12
  Widget buildSafetyGuidelinesWidget(Size screenSize) {
    double fontSize = screenSize.width * 0.03;

    return SingleChildScrollView(
      child: Column(
        children: [
          // First Card: Safety Guidelines Header
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
                    controller.headlines.isNotEmpty
                        ? controller.headlines[11].title
                        : "Loading Title...",
                    style: AppTextStyles.titleText.copyWith(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    controller.headlines.isNotEmpty
                        ? controller.headlines[11].description
                        : "Loading Description...",
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

          // Second Card: Safety Guidelines List
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
                  // Loading state handling for safety guidelines
                  controller.safetyGuidelines.isEmpty
                      ? Center(
                          child: SpinKitCircle(
                            size: 35.0,
                            color: AppColors.progressColor,
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: controller.safetyGuidelines.length,
                          itemBuilder: (context, index) {
                            var guideline = controller.safetyGuidelines[index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 15),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.warning,
                                      color: AppColors.iconColor,
                                      size: fontSize,
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            guideline.title,
                                            style:
                                                AppTextStyles.bodyText.copyWith(
                                              fontSize: fontSize - 2,
                                              color: AppColors.textColor,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            guideline.description,
                                            style:
                                                AppTextStyles.bodyText.copyWith(
                                              fontSize: fontSize - 2,
                                              color: AppColors.textColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),

          // Acknowledge Button
          ElevatedButton(
            onPressed:nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonColor,
              foregroundColor: AppColors.textColor,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              'Acknowledge',
              style: AppTextStyles.buttonText.copyWith(
                fontSize: fontSize,
              ),
            ),
          ),
          SizedBox(height: 10),

          // Back Button
          ElevatedButton(
            onPressed: onBackPressed,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
              backgroundColor: AppColors.buttonColor,
              foregroundColor: AppColors.textColor,
            ),
            child: Text('Back', style: AppTextStyles.buttonText),
          ),
        ],
      ),
    );
  }

  Widget buildConfirmationRow(
      String label, String value, IconData icon, Size screenSize) {
    double fontSize = screenSize.width * 0.03;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: Colors.blueAccent,
          size: fontSize,
        ),
        SizedBox(width: 12),
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

  void nextStep() {
    if (currentPage < 12) {
      markStepAsCompleted(currentPage);
      pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
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
              onPressed: () async {
                await controller.register(controller.userRegistrationRequest);
                Get.offAll(Login());
              },
              child: Text('Next'),
            ),
          ],
        ),
      );
    }
  }
}
