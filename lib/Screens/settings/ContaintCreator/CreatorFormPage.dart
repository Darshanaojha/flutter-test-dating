import 'dart:io';
import 'package:dating_application/Models/ResponseModels/creators_generic_response.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';

import '../../../constants.dart';
import '../../../Controllers/controller.dart';
import 'ContaintCreatorList/ContaintCreatorList.dart';
import 'CreatorHomesScreen.dart';

class CreatorFormPage extends StatefulWidget {
  const CreatorFormPage({super.key});

  @override
  State<CreatorFormPage> createState() => _CreatorFormPageState();
}

class _CreatorFormPageState extends State<CreatorFormPage> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  // Use Get.find to get the existing controller instance
  final Controller controller = Get.put(Controller());

  CreatorGeneric? selectedGeneric;

  File? profileImage;
  File? bannerImage;
  String monetizationType = 'Subscription';

  @override
  void initState() {
    super.initState();
    controller.fetchAllCreatorGeneric();
  }

  Future<void> pickImageBottomSheet(bool isProfile) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff1a1a1a),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFFFF1694)),
              title: Text(
                "Take a Photo",
                style: AppTextStyles.bodyText.copyWith(
                  fontSize: getResponsiveFontSize(0.03),
                  color: Colors.white,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                final picked =
                    await ImagePicker().pickImage(source: ImageSource.camera);
                if (picked != null) {
                  setState(() {
                    isProfile
                        ? profileImage = File(picked.path)
                        : bannerImage = File(picked.path);
                  });
                }
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.photo_library, color: Color(0xFFFF1694)),
              title: Text(
                "Choose from Gallery",
                style: AppTextStyles.bodyText.copyWith(
                  fontSize: getResponsiveFontSize(0.03),
                  color: Colors.white,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                final picked =
                    await ImagePicker().pickImage(source: ImageSource.gallery);
                if (picked != null) {
                  setState(() {
                    isProfile
                        ? profileImage = File(picked.path)
                        : bannerImage = File(picked.path);
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  double getResponsiveFontSize(double scale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * scale;
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 600;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 2,
        title: Text(
          "🎨 Creator Setup",
          style: AppTextStyles.bodyText.copyWith(
            fontSize: getResponsiveFontSize(0.03),
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Wrap(
                    spacing: isWide ? 20 : 0,
                    runSpacing: 20,
                    children: [
                      _buildLabeledField("Package Title", titleController,
                          icon: FontAwesomeIcons.penNib),
                      _buildGenericPickerField(context),
                      _buildLabeledField("Description", descriptionController,
                          maxLines: 4, icon: FontAwesomeIcons.alignLeft),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Row(
                    children: [
                      const Icon(FontAwesomeIcons.moneyBill,
                          color: Color(0xFFFF1694), size: 18),
                      const SizedBox(width: 10),
                      Text('Monetization Model',
                          style: textTheme.bodyLarge
                              ?.copyWith(color: Colors.white70)),
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 30),
                  _buildRadioPayment(),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  // _buildImagePicker("Creator Avatar", profileImage,
                  //     () => pickImageBottomSheet(true)),
                  // SizedBox(
                  //   height: MediaQuery.of(context).size.height * 0.01,
                  // ),
                  // _buildImagePicker("Banner Image", bannerImage,
                  //     () => pickImageBottomSheet(false)),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  _buildGradientButton("🚀 Submit Package", () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                          'Creator package submitted!',
                          style: AppTextStyles.bodyText.copyWith(
                            fontSize: getResponsiveFontSize(0.03),
                            color: Colors.white,
                          ),
                        )),
                      );
                      Get.to(CreatorHomeScreen());
                      Get.to(CreatorListPage());
                    }
                  }),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabeledField(String label, TextEditingController controller,
      {int maxLines = 1, IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        cursorColor: const Color(0xFFFF1694),
        style: AppTextStyles.bodyText.copyWith(
          fontSize: getResponsiveFontSize(0.03),
          color: Colors.white,
        ),
        validator: (value) => value == null || value.trim().isEmpty
            ? 'Please enter $label'
            : null,
        decoration: InputDecoration(
          prefixIcon: icon != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 12, right: 8),
                  child: Icon(icon, color: Colors.white60, size: 20),
                )
              : null,
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: const Color(0xff1a1a1a),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.white12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFFF1694), width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildGenericPickerField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: GestureDetector(
        onTap: () async {
          if (controller.creatorGeneric.isEmpty) {
            await controller.fetchAllCreatorGeneric();
          }
          final picked = await showModalBottomSheet<CreatorGeneric>(
            context: context,
            backgroundColor: const Color(0xff1a1a1a),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) {
              // Use GetX builder to listen for changes
              return GetBuilder<Controller>(
                init: controller,
                builder: (_) {
                  return ListView(
                    shrinkWrap: true,
                    children: controller.creatorGeneric.map((generic) {
                      return ListTile(
                        title: Text(
                          generic.title,
                          style: AppTextStyles.bodyText.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context, generic);
                        },
                      );
                    }).toList(),
                  );
                },
              );
            },
          );
          if (picked != null) {
            setState(() {
              selectedGeneric = picked;
            });
          }
        },
        child: AbsorbPointer(
          child: TextFormField(
            readOnly: true,
            validator: (value) =>
                selectedGeneric == null ? 'Please select a category' : null,
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: Icon(FontAwesomeIcons.tags,
                    color: Colors.white60, size: 20),
              ),
              labelText: "Category",
              labelStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: const Color(0xff1a1a1a),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Colors.white12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: Color(0xFFFF1694), width: 1.5),
              ),
              hintText: selectedGeneric?.title ?? "Select Category",
              hintStyle: AppTextStyles.bodyText.copyWith(
                color: Colors.white,
              ),
            ),
            style: AppTextStyles.bodyText.copyWith(
              fontSize: getResponsiveFontSize(0.03),
              color: Colors.white,
            ),
            controller:
                TextEditingController(text: selectedGeneric?.title ?? ""),
          ),
        ),
      ),
    );
  }

  Widget _buildRadioPayment() {
    return Column(
      children: ['Subscription', 'Pay-Per-View', 'Tips Only'].map((label) {
        return RadioListTile(
          value: label,
          groupValue: monetizationType,
          activeColor: const Color(0xFFFF1694),
          onChanged: (value) =>
              setState(() => monetizationType = value.toString()),
          title: Text(
            label,
            style: AppTextStyles.bodyText.copyWith(
              fontSize: getResponsiveFontSize(0.03),
              color: Colors.white,
            ),
          ),
          contentPadding: EdgeInsets.zero,
        );
      }).toList(),
    );
  }

  

  Widget _buildGradientButton(String text, VoidCallback onPressed) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff870160),
            Color(0xffac255e),
            Color(0xfff39060),
            Color(0xfffffb56b),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.pinkAccent.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: AppTextStyles.bodyText.copyWith(
            fontSize: getResponsiveFontSize(0.03),
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
