// // import 'package:chatappgx/controller/postcontroller.dart';
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// //
// //
// // class UploadPostScreen extends StatelessWidget {
// //   final TextEditingController captionController = TextEditingController();
// //   final PostController postController = Get.find();
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text("Upload Post")),
// //       body: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: Column(
// //           children: [
// //
// //             Container(
// //               height: 200,
// //               width: double.infinity,
// //               color: Colors.grey[300],
// //               child: Center(child: Text("Image Preview Here")),
// //             ),
// //             SizedBox(height: 20),
// //             TextField(
// //               controller: captionController,
// //               decoration: InputDecoration(
// //                 labelText: "Caption",
// //                 border: OutlineInputBorder(),
// //               ),
// //             ),
// //             Spacer(),
// //             ElevatedButton(
// //               onPressed: () {
// //                 postController.addPost("https://via.placeholder.com/200", captionController.text);
// //                 Get.back(); // Go back to PostLibraryScreen
// //               },
// //               child: Text("Upload"),
// //             )
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// /*

// import 'dart:io';

// import 'package:chatappgx/controller/postcontroller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';

// class UploadPostScreen extends StatefulWidget {
//   @override
//   State<UploadPostScreen> createState() => _UploadPostScreenState();
// }

// class _UploadPostScreenState extends State<UploadPostScreen> {
//   final TextEditingController captionController = TextEditingController();
//   final PostController postController = Get.find();

//   File? selectedMedia;
//   bool isVideo = false;

//   final ImagePicker _picker = ImagePicker();

//   @override
//   void initState() {
//     super.initState();
//     // Open gallery immediately when the screen opens
//     Future.delayed(Duration.zero, () => pickMediaFromGallery());
//   }

//   Future<void> pickMediaFromGallery() async {
//     final XFile? media = await _picker.pickImage(source: ImageSource.gallery);

//     if (media != null) {
//       setState(() {
//         selectedMedia = File(media.path);
//         isVideo = media.mimeType?.startsWith("video") ?? false;
//       });
//     } else {
//       Get.back(); // Close if user cancels picker
//     }
//   }

//   Future<void> captureFromCamera() async {
//     final XFile? captured = await _picker.pickImage(source: ImageSource.camera);
//     if (captured != null) {
//       setState(() {
//         selectedMedia = File(captured.path);
//         isVideo = captured.mimeType?.startsWith("video") ?? false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: selectedMedia == null ? Colors.white : Colors.black,
//       body: selectedMedia == null
//           ? Center(child: CircularProgressIndicator())
//           : Stack(
//         children: [
//           Positioned.fill(
//             child: isVideo
//                 ? Center(child: Icon(Icons.videocam, color: Colors.white, size: 100))
//                 : Image.file(selectedMedia!, fit: BoxFit.contain),
//           ),
//           Positioned(
//             top: 40,
//             left: 20,
//             child: IconButton(
//               icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
//               onPressed: () => Get.back(),
//             ),
//           ),
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               color: Colors.black.withOpacity(0.9),
//               padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: captionController,
//                           style: TextStyle(color: Colors.white),
//                           decoration: InputDecoration(
//                             hintText: 'Write a caption...',
//                             hintStyle: TextStyle(color: Colors.grey[400]),
//                             filled: true,
//                             fillColor: Colors.grey[900],
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10),
//                               borderSide: BorderSide.none,
//                             ),
//                             contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 10),
//                       ElevatedButton(
//                         onPressed: () {
//                           postController.addPost(
//                               selectedMedia!.path, captionController.text);
//                           Get.back();
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blueAccent,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                         child: Text("Post"),
//                       )
//                     ],
//                   ),
//                   SizedBox(height: 10),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       IconButton(
//                         icon: Icon(Icons.camera_alt, color: Colors.white),
//                         onPressed: captureFromCamera,
//                       ),
//                       TextButton(
//                         onPressed: pickMediaFromGallery,
//                         child: Text("Pick Another", style: TextStyle(color: Colors.white)),
//                       ),
//                     ],
//                   )
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// */
// //
// //
// // import 'dart:io';
// // import 'package:chatappgx/controller/postcontroller.dart';
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:image_picker/image_picker.dart';
// //
// // class UploadPostScreen extends StatefulWidget {
// //   @override
// //   State<UploadPostScreen> createState() => _UploadPostScreenState();
// // }
// //
// // class _UploadPostScreenState extends State<UploadPostScreen> {
// //   final TextEditingController captionController = TextEditingController();
// //   final PostController postController = Get.find();
// //
// //   List<XFile> selectedMedia = [];
// //   int currentIndex = 0;
// //   final ImagePicker _picker = ImagePicker();
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       _openMultiMediaPicker();
// //     });
// //   }
// //
// //   Future<void> _openMultiMediaPicker() async {
// //     final List<XFile>? mediaList = await _picker.pickMultiImage();
// //     if (mediaList != null && mediaList.isNotEmpty) {
// //       setState(() {
// //         selectedMedia = mediaList;
// //       });
// //     } else {
// //       Get.back();
// //     }
// //   }
// //
// //   Future<void> _captureFromCamera() async {
// //     final XFile? media = await _picker.pickImage(source: ImageSource.camera);
// //     if (media != null) {
// //       setState(() {
// //         selectedMedia.insert(0, media);
// //         currentIndex = 0;
// //       });
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     if (selectedMedia.isEmpty) {
// //       return Container(color: Colors.black);
// //     }
// //
// //     final File currentFile = File(selectedMedia[currentIndex].path);
// //     final bool isVideo = selectedMedia[currentIndex].mimeType?.startsWith("video") ?? false;
// //
// //     return Scaffold(
// //       backgroundColor: Colors.black,
// //       appBar: AppBar(
// //         backgroundColor: Colors.black,
// //         elevation: 0,
// //         leading: IconButton(
// //           icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
// //           onPressed: () => Get.back(),
// //         ),
// //         actions: [
// //           IconButton(
// //             icon: Icon(Icons.camera_alt, color: Colors.white),
// //             onPressed: _captureFromCamera,
// //           ),
// //         ],
// //       ),
// //       body: Column(
// //         children: [
// //           // Gallery Thumbnails
// //           Container(
// //             height: 100,
// //             child: ListView.builder(
// //               scrollDirection: Axis.horizontal,
// //               itemCount: selectedMedia.length,
// //               itemBuilder: (context, index) {
// //                 return GestureDetector(
// //                   onTap: () {
// //                     setState(() {
// //                       currentIndex = index;
// //                     });
// //                   },
// //                   child: Container(
// //                     margin: EdgeInsets.symmetric(horizontal: 6),
// //                     decoration: BoxDecoration(
// //                       border: Border.all(
// //                         color: currentIndex == index ? Colors.blue: Colors.transparent,
// //                         width: 2,
// //                       ),
// //                     ),
// //                     child: Image.file(
// //                       File(selectedMedia[index].path),
// //                       width: 80,
// //                       height: 80,
// //                       fit: BoxFit.cover,
// //                     ),
// //                   ),
// //                 );
// //               },
// //             ),
// //           ),
// //
// //           // Main Preview
// //           Expanded(
// //             child: isVideo
// //                 ? Center(child: Icon(Icons.videocam, color: Colors.white, size: 100))
// //                 : Image.file(currentFile, fit: BoxFit.contain),
// //           ),
// //
// //           // Caption + Post
// //           Container(
// //             padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// //             decoration: BoxDecoration(
// //               color: Colors.black.withOpacity(0.95),
// //               borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// //             ),
// //             child: SafeArea(
// //               top: false,
// //               child: Column(
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   Row(
// //                     children: [
// //                       Expanded(
// //                         child: TextField(
// //                           controller: captionController,
// //                           style: TextStyle(color: Colors.white),
// //                           decoration: InputDecoration(
// //                             hintText: 'Write a caption...',
// //                             hintStyle: TextStyle(color: Colors.grey[400]),
// //                             filled: true,
// //                             fillColor: Colors.grey[900],
// //                             border: OutlineInputBorder(
// //                               borderRadius: BorderRadius.circular(10),
// //                               borderSide: BorderSide.none,
// //                             ),
// //                             contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// //                           ),
// //                         ),
// //                       ),
// //                       SizedBox(width: 10),
// //                       OutlinedButton(
// //                         onPressed: () {
// //                           postController.addPost(
// //                               currentFile.path, captionController.text);
// //                           Get.back();
// //                         },
// //                         style: OutlinedButton.styleFrom(
// //                           backgroundColor: Colors.black,
// //                           side: BorderSide(color: Colors.white, width: 1),
// //                           shape: RoundedRectangleBorder(
// //                               borderRadius: BorderRadius.circular(10)),
// //                           padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
// //                         ),
// //                         child: Text(
// //                           "Post",
// //                           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// //                         ),
// //                       )
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           )
// //         ],
// //       ),
// //     );
// //   }
// // } 17 aprilll


// /*

// import 'dart:io';
// import 'package:chatappgx/controller/postcontroller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';

// class UploadPostScreen extends StatefulWidget {
//   @override
//   State<UploadPostScreen> createState() => _UploadPostScreenState();
// }

// class _UploadPostScreenState extends State<UploadPostScreen> {
//   final TextEditingController captionController = TextEditingController();
//   final PostController postController = Get.find();

//   List<XFile> selectedMedia = [];
//   int currentIndex = 0;
//   final ImagePicker _picker = ImagePicker();

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _openMultiMediaPicker();
//     });
//   }

//   Future<void> _openMultiMediaPicker() async {
//     final List<XFile>? mediaList = await _picker.pickMultiImage();
//     if (mediaList != null && mediaList.isNotEmpty) {
//       setState(() {
//         selectedMedia = mediaList;
//       });
//     } else {
//       Get.back();
//     }
//   }

//   Future<void> _captureFromCamera() async {
//     final XFile? media = await _picker.pickImage(source: ImageSource.camera);
//     if (media != null) {
//       setState(() {
//         selectedMedia.insert(0, media);
//         currentIndex = 0;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (selectedMedia.isEmpty) {
//       return Container(color: Colors.black);
//     }

//     final File currentFile = File(selectedMedia[currentIndex].path);
//     final bool isVideo = selectedMedia[currentIndex].mimeType?.startsWith("video") ?? false;

//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
//           onPressed: () => Get.back(),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.camera_alt, color: Colors.white),
//             onPressed: _captureFromCamera,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Gallery Thumbnails with tick icon
//           Container(
//             height: 100,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: selectedMedia.length,
//               itemBuilder: (context, index) {
//                 final bool isSelected = index == currentIndex;
//                 return GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       currentIndex = index;
//                     });
//                   },
//                   child: Stack(
//                     alignment: Alignment.topRight,
//                     children: [
//                       Container(
//                         margin: EdgeInsets.symmetric(horizontal: 6),
//                         decoration: BoxDecoration(
//                           border: Border.all(
//                             color: isSelected ? Color(0xFFFF1694) : Colors.transparent,
//                             width: 2,
//                           ),
//                         ),
//                         child: Image.file(
//                           File(selectedMedia[index].path),
//                           width: 80,
//                           height: 80,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                       if (isSelected)
//                         Positioned(
//                           top: 4,
//                           right: 4,
//                           child: Icon(Icons.check_circle,
//                               color: Color(0xFFFF1694), size: 20),
//                         ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),

//           // Main Preview
//           Expanded(
//             child: isVideo
//                 ? Center(child: Icon(Icons.videocam, color: Colors.white, size: 100))
//                 : Image.file(currentFile, fit: BoxFit.contain),
//           ),

//           // Caption + Post
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             decoration: BoxDecoration(
//               color: Colors.black.withOpacity(0.95),
//               borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//             ),
//             child: SafeArea(
//               top: false,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: captionController,
//                           style: TextStyle(color: Colors.white),
//                           decoration: InputDecoration(
//                             hintText: 'Write a caption...',
//                             hintStyle: TextStyle(color: Colors.grey[400]),
//                             filled: true,
//                             fillColor: Colors.grey[900],
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10),
//                               borderSide: BorderSide.none,
//                             ),
//                             contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 10),
//                       OutlinedButton
//                         (
//                         onPressed: () {
//                           postController.addPost(
//                               currentFile.path, captionController.text);
//                           Get.back();
//                         },
//                         style: OutlinedButton.styleFrom(
//                           backgroundColor: Colors.black,
//                           side: BorderSide(color: Colors.white, width: 1),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10)),
//                           padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//                         ),
//                         child: Text(
//                           "Post",
//                           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                         ),
//                       )
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
// */
// //
// // import 'dart:io';
// // import 'package:chatappgx/controller/postcontroller.dart';
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:image_picker/image_picker.dart';
// //
// // class UploadPostScreen extends StatefulWidget {
// //   final Map<String, dynamic>? existingPost;
// //   //final void Function(String mediaPath, String caption)? onPostUpdated;
// //
// //   final void Function(Map<String, dynamic>)? onPostUpdated;
// //
// //
// //   const UploadPostScreen({
// //     Key? key,
// //     this.existingPost,
// //     this.onPostUpdated,
// //   }) : super(key: key);
// //
// //   @override
// //   State<UploadPostScreen> createState() => _UploadPostScreenState();
// // }
// //
// // class _UploadPostScreenState extends State<UploadPostScreen> {
// //   final TextEditingController captionController = TextEditingController();
// //   final PostController postController = Get.find();
// //
// //   List<XFile> selectedMedia = [];
// //   int currentIndex = 0;
// //   final ImagePicker _picker = ImagePicker();
// //
// //   bool get isEditMode => widget.existingPost != null;
// //
// //
// //   // @override
// //   // void initState()
// //   // {
// //   //   super.initState();
// //   //
// //   //   if (isEditMode) {
// //   //     captionController.text = widget.existingPost!['caption'] ?? '';
// //   //     String existingMediaPath = widget.existingPost!['mediaPath'] ?? '';
// //   //     if (existingMediaPath.isNotEmpty) {
// //   //       selectedMedia = [XFile(existingMediaPath)];
// //   //     }
// //   //   } else {
// //   //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //   //       _openMultiMediaPicker();
// //   //     });
// //   //   }
// //   // }
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //
// //     if (isEditMode) {
// //       // Ensure data is correctly prepopulated
// //       captionController.text = widget.existingPost!['caption'] ?? '';
// //       String existingMediaPath = widget.existingPost!['mediaPath'] ?? '';
// //       if (existingMediaPath.isNotEmpty) {
// //         selectedMedia = [XFile(existingMediaPath)];
// //       }
// //     } else {
// //       WidgetsBinding.instance.addPostFrameCallback((_) {
// //         _openMultiMediaPicker();
// //       });
// //     }
// //   }
// //
// //
// //   Future<void> _openMultiMediaPicker() async {
// //     final List<XFile>? mediaList = await _picker.pickMultiImage();
// //     if (mediaList != null && mediaList.isNotEmpty) {
// //       setState(() {
// //         selectedMedia = mediaList;
// //       });
// //     } else {
// //       Get.back();
// //     }
// //   }
// //
// //   Future<void> _captureFromCamera() async {
// //     final XFile? media = await _picker.pickImage(source: ImageSource.camera);
// //     if (media != null) {
// //       setState(() {
// //         selectedMedia.insert(0, media);
// //         currentIndex = 0;
// //       });
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     if (selectedMedia.isEmpty) {
// //       return Container(color: Colors.black);
// //     }
// //
// //     final File currentFile = File(selectedMedia[currentIndex].path);
// //     final bool isVideo = selectedMedia[currentIndex].mimeType?.startsWith("video") ?? false;
// //
// //     return Scaffold(
// //       backgroundColor: Colors.black,
// //       appBar: AppBar(
// //         backgroundColor: Colors.black,
// //         elevation: 0,
// //         leading: IconButton(
// //           icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
// //           onPressed: () => Get.back(),
// //         ),
// //         actions: [
// //           IconButton(
// //             icon: Icon(Icons.camera_alt, color: Colors.white),
// //             onPressed: _captureFromCamera,
// //           ),
// //         ],
// //       ),
// //       body: Column(
// //         children: [
// //           // Gallery Thumbnails
// //           Container(
// //             height: 100,
// //             child: ListView.builder(
// //               scrollDirection: Axis.horizontal,
// //               itemCount: selectedMedia.length,
// //               itemBuilder: (context, index) {
// //                 final bool isSelected = index == currentIndex;
// //                 return GestureDetector(
// //                   onTap: () {
// //                     setState(() {
// //                       currentIndex = index;
// //                     });
// //                   },
// //                   child: Stack(
// //                     alignment: Alignment.topRight,
// //                     children: [
// //                       Container(
// //                         margin: EdgeInsets.symmetric(horizontal: 6),
// //                         decoration: BoxDecoration(
// //                           border: Border.all(
// //                             color: isSelected ? Color(0xFFFF1694) : Colors.transparent,
// //                             width: 2,
// //                           ),
// //                         ),
// //                         child: Image.file(
// //                           File(selectedMedia[index].path),
// //                           width: 80,
// //                           height: 80,
// //                           fit: BoxFit.cover,
// //                         ),
// //                       ),
// //                       if (isSelected)
// //                         Positioned(
// //                           top: 4,
// //                           right: 4,
// //                           child: Icon(Icons.check_circle,
// //                               color: Color(0xFFFF1694), size: 20),
// //                         ),
// //                     ],
// //                   ),
// //                 );
// //               },
// //             ),
// //           ),
// //
// //           // Main Preview
// //           Expanded(
// //             child: isVideo
// //                 ? Center(child: Icon(Icons.videocam, color: Colors.white, size: 100))
// //                 : Image.file(currentFile, fit: BoxFit.contain),
// //           ),
// //
// //           // Caption + Post Button
// //           Container(
// //             padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// //             decoration: BoxDecoration(
// //               color: Colors.black.withOpacity(0.95),
// //               borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// //             ),
// //             child: SafeArea(
// //               top: false,
// //               child: Column(
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   Row(
// //                     children: [
// //                       Expanded(
// //                         child: TextField(
// //                           controller: captionController,
// //                           style: TextStyle(color: Colors.white),
// //                           decoration: InputDecoration(
// //                             hintText: 'Write a caption...',
// //                             hintStyle: TextStyle(color: Colors.grey[400]),
// //                             filled: true,
// //                             fillColor: Colors.grey[900],
// //                             border: OutlineInputBorder(
// //                               borderRadius: BorderRadius.circular(10),
// //                               borderSide: BorderSide.none,
// //                             ),
// //                             contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// //                           ),
// //                         ),
// //                       ),
// //                       SizedBox(width: 10),
// //
// //
// //
// //                       // OutlinedButton(
// //                       //   onPressed: () {
// //                       //     final String path = currentFile.path;
// //                       //     final String caption = captionController.text.trim();
// //                       //
// //                       //     if (isEditMode && widget.onPostUpdated != null)
// //                       //     {
// //                       //       widget.onPostUpdated!(path, caption);
// //                       //     } else
// //                       //     {
// //                       //       postController.addPost(path, caption);
// //                       //     }
// //                       //
// //                       //     Get.back();
// //                       //   },
// //                       //
// //                       //
// //                       //
// //                       //   style: OutlinedButton.styleFrom(
// //                       //     backgroundColor: Colors.black,
// //                       //     side: BorderSide(color: Colors.white, width: 1),
// //                       //     shape: RoundedRectangleBorder(
// //                       //         borderRadius: BorderRadius.circular(10)),
// //                       //     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
// //                       //   ),
// //                       //   child: Text(
// //                       //     isEditMode ? "Update" : "Post",
// //                       //     style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// //                       //   ),
// //                       // )
// //
// //                       OutlinedButton(
// //                         onPressed: () {
// //                           final String path = currentFile.path;
// //                           final String caption = captionController.text.trim();
// //
// //                           if (isEditMode && widget.onPostUpdated != null) {
// //                             Map<String, dynamic> updatedPost = {
// //                               'caption': caption,
// //                               'mediaPath': path,
// //                               'isVideo': isVideo,
// //                               // You can include more fields here if needed, like:
// //                               // 'postId': widget.existingPost?['postId'],
// //                               // 'timestamp': DateTime.now().toIso8601String(),
// //                             };
// //                             widget.onPostUpdated!(updatedPost);
// //                           } else {
// //                             postController.addPost(path, caption);
// //                           }
// //
// //                           Get.back();
// //                         },
// //                         style: OutlinedButton.styleFrom(
// //                           backgroundColor: Colors.black,
// //                           side: BorderSide(color: Colors.white, width: 1),
// //                           shape: RoundedRectangleBorder(
// //                             borderRadius: BorderRadius.circular(10),
// //                           ),
// //                           padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
// //                         ),
// //                         child: Text(
// //                           isEditMode ? "Update" : "Post",
// //                           style: TextStyle(
// //                             color: Colors.white,
// //                             fontWeight: FontWeight.bold,
// //                           ),
// //                         ),
// //                       )
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           )
// //         ],
// //       ),
// //     );
// //   }
// // }

// /*


// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class UploadPostScreen extends StatefulWidget {
//   final Map<String, dynamic>? existingPost;
//   final Function(Map<String, dynamic>) onPostUpdated;

//   const UploadPostScreen({super.key, this.existingPost, required this.onPostUpdated});

//   @override
//   State<UploadPostScreen> createState() => _UploadPostScreenState();
// }

// class _UploadPostScreenState extends State<UploadPostScreen> {
//   late TextEditingController _captionController;

//   @override
//   void initState() {
//     super.initState();
//     _captionController = TextEditingController(
//         text: widget.existingPost != null ? widget.existingPost!['description'] : '');
//   }

//   void savePost() {
//     Map<String, dynamic> updatedPost = {
//       'username': widget.existingPost?['username'] ?? 'NewUser',
//       'imageUrl': widget.existingPost?['imageUrl'] ??
//           'https://source.unsplash.com/random/400x400?new',
//       'isVideo': widget.existingPost?['isVideo'] ?? false,
//       'description': _captionController.text,
//     };

//     widget.onPostUpdated(updatedPost);
//     Get.back();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: Text(widget.existingPost != null ? "Edit Post" : "New Post"),
//         backgroundColor: Colors.black,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.check, color: Colors.white),
//             onPressed: savePost,
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             widget.existingPost != null
//                 ? Container(
//               height: 200,
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(12),
//                 image: widget.existingPost!['isVideo']
//                     ? null
//                     : DecorationImage(
//                   image:
//                   NetworkImage(widget.existingPost!['imageUrl']),
//                   fit: BoxFit.cover,
//                 ),
//                 color: Colors.grey[900],
//               ),
//               child: widget.existingPost!['isVideo']
//                   ? const Center(
//                 child: Icon(Icons.videocam,
//                     size: 64, color: Colors.white70),
//               )
//                   : null,
//             )
//                 : const SizedBox.shrink(),
//             const SizedBox(height: 20),
//             TextField(
//               controller: _captionController,
//               style: const TextStyle(color: Colors.white),
//               maxLines: 4,
//               decoration: InputDecoration(
//                 labelText: "Caption",
//                 labelStyle: const TextStyle(color: Colors.white60),
//                 enabledBorder: OutlineInputBorder(
//                   borderSide: const BorderSide(color: Colors.white38),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: const BorderSide(color: Colors.white),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// } working */
// //
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// //
// // class UploadPostScreen extends StatefulWidget {
// //   final Map<String, dynamic>? existingPost;
// //   final Function(Map<String, dynamic>) onPostUpdated;
// //
// //   const UploadPostScreen({
// //     super.key,
// //     this.existingPost,
// //     required this.onPostUpdated,
// //   });
// //
// //   @override
// //   State<UploadPostScreen> createState() => _UploadPostScreenState();
// // }
// //
// // class _UploadPostScreenState extends State<UploadPostScreen> {
// //   late TextEditingController _captionController;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _captionController = TextEditingController(
// //       text: widget.existingPost != null ? widget.existingPost!['description'] : '',
// //     );
// //   }
// //
// //   void savePost() {
// //     Map<String, dynamic> updatedPost = {
// //       'username': widget.existingPost?['username'] ?? 'NewUser',
// //       'imageUrl': widget.existingPost?['imageUrl'] ??
// //           'https://source.unsplash.com/random/400x400?new',
// //       'isVideo': widget.existingPost?['isVideo'] ?? false,
// //       'description': _captionController.text,
// //     };
// //
// //     widget.onPostUpdated(updatedPost);
// //     Get.back();
// //   }
// //
// //   void cancelEdit() {
// //     Get.back();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final post = widget.existingPost;
// //     final height = MediaQuery.of(context).size.height;
// //     final bottomInset = MediaQuery.of(context).viewInsets.bottom;
// //
// //     return Scaffold(
// //       backgroundColor: Colors.black,
// //       appBar: AppBar
// //         (
// //         backgroundColor: Colors.black,
// //         leading: IconButton(
// //           icon: const Icon(Icons.close, color: Colors.white),
// //           onPressed: cancelEdit,
// //         ),
// //         title: Text(
// //           post != null ? "Edit Post" : "New Post",
// //           style: const TextStyle(color: Colors.white),
// //         ),
// //         actions: [
// //           IconButton(
// //             icon: const Icon(Icons.check, color: Colors.white),
// //             onPressed: savePost,
// //           ),
// //         ],
// //       //  elevation: 0,
// //       ),
// //
// //
// //
// //
// //
// //
// //       body: SingleChildScrollView(
// //         padding: EdgeInsets.only(
// //           left: 16,
// //           right: 16,
// //           top: 10,
// //           bottom: bottomInset + 24,
// //         ),
// //         child: ConstrainedBox(
// //           constraints: BoxConstraints(minHeight: height - 100),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               if (post != null) ...[
// //                 Row(
// //                   children: [
// //                     const CircleAvatar(
// //                       radius: 20,
// //                       backgroundImage: NetworkImage(
// //                         'https://i.pravatar.cc/100?img=12',
// //                       ),
// //                     ),
// //                     const SizedBox(width: 12),
// //                     Text(
// //                       post['username'] ?? 'User',
// //                       style: const TextStyle(
// //                           color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16),
// //                     ),
// //                   ],
// //                 ),
// //                 const SizedBox(height: 14),
// //                 ClipRRect(
// //                   borderRadius: BorderRadius.circular(12),
// //                   child: Container(
// //                     height: 250,
// //                     width: double.infinity,
// //                     decoration: BoxDecoration(
// //                       color: Colors.grey[900],
// //                     ),
// //                     child: post['isVideo']
// //                         ? const Center(
// //                       child: Icon(Icons.videocam, size: 64, color: Colors.white70),
// //                     )
// //                         : Image.network(
// //                       post['imageUrl'],
// //                       fit: BoxFit.cover,
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //               const SizedBox(height: 30),
// //               TextField(
// //                 controller: _captionController,
// //                 style: const TextStyle(color: Colors.white, fontSize: 16),
// //                 maxLines: 6,
// //                 decoration: InputDecoration(
// //                   filled: true,
// //                   fillColor: Colors.grey[850],
// //                   hintText: "Write a caption...",
// //                   hintStyle: const TextStyle(color: Colors.white54),
// //                   contentPadding:
// //                   const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
// //                   border: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(12),
// //                     borderSide: BorderSide(color: Colors.white24),
// //                   ),
// //                   enabledBorder: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(12),
// //                     borderSide: BorderSide(color: Colors.white24),
// //                   ),
// //                   focusedBorder: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(12),
// //                     borderSide: BorderSide(color: Colors.white),
// //                   ),
// //                 ),
// //                 cursorColor: Colors.white,
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // } 18 even wrong


// //
// //
// // import 'dart:io';
// // import 'package:chatappgx/controller/postcontroller.dart';
// // import 'package:flutter/material.dart';
// // import 'package:get/get.dart';
// // import 'package:image_picker/image_picker.dart';
// //
// // class UploadPostScreen extends StatefulWidget {
// //   final Map<String, dynamic>? existingPost;
// //   final Function(Map<String, dynamic>) onPostUpdated;
// //
// //   const UploadPostScreen({
// //     super.key,
// //     this.existingPost,
// //     required this.onPostUpdated,
// //   });
// //
// //   @override
// //   State<UploadPostScreen> createState() => _UploadPostScreenState();
// // }
// //
// // class _UploadPostScreenState extends State<UploadPostScreen> {
// //   final TextEditingController captionController = TextEditingController();
// //   final PostController postController = Get.find();
// //
// //   List<XFile> selectedMedia = [];
// //   int currentIndex = 0;
// //   final ImagePicker _picker = ImagePicker();
// //
// //   bool get isEditMode => widget.existingPost != null;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //
// //     if (isEditMode) {
// //       captionController.text = widget.existingPost!['description'] ?? '';
// //       String imageUrl = widget.existingPost!['imageUrl'] ?? '';
// //       if (imageUrl.isNotEmpty) {
// //         // Assume it's a local file if editing (convert to XFile)
// //         selectedMedia = [XFile(imageUrl)];
// //       }
// //     } else {
// //       WidgetsBinding.instance.addPostFrameCallback((_) {
// //         _openMultiMediaPicker();
// //       });
// //     }
// //   }
// //
// //   Future<void> _openMultiMediaPicker() async {
// //     final List<XFile>? mediaList = await _picker.pickMultiImage();
// //     if (mediaList != null && mediaList.isNotEmpty) {
// //       setState(() {
// //         selectedMedia = mediaList;
// //         currentIndex = 0;
// //       });
// //     } else {
// //       Get.back();
// //     }
// //   }
// //
// //   Future<void> _captureFromCamera() async {
// //     final XFile? media = await _picker.pickImage(source: ImageSource.camera);
// //     if (media != null) {
// //       setState(() {
// //         selectedMedia.insert(0, media);
// //         currentIndex = 0;
// //       });
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     if (selectedMedia.isEmpty) {
// //       return Container(color: Colors.black);
// //     }
// //
// //     final File currentFile = File(selectedMedia[currentIndex].path);
// //     final bool isVideo = selectedMedia[currentIndex].mimeType?.startsWith("video") ?? false;
// //
// //     return Scaffold(
// //       backgroundColor: Colors.black,
// //       appBar: AppBar(
// //         backgroundColor: Colors.black,
// //         elevation: 0,
// //         leading: IconButton(
// //           icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
// //           onPressed: () => Get.back(),
// //         ),
// //         actions: [
// //           IconButton(
// //             icon: Icon(Icons.camera_alt, color: Colors.white),
// //             onPressed: _captureFromCamera,
// //           ),
// //         ],
// //       ),
// //       body: Column(
// //         children: [
// //           // Gallery Thumbnails
// //           Container(
// //             height: 100,
// //             child: ListView.builder(
// //               scrollDirection: Axis.horizontal,
// //               itemCount: selectedMedia.length,
// //               itemBuilder: (context, index) {
// //                 final bool isSelected = index == currentIndex;
// //                 return GestureDetector(
// //                   onTap: () {
// //                     setState(() {
// //                       currentIndex = index;
// //                     });
// //                   },
// //                   child: Stack(
// //                     alignment: Alignment.topRight,
// //                     children: [
// //                       Container(
// //                         margin: EdgeInsets.symmetric(horizontal: 6),
// //                         decoration: BoxDecoration(
// //                           border: Border.all(
// //                             color: isSelected ? Color(0xFFFF1694) : Colors.transparent,
// //                             width: 2,
// //                           ),
// //                         ),
// //                         child: Image.file(
// //                           File(selectedMedia[index].path),
// //                           width: 80,
// //                           height: 80,
// //                           fit: BoxFit.cover,
// //                         ),
// //                       ),
// //                       if (isSelected)
// //                         Positioned(
// //                           top: 4,
// //                           right: 4,
// //                           child: Icon(Icons.check_circle,
// //                               color: Color(0xFFFF1694), size: 20),
// //                         ),
// //                     ],
// //                   ),
// //                 );
// //               },
// //             ),
// //           ),
// //
// //           // Main Preview
// //           Expanded(
// //             child: isVideo
// //                 ? Center(child: Icon(Icons.videocam, color: Colors.white, size: 100))
// //                 : Image.file(currentFile, fit: BoxFit.contain),
// //           ),
// //
// //           // Caption + Post Button
// //           Container(
// //             padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// //             decoration: BoxDecoration(
// //               color: Colors.black.withOpacity(0.95),
// //               borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// //             ),
// //             child: SafeArea(
// //               top: false,
// //               child: Column(
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   Row(
// //                     children: [
// //                       Expanded(
// //                         child: TextField(
// //                           controller: captionController,
// //                           style: TextStyle(color: Colors.white),
// //                           decoration: InputDecoration(
// //                             hintText: 'Write a caption...',
// //                             hintStyle: TextStyle(color: Colors.grey[400]),
// //                             filled: true,
// //                             fillColor: Colors.grey[900],
// //                             border: OutlineInputBorder(
// //                               borderRadius: BorderRadius.circular(10),
// //                               borderSide: BorderSide.none,
// //                             ),
// //                             contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// //                           ),
// //                         ),
// //                       ),
// //                       SizedBox(width: 10),
// //                       OutlinedButton(
// //                         onPressed: () {
// //                           final String path = currentFile.path;
// //                           final String caption = captionController.text.trim();
// //
// //                           Map<String, dynamic> post = {
// //                             'username': widget.existingPost?['username'] ?? 'NewUser',
// //                             'imageUrl': path,
// //                             'description': caption,
// //                             'isVideo': isVideo,
// //                           };
// //
// //                           widget.onPostUpdated(post);
// //                           Get.back();
// //                         },
// //                         style: OutlinedButton.styleFrom(
// //                           backgroundColor: Colors.black,
// //                           side: BorderSide(color: Colors.white, width: 1),
// //                           shape: RoundedRectangleBorder(
// //                               borderRadius: BorderRadius.circular(10)),
// //                           padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
// //                         ),
// //                         child: Text(
// //                           isEditMode ? "Update" : "Post",
// //                           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
// //                         ),
// //                       )
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           )
// //         ],
// //       ),
// //     );
// //   }
// // }
// //   18 april




// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';

// class UploadPostScreen extends StatefulWidget {
//   final Map<String, dynamic>? existingPost;
//   final Function(Map<String, dynamic>) onPostUpdated;

//   const UploadPostScreen({
//     super.key,
//     this.existingPost,
//     required this.onPostUpdated,
//   });

//   @override
//   State<UploadPostScreen> createState() => _UploadPostScreenState();
// }

// class _UploadPostScreenState extends State<UploadPostScreen> {
//   final TextEditingController captionController = TextEditingController();
//   final PostController postController = Get.find();

//   List<XFile> selectedMedia = [];
//   int currentIndex = 0;
//   final ImagePicker _picker = ImagePicker();

//   bool get isEditMode => widget.existingPost != null;

//   @override
//   void initState() {
//     super.initState();

//     if (isEditMode) {
//       captionController.text = widget.existingPost!['description'] ?? '';
//       String imageUrl = widget.existingPost!['imageUrl'] ?? '';
//       if (imageUrl.isNotEmpty) {

//         selectedMedia = [XFile(imageUrl)];
//       }
//     } else {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _openMultiMediaPicker();
//       });
//     }
//   }

//   Future<void> _openMultiMediaPicker() async {
//     final List<XFile>? mediaList = await _picker.pickMultiImage();
//     if (mediaList != null && mediaList.isNotEmpty) {
//       setState(() {
//         selectedMedia = mediaList;
//         currentIndex = 0;
//       });
//     } else {
//       Get.back();
//     }
//   }

//   Future<void> _captureFromCamera() async {
//     final XFile? media = await _picker.pickImage(source: ImageSource.camera);
//     if (media != null) {
//       setState(() {
//         selectedMedia.insert(0, media);
//         currentIndex = 0;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;

//     if (selectedMedia.isEmpty) {
//       return Container(color: Colors.black);
//     }

//     final File currentFile = File(selectedMedia[currentIndex].path);
//     final bool isVideo = selectedMedia[currentIndex].mimeType?.startsWith("video") ?? false;

//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
//           onPressed: () => Get.back(),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.camera_alt, color: Colors.white),
//             onPressed: _captureFromCamera,
//           ),
//         ],
//       ),
//       body: Column(
//         children: [


//           Container(
//             height: screenHeight * 0.15, // Adjust thumbnail height based on screen height
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: selectedMedia.length,
//               itemBuilder: (context, index) {
//                 final bool isSelected = index == currentIndex;
//                 return GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       currentIndex = index;
//                     });
//                   },
//                   child: Stack(
//                     alignment: Alignment.topRight,
//                     children: [
//                       Container(
//                         margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
//                         decoration: BoxDecoration(
//                           border: Border.all(
//                             color: isSelected ? Color(0xFFFF1694) : Colors.transparent,
//                             width: 2,
//                           ),
//                         ),
//                         child: Image.file(
//                           File(selectedMedia[index].path),
//                           width: screenWidth * 0.2, // Responsive thumbnail size
//                           height: screenWidth * 0.2,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                       if (isSelected)
//                         Positioned(
//                           top: 4,
//                           right: 4,
//                           child: Icon(Icons.check_circle,
//                               color: Color(0xFFFF1694), size: 20),
//                         ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),

//           // Main Preview
//           Expanded(
//             child: isVideo
//                 ? Center(child: Icon(Icons.videocam, color: Colors.white, size: screenWidth * 0.3))
//                 : Image.file(currentFile, fit: BoxFit.contain),
//           ),

//           // Caption + Post Button
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenHeight * 0.02),
//             decoration: BoxDecoration(
//               color: Colors.black,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//             ),
//             child: SafeArea(
//               top: false,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: captionController,
//                           style: TextStyle(color: Colors.white),
//                           decoration: InputDecoration(
//                             hintText: 'Write a caption...',
//                             hintStyle: TextStyle(color: Colors.grey[400]),
//                             filled: true,
//                             fillColor: Colors.grey[900],
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10),
//                               borderSide: BorderSide.none,
//                             ),
//                             contentPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.015),
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: screenWidth * 0.03),
//                       OutlinedButton(
//                         onPressed: () {
//                           final String path = currentFile.path;
//                           final String caption = captionController.text.trim();

//                           Map<String, dynamic> post = {
//                             'username': widget.existingPost?['username'] ?? 'NewUser',
//                             'imageUrl': path,
//                             'description': caption,
//                             'isVideo': isVideo,
//                           };

//                           widget.onPostUpdated(post);
//                           Get.back();
//                         },
//                         style: OutlinedButton.styleFrom(
//                           backgroundColor: Colors.black,
//                           side: BorderSide(color: Colors.white, width: 1),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10)),
//                           padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1, vertical: screenHeight * 0.02),
//                         ),
//                         child: Text(
//                           isEditMode ? "Update" : "Post",
//                           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                         ),
//                       )
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
