import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../Controllers/controller.dart';
import '../../Models/RequestModels/estabish_connection_request_model.dart';
import '../../constants.dart';
import 'package:intl/intl.dart';

class MessageRequestPage extends StatefulWidget {
  const MessageRequestPage({super.key});

  @override
  MessageRequestPageState createState() => MessageRequestPageState();
}

class MessageRequestPageState extends State<MessageRequestPage> {
  final Controller controller = Get.find();

  String _normalizeBase64(String base64) {
    String clean = base64.contains(',') ? base64.split(',')[1] : base64;
    clean = clean.trim();
    final int remainder = clean.length % 4;
    if (remainder != 0) {
      clean += '=' * (4 - remainder);
    }
    return clean;
  }

  bool _isBase64Image(String? image) {
    if (image == null || image.isEmpty) return false;
    // If it starts with http, it's definitely a URL
    if (image.startsWith('http://') || image.startsWith('https://')) {
      return false;
    }
    final String trimmed = image.trim();
    // If it starts with /, it might be a base64 string (like /9j/ for JPEG)
    // or it could be a path - check if it's long enough to be base64
    if (trimmed.startsWith('/') && trimmed.length > 50) {
      // Likely base64 if it's long and starts with /9j/ (JPEG) or /iVB (PNG)
      if (trimmed.startsWith('/9j/') || trimmed.startsWith('/iVB')) {
        try {
          final String normalized = _normalizeBase64(trimmed);
          base64Decode(normalized);
          return true;
        } catch (_) {
          return false;
        }
      }
    }
    // Remove data URL prefix if present (e.g., "data:image/jpeg;base64,")
    String cleanImage = trimmed.contains(',') ? trimmed.split(',')[1] : trimmed;
    cleanImage = cleanImage.trim();
    // Base64 strings should be reasonably long (at least 20 chars for a tiny image)
    if (cleanImage.length < 20) return false;
    // Try to normalize and decode
    try {
      final String normalized = _normalizeBase64(cleanImage);
      base64Decode(normalized);
      return true;
    } catch (_) {
      return false;
    }
  }

  Widget _buildAvatar(String imageUrl, double radius) {
    if (imageUrl.isEmpty) {
      debugPrint('_buildAvatar: imageUrl is empty, showing placeholder');
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey.shade300,
        child: const Icon(Icons.person, color: Colors.white),
      );
    }

    final bool isBase64 = _isBase64Image(imageUrl);
    debugPrint('_buildAvatar: imageUrl length: ${imageUrl.length}, isBase64: $isBase64');

    if (isBase64) {
      try {
        final Uint8List bytes = base64Decode(_normalizeBase64(imageUrl));
        return CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey.shade200,
          child: ClipOval(
            child: Image.memory(
              bytes,
              fit: BoxFit.cover,
              width: radius * 2,
              height: radius * 2,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Error loading base64 avatar: $error');
                return CircleAvatar(
                  radius: radius,
                  backgroundColor: Colors.grey.shade300,
                  child: const Icon(Icons.person, color: Colors.white),
                );
              },
            ),
          ),
        );
      } catch (e) {
        debugPrint('Error decoding base64 avatar: $e');
        // Fallback to placeholder on decode failure
        return CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey.shade300,
          child: const Icon(Icons.person, color: Colors.white),
        );
      }
    }

    // Network image
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade200,
      child: ClipOval(
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: radius * 2,
          height: radius * 2,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return Container(
              width: radius * 2,
              height: radius * 2,
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            debugPrint('Error loading network avatar: $error');
            return Container(
              width: radius * 2,
              height: radius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade300,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            );
          },
        ),
      ),
    );
  }

  void showImageDialog(String imageUrl) {
    if (imageUrl.isEmpty) {
      debugPrint('showImageDialog: imageUrl is empty');
      return;
    }
    
    debugPrint('showImageDialog: imageUrl length: ${imageUrl.length}');
    debugPrint('showImageDialog: isBase64: ${_isBase64Image(imageUrl)}');
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Center(
              child: _isBase64Image(imageUrl)
                  ? Builder(
                      builder: (context) {
                        try {
                          final String normalized = _normalizeBase64(imageUrl);
                          final Uint8List bytes = base64Decode(normalized);
                          return Image.memory(
                            bytes,
                            fit: BoxFit.contain,
                            height: 300,
                            width: 300,
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint('Error displaying base64 image: $error');
                              return const Icon(
                                Icons.broken_image,
                                size: 100,
                                color: Colors.grey,
                              );
                            },
                          );
                        } catch (e) {
                          debugPrint('Error decoding base64 in dialog: $e');
                          return const Icon(
                            Icons.broken_image,
                            size: 100,
                            color: Colors.grey,
                          );
                        }
                      },
                    )
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      height: 300,
                      width: 300,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('Error loading network image in dialog: $error');
                        return const Icon(
                          Icons.broken_image,
                          size: 100,
                          color: Colors.grey,
                        );
                      },
                    ),
            ),
          ),
        );
      },
    );
  }

  String formatRequestDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inSeconds < 60) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return DateFormat('dd/MM/yy').format(dateTime);
      }
    } catch (e) {
      return '';
    }
  }

  Future<void> _refreshMessageRequests() async {
    await controller.fetchallpingrequestmessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Builder(
          builder: (context) {
            double fontSize = MediaQuery.of(context).size.width * 0.05;
            return Text(
              'Message Requests',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
                color: AppColors.textColor,
              ),
            );
          },
        ),
        foregroundColor: AppColors.textColor,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.gradientBackgroundList,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshMessageRequests,
        color: AppColors.lightGradientColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Obx(() {
            final receivedMessages = controller.messageRequest
                .where((request) => request.messageSendByMe == 0)
                .toList();

            if (receivedMessages.isEmpty) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: constraints.maxHeight,
                      child: Center(
                        child: Lottie.asset(
                          "assets/animations/requestmessageanimation.json",
                          repeat: true,
                          reverse: true,
                        ),
                      ),
                    ),
                  );
                },
              );
            }
            return LayoutBuilder(
              builder: (context, constraints) {
                double screenWidth = constraints.maxWidth;

                return ListView.builder(
                  itemCount: receivedMessages.length,
                  itemBuilder: (context, index) {
                    final messageRequest = receivedMessages[index];

                    return Card(
                      // margin: EdgeInsets.only(bottom: 5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 4,
                      child: ListTile(
                        contentPadding: EdgeInsets.all(5),
                        leading: GestureDetector(
                          onTap: () {
                            debugPrint('Avatar tapped, profileImage: ${messageRequest.profileImage?.isEmpty == false ? 'has image (length: ${messageRequest.profileImage.length})' : 'empty or null'}');
                            if (messageRequest.profileImage != null && messageRequest.profileImage.isNotEmpty) {
                              showImageDialog(messageRequest.profileImage);
                            }
                          },
                          child: _buildAvatar(
                            messageRequest.profileImage ?? '',
                            screenWidth < 600 ? 30 : 40,
                          ),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                messageRequest.name,
                                style: AppTextStyles.bodyText.copyWith(
                                  fontSize: screenWidth < 600 ? 16 : 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              formatRequestDate(messageRequest.created),
                              style: AppTextStyles.bodyText.copyWith(
                                color: AppColors.disabled,
                                fontSize: screenWidth < 600 ? 12 : 14,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          messageRequest.message,
                          style: AppTextStyles.bodyText.copyWith(
                            color: AppColors.disabled,
                            fontSize: screenWidth < 600 ? 14 : 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.reply,
                              color: AppColors.lightGradientColor),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReplyMessagePage(
                                  senderName: messageRequest.name,
                                  senderId: messageRequest.userId,
                                  lastMessage: messageRequest.message,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }),
        ),
      ),
    );
  }
}

class ReplyMessagePage extends StatefulWidget {
  final String senderName;
  final String senderId;
  final String lastMessage;

  const ReplyMessagePage({
    super.key,
    required this.senderName,
    required this.senderId,
    required this.lastMessage,
  });

  @override
  ReplyMessagePageState createState() => ReplyMessagePageState();
}

class ReplyMessagePageState extends State<ReplyMessagePage> {
  TextEditingController messageController = TextEditingController();
  final Controller controller = Get.find();
  EstablishConnectionMessageRequest establishConnectionMessageRequest =
      EstablishConnectionMessageRequest(
          message: '', receiverId: '', messagetype: textMessage);
  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reply to ${widget.senderName}",
            style: AppTextStyles.headingText),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.lastMessage,
                            style: AppTextStyles.bodyText
                                .copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: InputDecoration(
                labelText: 'Write your message...',
                labelStyle: AppTextStyles.bodyText,
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: _isSending
                      ? CircularProgressIndicator(color: AppColors.textColor)
                      : Icon(Icons.send, color: AppColors.textColor),
                  onPressed: _isSending
                      ? null
                      : () {
                          sendMessage(widget.senderId, messageController.text);
                        },
                ),
              ),
              style: AppTextStyles.bodyText,
              cursorColor: AppColors.cursorColor,
            ),
          ],
        ),
      ),
    );
  }

  void sendMessage(String senderId, String message) async {
    if (message.trim().isEmpty) {
      failure("Message Empty", "Please write a message to send.");
      return;
    }
    setState(() {
      _isSending = true;
    });

    establishConnectionMessageRequest.message = message;
    establishConnectionMessageRequest.receiverId = senderId;

    bool messageSent = await controller
        .sendConnectionMessage(establishConnectionMessageRequest);

    if (messageSent) {
      // Success notification is already shown by sendConnectionMessage
      // but we can add additional feedback here if needed
      await controller.fetchallpingrequestmessage();
      await controller.fetchalluserconnections();
      messageController.clear();
      // Additional success feedback for favorites page context
      success('Message Sent!', 'Your message has been sent successfully');
    }

    if (mounted) {
      setState(() {
        _isSending = false;
      });
    }
  }
}
