import 'dart:io';
import 'package:dating_application/Models/ResponseModels/get_all_benifites_response_model.dart';
import 'package:dating_application/Models/ResponseModels/get_all_desires_model_response.dart';
import 'package:dating_application/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../Controllers/controller.dart';
import '../../Models/RequestModels/subgender_request_model.dart';
import '../../Models/ResponseModels/get_all_gender_from_response_model.dart';
import '../navigationbar/navigationpage.dart';

class MultiStepFormPage extends StatefulWidget {
  const MultiStepFormPage({super.key});

  @override
  MultiStepFormPageState createState() => MultiStepFormPageState();
}

class MultiStepFormPageState extends State<MultiStepFormPage> {
  Controller controller = Get.put(Controller());
  int selectedDay = DateTime.now().day;
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  String name = '';
  String? gender;
  String description = '';

  int currentPage = 1;
  final PageController pageController = PageController();
  RxList<bool> preferencesSelectedOptions = <bool>[].obs;

  RxList<bool> desireSelectedOptions = <bool>[].obs;
  RxList<String> selectedStatus = <String>[].obs;
  RxList<String> genderIds = <String>[].obs;

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
    genderIds.addAll(controller.genders.map((gender) => gender.id));
    for (String genderId in genderIds) {
      await controller.fetchSubGender(SubGenderRequest(genderId: genderId));
    }

    preferencesSelectedOptions.value =
        List<bool>.filled(controller.preferences.length, false);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    double padding = isPortrait ? 16.0 : 24.0;
    double fontSize = screenWidth < 400 ? 18 : 20;
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
                SizedBox(
                  height: screenHeight * 0.75,
                  child: PageView(
                    controller: pageController,
                    onPageChanged: (pageIndex) {
                      setState(() {
                        currentPage = pageIndex + 1;
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
                SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, buttonHeight),
                    foregroundColor: AppColors.textColor,
                    backgroundColor: AppColors.buttonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                  ),
                  onPressed: nextStep,
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
    final screenSize = MediaQuery.of(context).size;
    final controller = Get.find<Controller>();

    double titleFontSize = screenSize.width * 0.05;
    double subHeadingFontSize = screenSize.width * 0.045;
    double datePickerFontSize = screenSize.width * 0.05;

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
            SizedBox(height: 43),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildDatePicker("Day", 1, 31, selectedDay, (value) {
                  setState(() {
                    selectedDay = value;
                  });
                }),
                SizedBox(width: 20),
                Text("", style: AppTextStyles.bodyText),
                SizedBox(width: 8),
                buildDatePicker("Month", 1, 12, selectedMonth, (value) {
                  setState(() {
                    selectedMonth = value;
                  });
                }),
                SizedBox(width: 20),
                Text('', style: AppTextStyles.bodyText),
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

            ElevatedButton(
              onPressed: () {
                DateTime selectedDate =
                    DateTime(selectedYear, selectedMonth, selectedDay);
                DateTime now = DateTime.now();
                if (now.difference(selectedDate).inDays >= 18 * 365) {
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      'You must be at least 18 years old to proceed.',
                      style: AppTextStyles.bodyText,
                    ),
                    backgroundColor: Colors.red,
                  ));
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                backgroundColor: AppColors.buttonColor,
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
              onChanged: (value) {
                name = value;
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
          ],
        ),
      ),
    );
  }

  // Step 3: Gender Selection
  Widget buildGenderStep(Size screenSize) {
    final Rx<Gender?> selectedGender = Rx<Gender?>(null);

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
                if (controller.preferences.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(),
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
                            selectedGender.value = value;
                          },
                          activeColor: AppColors.buttonColor,
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
    genderIds.addAll(controller.genders.map((gender) => gender.id));

    RxList<String> options = <String>[].obs;

    options
        .assignAll(controller.subGenders.map((subGender) => subGender.title));

    double titleFontSize = screenSize.width * 0.05;
    double descriptionFontSize = screenSize.width * 0.03;
    double optionFontSize = screenSize.width * 0.03;

    RxString selectedOption = ''.obs;

    return Obx(() {
      if (controller.subGenders.isEmpty) {
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
              Column(
                children: List.generate(options.length, (index) {
                  return RadioListTile<String>(
                    title: Text(
                      options[index],
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: optionFontSize,
                        color: AppColors.textColor,
                      ),
                    ),
                    value: options[index],
                    groupValue: selectedOption.value,
                    onChanged: (String? value) {
                      selectedOption.value = value ?? '';
                    },
                    activeColor: AppColors.buttonColor,
                    contentPadding: EdgeInsets.zero,
                  );
                }),
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
              Center(
                child: Text(
                  controller.headlines.length == 5
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
                        controller.preferences.isEmpty
                            ? controller.preferences.length.toString()
                            : controller.preferences[index].title,
                        style: AppTextStyles.bodyText.copyWith(
                          fontSize: optionFontSize,
                          color: AppColors.textColor,
                        ),
                      ),
                      value: preferencesSelectedOptions.isNotEmpty
                          ? preferencesSelectedOptions[index]
                          : false,
                      onChanged: (bool? value) {
                        preferencesSelectedOptions[index] = value ?? false;
                      },
                      activeColor: AppColors.buttonColor,
                      checkColor: Colors.white,
                      contentPadding: EdgeInsets.zero,
                    );
                  });
                },
              )),
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

    void updateSelectedStatus() {
      selectedStatus.clear();
      for (int i = 0; i < selectedOptions.length; i++) {
        if (selectedOptions[i]) {
          selectedStatus.add(options[i]);
        }
      }
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
    bool isSelectionValid() {
      return selectedInterests.length >= 10;
    }

    void addInterest() {
      String newInterest = interestController.text.trim();
      if (newInterest.isNotEmpty && !selectedInterests.contains(newInterest)) {
        selectedInterests.add(newInterest);
        interestController.clear();
        interestFocusNode.unfocus();
      }
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
                onSubmitted: (_) {
                  addInterest();
                },
              ),
              SizedBox(height: 20),
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
              Obx(() {
                return selectedInterests.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Your Interest:",
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
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.acceptColor,
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
            ],
          ),
        ),
      ),
    );
  }

// step 8
  Widget buildUserDescriptionStep(Size screenSize) {
    RxString userDescription = ''.obs;
    void onDescriptionChanged(String value) {
      userDescription.value = value;
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
                    ? controller.headlines[7].title
                    : "",
                style: AppTextStyles.bodyText.copyWith(
                  fontSize: bodyFontSize,
                  color: AppColors.textColor,
                ),
              ),
              SizedBox(height: 20),
              TextField(
                onChanged: onDescriptionChanged,
                maxLength: 250,
                maxLines: 6,
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
                ),
                style: TextStyle(
                    color: AppColors.textColor, fontSize: inputFontSize),
                cursorColor: AppColors.cursorColor,
                textInputAction: TextInputAction.done,
              ),
              SizedBox(height: 20),
              Obx(() {
                return Text(
                  '${userDescription.value.length} / 250 characters',
                  style: AppTextStyles.bodyText.copyWith(
                    fontSize: bodyFontSize,
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

    Future<void> pickImage(int index, ImageSource source) async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        images[index] = File(pickedFile.path);
      }
    }

    Future<void> requestCameraPermission() async {
      var status = await Permission.camera.request();
      if (status.isDenied) {
        Get.snackbar('', "Camera permission denied");
      }
    }

    Future<void> requestGalleryPermission() async {
      var status = await Permission.photos.request();
      if (status.isDenied) {
        Get.snackbar("", "Gallery permission denied");
      }
    }

    double screenWidth = screenSize.width;

    double iconSize = screenWidth * 0.12;
    double dialogButtonFontSize = screenWidth * 0.03;
    double imageContainerSize = screenWidth * 0.39;
    return Scaffold(
        body: Padding(
      padding: EdgeInsets.all(16.0), // Add some padding around the content
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and description
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
                itemCount: images.length + 1,
                itemBuilder: (context, index) {
                  if (index == images.length) {
                    return Center(
                      child: ElevatedButton(
                        onPressed: () {
                          images.add(null);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(12),
                        ),
                        child: Icon(
                          Icons.add_a_photo,
                          size: iconSize, // Responsive icon size
                          color: Colors.grey.shade600,
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
                                                  child: const Icon(
                                                      Icons.camera_alt),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    pickImage(index,
                                                        ImageSource.gallery);
                                                  },
                                                  child:
                                                      const Icon(Icons.photo),
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
                                                  child: const Icon(
                                                      Icons.camera_alt),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    pickImage(index,
                                                        ImageSource.gallery);
                                                  },
                                                  child:
                                                      const Icon(Icons.photo),
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
          ),
        ],
      ),
    ));
  }

  // step 10
  Widget buildPermissionRequestStep(Size screenSize) {
    RxBool notificationGranted = false.obs;
    RxBool locationGranted = false.obs;
    Future<void> showPermissionDialog(
        BuildContext context, String permissionType) async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false,
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
                      "We need permission to send you notifications.",
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
    RxString selectedPlan = 'None'.obs;
    RxString selectedService = 'None'.obs;
    double fontSize = screenSize.width * 0.03;

    Future<void> showPaymentConfirmationDialog(
        BuildContext context, String planType, String amount) async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Confirm Subscription",
              style: AppTextStyles.titleText.copyWith(
                fontSize: fontSize,
                color: AppColors.textColor,
              ),
            ),
            content: Text(
              "Do you want to subscribe to the $planType plan for $amount?",
              style: AppTextStyles.bodyText.copyWith(
                fontSize: fontSize - 2,
                color: AppColors.textColor,
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cancel',
                  style: AppTextStyles.bodyText.copyWith(
                    color: AppColors.deniedColor,
                    fontSize: fontSize,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  selectedPlan.value = planType;
                  Navigator.of(context).pop();
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
                  return Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.formFieldColor),
                    ),
                    child: DropdownButton<String>(
                      value: controller.benefits.isEmpty
                          ? null
                          : controller.benefits
                                  .map((benefit) => benefit.title)
                                  .toList()
                                  .contains(controller.selectedBenefit.value)
                              ? controller.selectedBenefit.value
                              : null,
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
                          controller.selectedBenefit.value = newValue;
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
                    controller.headlines.isNotEmpty
                        ? controller.headlines[10].title
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
                        ? controller.headlines[10].description
                        : "Loading Title...",
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
          Obx(() {
            return ElevatedButton(
              onPressed: selectedPlan.value != 'None'
                  ? () {
                      print("Selected Plan: ${selectedPlan.value}");
                    }
                  : null,
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
    double fontSize = screenSize.width * 0.03;
    final controller = Get.find<Controller>();

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
                  controller.safetyGuidelines.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap:
                              true, // Allows ListView to take only as much space as needed
                          physics:
                              NeverScrollableScrollPhysics(), // Prevents nested scrolls
                          itemCount: controller.safetyGuidelines.length,
                          itemBuilder: (context, index) {
                            var guideline = controller.safetyGuidelines[index];
                            return Column(
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
                        )
                      : Center(
                          child: SpinKitCircle(
                            size: 35.0, // Adjust the size as needed
                            color: AppColors.acceptColor,
                          ),
                        ),
                  SizedBox(height: 20),
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
        ],
      ),
    );
  }

// step 13
  Widget buildProfileSummaryPage(Size screenSize) {
    double fontSize = screenSize.width * 0.03;

    return SingleChildScrollView(
      child: Column(
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
                    "Profile Summary",
                    style: AppTextStyles.titleText.copyWith(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Review your profile and preferences before starting your journey.",
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
                    backgroundImage: AssetImage('assets/profile_picture.jpg'),
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
                            color: AppColors.textColor,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Age: 25",
                          style: AppTextStyles.bodyText.copyWith(
                            fontSize: fontSize - 2,
                            color: AppColors.textColor,
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
                      color: AppColors.textColor,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Interested in: Men & Women",
                    style: AppTextStyles.bodyText.copyWith(
                      fontSize: fontSize - 2,
                      color: AppColors.textColor,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Looking for: Long-Term Relationship",
                    style: AppTextStyles.bodyText.copyWith(
                      fontSize: fontSize - 2,
                      color: AppColors.textColor,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Location: New York",
                    style: AppTextStyles.bodyText.copyWith(
                      fontSize: fontSize - 2,
                      color: AppColors.textColor,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Hobbies: Traveling, Reading, Photography",
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
                    color: AppColors.accentColor,
                    size: fontSize,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "You are subscribed to the Quarterly Plan (599 INR).",
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: fontSize - 2,
                        color: AppColors.textColor,
                      ),
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
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: fontSize,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "You have acknowledged the safety guidelines.",
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: fontSize - 2,
                        color: AppColors.textColor,
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
              backgroundColor: AppColors.buttonColor,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.edit,
                  color: AppColors.iconColor,
                ),
                SizedBox(width: 8),
                Text(
                  'Edit',
                  style: AppTextStyles.buttonText.copyWith(
                    fontSize: fontSize,
                  ),
                ),
              ],
            ),
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
    if (currentPage == 1) {
      pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    } else if (currentPage == 2) {
      pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    } else if (currentPage == 3) {
      pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    } else if (currentPage == 4) {
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
