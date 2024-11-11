
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import '../../constants.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:permission_handler/permission_handler.dart'; 
import 'package:video_player/video_player.dart'; 

class ChatPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const ChatPage({super.key, required this.user});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> _messages = []; // List to hold messages and media files

  // @override
  // void initState() {
  //   super.initState();
  //   // Disable screenshots for this page
  //   FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  // }

  // @override
  // void dispose() {
  //   // Remove the screenshot flag when exiting the page
  //   FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
  //   super.dispose();
  // }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        _messages.add({
          'type': 'text',
          'content': _messageController.text,
        });
      });
      _messageController.clear();
    }
  }


  void _startVideoCall() {
    print("Starting video call with ${widget.user['name']}");
  }

 
  void _startVoiceCall() {
    print("Starting voice call with ${widget.user['name']}");
  }


  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.request();
    if (status.isDenied) {
      Get.snackbar('Permission Denied', "Camera permission denied");
    }
  }

  // Request gallery permission
  Future<void> _requestGalleryPermission() async {
    var status = await Permission.photos.request();
    if (status.isDenied) {
      Get.snackbar('Permission Denied', "Gallery permission denied");
    }
  }

  Future<void> _pickImageOrVideo() async {

    await _requestGalleryPermission();
    await _requestCameraPermission();

    // Show dialog to choose between gallery or camera
    final pickedFile = await showDialog<XFile?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Choose an option"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text("Pick Image from Gallery"),
                onTap: () async {
                  Navigator.of(context).pop(await _picker.pickImage(source: ImageSource.gallery));
                },
              ),
              ListTile(
                title: Text("Pick Video from Gallery"),
                onTap: () async {
                  Navigator.of(context).pop(await _picker.pickVideo(source: ImageSource.gallery));
                },
              ),
              ListTile(
                title: Text("Take Photo with Camera"),
                onTap: () async {
                  Navigator.of(context).pop(await _picker.pickImage(source: ImageSource.camera));
                },
              ),
              ListTile(
                title: Text("Record Video with Camera"),
                onTap: () async {
                  Navigator.of(context).pop(await _picker.pickVideo(source: ImageSource.camera));
                },
              ),
            ],
          ),
        );
      },
    );

    if (pickedFile != null) {
      setState(() {
        if (pickedFile.path.endsWith('.mp4')) {
          // It's a video
          _messages.add({
            'type': 'video',
            'content': pickedFile.path,
          });
        } else {
          // It's an image
          _messages.add({
            'type': 'image',
            'content': pickedFile.path,
          });
        }
      });
    } else {
      print('No file picked');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondaryColor,
        title: Text("Chat with ${widget.user['name']}", style: AppTextStyles.titleText),
        actions: [
          IconButton(
            icon: Icon(Icons.call, color: AppColors.iconColor),
            onPressed: _startVoiceCall,
          ),
          IconButton(
            icon: Icon(Icons.video_call, color: AppColors.iconColor),
            onPressed: _startVideoCall,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                if (message['type'] == 'text') {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(message['content'], style: AppTextStyles.bodyText),
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
                      title: VideoPlayerWidget(path: message['content']),
                    ),
                  );
                }
                return Container(); // Default case
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.upload_rounded, color: AppColors.iconColor),
                  onPressed: _pickImageOrVideo, // Open gallery or camera options on tap
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: AppTextStyles.inputFieldText,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: AppTextStyles.customTextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.formFieldColor,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: AppColors.iconColor),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String path;
  VideoPlayerWidget({required this.path});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.path))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.value.isInitialized) {
      return AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: VideoPlayer(_controller),
      );
    } else {
      return CircularProgressIndicator();
    }
  }
}
