import 'dart:convert';
import 'dart:io';
import 'package:dating_application/Screens/login.dart';
import 'package:dating_application/constants.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    intialize();
  }

  intialize() async {
    await controller.fetchAllHeadlines();
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
                        color: Colors.redAccent,
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
                          date.value.isEmpty
                              ? 'Select Date of Birth'
                              : date.value.split(' ')[0],
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
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(nickname)) {
      failure('Nickname', 'Nickname must only contain letters.');
      return false;
    }
    return true;
  }

  // Step 2: Name Input
  Widget buildNameStep(Size screenSize) {
    double titleFontSize = screenSize.width * 0.065;
    double labelfontSize = screenSize.width * 0.035;
    double inputTextFontSize = screenSize.width * 0.04;
    TextEditingController nicknameController = TextEditingController(
      text: controller.userRegistrationRequest.nickname,
    );

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
                    color: Colors.redAccent,
                    fontSize: labelfontSize * 0.8,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 32),
                Text(
                  "Your Name",
                  style: AppTextStyles.labelText.copyWith(
                    fontSize: labelfontSize,
                    color: AppColors.textColor,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 8),
                TextField(
                  controller: nicknameController,
                  onChanged: (value) {
                    controller.userRegistrationRequest.nickname = value.trim();
                  },
                  decoration: InputDecoration(
                    hintText: "Enter your name",
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
          child: buildBottomButtonRow(
            onBack: onBackPressed,
            onNext: controller.userRegistrationRequest.nickname.isEmpty
                ? null
                : () {
                    if (controller.userRegistrationRequest.nickname.isEmpty) {
                      failure('Nickname', 'Enter Your Nickname');
                      return;
                    } else {
                      if (_validateNickname(
                          controller.userRegistrationRequest.nickname)) {
                        markStepAsCompleted(2);
                        Get.snackbar('nickname',
                            controller.userRegistrationRequest.nickname);
                        pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      }
                    }
                  },
            nextLabel: 'Next',
            backLabel: 'Back',
            nextEnabled: controller.userRegistrationRequest.nickname.isNotEmpty,
            context: context,
          ),
        ),
      ],
    );
  }

  // Step 3: Gender Selection
  Widget buildGenderStep(Size screenSize) {
    double titleFontSize = screenSize.width * 0.065;
    double optionFontSize = screenSize.width * 0.035;
    double buttonFontSize = screenSize.width * 0.045;

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
                        final isSelected = selectedGender.value?.id == gender.id;
                        return GestureDetector(
                          onTap: () {
                            selectedGender.value = gender;
                            controller.userRegistrationRequest.gender = gender.id;
                            controller.fetchSubGender(SubGenderRequest(genderId: gender.id));
                            // Force UI update for PageView (since Obx in PageView sometimes doesn't trigger setState)
                            setState(() {});
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? LinearGradient(
                                      colors: AppColors.gradientBackgroundList,
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
                                    gender.title,
                                    style: AppTextStyles.bodyText.copyWith(
                                      fontSize: optionFontSize,
                                      color: AppColors.textColor,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(Icons.check_circle, color: Colors.white)
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
        // Bottom-aligned button row
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Obx(() => buildBottomButtonRow(
            onBack: onBackPressed,
            onNext: selectedGender.value == null
                ? null
                : () {
                    if (selectedGender.value == null) {
                      failure('Failed', 'Please select an option to proceed.');
                    } else {
                      markStepAsCompleted(3);
                      Get.snackbar('gender', controller.userRegistrationRequest.gender.toString());
                      pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    }
                  },
            nextLabel: 'Next',
            backLabel: 'Back',
            nextEnabled: selectedGender.value != null,
            context: context,
          )),
        ),
      ],
    );
  }

  // Step 4: Describe Yourself (New Step)
  Widget buildBestDescribeYouStep(Size screenSize) {
    double titleFontSize = screenSize.width * 0.03;
    double descriptionFontSize = screenSize.width * 0.02;
    double optionFontSize = screenSize.width * 0.02;

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
                child: Scrollbar(
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
              ),
              SizedBox(height: 30),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                ElevatedButton(
                  onPressed: onBackPressed,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                    backgroundColor: AppColors.activeColor,
                    foregroundColor: AppColors.textColor,
                  ),
                  child: Text(
                    'Back',
                    style: AppTextStyles.buttonText.copyWith(
                      fontSize: screenSize.width * 0.02,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment(0.8, 1),
                      colors: AppColors.gradientBackgroundList,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ElevatedButton(
                    onPressed: selectedOption.value.isEmpty
                        ? null
                        : () {
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
                      padding:
                          EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                      backgroundColor: selectedOption.value.isEmpty
                          ? AppColors.disabled
                          : Colors.transparent,
                      foregroundColor: AppColors.textColor,
                    ),
                    child: Text(
                      'Next',
                      style: AppTextStyles.buttonText.copyWith(
                        fontSize: screenSize.width * 0.02,
                      ),
                    ),
                  ),
                ),
              ]),
              SizedBox(height: 10),
            ],
          ),
        ),
      );
    });
  }

// step 5 who are you looking for
  Widget buildLookingForStep(Size screenSize) {
    double titleFontSize = screenSize.width * 0.03;
    double descriptionFontSize = screenSize.width * 0.02;
    double optionFontSize = screenSize.width * 0.02;
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
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                ElevatedButton(
                  onPressed: onBackPressed,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 22),
                    backgroundColor: AppColors.activeColor,
                    foregroundColor: AppColors.textColor,
                  ),
                  child: Text('Back', style: AppTextStyles.textStyle),
                ),
                Container(
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
                          selectedPreferences.add(controller.preferences[i].id);
                        }
                      }

                      controller.userRegistrationRequest.preferences =
                          selectedPreferences;

                      if (selectedPreferences.isEmpty) {
                        failure(
                            'Failed', 'Please select at least one preference.');
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
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 22),
                      backgroundColor: preferencesSelectedOptions.isNotEmpty
                          ? Colors.transparent
                          : AppColors.disabled,
                      foregroundColor: AppColors.textColor,
                    ),
                    child: Text(
                      'Next',
                      style: AppTextStyles.textStyle,
                    ),
                  ),
                ),
              ]),
            ],
          ),
        ),
      );
    });
  }

// Step 6: Gender Identity Selection

  Widget buildRelationshipStatusInterestStep(
      BuildContext context, Size screenSize) {
    List<String> options = controller.categories
        .expand((category) => category.desires.map((desire) => desire.title))
        .toList();

    print(options.map((elem) => elem));

    controller.categories.map((category) => category.category).toList();
    if (selectedOptions.isEmpty || selectedOptions.length != options.length) {
      selectedOptions = List.filled(options.length, false).obs;
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
    }

    double screenWidth = screenSize.width;
    double titleFontSize = screenWidth * 0.03;
    double bodyFontSize = screenWidth * 0.02;
    double chipFontSize = screenWidth * 0.02;

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
                                    backgroundColor: AppColors.chipColor,
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
                        handleChipSelection(index); // Toggle selection
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Obx(() => Chip(
                              label: Text(options[index]),
                              backgroundColor: selectedOptions[index]
                                  ? AppColors.chipColor
                                  : AppColors.buttonColor,
                              labelStyle: TextStyle(
                                color: selectedOptions[index]
                                    ? Colors.white
                                    : AppColors.textColor,
                                fontSize: chipFontSize,
                              ),
                            )),
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
                                horizontal: 22, vertical: 12),
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
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                ElevatedButton(
                  onPressed: onBackPressed,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 22),
                    backgroundColor: AppColors.activeColor,
                    foregroundColor: AppColors.textColor,
                  ),
                  child: Text('Back', style: AppTextStyles.textStyle),
                ),
                Obx(() {
                  return selectedStatus.isNotEmpty
                      ? Align(
                          alignment: Alignment.centerRight,
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
                                markStepAsCompleted(6);
                                Get.snackbar(
                                    'desires',
                                    controller.userRegistrationRequest.desires
                                        .toString());
                                pageController.nextPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.ease,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
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
                          ),
                        )
                      : Container();
                }),
              ]),
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
      return selectedInterests.isNotEmpty && selectedInterests.length <= 6;
    }

    void updateUserInterests() {
      controller.userRegistrationRequest.interest =
          selectedInterests.join(', ');
    }

    void addInterest() {
      String newInterest = interestController.text.trim();
      if (newInterest.isNotEmpty && !selectedInterests.contains(newInterest)) {
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
    double titleFontSize = screenWidth * 0.03;
    double bodyFontSize = screenWidth * 0.02;
    double chipFontSize = screenWidth * 0.02;
    double inputFontSize = screenWidth * 0.02;
    double buttonFontSize = screenWidth * 0.02;

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
                    borderSide: BorderSide(color: AppColors.activeColor),
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
              // SizedBox(height: 20),
              // // Show the entered interest immediately (Text below TextField)
              // Text(
              //   interestController.text.isNotEmpty
              //       ? "You are adding: ${interestController.text}"
              //       : "",
              //   style: AppTextStyles.bodyText.copyWith(
              //     fontSize: bodyFontSize,
              //     fontStyle: FontStyle.italic,
              //     color: AppColors.textColor.withOpacity(0.7),
              //   ),
              // ),
              SizedBox(height: 20),

              // Add Interest button
              Container(
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
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                                    updateUserInterests();
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
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                ElevatedButton(
                  onPressed: onBackPressed,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 22),
                    backgroundColor: AppColors.activeColor,
                    foregroundColor: AppColors.textColor,
                  ),
                  child: Text('Back', style: AppTextStyles.textStyle),
                ),
                Obx(() {
                  return isSelectionValid()
                      ? Align(
                          alignment: Alignment.centerRight,
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
                                markStepAsCompleted(7);
                                Get.snackbar(
                                    'intrest',
                                    controller.userRegistrationRequest.interest
                                        .toString());
                                pageController.nextPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.ease,
                                );
                                controller.fetchlang();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: selectedInterests.isNotEmpty
                                    ? Colors.transparent
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
                          ),
                        )
                      : Container();
                }),
              ]),
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

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              return selectedLanguages.isEmpty
                  ? Center(child: Text("Please Select the Languages!!!!!!"))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Selected Languages',
                            style: TextStyle(fontSize: 8)),
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
                                  labelStyle: TextStyle(fontSize: 12),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    );
            }),
            SizedBox(height: 20),
            Text('Languages List', style: TextStyle(fontSize: 12)),
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
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.green, width: 2.0),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.white,
                                  width: 1.5), // Green border when not focused
                              borderRadius: BorderRadius.circular(20),
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
                                    fontSize: 12,
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
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              ElevatedButton(
                onPressed: onBackPressed,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 22),
                  backgroundColor: AppColors.activeColor,
                  foregroundColor: AppColors.textColor,
                ),
                child: Text('Back', style: AppTextStyles.buttonText),
              ),
              Align(
                alignment: Alignment.centerRight,
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
                      if (selectedLanguages.isEmpty) {
                        failure('Error', 'Please select at least one language');
                        Get.snackbar(
                            "lang", controller.language.length.toString());
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
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 22),
                      backgroundColor: Colors.transparent,
                      foregroundColor: AppColors.textColor,
                    ),
                    child: Text('Next'),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

// step 9
  RxString userDescription = ''.obs;
  final TextEditingController descriptionController = TextEditingController();
  Widget buildUserDescriptionStep(Size screenSize) {
    // bool isInputValid = true;
    void onDescriptionChanged(String value) {
      userDescription.value = value;
      controller.userRegistrationRequest.bio = value;
      // isInputValid = RegExp(r'^[a-zA-Z\s]*$').hasMatch(value);
    }

    double screenWidth = screenSize.width;
    double titleFontSize = screenWidth * 0.03;
    double bodyFontSize = screenWidth * 0.02;
    double inputFontSize = screenWidth * 0.02;
    double buttonFontSize = screenWidth * 0.02;

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
                    ? controller.headlines[7].description
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
                    borderSide: BorderSide(color: AppColors.activeColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.textColor),
                  ),
                  // errorText:
                  //     isInputValid ? null : 'Please enter only alphabets',
                ),
                style: TextStyle(
                  color: AppColors.textColor,
                  fontSize: inputFontSize,
                ),
                // inputFormatters: [
                //   FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                // ],
                cursorColor: AppColors.cursorColor,
                textInputAction: TextInputAction.done,
              ),
              SizedBox(height: 20),
              Obx(() {
                return Text(
                  '${userDescription.value.length} / 1000 characters',
                  style: AppTextStyles.bodyText.copyWith(
                    fontSize: bodyFontSize,
                    color: userDescription.value.length > 1000
                        ? Colors.red
                        : AppColors.textColor,
                  ),
                );
              }),
              SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                ElevatedButton(
                  onPressed: onBackPressed,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    backgroundColor: AppColors.activeColor,
                    foregroundColor: AppColors.textColor,
                  ),
                  child: Text(
                    'Back',
                    style: AppTextStyles.buttonText.copyWith(
                      fontSize: buttonFontSize,
                    ),
                  ),
                ),
                Obx(() {
                  return Container(
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
                        markStepAsCompleted(9);
                        Get.snackbar('bio',
                            controller.userRegistrationRequest.bio.toString());
                        pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                        // controller.register(controller.userRegistrationRequest);
                        print("User Description: ${userDescription.value}");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: userDescription.value.isNotEmpty &&
                                userDescription.value.length <= 1000
                            ? Colors.transparent
                            : AppColors.disabled,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: Text(
                        'Next',
                        style: AppTextStyles.buttonText.copyWith(
                          fontSize: buttonFontSize,
                        ),
                      ),
                    ),
                  );
                }),
              ]),
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
                fontSize: screenSize.width * 0.03,
                color: AppColors.textColor,
              ),
            ),
            content: Text(
              permissionType == 'notification'
                  ? "Do you allow the app to send notifications?"
                  : "Do you allow the app to access your location?",
              style: AppTextStyles.bodyText.copyWith(
                fontSize: screenSize.width * 0.03,
                color: AppColors.textColor,
              ),
            ),
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
                child: Text(
                  'Deny',
                  style: AppTextStyles.bodyText.copyWith(
                    color: Colors.red,
                    fontSize: screenSize.width * 0.02,
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
                    fontSize: screenSize.width * 0.02,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    double fontSize = screenSize.width * 0.02;

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
                        fontSize: fontSize,
                        color: AppColors.textColor,
                      ),
                    ),
                  ),
                  Obx(() {
                    return Text(
                      notificationGranted.value ? 'Granted' : 'Tap to Grant',
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: fontSize,
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
                        fontSize: fontSize,
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
                            ? AppColors.activeColor
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
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          ElevatedButton(
            onPressed: onBackPressed,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 22),
              backgroundColor: AppColors.disabled,
              foregroundColor: AppColors.textColor,
            ),
            child: Text(
              'Back',
              style: AppTextStyles.buttonText.copyWith(
                fontSize: fontSize,
              ),
            ),
          ),
          Obx(() {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment(0.8, 1),
                  colors: AppColors.gradientBackgroundList,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: ElevatedButton(
                onPressed: notificationGranted.value && locationGranted.value
                    ? () {
                        markStepAsCompleted(10);
                        Get.snackbar(
                            'permission',
                            controller.userRegistrationRequest.emailAlerts
                                .toString());
                        pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.ease,
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      notificationGranted.value && locationGranted.value
                          ? Colors.transparent
                          : Colors.grey,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text('Next',
                    style: AppTextStyles.buttonText.copyWith(
                      fontSize: fontSize,
                    )),
              ),
            );
          }),
        ]),
        SizedBox(height: 20),
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
          controller.userRegistrationRequest.photos.length <= index) {
        // Get.snackbar(
        //     "Error", "Please take a photo for the previous position first.");
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
          if (index < controller.userRegistrationRequest.photos.length) {
            controller.userRegistrationRequest.photos[index] = base64Image;
          } else {
            controller.userRegistrationRequest.photos.add(base64Image);
          }

          images[index] = imageFile;
        } else {
          // Get.snackbar("Error", "Image compression failed");
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
    double iconSize = screenWidth * 0.10;
    double imageContainerSize = screenWidth * 0.39;
    resetImagesForNewUser();

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Wrap the entire Column with SingleChildScrollView
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
              Obx(() {
                return GridView.builder(
                  shrinkWrap:
                      true, // Use shrinkWrap to make the GridView take only the space it needs
                  physics:
                      NeverScrollableScrollPhysics(), // Disable GridView scrolling when inside SingleChildScrollView
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
                    bool isIndexEditable = (index == 0 ||
                        (index > 0 && images[index - 1] != null));

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
                                    onTap: isIndexEditable
                                        ? () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                      'Pick an image'),
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              AppColors
                                                                  .favouriteColor,
                                                          foregroundColor:
                                                              AppColors
                                                                  .textColor,
                                                        ),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                          pickImage(
                                                              index,
                                                              ImageSource
                                                                  .camera);
                                                        },
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                                Icons
                                                                    .camera_alt,
                                                                color: AppColors
                                                                    .favouriteColor),
                                                            SizedBox(width: 8),
                                                            Text(
                                                              "Camera",
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontStyle:
                                                                    AppTextStyles
                                                                        .bodyText
                                                                        .fontStyle,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              AppColors
                                                                  .favouriteColor,
                                                          foregroundColor:
                                                              AppColors
                                                                  .textColor,
                                                        ),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                          pickImage(
                                                              index,
                                                              ImageSource
                                                                  .gallery);
                                                        },
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons.photo,
                                                                color: AppColors
                                                                    .favouriteColor),
                                                            const SizedBox(
                                                                width: 8),
                                                            Text(
                                                              "Gallery",
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontStyle:
                                                                    AppTextStyles
                                                                        .bodyText
                                                                        .fontStyle,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          }
                                        : null,
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
                                                  onPressed: isIndexEditable
                                                      ? () {
                                                          Navigator.pop(
                                                              context);
                                                          pickImage(
                                                              index,
                                                              ImageSource
                                                                  .camera);
                                                        }
                                                      : null,
                                                  child: const Row(
                                                    children: [
                                                      Icon(Icons.camera_alt),
                                                      SizedBox(width: 8),
                                                      Text("Camera"),
                                                    ],
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  onPressed: isIndexEditable
                                                      ? () {
                                                          Navigator.pop(
                                                              context);
                                                          pickImage(
                                                              index,
                                                              ImageSource
                                                                  .gallery);
                                                        }
                                                      : null,
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
                              onPressed: isIndexEditable
                                  ? () {
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
                                    }
                                  : null,
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
              SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                ElevatedButton(
                  onPressed: onBackPressed,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 22),
                    backgroundColor: AppColors.activeColor,
                    foregroundColor: AppColors.textColor,
                  ),
                  child: Text('Back',
                      style: AppTextStyles.buttonText.copyWith(
                        color: AppColors.primaryColor,
                      )),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment(0.8, 1),
                      colors: AppColors.gradientBackgroundList,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ElevatedButton(
                    onPressed: onNextButtonPressed,
                    style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 22),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor:
                            controller.userRegistrationRequest.photos.isNotEmpty
                                ? Colors.transparent
                                : AppColors.inactiveColor),
                    child: Text("Next",
                        style: AppTextStyles.buttonText.copyWith(
                          color: AppColors.primaryColor,
                        )),
                  ),
                ),
              ]),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

// step 12
  Widget buildSafetyGuidelinesWidget(Size screenSize) {
    double fontSize = screenSize.width * 0.02;

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
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            ElevatedButton(
              onPressed: onBackPressed,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 22),
                backgroundColor: AppColors.activeColor,
                foregroundColor: AppColors.textColor,
              ),
              child: Text(
                'Back',
                style: AppTextStyles.buttonText.copyWith(
                  fontSize: fontSize,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: nextStep,
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
          ]),
          SizedBox(height: 10),
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

Widget buildBottomButtonRow({
  required VoidCallback onBack,
  required VoidCallback? onNext,
  required String nextLabel,
  required String backLabel,
  required bool nextEnabled,
  required BuildContext context,
}) {
  final screenWidth = MediaQuery.of(context).size.width;
  return Padding(
    padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16, top: 8),
    child: Row(
      children: [
        SizedBox(
          width: screenWidth * 0.42,
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
              onPressed: onBack,
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
                backLabel,
                style: AppTextStyles.buttonText.copyWith(
                  fontSize: screenWidth * 0.045,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.09),
        SizedBox(
          width: screenWidth * 0.42,
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
              onPressed: nextEnabled ? onNext : null,
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
                nextLabel,
                style: AppTextStyles.buttonText.copyWith(
                  fontSize: screenWidth * 0.045,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
