import 'dart:io';
import 'package:dating_application/Screens/register_subpag/registrationotp.dart';
import 'package:dating_application/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

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
                    controller:
                        pageController, 
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


    double titleFontSize =
        screenSize.width * 0.05; 
    double subHeadingFontSize =
        screenSize.width * 0.045;
    double datePickerFontSize =
        screenSize.width * 0.05;

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

            Text(
              "What is your date of birth?",
              style: AppTextStyles.titleText.copyWith(
                fontSize: titleFontSize, 
              ),
            ),
            SizedBox(height: 40),

            Text(
              "You must be 18+ to use this app.",
              style: AppTextStyles.bodyText.copyWith(
                color:
                    Colors.redAccent, 
                fontSize: subHeadingFontSize, 
              ),
            ),
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
                Text("",
                    style: AppTextStyles
                        .bodyText), 
                SizedBox(width: 8),
                buildDatePicker("Month", 1, 12, selectedMonth, (value) {
                  setState(() {
                    selectedMonth = value;
                  });
                }),
                SizedBox(width: 20),
                Text('',
                    style: AppTextStyles
                        .bodyText), 
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
                      style: AppTextStyles
                          .bodyText,
                    ),
                    backgroundColor: Colors.red,
                  ));
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                backgroundColor:
                    AppColors.buttonColor,
                foregroundColor: AppColors.textColor, 
              ),
              child: Text('Next',
                  style:
                      AppTextStyles.buttonText), 
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
            "What do we call you?",
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
  List<String> genderOptions = ['Male', 'Female', 'Non-Binary'];
  Rx<int> selectedGenderIndex =
      Rx<int>(-1);

 
  double titleFontSize = screenSize.width * 0.05; 
  double optionfontSize = screenSize.width * 0.03; 

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
            "Select your gender",
            style: AppTextStyles.titleText.copyWith(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor, 
            ),
          ),
          SizedBox(height: 20),


          Obx(() {
            return Column(
              children: List.generate(genderOptions.length, (index) {
                return RadioListTile<int>(
                  title: Text(
                    genderOptions[index],
                    style: AppTextStyles.bodyText.copyWith(
                      fontSize: optionfontSize, 
                      color: AppColors.textColor, 
                    ),
                  ),
                  value: index,
                  groupValue: selectedGenderIndex.value,
                  onChanged: (int? value) {
                    selectedGenderIndex.value = value ?? -1;
                  },
                  activeColor: AppColors.buttonColor,
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
 Widget buildBestDescribeYouStep(Size screenSize) {

  RxString selectedOption = ''.obs;

  List<String> options = [
    'Pansexual',
    'Polysexual',
    'Bisexual',
    'Asexual',
    'Other'
  ];

  double titleFontSize = screenSize.width * 0.05; 
  double descriptionfontSize = screenSize.width * 0.03; 
  double optionfontSize = screenSize.width * 0.03;

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
            "Which Best Describe You",
            style: AppTextStyles.titleText.copyWith(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          SizedBox(height: 20),

          Text(
            "Select the option that best describes your identity.",
            style: AppTextStyles.bodyText.copyWith(
              fontSize: descriptionfontSize,
              color: AppColors.textColor, 
            ),
          ),
          SizedBox(height: 20),

          Obx(() {
            return Column(
              children: List.generate(options.length, (index) {
                return RadioListTile<String>(
                  title: Text(
                    options[index],
                    style: AppTextStyles.bodyText.copyWith(
                      fontSize: optionfontSize, 
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
            );
          }),
        ],
      ),
    ),
  );
}

// step 5 who are you looking for
  Widget buildLookingForStep(Size screenSize) {

  RxList<bool> selectedOptions = [false, false, false, false, false].obs;
  List<String> options = ['Men', 'Women', 'Men+MenCouple', 'Agender', 'Both'];
  double titleFontSize = screenSize.width * 0.05; 
  double descriptionfontSize = screenSize.width * 0.03; 
  double optionfontSize = screenSize.width * 0.03; 
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
            "Who are you looking for?",
            style: AppTextStyles.titleText.copyWith(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor, 
            ),
          ),
          SizedBox(height: 20),
          Text(
            "Select the gender(s) you're interested in.",
            style: AppTextStyles.bodyText.copyWith(
              fontSize: descriptionfontSize, 
              color: AppColors.textColor,
            ),
          ),
          SizedBox(height: 20),
          Obx(() {
            return Column(
              children: List.generate(options.length, (index) {
                return CheckboxListTile(
                  title: Text(
                    options[index],
                    style: AppTextStyles.bodyText.copyWith(
                      fontSize: optionfontSize, 
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
              }),
            );
          }),
        ],
      ),
    ),
  );
}

// Step 6: Gender Identity Selection
  Widget buildRelationshipStatusInterestStep(BuildContext context, Size screenSize) {
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
              "Relationship",
              style: AppTextStyles.titleText.copyWith(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Let people know what you are into. You can add or edit desires as often as you want.",
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
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
              "What are your interests?",
              style: AppTextStyles.titleText.copyWith(
                fontSize: titleFontSize, 
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Enter your interests one by one. Select at least 10.",
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
              style: TextStyle(color: AppColors.textColor, fontSize: inputFontSize),
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
                        onPressed: () {
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.acceptColor, 
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
              "Tell Us About You",
              style: AppTextStyles.titleText.copyWith(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Describe yourself in 250 words or less.",
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
              style: TextStyle(color: AppColors.textColor, fontSize: inputFontSize), 
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
  double dialogButtonFontSize = screenWidth * 0.04;
  double imageContainerSize = screenWidth * 0.4;

  return Scaffold(
    body: Obx(() {
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
                                            pickImage(index, ImageSource.camera);
                                          },
                                          child: const Icon(Icons.camera_alt),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            pickImage(index, ImageSource.gallery);
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
                                            pickImage(index, ImageSource.camera);
                                          },
                                          child: const Icon(Icons.camera_alt),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            pickImage(index, ImageSource.gallery);
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
                "Permissions",
                style: AppTextStyles.titleText.copyWith(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              SizedBox(height: 10),
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
                    value: selectedService.value == 'None' ? null : selectedService.value,
                    hint: Text(
                      "Click to know what we offer",
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: fontSize - 6,
                        color: AppColors.textColor.withOpacity(0.6),
                      ),
                    ),
                    icon: Icon(Icons.arrow_drop_down, color: AppColors.iconColor),
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                      }
                    },
                    items: <String>[
                      'Send Ping',
                      'Chatting',
                      'Filter by Desire',
                      'Other Services'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: AppTextStyles.bodyText.copyWith(
                            fontSize: fontSize - 6,
                            color: AppColors.textColor,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }),
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
                          selectedPlan.value == 'Monthly' ? 'Selected' : 'Select',
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
            showPaymentConfirmationDialog(context, 'Quarterly', '₹599/3 months');
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
                          selectedPlan.value == 'Quarterly' ? 'Selected' : 'Select',
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
                          selectedPlan.value == 'Yearly' ? 'Selected' : 'Select',
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
  // Calculate responsive font size based on screen width
  double fontSize = screenSize.width * 0.03; // You can adjust 0.05 to make it larger/smaller
  
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
            foregroundColor: AppColors.textColor, // Consistent button text color
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
  // Calculate responsive font size based on screen width
  double fontSize = screenSize.width * 0.03; // You can adjust 0.05 to fit the design needs
  
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
                  backgroundImage: AssetImage('assets/profile_picture.jpg'), // Example image
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
                  fontSize: fontSize, // Apply the responsive font size to the button text
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
  // Calculate responsive font size based on screen width
  double fontSize = screenSize.width * 0.03; // Adjust multiplier as needed
  
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      // Icon with fixed size
      Icon(
        icon,
        color: Colors.blueAccent,
        size: fontSize, // Make the icon size responsive as well
      ),
      SizedBox(width: 12),
      Expanded(
        child: Text(
          "$label: $value",
          style: TextStyle(
            fontSize: fontSize, // Apply the responsive font size
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
                  Get.to(OTPVerificationPage());
                },
                child: Text('Next'))
          ],
        ),
      );
    }
  }
}
