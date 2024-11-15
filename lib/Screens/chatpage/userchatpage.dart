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

  // To simulate online status for the user
  bool get isUserOnline => widget.user['isOnline'] ?? false;
  double getResponsiveFontSize(double scale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * scale; // Adjust this scale for different text elements
  }
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
          title: Text("Choose Camera Option", style: AppTextStyles.headingText.copyWith(fontSize: getResponsiveFontSize(0.04))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                child: Text("Take Photo", style: AppTextStyles.bodyText.copyWith(fontSize: getResponsiveFontSize(0.04))),
              ),
              SizedBox(height: 10),
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
                child: Text("Record Video", style: AppTextStyles.bodyText.copyWith(fontSize: getResponsiveFontSize(0.04))),
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
              Text("Choose Gallery Option", style: AppTextStyles.headingText.copyWith(fontSize: getResponsiveFontSize(0.04))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                      .pop(await picker.pickImage(source: ImageSource.gallery));
                },
                child: Text("Pick Image", style: AppTextStyles.bodyText.copyWith(fontSize: getResponsiveFontSize(0.04))),
              ),
              SizedBox(height: 10),
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
                      .pop(await picker.pickVideo(source: ImageSource.gallery));
                },
                child: Text("Pick Video", style: AppTextStyles.bodyText.copyWith(fontSize: getResponsiveFontSize(0.04))),
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
  void initiateVideoCall() {
    // Replace this with your actual video call integration code
    Get.snackbar("Video Call", "Initiating video call...",
        snackPosition: SnackPosition.BOTTOM);
  }

  // Placeholder method for initiating a voice call
  void initiateVoiceCall() {
    // Replace this with your actual voice call integration code
    Get.snackbar("Voice Call", "Initiating voice call...",
        snackPosition: SnackPosition.BOTTOM);
  }

  // Function to show profile picture in a dialog
  void showProfilePhoto() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: Image.network(widget.user['imageUrl']),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Chat with ${widget.user['name']}",
                style: AppTextStyles.titleText.copyWith(fontSize: getResponsiveFontSize(0.04))),
            if (isUserOnline)
              Text(
                'Online',
                style: AppTextStyles.bodyText.copyWith(
                  fontSize: getResponsiveFontSize(0.03),
                  color: Colors.green,
                ),
              ),
          ],
        ),
        leading: GestureDetector(
  onTap: showProfilePhoto, // Show the photo in a dialog
  child: Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      // Apply a green border if the user is online
      decoration: isUserOnline
          ? BoxDecoration(
              border: Border.all(
                color: Colors.green, // Green border for online users
                width: 2,
              ),
              borderRadius: BorderRadius.circular(40), // Ensure it's circular
            )
          : null, // No border if the user is not online
      child: CircleAvatar(
        radius: 32,
        backgroundImage: NetworkImage(widget.user['imageUrl']),
        backgroundColor: AppColors.chipColor,
        // If the user is online, add a small green circle at the bottom-right
        child: isUserOnline
            ? Align(
                alignment: Alignment.bottomRight,
                child: CircleAvatar(
                  radius: 8, // Small circle indicating online status
                  backgroundColor: Colors.green,
                ),
              )
            : null, // No indicator if the user is offline
      ),
    ),
  ),
),

        actions: [
          IconButton(
            icon: Icon(Icons.call, color: AppColors.iconColor),
            onPressed: initiateVoiceCall,
          ),
          IconButton(
            icon: Icon(Icons.video_call, color: AppColors.iconColor),
            onPressed: initiateVideoCall,
          ),
        ],
      ),
      body: Column(
        children: [
          if (isLoading)
            Center(
              child: SpinKitCircle(
                color: AppColors.buttonColor,
                size: 50.0,
              ),
            ),
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
                          style: AppTextStyles.bodyText.copyWith(fontSize: getResponsiveFontSize(0.04))),
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
                          Text("Video message", style: AppTextStyles.bodyText.copyWith(fontSize: getResponsiveFontSize(0.04))),
                    ),
                  );
                }
                return Container();
              },
            ),
          ),
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
                    style: AppTextStyles.inputFieldText.copyWith(fontSize: getResponsiveFontSize(0.03)),
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
