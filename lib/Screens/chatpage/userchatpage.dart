import 'dart:io';
import 'package:dating_application/constants.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ChatPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const ChatPage({super.key, required this.user});

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  final TextEditingController messageController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  List<Map<String, dynamic>> messages = [];
  bool isTyping = false;
  bool isLoading = false;

  // Request camera, gallery, and microphone permissions
  Future<void> requestPermissions() async {
    var cameraStatus = await Permission.camera.request();
    var galleryStatus = await Permission.photos.request();
    var microphoneStatus = await Permission.microphone.request();

    if (cameraStatus.isDenied ||
        galleryStatus.isDenied ||
        microphoneStatus.isDenied) {
      Get.snackbar(
          'Permission Denied', 'Please allow all necessary permissions.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.deniedColor);
    }
  }

  // Handle picking image or video from the camera
  Future<void> pickFromCamera() async {
    await requestPermissions();

    final pickedFile = await showDialog<XFile?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Choose Camera Option", style: AppTextStyles.headingText),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Button for taking a photo
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: AppColors.textColor,
                  backgroundColor: AppColors.buttonColor, // text color
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  Navigator.of(context)
                      .pop(await picker.pickImage(source: ImageSource.camera));
                },
                child: Text("Take Photo", style: AppTextStyles.bodyText),
              ),
              SizedBox(height: 10),
              // Button for recording a video
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: AppColors.textColor,
                  backgroundColor: AppColors.buttonColor, // text color
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  Navigator.of(context)
                      .pop(await picker.pickVideo(source: ImageSource.camera));
                },
                child: Text("Record Video", style: AppTextStyles.bodyText),
              ),
            ],
          ),
        );
      },
    );

    if (pickedFile != null) {
      addMediaMessage(pickedFile);
    }
  }

  // Handle picking image or video from the gallery
  Future<void> pickFromGallery() async {
    await requestPermissions();

    final pickedFile = await showDialog<XFile?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text("Choose Gallery Option", style: AppTextStyles.headingText),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Button for picking an image
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: AppColors.textColor,
                  backgroundColor: AppColors.buttonColor, // text color
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  Navigator.of(context).pop(
                      await picker.pickImage(source: ImageSource.gallery));
                },
                child: Text("Pick Image", style: AppTextStyles.bodyText),
              ),
              SizedBox(height: 10),
              // Button for picking a video
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: AppColors.textColor,
                  backgroundColor: AppColors.buttonColor, // text color
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  Navigator.of(context).pop(
                      await picker.pickVideo(source: ImageSource.gallery));
                },
                child: Text("Pick Video", style: AppTextStyles.bodyText),
              ),
            ],
          ),
        );
      },
    );

    if (pickedFile != null) {
      addMediaMessage(pickedFile);
    }
  }

  // Add media (image/video) message to the list
  void addMediaMessage(XFile pickedFile) {
    setState(() {
      isLoading = true; // Start loading
    });

    if (pickedFile.path.endsWith('.mp4')) {
      messages.add({
        'type': 'video',
        'content': pickedFile.path,
      });
    } else {
      messages.add({
        'type': 'image',
        'content': pickedFile.path,
      });
    }

    // Simulate a delay for loading (for demo purposes, you can remove this later)
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isLoading = false; // Stop loading after the delay
      });
    });
  }

  // Send text message
  void sendMessage() {
    if (messageController.text.isNotEmpty) {
      setState(() {
        isLoading = true; // Start loading spinner when message is sent
        messages.add({
          'type': 'text',
          'content': messageController.text,
        });
      });
      messageController.clear();

      // Simulate a delay for sending message (for demo purposes, remove in production)
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          isLoading = false; // Stop loading after sending the message
        });
      });
    }
  }

  // Placeholder method for initiating a video call
  void _initiateVideoCall() {
    // Replace this with your actual video call integration code
    Get.snackbar("Video Call", "Initiating video call...",
        snackPosition: SnackPosition.BOTTOM);
  }

  // Placeholder method for initiating a voice call
  void _initiateVoiceCall() {
    // Replace this with your actual voice call integration code
    Get.snackbar("Voice Call", "Initiating voice call...",
        snackPosition: SnackPosition.BOTTOM);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text("Chat with ${widget.user['name']}",
            style: AppTextStyles.titleText),
        actions: [
          IconButton(
            icon: Icon(Icons.call, color: AppColors.iconColor),
            onPressed: _initiateVoiceCall,
          ),
          IconButton(
            icon: Icon(Icons.video_call, color: AppColors.iconColor),
            onPressed: _initiateVideoCall,
          ),
        ],
      ),
      body: Column(
        children: [
          // Show loading spinner when _isLoading is true
          if (isLoading)
            Center(
              child: SpinKitCircle(
                color: AppColors.buttonColor,
                size: 50.0,
              ),
            ),
          // Messages List
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                if (message['type'] == 'text') {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(message['content'],
                          style: AppTextStyles.bodyText),
                    ),
                  );
                } else if (message['type'] == 'image') {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Image.file(File(message['content'])),
                    ),
                  );
                } else if (message['type'] == 'video') {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title:
                          Text("Video message", style: AppTextStyles.bodyText),
                    ),
                  );
                }
                return Container();
              },
            ),
          ),
          // Input field and icons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                if (!isTyping) ...[
                  IconButton(
                    icon: Icon(Icons.camera_alt, color: AppColors.iconColor),
                    onPressed: pickFromCamera,
                  ),
                  IconButton(
                    icon: Icon(Icons.photo_library, color: AppColors.iconColor),
                    onPressed: pickFromGallery,
                  ),
                ],
                Expanded(
                  child: TextField(
                    cursorColor: AppColors.cursorColor,
                    controller: messageController,
                    onChanged: (text) {
                      setState(() {
                        isTyping = text.isNotEmpty;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      filled: true,
                      fillColor: AppColors.formFieldColor,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.buttonColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.buttonColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.buttonColor),
                      ),
                    ),
                    style: AppTextStyles.inputFieldText,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: AppColors.iconColor),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
