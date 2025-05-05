import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../../../../constants.dart';

class CreateNewPostPage extends StatefulWidget {
  const CreateNewPostPage({super.key});

  @override
  State<CreateNewPostPage> createState() => _CreateNewPostPageState();
}

class _CreateNewPostPageState extends State<CreateNewPostPage> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _captionController = TextEditingController();

  XFile? _mediaFile;
  bool _isVideo = false;
  VideoPlayerController? _videoController;

  double getResponsiveFontSize(double scale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * scale;
  }
  Future<XFile?> _showMediaPickerDialog() async {
    return await showModalBottomSheet<XFile>(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.image, color: Colors.white),
                title:  Text("Pick Image from Gallery",
                     style: AppTextStyles.bodyText.copyWith(
                    fontSize: getResponsiveFontSize(0.03),
                    color: Colors.white,
                  ),),
                onTap: () async {
                  final file =
                      await _picker.pickImage(source: ImageSource.gallery);
                  Navigator.pop(context, file);
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_library, color: Colors.white),
                title:  Text("Pick Video from Gallery",
                     style: AppTextStyles.bodyText.copyWith(
                    fontSize: getResponsiveFontSize(0.03),
                    color: Colors.white,
                  ),),
                onTap: () async {
                  final file =
                      await _picker.pickVideo(source: ImageSource.gallery);
                  Navigator.pop(context, file);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickMedia({required bool fromCamera}) async {
    final XFile? file = fromCamera
        ? await _picker.pickVideo(source: ImageSource.camera)
        : await _showMediaPickerDialog();

    if (file != null) {
      _disposeVideoController();

      final isVideoFile = file.path.toLowerCase().endsWith('.mp4') ||
          file.path.toLowerCase().endsWith('.mov') ||
          file.path.toLowerCase().endsWith('.avi');

      setState(() {
        _mediaFile = file;
        _isVideo = isVideoFile;
      });

      if (_isVideo) {
        _videoController = VideoPlayerController.file(File(file.path));
        await _videoController!.initialize();
        _videoController!
          ..setLooping(true)
          ..play();
        setState(() {});
      }
    }
  }

  void _disposeVideoController() {
    _videoController?.dispose();
    _videoController = null;
  }

  void _publishPost() {
    if (_mediaFile == null) return;

    Get.back(result: {
      'mediaPath': _mediaFile!.path,
      'caption': _captionController.text.trim(),
      'isVideo': _isVideo,
    });
  }

  @override
  void dispose() {
    _disposeVideoController();
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final file = _mediaFile != null ? File(_mediaFile!.path) : null;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Create Post", style: AppTextStyles.bodyText.copyWith(
                    fontSize: getResponsiveFontSize(0.03),
                    color: Colors.white,
                  ),),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: _publishPost,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Media Preview
            Container(
              height: 260,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: _mediaFile == null
                  ? Center(
                      child: Text(
                        "No media selected",
                        style: AppTextStyles.bodyText.copyWith(
                          fontSize: getResponsiveFontSize(0.03),
                          color: Colors.white,
                        ),
                      ),
                    )
                  : _isVideo
                      ? _videoController != null &&
                              _videoController!.value.isInitialized
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: AspectRatio(
                                aspectRatio:
                                    _videoController!.value.aspectRatio,
                                child: VideoPlayer(_videoController!),
                              ),
                            )
                          : const Center(child: CircularProgressIndicator())
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(file!, fit: BoxFit.cover),
                        ),
            ),
       SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),

            // Caption Input
            TextField(
              controller: _captionController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Write a caption...",
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
           SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickMedia(fromCamera: false),
                    icon: const Icon(Icons.photo_library),
                    label: Text(
                      "Pick from Gallery",
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: getResponsiveFontSize(0.03),
                        color: Colors.white,
                      ),
                    ),
                    style: _buttonStyle(),
                  ),
                ),
               SizedBox(
                    width: MediaQuery.of(context).size.width * 0.02,
                  ),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickMedia(fromCamera: true),
                    icon: const Icon(Icons.videocam),
                    label: Text(
                      "Record Video",
                      style: AppTextStyles.bodyText.copyWith(
                        fontSize: getResponsiveFontSize(0.03),
                        color: Colors.white,
                      ),
                    ),
                    style: _buttonStyle(),
                  ),
                ),
                if (_mediaFile != null) ...[
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.02,
                  ),// Add spacing between buttons
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _mediaFile = null;
                          _captionController.clear();
                          _disposeVideoController();
                        });
                      },
                      icon: const Icon(Icons.delete_forever,
                          color: Colors.redAccent),
                      label: Text(
                        "Clear Media",
                        style: AppTextStyles.bodyText.copyWith(
                          fontSize: getResponsiveFontSize(0.03),
                          color: Colors.red,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ],
            )
          ],
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFFF1694),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
