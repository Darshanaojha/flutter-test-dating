import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:dating_application/Controllers/controller.dart';
import 'package:dating_application/Screens/chatpage/VideoCallPage.dart';
import 'package:dating_application/constants.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // Added import
import 'package:permission_handler/permission_handler.dart';
import 'package:vibration/vibration.dart';

import '../../Models/ResponseModels/chat_history_response_model.dart';
import '../../Providers/WebsocketService.dart';
import '../userprofile/userprofilesummary.dart';
import 'AudioCallPage.dart';
import '../../ui/chat_neon_glass/neon_chat_live_screen.dart';
import 'package:dating_application/widgets/frosted_dialog.dart';

class ChatScreen extends StatefulWidget {
  final String senderId;
  final String receiverId;
  final String receiverName;
  final String receiverImageUrl;

  const ChatScreen({
    super.key,
    required this.senderId,
    required this.receiverId,
    required this.receiverName,
    required this.receiverImageUrl,
  });

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  Controller controller = Get.find<Controller>();
  final WebSocketService websocketService = WebSocketService();
  File? selectedImage;
  final TextEditingController messageController = TextEditingController();
  String? bearerToken =
      EncryptedSharedPreferences.getInstance().getString('token');
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    websocketService.connect(controller.token.value);
    
    // Fetch chat history and scroll to bottom after loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchChats(widget.receiverId).then((_) {
        // Scroll to bottom after messages are loaded
        _scrollToBottom();
      });
    });
  }

  void _scrollToBottom() {
    // Wait a bit longer to ensure images are loaded and rendered
    Future.delayed(const Duration(milliseconds: 300), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        // If controller doesn't have clients yet, wait a bit more and try again
        Future.delayed(const Duration(milliseconds: 200), () {
          if (scrollController.hasClients) {
            scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
  }

  /// Helper function to normalize base64 string (add padding if needed)
  String _normalizeBase64(String base64) {
    // Remove data URL prefix if present
    String clean = base64.contains(',') ? base64.split(',')[1] : base64;
    // Remove whitespace
    clean = clean.trim();
    // Add padding if needed (base64 strings should be divisible by 4)
    int remainder = clean.length % 4;
    if (remainder != 0) {
      clean += '=' * (4 - remainder);
    }
    return clean;
  }

  /// Helper function to check if a string is a base64 image
  bool _isBase64Image(String? image) {
    if (image == null || image.isEmpty) return false;
    // If it starts with http, it's definitely a URL
    if (image.startsWith('http://') || image.startsWith('https://')) {
      return false;
    }
    // If it starts with /, it might be a base64 string (like /9j/ for JPEG)
    // or it could be a path - check if it's long enough to be base64
    if (image.startsWith('/') && image.length > 50) {
      // Likely base64 if it's long and starts with /9j/ (JPEG) or /iVB (PNG)
      if (image.startsWith('/9j/') || image.startsWith('/iVB')) {
        try {
          String normalized = _normalizeBase64(image);
          base64Decode(normalized);
          return true;
        } catch (e) {
          return false;
        }
      }
    }
    // Remove data URL prefix if present (e.g., "data:image/jpeg;base64,")
    String cleanImage = image.contains(',') ? image.split(',')[1] : image;
    cleanImage = cleanImage.trim();
    // Base64 strings should be reasonably long (at least 20 chars for a tiny image)
    if (cleanImage.length < 20) return false;
    // If it's a very long string without http, it's likely base64
    if (cleanImage.length > 100) {
      try {
        String normalized = _normalizeBase64(cleanImage);
        base64Decode(normalized);
        return true;
      } catch (e) {
        return false;
      }
    }
    // Try to normalize and decode
    try {
      String normalized = _normalizeBase64(cleanImage);
      base64Decode(normalized);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Build image widget that handles both network URLs and base64 strings
  Widget _buildProfileImageWidget(String imageUrl, {double radius = 20}) {
    if (imageUrl.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey.shade800,
        child: Icon(
          Icons.person,
          size: radius,
          color: Colors.white.withOpacity(0.7),
        ),
      );
    }

    if (_isBase64Image(imageUrl)) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey.shade800,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Builder(
            builder: (context) {
              try {
                String normalizedBase64 = _normalizeBase64(imageUrl);
                Uint8List imageBytes = base64Decode(normalizedBase64);
                return Image.memory(
                  imageBytes,
                  fit: BoxFit.cover,
                  width: radius * 2,
                  height: radius * 2,
                  errorBuilder: (context, error, stackTrace) {
                    print('Error displaying base64 image: $error');
                    return Icon(
                      Icons.person,
                      size: radius,
                      color: Colors.white.withOpacity(0.7),
                    );
                  },
                );
              } catch (e) {
                print('Error decoding base64 image: $e');
                return Icon(
                  Icons.person,
                  size: radius,
                  color: Colors.white.withOpacity(0.7),
                );
              }
            },
          ),
        ),
      );
    } else {
      // Network image
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey.shade800,
        backgroundImage: NetworkImage(imageUrl),
        onBackgroundImageError: (exception, stackTrace) {
          print('Error loading network image: $exception');
        },
        child: imageUrl.isEmpty
            ? Icon(
                Icons.person,
                size: radius,
                color: Colors.white.withOpacity(0.7),
              )
            : null,
      );
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    websocketService.disconnect();
    super.dispose();
  }

  // void _sendMessage() {
  //   final messageText = messageController.text.trim();
  //   if (messageText.isNotEmpty) {
  //     websocketService.sendMessage(
  //         '/app/sendMessage',
  //         Message(
  //                 id: null,
  //                 senderId: widget.senderId,
  //                 receiverId: widget.receiverId,
  //                 message: controller.encryptMessage(messageText, secretkey),
  //                 messageType: 1,
  //                 created: DateTime.now().toIso8601String(),
  //                 updated: DateTime.now().toIso8601String(),
  //                 status: 1,
  //                 isEdited: 0,
  //                 deletedBySender: 0,
  //                 deletedByReceiver: 0,
  //                 deletedAtReceiver: null,
  //                 deletedAtSender: null)
  //             .toJson());

  //     messageController.clear();
  //     controller.fetchChats(widget.receiverId);
  //   }
  // }

  Future<void> _sendMessage({
    required String message,
    required String receiverId,
    File? image,
  }) async {
    final sharedPreferences = EncryptedSharedPreferences.getInstance();
    final token = sharedPreferences
        .getString('token'); // Await here if getString is async

    debugPrint('Bearer Token: $token');
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$springbooturl/ChatController/send-message'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.fields['receiverId'] = receiverId;
    request.fields['message'] = message;

    debugPrint('Chat reqeust header: ${request.headers}');

    if (image != null) {
      // Compress the image and convert to base64
      String? base64ImageString;
      
      try {
        // Compress the image before converting to base64
        // Use higher quality (85) for better visual quality in fullscreen
        // minWidth/minHeight ensure larger images maintain detail
        final compressedImageBytes = await FlutterImageCompress.compressWithFile(
          image.path,
          quality: 85,
          minWidth: 1920,
          minHeight: 1920,
        );

        if (compressedImageBytes != null) {
          // Convert compressed image to base64
          base64ImageString = base64Encode(compressedImageBytes);
          print('✅ Image compressed and converted to base64: ${base64ImageString.length} characters');
        } else {
          print('❌ Image compression failed, using original image');
          // Fallback to original image if compression fails
          final originalImageBytes = await image.readAsBytes();
          base64ImageString = base64Encode(originalImageBytes);
        }
      } catch (e) {
        print('❌ Error compressing image: $e, using original image');
        // Fallback to original image if compression fails
        final originalImageBytes = await image.readAsBytes();
        base64ImageString = base64Encode(originalImageBytes);
      }
      
      request.fields['image'] = base64ImageString!;
      // Use the base64 string (stored in base64ImageString variable)
      // You can use this variable as needed
      
      // request.files.add(
      //   await http.MultipartFile.fromPath(
      //     'image',
      //     image.path,
      //     contentType: MediaType('image', 'jpeg'), // or detect content type
      //   ),
      // );
    }

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        print('✅ Message sent successfully');
      } else {
        print('❌ Failed to send message. Status code: ${response.statusCode}');
        final body = await response.stream.bytesToString();
        print('Response body: $body');
      }
    } catch (e) {
      print('❗ Exception sending message: $e');
    }
  }

  List<Message> selectedMessages = []; // List to track selected messages
  // Toggle selection of a message
  void toggleSelection(Message message) {
    setState(() {
      if (selectedMessages.contains(message)) {
        selectedMessages.remove(message);
      } else {
        selectedMessages.add(message);
      }
    });
  }

  // Method to delete selected messages
  Future<void> deleteSelectedMessages() async {
    bool proceed = false;
    await showFrostedDialog(
      context: context,
      title: 'Delete selected?',
      message: 'This will permanently delete the selected messages.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      onConfirm: () async {
        proceed = true;
      },
    );
    if (!proceed) return;

    if (selectedMessages.isNotEmpty) {
      bool success = await controller
          .deleteChats(selectedMessages); // Your method to delete
      if (success) {
        setState(() {
          controller.messages
              .removeWhere((msg) => selectedMessages.contains(msg));
          selectedMessages.clear(); // Clear selected messages after deletion
        });
      } else {
        failure('Error', 'Error deleting the chat');
      }
    }
  }

  Future<void> deleteAllMessages() async {
    bool proceed = false;
    await showFrostedDialog(
      context: context,
      title: 'Delete all?',
      message: 'This will permanently delete all messages in this chat.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      onConfirm: () async {
        proceed = true;
      },
    );
    if (!proceed) return;

    List<Message> selectedMessages = controller.messages
        .where((m) => m.senderId == widget.senderId)
        .toList();
    bool success =
        await controller.deleteChats(selectedMessages); // Your method to delete
    if (success) {
      setState(() {
        controller.messages.removeWhere(
            (m) => selectedMessages.any((selected) => selected.id == m.id));
        selectedMessages.clear();
      });
    } else {
      failure('Error', 'Error deleting the chat');
    }
  }

  Future<void> deleteSingleMessage(int index) async {
    bool proceed = false;
    await showFrostedDialog(
      context: context,
      title: 'Delete message?',
      message: 'This will permanently delete this message.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      onConfirm: () async {
        proceed = true;
      },
    );
    if (!proceed) return;

    selectedMessages.clear();
    selectedMessages.add(controller.messages[index]);
    bool success =
        await controller.deleteChats(selectedMessages); // Your method to delete
    if (success) {
      setState(() {
        controller.messages
            .removeWhere((msg) => selectedMessages.contains(msg));
        selectedMessages.clear(); // Clear selected messages after deletion
      });
    } else {
      failure('Error', 'Error deleting the chat');
    }
  }

  void _showMessageDialog(BuildContext context, Message message, int index) {
    showFrostedTextInputDialog(
      context: context,
      title: 'Edit Message',
      hintText: 'Edit your message',
      initialValue: message.message ?? '',
      confirmText: 'Update',
      cancelText: 'Cancel',
      onConfirm: (editedText) {
        _editMessage(editedText, index);
      },
    );
  }

  void _editMessage(String newMessage, int index) async {
    if (newMessage.trim().isEmpty) {
      return;
    }

    Message originalMessage = controller.messages[index];

    Message updatedMessageForUI = originalMessage.copyWith(
      message: newMessage,
      isEdited: 1,
      deletedAtReceiver: null,
      deletedAtSender: null,
      deletedBySender: 0,
      deletedByReceiver: 0,
    );

    controller.messages[index] = updatedMessageForUI;

    Message messageForBackend = updatedMessageForUI.copyWith(
      message: controller.encryptMessage(newMessage, secretkey),
    );

    await controller.updateChats(messageForBackend);
  }

  RxString selectedReason = ''.obs;
  RxString selectedReasonId = ''.obs;
  bool isLoading = true;
  RxBool isselected = false.obs;
  RxBool iswriting = false.obs;
  RxString reportDescription = ''.obs;

  // Group messages by date
  Map<String, List<Message>> _groupMessagesByDate(List<Message> messages) {
    final Map<String, List<Message>> groupedMessages = {};

    for (var message in messages) {
      if (message.created != null) {
        final createdDate = DateTime.parse(message.created!);
        final dateKey = DateFormat('yyyy-MM-dd').format(createdDate);
        if (!groupedMessages.containsKey(dateKey)) {
          groupedMessages[dateKey] = [];
        }
        groupedMessages[dateKey]!.add(message);
      }
    }

    return groupedMessages;
  }

  // Format date for display
  String _formatDateHeader(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));

    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return 'Today';
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    } else {
      return DateFormat('MMMM d, yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
  backgroundColor: Colors.transparent,
  extendBodyBehindAppBar: true,
  extendBody: true,
body: Stack(
  children: [
    Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.gradientBackgroundList,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    ),
    Material(
      color: Colors.transparent,
      child: Column(
        children: [
          Expanded(
            child: NeonChatLiveScreen(
              controller: controller,
              messageController: messageController,
              scrollController: scrollController,
              bearerToken: bearerToken ?? '',
              onSendMessage: ({
                required String message,
                required String receiverId,
                File? image,
              }) async {
                // Preserve legacy encryption + upload pipeline.
                final String encrypted =
                    controller.encryptMessage(message, secretkey);
                await _sendMessage(
                  message: encrypted,
                  receiverId: receiverId,
                  image: image,
                );
              },
              pickImageFromGallery: () async {
                return await _pickImage(ImageSource.gallery);
              },
              viewerId: widget.senderId,
              peerId: widget.receiverId,
              peerName: widget.receiverName,
              peerImageUrl: widget.receiverImageUrl,
            ),
          ),
        ],
      ),
    ),
  ],
),



    );
  }

  Widget _buildImagePickerOptions() {
    return SafeArea(
      child: Wrap(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.photo_library),
            title: Text('Gallery'),
            onTap: () async {
              final picked = await _pickImage(ImageSource.gallery);
              Navigator.pop(context, picked);
            },
          ),
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text('Camera'),
            onTap: () async {
              final picked = await _pickImage(ImageSource.camera);
              Navigator.pop(context, picked);
            },
          ),
        ],
      ),
    );
  }

  Future<bool> _requestPermission(
      Permission permission, String permissionName) async {
    var status = await permission.status;
    if (status.isGranted || (status.isLimited && Platform.isIOS)) {
      return true;
    } else if (status.isDenied) {
      status = await permission.request();
      if (status.isGranted || (status.isLimited && Platform.isIOS)) {
        return true;
      } else {
        Get.snackbar(
            'Permission Denied', "$permissionName permission is required.");
        return false;
      }
    } else if (status.isPermanentlyDenied || status.isRestricted) {
      Get.snackbar(
        'Permission Required',
        "$permissionName permission has been permanently denied. Please enable it in app settings.",
        mainButton: TextButton(
          child: const Text("Open Settings"),
          onPressed: () {
            openAppSettings();
          },
        ),
        duration: const Duration(seconds: 5),
      );
      return false;
    }
    return false;
  }

  Future<bool> _requestGalleryPermission() async {
    try {
      // Handle platform-specific permissions
      if (Platform.isAndroid) {
        // On Android 13+, we need both photos and storage permissions
        if (await Permission.storage.isGranted ||
            await Permission.photos.isGranted) {
          return true;
        }

        // Request the appropriate permissions
        final status = await Permission.storage.request();
        if (status.isGranted) return true;

        // If storage is denied but photos is granted (Android 13+)
        if (await Permission.photos.isGranted) return true;

        // Final fallback request
        final photosStatus = await Permission.photos.request();
        return photosStatus.isGranted;
      } else if (Platform.isIOS) {
        // On iOS, we only need photos permission
        var status = await Permission.photos.status;

        if (status.isGranted || status.isLimited) {
          return true;
        }

        // Request permission if not determined
        status = await Permission.photos.request();
        return status.isGranted || status.isLimited;
      }

      // Default case for other platforms
      return false;
    } catch (e) {
      print('Error checking gallery permission: $e');
      return false;
    }
  }

  Future<XFile?> _pickImage(ImageSource source) async {
    try {
      bool permissionGranted = false;

      if (source == ImageSource.camera) {
        permissionGranted =
            await _requestPermission(Permission.camera, "Camera");
      } else if (source == ImageSource.gallery) {
        permissionGranted = await _requestGalleryPermission();

        // Additional check to prevent settings popup when permission is actually granted
        if (!permissionGranted) {
          final currentStatus = Platform.isAndroid
              ? (await Permission.storage.status).isGranted ||
                  (await Permission.photos.status).isGranted
              : (await Permission.photos.status).isGranted ||
                  (await Permission.photos.status).isLimited;

          if (currentStatus) {
            permissionGranted = true;
          }
        }
      }

      if (!permissionGranted) {
        // Only show settings suggestion if permission is truly denied
        final status = Platform.isAndroid
            ? await Permission.storage.status
            : await Permission.photos.status;

        if (status.isPermanentlyDenied || status.isRestricted) {
          _showPermissionSettingsDialog(
              context, Platform.isAndroid ? "Storage" : "Photos");
        }
        return null;
      }

      return await ImagePicker().pickImage(source: source);
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  void _showPermissionSettingsDialog(
      BuildContext context, String permissionName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Permission Required"),
        content: Text(
            "$permissionName permission is required to access this feature. "
            "Please enable it in your device settings."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  Future<void> showReportUserDialog(reporttouserid) async {
    await controller.reportReason();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Obx(() {
          String displayText = selectedReason.value.isEmpty
              ? 'Select Reason'
              : selectedReason.value;
          String truncatedText = displayText.length > 30
              ? '${displayText.substring(0, 30)}...'
              : displayText;

          return AlertDialog(
            title: Text('Report User'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: AppColors.activeColor, width: 2),
                    ),
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16))),
                      builder: (_) {
                        return ListView(
                          children: controller.reportReasons.map((reason) {
                            return ListTile(
                              title: Text(reason.title),
                              onTap: () {
                                selectedReason.value = reason.title;
                                selectedReasonId.value = reason.id;
                                isselected.value = true;
                                controller.reportUserReasonFeedbackRequestModel
                                    .reasonId = reason.id;
                                // Get.snackbar(
                                //     "selected reasonId",
                                //     controller
                                //         .reportUserReasonFeedbackRequestModel
                                //         .reasonId
                                //         .toString());
                                Get.snackbar("selected reasonId with title",
                                    "${selectedReason.value} title ${selectedReasonId.value}");
                                Navigator.pop(context, reason.id);
                              },
                            );
                          }).toList(),
                        );
                      },
                      //label: "Select Reason",
                      // options: controller.reportReasons
                      //     .map((reason) => reason.id)
                      //     .toList(),
                      // onSelected: (String? value) {
                      //   Get.snackbar(
                      //       "selected reasonId",
                      //       controller
                      //           .reportUserReasonFeedbackRequestModel.reasonId
                      //           .toString());
                      //   if (value != null && value.isNotEmpty) {
                      //     selectedReason.value = value;
                      //     selectedReasonId.value. =
                      //     isselected.value = true;
                      //   } else {
                      //     isselected.value = false;
                      //   }
                      // },
                    );
                    // showBottomSheet(
                    //   context: context,
                    //   label: "Select Reason",
                    //   options: controller.reportReasons
                    //       .map((reason) => reason.id)
                    //       .toList(),
                    //   onSelected: (String? value) {
                    //     Get.snackbar(
                    //         "selected reasonId",
                    //         controller
                    //             .reportUserReasonFeedbackRequestModel.reasonId
                    //             .toString());
                    //     if (value != null && value.isNotEmpty) {
                    //       selectedReason.value = value;
                    //       selectedReasonId.value. =
                    //       isselected.value = true;
                    //     } else {
                    //       isselected.value = false;
                    //     }
                    //   },
                    // );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Text(
                          truncatedText,
                          style: AppTextStyles.bodyText,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_drop_down,
                        color: AppColors.activeColor,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
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
                      reportDescription.value = value;
                      iswriting.value = value.isNotEmpty;
                    },
                  ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: iswriting.value
                    ? () {
                        if (selectedReason.value.isNotEmpty &&
                            reportDescription.value.isNotEmpty) {
                          controller.reportUserReasonFeedbackRequestModel
                              .reasonId = selectedReasonId.value;
                          controller.reportUserReasonFeedbackRequestModel
                              .reason = reportDescription.value;
                          controller.reportUserReasonFeedbackRequestModel
                              .reportAgainst = reporttouserid;
                          Get.snackbar(
                              "selected description",
                              controller
                                  .reportUserReasonFeedbackRequestModel.reason
                                  .toString());
                          Get.snackbar(
                              "selected reasonId",
                              controller
                                  .reportUserReasonFeedbackRequestModel.reasonId
                                  .toString());
                          Get.snackbar(
                              "selected report against",
                              controller.reportUserReasonFeedbackRequestModel
                                  .reportAgainst
                                  .toString());
                          controller.reportAgainstUser(
                              controller.reportUserReasonFeedbackRequestModel);
                          Navigator.pop(context);

                          success('Report Submitted',
                              'The user has been reported.');
                        } else {
                          failure('Error',
                              'Please select a reason and provide a description.');
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                  backgroundColor: AppColors.buttonColor,
                  foregroundColor: AppColors.textColor,
                ),
                child: Text('Report User'),
              ),
            ],
          );
        });
      },
    );
  }

  void showBottomSheet({
    required BuildContext context,
    required String label,
    required List<String> options,
    required Function(String?) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextStyles.bodyText.copyWith(fontSize: 18),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView(
                  children: List.generate(options.length, (index) {
                    return RadioListTile<String>(
                      title:
                          Text(options[index], style: AppTextStyles.bodyText),
                      value: options[index],
                      groupValue: selectedReason.value,
                      onChanged: (String? value) {
                        onSelected(value);
                        Navigator.pop(context);
                      },
                      activeColor: AppColors.activeColor,
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// controller.encryptMessage( messageController.text.trim(), secretkey)

class SensitiveImageWidget extends StatefulWidget {
  final String imagePath;
  final String bearerToken;
  final String sensitivity;

  const SensitiveImageWidget({
    super.key,
    required this.imagePath,
    required this.bearerToken,
    required this.sensitivity,
  });

  @override
  State<SensitiveImageWidget> createState() => _SensitiveImageWidgetState();
}

class _SensitiveImageWidgetState extends State<SensitiveImageWidget> {
  bool _showBlur = true;
  late Future<String> _imageFuture;

  @override
  void initState() {
    super.initState();
    _imageFuture = _fetchImageBytes(widget.imagePath, widget.bearerToken);
  }

  @override
  void didUpdateWidget(covariant SensitiveImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imagePath != oldWidget.imagePath ||
        widget.bearerToken != oldWidget.bearerToken) {
      _imageFuture = _fetchImageBytes(widget.imagePath, widget.bearerToken);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _imageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Icon(Icons.broken_image);
        } else if (snapshot.hasData) {
          // Decode base64 string to bytes for Image.memory
          final imageBytes = base64Decode(snapshot.data!);
          
          // Responsive image sizing
          final screenWidth = MediaQuery.of(context).size.width;
          final imageSize = (screenWidth * 0.5).clamp(150.0, 250.0);
          
          Widget chatBubbleImage = ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              imageBytes,
              width: imageSize,
              height: imageSize,
              fit: BoxFit.cover,
            ),
          );

          Widget fullScreenImage = Image.memory(
            imageBytes,
          );

          if (widget.sensitivity != "non-explicit" && _showBlur) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _showBlur = false;
                });
              },
              child: Stack(
                children: [
                  // Blurred image
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: chatBubbleImage,
                  ),
                  // Simple overlay - Reddit style
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.black.withOpacity(0.1),
                      ),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20, 
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "View sensitive content",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            // Not sensitive or user has chosen to view
            return GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: EdgeInsets.all(10),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: InteractiveViewer(
                          child: fullScreenImage,
                        ),
                      ),
                    );
                  },
                );
              },
              child: chatBubbleImage,
            );
          }
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Future<String> _fetchImageBytes(
      String imagePath, String bearerToken) async {
    final response = await http.get(
      Uri.parse('$springbooturl/ChatController/uploads/$imagePath'),
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      // Backend returns base64 string, return it directly
      return response.body;
    } else {
      throw Exception('Failed to load image');
    }
  }
}
