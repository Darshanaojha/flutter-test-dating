import 'dart:io';
import 'package:dating_application/Controllers/controller.dart';
import 'package:dating_application/constants.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../Models/ResponseModels/get_report_user_options_response_model.dart';

class ChatPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const ChatPage({super.key, required this.user});

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  Controller controller = Get.put(Controller());
  final TextEditingController messageController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  List<Map<String, dynamic>> messages = [];
  bool isTyping = false;
  bool isLoading = false;

  bool get isUserOnline => widget.user['isOnline'] ?? false;

  double getResponsiveFontSize(double scale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * scale;
  }

  // Permissions request
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
          title: Text("Choose Camera Option",
              style: AppTextStyles.headingText
                  .copyWith(fontSize: getResponsiveFontSize(0.04))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: AppColors.textColor,
                  backgroundColor: AppColors.buttonColor, // text color
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  Navigator.of(context)
                      .pop(await picker.pickImage(source: ImageSource.camera));
                },
                child: Text("Take Photo",
                    style: AppTextStyles.bodyText
                        .copyWith(fontSize: getResponsiveFontSize(0.04))),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: AppColors.textColor,
                  backgroundColor: AppColors.buttonColor, // text color
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  Navigator.of(context)
                      .pop(await picker.pickVideo(source: ImageSource.camera));
                },
                child: Text("Record Video",
                    style: AppTextStyles.bodyText
                        .copyWith(fontSize: getResponsiveFontSize(0.04))),
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

  Future<void> pickFromGallery() async {
    await requestPermissions();

    final pickedFile = await showDialog<XFile?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Choose Gallery Option",
              style: AppTextStyles.headingText
                  .copyWith(fontSize: getResponsiveFontSize(0.04))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: AppColors.textColor,
                  backgroundColor: AppColors.buttonColor, // text color
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  Navigator.of(context)
                      .pop(await picker.pickImage(source: ImageSource.gallery));
                },
                child: Text("Pick Image",
                    style: AppTextStyles.bodyText
                        .copyWith(fontSize: getResponsiveFontSize(0.04))),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: AppColors.textColor,
                  backgroundColor: AppColors.buttonColor, // text color
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  Navigator.of(context)
                      .pop(await picker.pickVideo(source: ImageSource.gallery));
                },
                child: Text("Pick Video",
                    style: AppTextStyles.bodyText
                        .copyWith(fontSize: getResponsiveFontSize(0.04))),
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

  void addMediaMessage(XFile pickedFile) {
    setState(() {
      isLoading = true;
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

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  void sendMessage() {
    if (messageController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
        messages.add({
          'type': 'text',
          'content': messageController.text,
        });
      });
      messageController.clear();

      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  void deleteMessage(int index) {
    setState(() {
      messages.removeAt(index);
    });
  }

  void editMessage(int index) {
    messageController.text = messages[index]['content'];

    // Show the bottom sheet to edit the message
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: messageController,
                decoration: InputDecoration(
                  hintText: "Edit your message",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if (messageController.text.isNotEmpty) {
                    setState(() {
                      messages.removeAt(index);
                      messages.insert(index, {
                        'type': 'text',
                        'content': messageController.text,
                      });
                      Navigator.pop(context);
                    });
                  }
                },
                child: Text("Save Changes"),
              ),
            ],
          ),
        );
      },
    );
  }

  void initiateVideoCall() {
    Get.snackbar("Video Call", "Initiating video call...",
        snackPosition: SnackPosition.BOTTOM);
  }

  void initiateVoiceCall() {
    Get.snackbar("Voice Call", "Initiating voice call...",
        snackPosition: SnackPosition.BOTTOM);
  }

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

  void showUserOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('User Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Block User'),
                onTap: () {
                  controller.blockUser(controller.blockToRequestModel);
                  Navigator.pop(context);
                  success('User Blocked', 'The user has been blocked.');
                },
              ),
              ListTile(
                title: Text('Report User'),
                onTap: () {
                  // Show report reason form
                  Navigator.pop(context);
                  showReportUserDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }
RxBool isselected = false.obs;
RxBool iswriting = false.obs;

void showReportUserDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Obx(() {
        // This makes the whole dialog reactive.
        return AlertDialog(
          title: Text('Report User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dropdown to select the reason
              DropdownButton<String>(
                hint: Text("Select Reason"),
                value: controller.reportUserReasonFeedbackRequestModel
                        .reasonId.isNotEmpty
                    ? controller.reportUserReasonFeedbackRequestModel.reasonId
                    : null,
                onChanged: (String? value) {
                  // When a reason is selected, update 'isselected' to true
                  controller.reportUserReasonFeedbackRequestModel.reasonId = value ?? '';
                  isselected.value = value != null && value.isNotEmpty; // Toggle isselected
                },
                items: controller.reportReasons
                    .map<DropdownMenuItem<String>>((ReportReason value) {
                  return DropdownMenuItem<String>(
                    value: value.id, // Assuming 'id' is a String
                    child: Text(value.title), // Display the title in the dropdown
                  );
                }).toList(),
              ),
              SizedBox(height: 10),

              // Only show the description TextField if a reason is selected
              if (isselected.value)
                TextField(
                  cursorColor: AppColors.cursorColor,
                  maxLength: 60,
                  decoration: InputDecoration(
                    hintText: 'Describe the issue...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.textColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  onChanged: (value) {
                    controller.reportUserReasonFeedbackRequestModel.reason = value;
                    iswriting.value = value.isNotEmpty;
                  },
                ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: iswriting.value
                  ? () {
                      if (controller.reportUserReasonFeedbackRequestModel
                              .reasonId.isNotEmpty &&
                          controller.reportUserReasonFeedbackRequestModel
                              .reason.isNotEmpty) {
                        controller.reportAgainstUser(
                            controller.reportUserReasonFeedbackRequestModel);
                        Navigator.pop(context);
                        success('Report Submitted', 'The user has been reported.');
                      } else {
                        failure('Error', 'Please select a reason and provide a description.');
                      }
                    }
                  : null, // Button is disabled if iswriting.value is false
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                backgroundColor: AppColors.buttonColor,
                foregroundColor: AppColors.textColor,
              ),
              child: Text('Submit Report'),
            )
          ],
        );
      });
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
                style: AppTextStyles.titleText
                    .copyWith(fontSize: getResponsiveFontSize(0.04))),
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
          onTap: showProfilePhoto,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: isUserOnline
                  ? BoxDecoration(
                      border: Border.all(
                        color: Colors.green,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(40),
                    )
                  : null,
              child: CircleAvatar(
                radius: 32,
                backgroundImage: NetworkImage(widget.user['imageUrl']),
                backgroundColor: AppColors.chipColor,
                child: isUserOnline
                    ? Align(
                        alignment: Alignment.bottomRight,
                        child: CircleAvatar(
                          radius: 8,
                          backgroundColor: Colors.green,
                        ),
                      )
                    : null,
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
          IconButton(
              onPressed: () {
                controller.reportReason().then((value) {
                  if (value == true) {
                    showUserOptionsDialog();
                  }
                });
              },
              icon: Icon(
                Icons.info,
                color: AppColors.inactiveColor,
              )),
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
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: GestureDetector(
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Options"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  title: Text("Edit Message"),
                                  onTap: () {
                                    editMessage(index);
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  title: Text("Delete Message"),
                                  onTap: () {
                                    deleteMessage(index);
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: ListTile(
                      title: message['type'] == 'text'
                          ? Text(
                              message['content'],
                              style: AppTextStyles.bodyText.copyWith(
                                  fontSize: getResponsiveFontSize(0.04)),
                            )
                          : message['type'] == 'image'
                              ? Image.file(File(message['content']))
                              : message['type'] == 'video'
                                  ? Text("Video message",
                                      style: AppTextStyles.bodyText.copyWith(
                                          fontSize:
                                              getResponsiveFontSize(0.04)))
                                  : Container(),
                    ),
                  ),
                );
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
                    style: AppTextStyles.inputFieldText
                        .copyWith(fontSize: getResponsiveFontSize(0.03)),
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
