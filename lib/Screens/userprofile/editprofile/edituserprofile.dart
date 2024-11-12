import 'package:flutter/material.dart';
import '../../../constants.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  List<String> photos = [
    'assets/images/image1.jpg',
    'assets/images/image1.jpg',
    'assets/images/image1.jpg',
    'assets/images/image1.jpg',
  ];

  TextEditingController userNameController = TextEditingController(text: "John Doe");
  TextEditingController dobController = TextEditingController(text: "1990-01-01");
  TextEditingController genderController = TextEditingController(text: "Male");
  TextEditingController sexualityController = TextEditingController(text: "Straight");
  TextEditingController aboutController = TextEditingController(text: "Love outdoor adventures, books, and music.");
  List<String> desires = ["Travel", "Fitness"];
  TextEditingController interestsController = TextEditingController(text: "Hiking, Cooking, Reading");

  bool hideMeOnFlame = true;
  bool incognitoMode = false;
  bool optOutOfPingNote = true;

  final TextEditingController desireController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photos Section with Floating Action Buttons
              Stack(
                children: [
                  Card(
                    color: AppColors.secondaryColor,
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Photos", style: AppTextStyles.subheadingText),
                          SizedBox(height: 6),
                          Container(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: photos.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.asset(
                                      photos[index],
                                      fit: BoxFit.cover,
                                      height: 120,
                                      width: double.infinity,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              // Navigate to edit photos page
                              Navigator.push(context, MaterialPageRoute(builder: (_) => EditPhotosPage()));
                            },
                            icon: Icon(Icons.edit, color: AppColors.iconColor),
                            label: Text('Edit Photos', style: AppTextStyles.buttonText.copyWith(color: AppColors.iconColor)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Row(
                      children: [
                        // Preview button
                        FloatingActionButton.extended(
                          onPressed: () {
                            // Preview action here
                          },
                          backgroundColor: AppColors.buttonColor,
                          icon: Icon(Icons.visibility, color: AppColors.textColor),
                          label: Text('Preview', style: AppTextStyles.buttonText),
                        ),
                        SizedBox(width: 16),
                        // Save button
                        FloatingActionButton.extended(
                          onPressed: () {
                            // Save action here
                          },
                          backgroundColor: AppColors.buttonColor,
                          icon: Icon(Icons.save, color: AppColors.textColor),
                          label: Text('Save', style: AppTextStyles.buttonText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Editable User Info Cards
              InfoField(
                label: 'Name',
                controller: userNameController,
              ),
              InfoField(
                label: 'Date of Birth',
                controller: dobController,
              ),
              InfoField(
                label: 'Gender',
                controller: genderController,
              ),
              InfoField(
                label: 'Sexuality',
                controller: sexualityController,
              ),
              InfoField(
                label: 'About',
                controller: aboutController,
              ),
              InfoField(
                label: 'Interests',
                controller: interestsController,
              ),

              // Desires Section with Chips
              Card(
                color: AppColors.secondaryColor,
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Desires", style: AppTextStyles.subheadingText),
                      SizedBox(height: 10),
                      Wrap(
                        spacing: 8.0,
                        children: desires.map((desire) => Chip(
                          label: Text(desire, style: AppTextStyles.bodyText),
                          backgroundColor: AppColors.chipColor,
                        )).toList(),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: desireController,
                              cursorColor: AppColors.cursorColor, // White cursor color
                              decoration: InputDecoration(
                                labelText: 'Add Desire',
                                labelStyle: AppTextStyles.buttonText,
                                filled: true,
                                fillColor: AppColors.formFieldColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add, color: AppColors.iconColor),
                            onPressed: () {
                              if (desireController.text.isNotEmpty) {
                                setState(() {
                                  desires.add(desireController.text);
                                  desireController.clear();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Privacy Settings
              Card(
                color: AppColors.secondaryColor,
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Privacy Settings", style: AppTextStyles.subheadingText),
                      SizedBox(height: 10),
                      PrivacyToggle(
                        label: "Hide me on Flame",
                        value: hideMeOnFlame,
                        onChanged: (val) => setState(() => hideMeOnFlame = val),
                      ),
                      SizedBox(height: 10),
                      PrivacyToggle(
                        label: "Incognito Mode",
                        value: incognitoMode,
                        onChanged: (val) => setState(() => incognitoMode = val),
                      ),
                      SizedBox(height: 10),
                      PrivacyToggle(
                        label: "Opt out of Ping + Note",
                        value: optOutOfPingNote,
                        onChanged: (val) => setState(() => optOutOfPingNote = val),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Widget for User Info
class InfoField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  InfoField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.secondaryColor,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.buttonText),
            SizedBox(height: 10),
            TextField(
              controller: controller,
              cursorColor: AppColors.cursorColor, // White cursor color
              style: AppTextStyles.bodyText,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.formFieldColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            Divider(color: AppColors.textColor),
          ],
        ),
      ),
    );
  }
}

// Privacy Toggle Widget
class PrivacyToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  PrivacyToggle({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyText),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.activeColor,
          inactiveThumbColor: AppColors.inactiveColor,
        ),
      ],
    );
  }
}

// Edit Photos Page (Placeholder)
class EditPhotosPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Photos')),
      body: Center(child: Text('Edit your photos here')),
    );
  }
}