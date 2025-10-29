import 'dart:convert';
import 'dart:io';
import 'package:dating_application/Screens/auth.dart';
import 'package:dating_application/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
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
  RxList<String> selectedLanguagesId = <String>[].obs;
  RxString searchQuery = ''.obs;
  final selectedGender = Rx<Gender?>(null);
  int currentPage = 1;
  final PageController pageController = PageController();
  RxList<bool> preferencesSelectedOptions = <bool>[].obs;

  RxList<bool> desireSelectedOptions = <bool>[].obs;
  RxList<String> selectedStatus = <String>[].obs;
  RxList<bool> selectedOptions = <bool>[].obs;
  RxList<String> selectedDesireIds = <String>[].obs;
  RxList<String> genderIds = <String>[].obs;
  RxList<String> selectedInterests = <String>[].obs;
  RxString selectedPlan = 'None'.obs;
  TextEditingController interestController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final RxString nickname = ''.obs;
  final RxString relationshipStepError = ''.obs;

  @override
  void initState() {
    super.initState();
    nicknameController.text = controller.userRegistrationRequest.name;
    nickname.value = nicknameController.text;
    nicknameController.addListener(() {
      nickname.value = nicknameController.text;
      controller.userRegistrationRequest.nickname =
          nicknameController.text.trim();
    });
    intialize();
  }

  intialize() async {
    // await controller.fetchAllHeadlines();
    await controller.fetchBenefits();
    await controller.fetchSafetyGuidelines();
    await controller.fetchPreferences();
    await controller.fetchGenders();
    await controller.fetchDesires();
    await controller.fetchAllPackages();
    await controller.fetchlang();
    genderIds.addAll(controller.genders.map((gender) => gender.id));
    // for (String genderId in genderIds) {
    //   await controller.fetchSubGender(SubGenderRequest(genderId: genderId));
    // }
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
          child: Text('Proceed', style: AppTextStyles.buttonText),
        ),
        ElevatedButton(
          onPressed: onBackPressed,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 5),
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

    // Total number of steps (update if you change the number of steps)
    final int totalSteps = 12;

    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: AppBar(
            automaticallyImplyLeading: false,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.gradientBackgroundList,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                  child: Text(
                    "$currentPage of $totalSteps",
                    style: TextStyle(
                      fontSize: isPortrait ? fontSize : fontSize + 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Progress Indicator
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      colors: AppColors.gradientBackgroundList,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                          ),
                        ),
                        FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: currentPage / totalSteps,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: AppColors.gradientBackgroundList,
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: pageController,
                  onPageChanged: onPageChanged,
                  itemCount: 14,
                  itemBuilder: (context, index) {
                    return buildStepWidget(index + 1, screenSize);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Step 1: DOB Input
  Widget buildBirthdayStep(Size screenSize) {
    double titleFontSize = screenSize.width * 0.065;
    double subHeadingFontSize = screenSize.width * 0.035;
    double datePickerFontSize = screenSize.width * 0.04;

    return Stack(
      children: [
        Card(
          elevation: 12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align to top left
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Obx(() {
                  return Center(
                    child: Text(
                      controller.headlines.isNotEmpty
                          ? controller.headlines[0].title
                          : 'Loading headlines...',
                      style: AppTextStyles.titleText.copyWith(
                        fontSize: titleFontSize,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  );
                }),
                SizedBox(height: 28),
                Obx(() {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      controller.headlines.isNotEmpty
                          ? controller.headlines[0].description
                          : 'Loading description...',
                      style: AppTextStyles.bodyText.copyWith(
                        color: Colors.white70,
                        fontSize: subHeadingFontSize,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  );
                }),
                SizedBox(height: 42),
                Text(
                  "Date of Birth",
                  style: AppTextStyles.labelText.copyWith(
                    fontSize: datePickerFontSize,
                    color: AppColors.textColor,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final DateTime eighteenYearsAgo = DateTime(
                        DateTime.now().year - 18,
                        DateTime.now().month,
                        DateTime.now().day);
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate.isAfter(eighteenYearsAgo)
                          ? eighteenYearsAgo
                          : selectedDate,
                      firstDate: DateTime(1900),
                      lastDate: eighteenYearsAgo,
                    );

                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                        date.value =
                            DateFormat('MM/dd/yyyy').format(pickedDate);
                      });
                    }
                  },
                  child: Obx(() => Container(
                        width: double.infinity,
                        padding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        decoration: BoxDecoration(
                          color: AppColors.formFieldColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.textColor),
                        ),
                        child: Text(
                          date.value.isEmpty ? 'MM/DD/YYYY' : date.value,
                          style: AppTextStyles.bodyText.copyWith(
                            fontSize: datePickerFontSize,
                            color: AppColors.textColor,
                          ),
                        ),
                      )),
                ),
                SizedBox(height: 32),
              ],
            ),
          ),
        ),
        // Bottom-aligned Next button
        Positioned(
          left: 0,
          right: 0,
          bottom: 24,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment(0.8, 1),
                colors: AppColors.gradientBackgroundList,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: ElevatedButton(
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
                    DateFormat('MM/dd/yyyy').format(selectedDate);
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
                minimumSize: Size(double.infinity, 48),
                padding: EdgeInsets.symmetric(vertical: 10),
                backgroundColor: Colors.transparent,
                foregroundColor: AppColors.textColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: Text(
                'Next',
                style: AppTextStyles.buttonText.copyWith(
                  fontSize: screenSize.width * 0.05,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _validateNickname(String nickname) {
    if (nickname.isEmpty) {
      failure('Nickname', 'Enter Your Nickname');
      return false;
    }
    // if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(nickname)) {
    //   failure('Nickname', 'Nickname must only contain letters.');
    //   return false;
    // }
    // check for number and special characters
    if (RegExp(r'[0-9!@#$%^&*(),.?":{}|<>]').hasMatch(nickname)) {
      failure('Nickname',
          'Nickname must not contain numbers or special characters.');
      return false;
    }

    return true;
  }

  // Step 2: Name Input
  Widget buildNameStep(Size screenSize) {
    double titleFontSize = screenSize.width * 0.065;
    double labelfontSize = screenSize.width * 0.035;
    double subHeadingFontSize = screenSize.width * 0.035;
    double inputTextFontSize = screenSize.width * 0.04;
    // TextEditingController nicknameController = TextEditingController(
    //   text: controller.userRegistrationRequest.nickname,
    // );

    return Stack(
      children: [
        Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align to top left
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  controller.headlines.isNotEmpty
                      ? controller.headlines[1].title
                      : "Loading Title",
                  style: AppTextStyles.titleText.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: titleFontSize,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 24),
                Text(
                  controller.headlines.isNotEmpty
                      ? controller.headlines[1].description
                      : "",
                  style: AppTextStyles.bodyText.copyWith(
                    color: Colors.white70,
                    fontSize: subHeadingFontSize,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 32),
                Text(
                  "Your Nick Name",
                  style: AppTextStyles.labelText.copyWith(
                    fontSize: labelfontSize,
                    color: AppColors.textColor,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 8),
                TextField(
                  autofocus: true,
                  controller: nicknameController,
                  onChanged: (value) {
                    nickname.value = value;
                    controller.userRegistrationRequest.nickname = value.trim();
                  },
                  onSubmitted: (value) {
                    nickname.value = value;
                    controller.userRegistrationRequest.nickname = value.trim();
                  },
                  decoration: InputDecoration(
                    hintText: "Enter your nick name",
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
                      borderSide: BorderSide(color: AppColors.activeColor),
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
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
        // Bottom-aligned button row
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Obx(() => buildBottomButtonRow(
                onBack: onBackPressed,
                onNext: () {
                  if (nickname.value.isEmpty) {
                    failure('Nickname', 'Enter Your Nickname');
                    return;
                  } else {
                    if (_validateNickname(nickname.value)) {
                      markStepAsCompleted(2);
                      Get.snackbar('nickname', nickname.value);
                      pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    }
                  }
                },
                nextLabel: 'Next',
                backLabel: 'Back',
                nextEnabled: nickname.value.isNotEmpty,
                context: context,
              )),
        ),
      ],
    );
  }

  final RxString genderStepError = ''.obs;

  // Step 3: Gender Selection
  Widget buildGenderStep(Size screenSize) {
    double titleFontSize = screenSize.width * 0.065;
    double optionFontSize = screenSize.width * 0.035;
    double errorFontSize = screenSize.width * 0.04;

    return Stack(
      children: [
        SizedBox(
          height: screenSize.height * 0.8,
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    controller.headlines.length > 2
                        ? controller.headlines[2].title
                        : "Gender Selection",
                    style: AppTextStyles.titleText.copyWith(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 12),
                  // Description
                  Text(
                    controller.headlines.length > 2
                        ? controller.headlines[2].description
                        : "",
                    style: AppTextStyles.bodyText.copyWith(
                      fontSize: optionFontSize * 0.9,
                      color: AppColors.textColor.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 24),
                  // Show error message prominently at the top of the content area
                  Obx(() {
                    if (genderStepError.value.isNotEmpty) {
                      return Container(
                        width: double.infinity,
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red, width: 1),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline,
                                color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                genderStepError.value,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: errorFontSize,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  }),
                  SizedBox(height: genderStepError.value.isNotEmpty ? 16 : 0),
                  // Gender List
                  Expanded(
                    child: Obx(() {
                      if (controller.genders.isEmpty) {
                        return Center(
                          child: SpinKitCircle(
                            size: 60,
                            color: AppColors.progressColor,
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: controller.genders.length,
                        itemBuilder: (context, index) {
                          final gender = controller.genders[index];
                          final isSelected =
                              selectedGender.value?.id == gender.id;
                          return GestureDetector(
                            onTap: () {
                              selectedGender.value = gender;
                              controller.userRegistrationRequest.gender =
                                  gender.id;
                              controller.fetchSubGender(
                                  SubGenderRequest(genderId: gender.id));
                              // Clear error when user selects a gender
                              genderStepError.value = '';
                              setState(() {});
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 16),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? LinearGradient(
                                        colors:
                                            AppColors.gradientBackgroundList,
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                                color: isSelected
                                    ? null
                                    : Colors.black.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(10),
                                border: isSelected
                                    ? Border.all(color: Colors.white, width: 2)
                                    : genderStepError.value.isNotEmpty
                                        ? Border.all(
                                            color: Colors.red, width: 1)
                                        : null,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      gender.title,
                                      style: AppTextStyles.bodyText.copyWith(
                                        fontSize: optionFontSize,
                                        color: AppColors.textColor,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(Icons.check_circle,
                                        color: Colors.white)
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Bottom-aligned button row
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: buildBottomButtonRow(
            onBack: onBackPressed,
            onNext: () {
              if (selectedGender.value == null) {
                failure('Gender', 'Please select a gender to proceed.');
              } else {
                genderStepError.value = '';
                markStepAsCompleted(3);
                Get.snackbar('gender',
                    controller.userRegistrationRequest.gender.toString());
                pageController.nextPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.ease,
                );
              }
            },
            nextLabel: 'Next',
            backLabel: 'Back',
            nextEnabled: true, // Always enable the button to allow validation
            context: context,
          ),
        ),
      ],
    );
  }

  // Step 4: Describe Yourself (Sub gender)
  Widget buildBestDescribeYouStep(Size screenSize) {
    double titleFontSize = screenSize.width * 0.065;
    double optionFontSize = screenSize.width * 0.035;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    controller.headlines.length > 3
                        ? controller.headlines[3].title
                        : "Describe Yourself",
                    style: AppTextStyles.titleText.copyWith(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 12),
                  // Description
                  Text(
                    controller.headlines.length > 3
                        ? controller.headlines[3].description
                        : "",
                    style: AppTextStyles.bodyText.copyWith(
                      fontSize: optionFontSize * 0.9,
                      color: AppColors.textColor.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 24),
                  // Sub-gender List
                  Expanded(
                    child: Obx(() {
                      if (controller.subGenders.isEmpty) {
                        return Center(
                          child: SpinKitCircle(
                            size: 60,
                            color: AppColors.progressColor,
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: controller.subGenders.length,
                        itemBuilder: (context, index) {
                          final subGender = controller.subGenders[index];
                          final isSelected =
                              selectedOption.value == subGender.id;
                          return GestureDetector(
                            onTap: () {
                              selectedOption.value = subGender.id;
                              controller.userRegistrationRequest.subGender =
                                  subGender.id;
                              setState(() {});
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 16),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? LinearGradient(
                                        colors:
                                            AppColors.gradientBackgroundList,
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                                color: isSelected
                                    ? null
                                    : Colors.black.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(10),
                                border: isSelected
                                    ? Border.all(color: Colors.white, width: 2)
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      subGender.title,
                                      style: AppTextStyles.bodyText.copyWith(
                                        fontSize: optionFontSize,
                                        color: AppColors.textColor,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(Icons.check_circle,
                                        color: Colors.white)
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
        // Bottom-aligned button row
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0, top: 16.0),
            child: buildBottomButtonRow(
              onBack: onBackPressed,
              onNext: () {
                print(controller.userRegistrationRequest.subGender);
                if (controller.userRegistrationRequest.subGender.isEmpty) {
                  failure('Failed', 'Please select an option to proceed.');
                  return;
                }
                markStepAsCompleted(4);
                Get.snackbar('Sub-gender',
                    controller.userRegistrationRequest.subGender.toString());
                pageController.nextPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.ease,
                );
              },
              nextLabel: 'Next',
              backLabel: 'Back',
              nextEnabled: true, // Always enable the button to allow validation
              context: context,
            ),
          ),
        ),
      ],
    );
  }

// step 5 who are you looking for
  Widget buildLookingForStep(Size screenSize) {
    double titleFontSize = screenSize.width * 0.065;
    double descriptionFontSize = screenSize.width * 0.035;
    double optionFontSize = screenSize.width * 0.04;
    double buttonFontSize = screenSize.width * 0.045;

    return Obx(() {
      // Initialize the preferences list if needed
      if (preferencesSelectedOptions.isEmpty ||
          preferencesSelectedOptions.length != controller.preferences.length) {
        preferencesSelectedOptions.value =
            List<bool>.filled(controller.preferences.length, false);
      }

      if (controller.preferences.isEmpty) {
        return Center(
          child: SpinKitCircle(
            size: 90,
            color: AppColors.progressColor,
          ),
        );
      }

      return Stack(
        children: [
          SizedBox(
            height: screenSize.height * 0.8,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
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
                    SizedBox(height: 20),
                    Center(
                      child: Text(
                        controller.headlines.length > 4
                            ? controller.headlines[4].description
                            : "Select the preferences you're interested in.",
                        style: AppTextStyles.bodyText.copyWith(
                          fontSize: descriptionFontSize,
                          color: AppColors.textColor.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 24),
                    Expanded(
                      child: ListView.builder(
                        itemCount: controller.preferences.length,
                        itemBuilder: (context, index) {
                          final preference = controller.preferences[index];
                          final isSelected = preferencesSelectedOptions[index];
                          return GestureDetector(
                            onTap: () {
                              preferencesSelectedOptions[index] =
                                  !preferencesSelectedOptions[index];
                              preferencesSelectedOptions.refresh();
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 16),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? LinearGradient(
                                        colors:
                                            AppColors.gradientBackgroundList,
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                                color: isSelected
                                    ? null
                                    : Colors.black.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(10),
                                border: isSelected
                                    ? Border.all(color: Colors.white, width: 2)
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      preference.title,
                                      style: AppTextStyles.bodyText.copyWith(
                                        fontSize: optionFontSize,
                                        color: AppColors.textColor,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(Icons.check_circle,
                                        color: Colors.white)
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          // Bottom-aligned button row
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.only(
                  bottom: 24, left: 16, right: 16, top: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment(0.8, 1),
                          colors: AppColors.gradientBackgroundList,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: ElevatedButton(
                        onPressed: onBackPressed,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          backgroundColor: Colors.transparent,
                          foregroundColor: AppColors.textColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          shadowColor: Colors.transparent,
                          elevation: 0,
                        ),
                        child: Text(
                          'Back',
                          style: AppTextStyles.buttonText.copyWith(
                            fontSize: buttonFontSize,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment(0.8, 1),
                          colors: AppColors.gradientBackgroundList,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          List<String> selectedPreferences = [];
                          for (int i = 0;
                              i < preferencesSelectedOptions.length;
                              i++) {
                            if (preferencesSelectedOptions[i]) {
                              selectedPreferences
                                  .add(controller.preferences[i].id);
                            }
                          }

                          controller.userRegistrationRequest.preferences =
                              selectedPreferences;

                          if (selectedPreferences.length < 3) {
                            failure('Failed',
                                'Please select at least three preferences.');
                          } else {
                            markStepAsCompleted(5);
                            Get.snackbar(
                                'pref',
                                controller.userRegistrationRequest.preferences
                                    .toString());
                            pageController.nextPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.ease,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          backgroundColor: Colors.transparent,
                          foregroundColor: AppColors.textColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          shadowColor: Colors.transparent,
                          elevation: 0,
                        ),
                        child: Text(
                          'Next',
                          style: AppTextStyles.buttonText.copyWith(
                            fontSize: buttonFontSize,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

// Step 6: Gender Identity Selection
  Widget buildRelationshipStatusInterestStep(
      BuildContext context, Size screenSize) {
    List<String> options = controller.categories
        .expand((category) => category.desires.map((desire) => desire.title))
        .toList();

    controller.categories.map((category) => category.category).toList();
    if (selectedOptions.isEmpty || selectedOptions.length != options.length) {
      selectedOptions.value = List.filled(options.length, false);
    }

    void updateSelectedStatus() {
      selectedStatus.clear();
      selectedDesireIds.clear();
      int globalIndex = 0;

      for (var category in controller.categories) {
        for (int j = 0; j < category.desires.length; j++) {
          if (selectedOptions[globalIndex]) {
            selectedStatus.add(category.desires[j].title);
            selectedDesireIds.add(category.desires[j].id);
          }
          globalIndex++;
        }
      }

      controller.userRegistrationRequest.desires = selectedDesireIds;
    }

    void handleChipSelection(int index) {
      selectedOptions[index] = !selectedOptions[index];
      updateSelectedStatus();
      // Force update for Obx
      selectedOptions.refresh();
      selectedStatus.refresh();
    }

    double screenWidth = screenSize.width;
    double titleFontSize = screenWidth * 0.065;
    double bodyFontSize = screenWidth * 0.04;
    double chipFontSize = screenWidth * 0.03;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
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
                  selectedStatus.isNotEmpty
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
                              child: Wrap(
                                spacing: 8,
                                children: selectedStatus.map((status) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 7),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 1,
                                        ),
                                        gradient: LinearGradient(
                                          colors:
                                              AppColors.gradientBackgroundList,
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            status,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: chipFontSize,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          GestureDetector(
                                            onTap: () {
                                              int index =
                                                  options.indexOf(status);
                                              selectedOptions[index] = false;
                                              updateSelectedStatus();
                                              selectedOptions.refresh();
                                              selectedStatus.refresh();
                                            },
                                            child: Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: chipFontSize + 2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            SizedBox(height: 20),
                          ],
                        )
                      : Container(),
                  Text(
                    "Select your interests:",
                    style: AppTextStyles.bodyText.copyWith(
                      fontSize: bodyFontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10),
                  Obx(() => Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: List.generate(options.length, (index) {
                          final isSelected = selectedOptions[index];
                          return GestureDetector(
                            onTap: () {
                              handleChipSelection(index);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? LinearGradient(
                                          colors:
                                              AppColors.gradientBackgroundList,
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: isSelected ? null : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(20),
                                  border: isSelected
                                      ? Border.all(
                                          color: Colors.white, width: 1)
                                      : null,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        options[index],
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: chipFontSize,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      if (isSelected) ...[
                                        SizedBox(width: 6),
                                        Icon(Icons.check_circle,
                                            color: Colors.white, size: 18),
                                      ]
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      )),
                  SizedBox(height: 20),
                  selectedStatus.isNotEmpty
                      ? Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              selectedOptions.value =
                                  List.filled(options.length, false);
                              updateSelectedStatus();
                              selectedOptions.refresh();
                              selectedStatus.refresh();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: AppColors.textColor,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 22, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Icon(
                              Icons.delete_outline,
                              color: Colors.pink,
                              size: titleFontSize,
                            ),
                          ),
                        )
                      : Container()
                ],
              ),
            ),
          ),

          // Footer Buttons
          Padding(
            padding:
                const EdgeInsets.only(bottom: 24, left: 16, right: 16, top: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment(0.8, 1),
                        colors: AppColors.gradientBackgroundList,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ElevatedButton(
                      onPressed: onBackPressed,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        backgroundColor: Colors.transparent,
                        foregroundColor: AppColors.textColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        shadowColor: Colors.transparent,
                        elevation: 0,
                      ),
                      child: Text(
                        'Back',
                        style: AppTextStyles.buttonText.copyWith(
                          fontSize: screenSize.width * 0.045,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment(0.8, 1),
                        colors: AppColors.gradientBackgroundList,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        if (selectedStatus.isNotEmpty) {
                          relationshipStepError.value = '';
                          markStepAsCompleted(6);
                          Get.snackbar(
                              'desires',
                              controller.userRegistrationRequest.desires
                                  .toString());
                          pageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        } else {
                          failure(
                              'Error', 'Please select at least one desire.');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        backgroundColor: Colors.transparent,
                        foregroundColor: AppColors.textColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        shadowColor: Colors.transparent,
                        elevation: 0,
                      ),
                      child: Text(
                        'Next',
                        style: AppTextStyles.buttonText.copyWith(
                          fontSize: screenSize.width * 0.045,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// step 7
  Widget buildInterestStep(BuildContext context, Size screenSize) {
    FocusNode interestFocusNode = FocusNode();

    bool isSelectionValid() {
      return selectedInterests.isNotEmpty && selectedInterests.length <= 6;
    }

    void updateUserInterests() {
      controller.userRegistrationRequest.interest =
          selectedInterests.join(', ');
    }

    void addInterest() {
      String newInterest = interestController.text.trim();
      if (newInterest.isEmpty) {
        failure('Error', 'Please enter an interest before adding.');
        return;
      }
      if (!selectedInterests.contains(newInterest)) {
        selectedInterests.add(newInterest);
        interestController.clear();
        interestFocusNode.unfocus();
        updateUserInterests();
      }
    }

    void onInterestChanged(String value) {
      updateUserInterests();
    }

    double screenWidth = screenSize.width;
    double titleFontSize = screenWidth * 0.065;
    double bodyFontSize = screenWidth * 0.035;
    double chipFontSize = screenWidth * 0.035;
    double inputFontSize = screenWidth * 0.04;
    double buttonFontSize = screenWidth * 0.045;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
                16, 16, 16, 100), // leave space for bottom button
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          : "Loading Description...",
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
                          borderSide: BorderSide(color: AppColors.activeColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppColors.textColor),
                        ),
                      ),
                      style: TextStyle(
                        color: AppColors.textColor,
                        fontSize: inputFontSize,
                      ),
                      cursorColor: AppColors.textColor,
                      onChanged: onInterestChanged,
                      onSubmitted: (_) => addInterest(),
                    ),
                    SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment(0.8, 1),
                          colors: AppColors.gradientBackgroundList,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: ElevatedButton(
                        onPressed: addInterest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: AppColors.textColor,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                        child: Text(
                          'Add Interest',
                          style: AppTextStyles.buttonText.copyWith(
                            fontSize: buttonFontSize,
                          ),
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
                                  "Your Interests:",
                                  style: AppTextStyles.bodyText.copyWith(
                                    fontSize: bodyFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textColor,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: selectedInterests.map((interest) {
                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors:
                                              AppColors.gradientBackgroundList,
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            interest,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: chipFontSize,
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          GestureDetector(
                                            onTap: () {
                                              selectedInterests
                                                  .remove(interest);
                                              updateUserInterests();
                                            },
                                            child: Icon(
                                              Icons.close,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                                SizedBox(height: 20),
                              ],
                            )
                          : Container();
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Sticky Bottom Navigation
        Obx(() => buildBottomButtonRow(
              onBack: onBackPressed,
              onNext: isSelectionValid()
                  ? () {
                      markStepAsCompleted(7);
                      Get.snackbar('Interest',
                          controller.userRegistrationRequest.interest);
                      pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                      controller.fetchlang();
                    }
                  : () {
                      failure('Error',
                          'Please enter at least one interest before proceeding.');
                    },
              nextLabel: 'Next',
              backLabel: 'Back',
              nextEnabled: true, // Always enabled to allow validation
              context: context,
            )),
      ],
    );
  }

  // Step 8 languages
  Widget buildUserLanguageStep(BuildContext context) {
    void updateSelectedStatus() {
      selectedLanguagesId.clear();
      for (int i = 0; i < controller.language.length; i++) {
        if (selectedLanguages.contains(controller.language[i].title)) {
          selectedLanguagesId.add(controller.language[i].id);
        }
      }
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

    final screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double titleFontSize = screenWidth * 0.065;
    double bodyFontSize = screenWidth * 0.035;
    double chipFontSize = screenWidth * 0.035;

    return Stack(
      children: [
        Container(
          padding:
              EdgeInsets.only(bottom: 80), // Leave space for bottom buttons
          child: SingleChildScrollView(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.headlines.isNotEmpty
                          ? controller.headlines[7].title
                          : "Select Languages",
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
                          : "Choose the languages you speak.",
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: bodyFontSize,
                        color: AppColors.textColor.withOpacity(0.7),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      cursorColor: AppColors.cursorColor,
                      onChanged: (query) {
                        searchQuery.value = query;
                      },
                      decoration: InputDecoration(
                        hintText: 'Search Languages...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: AppColors.textColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: AppColors.activeColor, width: 2.0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: AppColors.textColor, width: 1.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      ),
                      style: TextStyle(
                        color: AppColors.textColor,
                        fontSize: chipFontSize,
                      ),
                    ),
                    SizedBox(height: 16),
                    Obx(() {
                      var filteredLanguages = controller.language
                          .where((language) => language.title
                              .toLowerCase()
                              .contains(searchQuery.value.toLowerCase()))
                          .toList();

                      return controller.language.isEmpty
                          ? Center(
                              child: SpinKitCircle(
                                size: 60,
                                color: AppColors.progressColor,
                              ),
                            )
                          : Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: filteredLanguages.map((language) {
                                bool isSelected =
                                    selectedLanguages.contains(language.title);

                                return GestureDetector(
                                  onTap: () {
                                    handleChipSelection(language.title);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? LinearGradient(
                                              colors: AppColors
                                                  .gradientBackgroundList,
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            )
                                          : null,
                                      color:
                                          isSelected ? null : Colors.grey[300],
                                      borderRadius: BorderRadius.circular(20),
                                      border: isSelected
                                          ? Border.all(
                                              color: Colors.white, width: 1)
                                          : null,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 8),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            language.title,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontSize: chipFontSize,
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                          if (isSelected) ...[
                                            SizedBox(width: 6),
                                            Icon(Icons.check_circle,
                                                color: Colors.white, size: 18),
                                          ]
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                    }),
                    SizedBox(height: 20),
                    Obx(() {
                      return selectedLanguages.isNotEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Selected Languages:",
                                  style: AppTextStyles.bodyText.copyWith(
                                    fontSize: bodyFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textColor,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: selectedLanguages.map((lang) {
                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors:
                                              AppColors.gradientBackgroundList,
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            lang,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: chipFontSize,
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          GestureDetector(
                                            onTap: () {
                                              handleChipSelection(lang);
                                            },
                                            child: Icon(
                                              Icons.close,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                                SizedBox(height: 10),
                              ],
                            )
                          : Container();
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: buildBottomButtonRow(
            onBack: onBackPressed,
            onNext: () {
              if (selectedLanguages.isEmpty) {
                failure('Error', 'Please select at least one language');
                return;
              } else {
                markStepAsCompleted(8);
                pageController.nextPage(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.ease,
                );
              }
            },
            nextLabel: 'Next',
            backLabel: 'Back',
            nextEnabled: true,
            context: context,
          ),
        ),
      ],
    );
  }

// step 9 bio
  RxString userDescription = ''.obs;
  final TextEditingController descriptionController = TextEditingController();
  final RxString descriptionStepError = ''.obs;

  Widget buildUserDescriptionStep(Size screenSize) {
    void onDescriptionChanged(String value) {
      userDescription.value = value;
      controller.userRegistrationRequest.bio = value;
    }

    double screenWidth = screenSize.width;
    double titleFontSize = screenWidth * 0.065;
    double bodyFontSize = screenWidth * 0.035;
    double inputFontSize = screenWidth * 0.04;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 100,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            children: [
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.headlines.isNotEmpty
                            ? controller.headlines[8].title
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
                            ? controller.headlines[8].description
                            : "",
                        style: AppTextStyles.bodyText.copyWith(
                          fontSize: bodyFontSize,
                          color: AppColors.textColor.withOpacity(0.7),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: descriptionController,
                        onChanged: onDescriptionChanged,
                        maxLength: 1000,
                        maxLines: null, // Allows for dynamic expansion
                        keyboardType: TextInputType.multiline,
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
                            borderSide:
                                BorderSide(color: AppColors.activeColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: AppColors.textColor),
                          ),
                        ),
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontSize: inputFontSize,
                        ),
                        cursorColor: AppColors.cursorColor,
                        textInputAction: TextInputAction.newline,
                      ),
                      SizedBox(height: 10),
                      Obx(() {
                        return Text(
                          '${userDescription.value.length} / 1000 characters',
                          style: AppTextStyles.bodyText.copyWith(
                            fontSize: bodyFontSize,
                            color: userDescription.value.length > 1000
                                ? Colors.white70
                                : AppColors.textColor,
                          ),
                        );
                      }),
                      SizedBox(height: 80), // Spacer for bottom buttons
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Bottom-aligned button row
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Obx(() => buildBottomButtonRow(
                onBack: onBackPressed,
                onNext: userDescription.value.isNotEmpty &&
                        userDescription.value.length <= 1000
                    ? () {
                        markStepAsCompleted(9);
                        Get.snackbar('bio',
                            controller.userRegistrationRequest.bio.toString());
                        pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      }
                    : null,
                nextLabel: 'Next',
                backLabel: 'Back',
                nextEnabled: userDescription.value.isNotEmpty &&
                    userDescription.value.length <= 1000,
                context: context,
              )),
        ),
      ],
    );
  }

  RxBool notificationGranted = false.obs;
  RxBool locationGranted = false.obs;
  RxBool cameraGranted = false.obs;

// Helper to request notification permission
  Future<void> requestNotificationPermission() async {
    var status = await Permission.notification.request();
    notificationGranted.value = status.isGranted;
    if (status.isPermanentlyDenied) {
      // Open app settings if permanently denied
      await openAppSettings();
    }
    if (notificationGranted.value) {
      controller.userRegistrationRequest.emailAlerts = '1';
    } else {
      controller.userRegistrationRequest.emailAlerts = '0';
    }
  }

// Helper to request location permission
  Future<void> requestLocationPermission() async {
    var status = await Permission.location.request();
    locationGranted.value = status.isGranted;
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

// Helper to request camera/gallery permission
  Future<void> requestCameraPermission() async {
    var status = await Permission.camera.request();
    cameraGranted.value = status.isGranted;
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  // step 10 Permissions
  Widget buildPermissionRequestStep(Size screenSize) {
    Future<void> showPermissionDialog(
        BuildContext context, String permissionType) async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          double dialogFontSize = screenSize.width * 0.045;
          double dialogButtonFontSize = screenSize.width * 0.04;
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: AppColors.formFieldColor,
            title: Row(
              children: [
                Icon(
                  permissionType == 'notification'
                      ? Icons.notifications
                      : Icons.location_on,
                  color: Colors.white,
                  size: dialogFontSize + 4,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    permissionType == 'notification'
                        ? "Notification Permission"
                        : "Location Permission",
                    style: AppTextStyles.titleText.copyWith(
                      fontSize: dialogFontSize,
                      color: AppColors.textColor,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              permissionType == 'notification'
                  ? "Do you allow the app to send notifications?"
                  : "Do you allow the app to access your location?",
              style: AppTextStyles.bodyText.copyWith(
                fontSize: dialogFontSize * 0.95,
                color: AppColors.textColor,
              ),
            ),
            actionsPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  if (permissionType == 'notification') {
                    notificationGranted.value = false;
                    controller.userRegistrationRequest.emailAlerts = '0';
                  } else if (permissionType == 'location') {
                    locationGranted.value = false;
                  }
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                  textStyle: AppTextStyles.buttonText.copyWith(
                    fontSize: dialogButtonFontSize,
                  ),
                ),
                child: Text('Deny'),
              ),
              TextButton(
                onPressed: () {
                  if (permissionType == 'notification') {
                    notificationGranted.value = true;
                    controller.userRegistrationRequest.emailAlerts = '1';
                  } else if (permissionType == 'location') {
                    locationGranted.value = true;
                  }
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.green,
                  textStyle: AppTextStyles.buttonText.copyWith(
                    fontSize: dialogButtonFontSize,
                  ),
                ),
                child: Text('Accept'),
              ),
            ],
          );
        },
      );
    }

    double fontSize = screenSize.width * 0.035;
    double iconSize = screenSize.width * 0.07;

    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          SingleChildScrollView(
            padding:
                const EdgeInsets.only(bottom: 80), // leave space for button
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.all(24.0),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.headlines.isNotEmpty
                                  ? controller.headlines[9].title
                                  : "Loading Title...",
                              style: AppTextStyles.titleText.copyWith(
                                fontSize: fontSize * 1.2,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              controller.headlines.isNotEmpty
                                  ? controller.headlines[9].description
                                  : "",
                              style: AppTextStyles.bodyText.copyWith(
                                fontSize: fontSize,
                                color: AppColors.textColor.withOpacity(0.7),
                              ),
                            ),
                            SizedBox(height: 28),
                            GestureDetector(
                              onTap: () async {
                                // showPermissionDialog(context, 'notification');
                                await requestNotificationPermission();
                              },
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                color: AppColors.formFieldColor,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 18.0, horizontal: 16.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.notifications,
                                        color: Colors.white,
                                        size: iconSize,
                                      ),
                                      SizedBox(width: 14),
                                      Expanded(
                                        child: Text(
                                          "We need permission to send you notifications through email.",
                                          style:
                                              AppTextStyles.bodyText.copyWith(
                                            fontSize: fontSize,
                                            color: AppColors.textColor,
                                          ),
                                        ),
                                      ),
                                      Obx(() {
                                        return Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: notificationGranted.value
                                                ? AppColors.activeColor
                                                : Colors.grey.shade300,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Text(
                                            notificationGranted.value
                                                ? 'Granted'
                                                : 'Allow',
                                            style:
                                                AppTextStyles.bodyText.copyWith(
                                              fontSize: fontSize * 0.95,
                                              color: notificationGranted.value
                                                  ? Colors.white
                                                  : Colors.black54,
                                              fontWeight: FontWeight.bold,
                                            ),
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
                              onTap: () async {
                                // showPermissionDialog(context, 'location');
                                await requestLocationPermission();
                              },
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                color: AppColors.formFieldColor,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 18.0, horizontal: 16.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: Colors.white,
                                        size: iconSize,
                                      ),
                                      SizedBox(width: 14),
                                      Expanded(
                                        child: Text(
                                          "We need permission to access your location.",
                                          style:
                                              AppTextStyles.bodyText.copyWith(
                                            fontSize: fontSize,
                                            color: AppColors.textColor,
                                          ),
                                        ),
                                      ),
                                      Obx(() {
                                        return Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: locationGranted.value
                                                ? AppColors.activeColor
                                                : Colors.grey.shade300,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Text(
                                            locationGranted.value
                                                ? 'Granted'
                                                : 'Allow',
                                            style:
                                                AppTextStyles.bodyText.copyWith(
                                              fontSize: fontSize * 0.95,
                                              color: locationGranted.value
                                                  ? Colors.white
                                                  : Colors.black54,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 24),
                            GestureDetector(
                              onTap: () async {
                                await requestCameraPermission();
                              },
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                color: AppColors.formFieldColor,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 18.0, horizontal: 16.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: iconSize,
                                      ),
                                      SizedBox(width: 14),
                                      Expanded(
                                        child: Text(
                                          "We need permission to access your camera and images.",
                                          style:
                                              AppTextStyles.bodyText.copyWith(
                                            fontSize: fontSize,
                                            color: AppColors.textColor,
                                          ),
                                        ),
                                      ),
                                      Obx(() {
                                        return Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: cameraGranted.value
                                                ? AppColors.activeColor
                                                : Colors.grey.shade300,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Text(
                                            cameraGranted.value
                                                ? 'Granted'
                                                : 'Allow',
                                            style:
                                                AppTextStyles.bodyText.copyWith(
                                              fontSize: fontSize * 0.95,
                                              color: cameraGranted.value
                                                  ? Colors.white
                                                  : Colors.black54,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom-aligned button row (unchanged)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Obx(() => buildBottomButtonRow(
                  onBack: onBackPressed,
                  // onNext: notificationGranted.value && locationGranted.value && cameraGranted.value
                  onNext: () {
                    markStepAsCompleted(10);
                    Get.snackbar(
                      'permission',
                      controller.userRegistrationRequest.emailAlerts.toString(),
                    );
                    pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  },
                  nextLabel: 'Next',
                  backLabel: 'Back',
                  nextEnabled:
                      notificationGranted.value && locationGranted.value,
                  context: context,
                )),
          ),
        ],
      );
    });
  }

  RxList<File?> images = RxList<File?>(List.filled(6, null));
  void resetImagesForNewUser() {
    images.clear();
    images.addAll(List.filled(6, null));
  }

  final RxInt photoUpdateTrigger = 0.obs;
  // Step 11 photos
  Widget buildPhotosOfUser(Size screenSize) {
    Future<void> requestCameraPermission() async {
      var status = await Permission.camera.request();
      if (status.isDenied) {
        // Get.snackbar('Permission Denied', "Camera permission denied");
      }
    }

    Future<void> requestGalleryPermission() async {
      var status = await Permission.photos.request();
      if (status.isDenied) {
        // Get.snackbar('Permission Denied', "Gallery permission denied");
      }
    }

    Future<void> pickImage(int index, ImageSource source) async {
      if (index > 0 &&
          images[index - 1] == null &&
          (controller.userRegistrationRequest.photos.length <= index - 1 ||
              controller.userRegistrationRequest.photos[index - 1].isEmpty)) {
        Get.snackbar(
            "Error", "Please take a photo for the previous position first.");
        return;
      }

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

          /// ✅ Ensure the photos list has at least `index + 1` items
          if (controller.userRegistrationRequest.photos.length <= index) {
            while (controller.userRegistrationRequest.photos.length <= index) {
              controller.userRegistrationRequest.photos.add('');
            }
          }

          controller.userRegistrationRequest.photos[index] = base64Image;
          images[index] = imageFile;
          photoUpdateTrigger.value++;
        } else {
          Get.snackbar("Error", "Image compression failed.");
        }
      }
    }

    void onNextButtonPressed() {
      if (controller.userRegistrationRequest.photos
              .where((photo) => photo.isNotEmpty)
              .length >=
          3) {
        controller.userRegistrationRequest.imgcount =
            controller.userRegistrationRequest.photos.length.toString();
        markStepAsCompleted(11);
        // Get.snackbar(
        //     'photo', controller.userRegistrationRequest.photos.toString());
        // Get.snackbar(
        //     'photo', controller.userRegistrationRequest.imgcount.toString());
        pageController.nextPage(
          duration: Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      } else {
        Get.snackbar("Error", "Please add at least three photos.");
      }
    }

    double screenWidth = screenSize.width;
    double iconSize = screenWidth * 0.10;
    double imageContainerSize = screenWidth * 0.39;

    // Don't reset images every build, only on dispose/init
    // resetImagesForNewUser();

    return Stack(
      children: [
        Padding(
          padding:
              EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 90.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.headlines.isNotEmpty
                      ? controller.headlines[8].title
                      : "Loading Title...",
                  style: AppTextStyles.titleText.copyWith(
                    fontSize: screenWidth * 0.065,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  controller.headlines.isNotEmpty
                      ? controller.headlines[8].description
                      : "",
                  style: AppTextStyles.bodyText.copyWith(
                    fontSize: screenWidth * 0.035,
                    color: AppColors.textColor.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 20),
                Obx(() {
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 20.0,
                      mainAxisSpacing: 40.0,
                    ),
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      bool isPhotoUploaded = images[index] != null ||
                          (controller.userRegistrationRequest.photos.length >
                                  index &&
                              controller.userRegistrationRequest.photos[index]
                                  .isNotEmpty);
                      bool isIndexEditable = (index == 0 ||
                          (index > 0 && images[index - 1] != null));

                      Widget imageWidget;
                      if (images[index] != null) {
                        imageWidget = Image.file(
                          images[index]!,
                          fit: BoxFit.cover,
                          width: imageContainerSize,
                          height: imageContainerSize,
                        );
                      } else if (controller
                                  .userRegistrationRequest.photos.length >
                              index &&
                          controller.userRegistrationRequest.photos[index]
                              .isNotEmpty) {
                        imageWidget = Image.memory(
                          base64Decode(
                              controller.userRegistrationRequest.photos[index]),
                          fit: BoxFit.cover,
                          width: imageContainerSize,
                          height: imageContainerSize,
                        );
                      } else {
                        imageWidget = Container(
                          color: Colors.grey.shade300,
                          child: Icon(
                            Icons.add_a_photo,
                            color: Colors.grey.shade600,
                            size: iconSize,
                          ),
                        );
                      }

                      return GestureDetector(
                        onTap: isIndexEditable
                            ? () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      backgroundColor: AppColors.formFieldColor,
                                      child: Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Pick an image',
                                              style: AppTextStyles.titleText
                                                  .copyWith(
                                                fontSize: screenWidth * 0.045,
                                                color: AppColors.textColor,
                                              ),
                                            ),
                                            SizedBox(height: 16),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment(0.8, 1),
                                                        colors: AppColors
                                                            .gradientBackgroundList),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                  child: ElevatedButton.icon(
                                                    icon: Icon(Icons.camera_alt,
                                                        color: Colors.white),
                                                    label: Text(
                                                      "Camera",
                                                      style: AppTextStyles
                                                          .buttonText
                                                          .copyWith(
                                                        color: Colors.white,
                                                        fontSize:
                                                            screenWidth * 0.04,
                                                      ),
                                                    ),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      foregroundColor:
                                                          Colors.white,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 18,
                                                              vertical: 12),
                                                      elevation: 0,
                                                      shadowColor:
                                                          Colors.transparent,
                                                    ),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      pickImage(index,
                                                          ImageSource.camera);
                                                    },
                                                  ),
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment(0.8, 1),
                                                        colors: AppColors
                                                            .gradientColor),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                  ),
                                                  child: ElevatedButton.icon(
                                                    icon: Icon(Icons.photo,
                                                        color: Colors.white),
                                                    label: Text(
                                                      "Gallery",
                                                      style: AppTextStyles
                                                          .buttonText
                                                          .copyWith(
                                                        color: Colors.white,
                                                        fontSize:
                                                            screenWidth * 0.04,
                                                      ),
                                                    ),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      foregroundColor:
                                                          Colors.white,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 18,
                                                              vertical: 12),
                                                      elevation: 0,
                                                      shadowColor:
                                                          Colors.transparent,
                                                    ),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      pickImage(index,
                                                          ImageSource.gallery);
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }
                            : null,
                        child: Container(
                          width: imageContainerSize,
                          height: imageContainerSize,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                  child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: imageWidget,
                              )),
                              if (isPhotoUploaded)
                                Positioned(
                                  right: 4,
                                  top: 4,
                                  child: GestureDetector(
                                    onTap: isIndexEditable
                                        ? () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Dialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                  ),
                                                  backgroundColor:
                                                      AppColors.formFieldColor,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            20.0),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          'Pick an image',
                                                          style: AppTextStyles
                                                              .titleText
                                                              .copyWith(
                                                            fontSize:
                                                                screenWidth *
                                                                    0.045,
                                                            color: AppColors
                                                                .textColor,
                                                          ),
                                                        ),
                                                        SizedBox(height: 16),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                gradient: LinearGradient(
                                                                    begin: Alignment
                                                                        .topLeft,
                                                                    end:
                                                                        Alignment(
                                                                            0.8,
                                                                            1),
                                                                    colors: AppColors
                                                                        .gradientColor),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            30),
                                                              ),
                                                              child:
                                                                  ElevatedButton
                                                                      .icon(
                                                                icon: Icon(
                                                                    Icons
                                                                        .camera_alt,
                                                                    color: Colors
                                                                        .white),
                                                                label: Text(
                                                                  "Camera",
                                                                  style: AppTextStyles
                                                                      .buttonText
                                                                      .copyWith(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        screenWidth *
                                                                            0.04,
                                                                  ),
                                                                ),
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .transparent,
                                                                  foregroundColor:
                                                                      Colors
                                                                          .white,
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            12),
                                                                  ),
                                                                  padding: EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          18,
                                                                      vertical:
                                                                          12),
                                                                  elevation: 0,
                                                                  shadowColor:
                                                                      Colors
                                                                          .transparent,
                                                                ),
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                  pickImage(
                                                                      index,
                                                                      ImageSource
                                                                          .camera);
                                                                },
                                                              ),
                                                            ),
                                                            Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                gradient: LinearGradient(
                                                                    begin: Alignment
                                                                        .topLeft,
                                                                    end:
                                                                        Alignment(
                                                                            0.8,
                                                                            1),
                                                                    colors: AppColors
                                                                        .gradientColor),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            30),
                                                              ),
                                                              child:
                                                                  ElevatedButton
                                                                      .icon(
                                                                icon: Icon(
                                                                    Icons.photo,
                                                                    color: Colors
                                                                        .white),
                                                                label: Text(
                                                                  "Gallery",
                                                                  style: AppTextStyles
                                                                      .buttonText
                                                                      .copyWith(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        screenWidth *
                                                                            0.04,
                                                                  ),
                                                                ),
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .transparent,
                                                                  foregroundColor:
                                                                      Colors
                                                                          .white,
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            12),
                                                                  ),
                                                                  padding: EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          18,
                                                                      vertical:
                                                                          12),
                                                                  elevation: 0,
                                                                  shadowColor:
                                                                      Colors
                                                                          .transparent,
                                                                ),
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                  pickImage(
                                                                      index,
                                                                      ImageSource
                                                                          .gallery);
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          }
                                        : null,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.more_vert,
                                        size: 22,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
        // Bottom-aligned button row
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Obx(() {
            photoUpdateTrigger.value; // listen for changes
            return buildBottomButtonRow(
              onBack: onBackPressed,
              onNext: onNextButtonPressed,
              nextLabel: 'Next',
              backLabel: 'Back',
              nextEnabled: controller.userRegistrationRequest.photos
                      .where((photo) => photo.isNotEmpty)
                      .length >=
                  3,
              context: context,
            );
          }),
        ),
      ],
    );
  }

// step 12
  Widget buildSafetyGuidelinesWidget(Size screenSize) {
    double titleFontSize = screenSize.width * 0.065;
    double bodyFontSize = screenSize.width * 0.035;
    double itemFontSize = screenSize.width * 0.032;
    double buttonFontSize = screenSize.width * 0.045;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(
              left: 16.0, right: 16.0, top: 16.0, bottom: 90.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.headlines.isNotEmpty
                              ? controller.headlines[11].title
                              : "Loading Title...",
                          style: AppTextStyles.titleText.copyWith(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          controller.headlines.isNotEmpty
                              ? controller.headlines[11].description
                              : "Loading Description...",
                          style: AppTextStyles.bodyText.copyWith(
                            fontSize: bodyFontSize,
                            color: AppColors.textColor.withOpacity(0.7),
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
                    padding: const EdgeInsets.all(24.0),
                    child: controller.safetyGuidelines.isEmpty
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
                              var guideline =
                                  controller.safetyGuidelines[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 18.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      color: AppColors.iconColor,
                                      size: itemFontSize + 6,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            guideline.title,
                                            style:
                                                AppTextStyles.bodyText.copyWith(
                                              fontSize: itemFontSize,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textColor,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            guideline.description,
                                            style:
                                                AppTextStyles.bodyText.copyWith(
                                              fontSize: itemFontSize,
                                              color: AppColors.textColor
                                                  .withOpacity(0.85),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
        // Bottom-aligned button row
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: buildBottomButtonRow(
            onBack: onBackPressed,
            onNext: () async {
              // Show a standard confirmation dialog before proceeding
              await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    backgroundColor: Colors
                        .transparent, // Make Dialog background transparent
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment(0.8, 1),
                          colors: AppColors.gradientBackgroundList,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_user,
                                color: AppColors.iconColor, size: 48),
                            SizedBox(height: 16),
                            Text(
                              "Acknowledge Safety Guidelines",
                              style: AppTextStyles.titleText.copyWith(
                                fontSize: titleFontSize * 0.7,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 12),
                            Text(
                              "By proceeding, you acknowledge that you have read and understood the safety guidelines.",
                              style: AppTextStyles.bodyText.copyWith(
                                fontSize: bodyFontSize,
                                color: AppColors.textColor.withOpacity(0.8),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                      shadowColor: Colors.transparent,
                                    ),
                                    child: Text(
                                      'Cancel',
                                      style: AppTextStyles.buttonText.copyWith(
                                        fontSize: buttonFontSize,
                                        foreground: Paint()
                                          ..shader = LinearGradient(
                                            colors: AppColors
                                                .gradientBackgroundList,
                                          ).createShader(
                                            Rect.fromLTWH(0, 0, 200, 70),
                                          ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: AppColors.reversedGradientColor,
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                        await controller.register(
                                            controller.userRegistrationRequest);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors
                                            .transparent, // Transparent to show gradient
                                        padding:
                                            EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        elevation: 0,
                                        shadowColor: Colors.transparent,
                                      ),
                                      child: Text(
                                        'Acknowledge',
                                        style:
                                            AppTextStyles.buttonText.copyWith(
                                          fontSize: buttonFontSize,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            nextLabel: 'Acknowledge',
            backLabel: 'Back',
            nextEnabled: true,
            context: context,
          ),
        ),
      ],
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
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment(0.8, 1),
                colors: AppColors.gradientBackgroundList,
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Form Submitted',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your details have been submitted successfully!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'OK',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () async {
                        await controller
                            .register(controller.userRegistrationRequest);
                        Get.offAll(CombinedAuthScreen());
                      },
                      child: const Text(
                        'Next',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}

Widget buildBottomButtonRow({
  required VoidCallback onBack,
  required VoidCallback? onNext,
  required String nextLabel,
  required String backLabel,
  required bool nextEnabled,
  required BuildContext context,
}) {
  final screenWidth = MediaQuery.of(context).size.width;
  final isSmallScreen = screenWidth < 350;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        /// 🔙 Back Button
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.gradientBackgroundList,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: ElevatedButton(
              onPressed: onBack,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: AppColors.textColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                shadowColor: Colors.transparent,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: Text(
                backLabel,
                style: AppTextStyles.buttonText.copyWith(
                  fontSize: isSmallScreen ? 13 : screenWidth * 0.045,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        /// ⏭️ Next Button
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.reversedGradientColor,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: ElevatedButton(
              onPressed: nextEnabled ? onNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: AppColors.textColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                shadowColor: Colors.transparent,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: Text(
                nextLabel,
                style: AppTextStyles.buttonText.copyWith(
                  fontSize: isSmallScreen ? 13 : screenWidth * 0.045,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
