
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';


// class CleanBlackFormPage extends StatefulWidget {
//   const CleanBlackFormPage({super.key});

//   @override
//   State<CleanBlackFormPage> createState() => _CleanBlackFormPageState();
// }

// class _CleanBlackFormPageState extends State<CleanBlackFormPage> {
//   final _formKey = GlobalKey<FormState>();

//   final TextEditingController usernameController = TextEditingController();
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController bioController = TextEditingController();

//   File? profileImage;
//   File? bannerImage;
//   String paymentMode = 'One-Time Platform Fee';

//   Future<void> pickImageBottomSheet(bool isProfile) async {
//     await showModalBottomSheet(
//       context: context,
//       backgroundColor: const Color(0xff212122),
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) {
//         return Wrap(
//           children: [
//             ListTile(
//               leading: const Icon(Icons.camera_alt, color: Color(0xFFFF1694)),
//               title: const Text("Take a Photo", style: TextStyle(color: Colors.white)),
//               onTap: () async {
//                 Navigator.pop(context);
//                 final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
//                 if (pickedFile != null) {
//                   setState(() {
//                     isProfile ? profileImage = File(pickedFile.path) : bannerImage = File(pickedFile.path);
//                   });
//                 }
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.photo_library, color: Color(0xFFFF1694)),
//               title: const Text("Choose from Gallery", style: TextStyle(color: Colors.white)),
//               onTap: () async {
//                 Navigator.pop(context);
//                 final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
//                 if (pickedFile != null) {
//                   setState(() {
//                     isProfile ? profileImage = File(pickedFile.path) : bannerImage = File(pickedFile.path);
//                   });
//                 }
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         elevation: 0,
//         title: const Text(
//           "Creator's Profile Setup",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Get.back(),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildLabeledField("Username", usernameController, icon: FontAwesomeIcons.user),
//               _buildLabeledField("Name", nameController, icon: FontAwesomeIcons.idBadge),
//               _buildLabeledField("Bio", bioController, maxLines: 3, icon: FontAwesomeIcons.penToSquare),
//               const SizedBox(height: 30),
//               const Text(
//                 'Payment Mode',
//                 style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),
//               ),
//               const SizedBox(height: 10),
//               _buildRadioPayment(),
//               const SizedBox(height: 30),
//               _buildImagePicker('Profile Image', profileImage, () => pickImageBottomSheet(true)),
//               const SizedBox(height: 16),
//               _buildImagePicker('Banner Image', bannerImage, () => pickImageBottomSheet(false)),
//               const SizedBox(height: 30),
//               // _buildGradientButton('Submit', ()
//               // {
//               //   if (_formKey.currentState!.validate()) {
//               //     // Optionally show a snackbar
//               //     ScaffoldMessenger.of(context).showSnackBar(
//               //       const SnackBar(content: Text('Form submitted!')),
//               //     );
//               //     // Navigate to the CreatorsHomeScreen
//               //     Get.off(() => const CreatorsHomeScreen());
//               //   }
//               // }),


//               _buildGradientButton('Submit', () {
//                 if (_formKey.currentState!.validate()) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Form submitted!')),
//                   );

//                   Get.off(() => CreatorsHomeScreen(
//                     username: usernameController.text,
//                     name: nameController.text,
//                     bio: bioController.text,
//                     paymentMode: paymentMode,
//                     profileImage: profileImage,
//                     bannerImage: bannerImage,
//                   ));
//                 }
//               }),



//               const SizedBox(height: 50),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildLabeledField(String label, TextEditingController controller,
//       {int maxLines = 1, IconData? icon}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: TextFormField(
//         controller: controller,
//         maxLines: maxLines,
//         cursorColor: const Color(0xFFFF1694),
//         style: const TextStyle(color: Colors.white),
//         validator: (value) {
//           if (value == null || value.trim().isEmpty) {
//             return 'Please enter your $label';
//           }
//           return null;
//         },
//         decoration: InputDecoration(
//           prefixIcon: icon != null
//               ? Padding(
//             padding: const EdgeInsets.only(left: 12, right: 8),
//             child: Icon(icon, color: Colors.white70, size: 20),
//           )
//               : null,
//           prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
//           labelText: label,
//           labelStyle: const TextStyle(color: Colors.white70),
//           filled: true,
//           fillColor: Colors.black,
//           contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: Colors.white),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: Colors.white),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12),
//             borderSide: const BorderSide(color: Color(0xFFFF1694), width: 1.5),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildRadioPayment() {
//     return Column(
//       children: [
//         RadioListTile(
//           value: 'One-Time Platform Fee',
//           groupValue: paymentMode,
//           activeColor: const Color(0xFFFF1694),
//           onChanged: (value) => setState(() => paymentMode = value.toString()),
//           title: const Text('One-Time Platform Fee', style: TextStyle(color: Colors.white)),
//         ),
//         RadioListTile(
//           value: 'Commission Based',
//           groupValue: paymentMode,
//           activeColor: const Color(0xFFFF1694),
//           onChanged: (value) => setState(() => paymentMode = value.toString()),
//           title: const Text('Commission Based', style: TextStyle(color: Colors.white)),
//         ),
//       ],
//     );
//   }

//   Widget _buildImagePicker(String label, File? image, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 160,
//         width: double.infinity,
//         decoration: BoxDecoration(
//           color: Colors.transparent,
//           border: Border.all(color: Colors.white, width: 1),
//           borderRadius: BorderRadius.circular(14),
//         ),
//         child: image != null
//             ? ClipRRect(
//           borderRadius: BorderRadius.circular(14),
//           child: Image.file(image, fit: BoxFit.cover, width: double.infinity),
//         )
//             : Center(
//           child: Text(
//             'Tap to upload $label',
//             style: const TextStyle(color: Colors.white54),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildGradientButton(String text, VoidCallback onPressed) {
//     return Container(
//       width: double.infinity,
//       height: 60,
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [
//             Color(0xff1f005c),
//             Color(0xff5b0060),
//             Color(0xff870160),
//             Color(0xffac255e),
//             Color(0xffca485c),
//             Color(0xffe16b5c),
//             Color(0xfff39060),
//             Color(0xfffffb56b),
//           ],
//           begin: Alignment.centerLeft,
//           end: Alignment.centerRight,
//         ),
//         borderRadius: BorderRadius.circular(50),
//       ),
//       child: TextButton(
//         onPressed: onPressed,
//         child: const Padding(
//           padding: EdgeInsets.symmetric(vertical: 14),
//           child: Text(
//             'Submit',
//             style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
//           ),
//         ),
//       ),
//     );
//   }
// }