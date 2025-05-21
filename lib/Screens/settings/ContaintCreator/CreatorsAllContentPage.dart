import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Controllers/controller.dart';
import '../../../Models/ResponseModels/creators_content_model.dart';

class CreatorsAllContentPage extends StatefulWidget {
  const CreatorsAllContentPage({super.key});

  @override
  State<CreatorsAllContentPage> createState() => _CreatorsAllContentPageState();
}

class _CreatorsAllContentPageState extends State<CreatorsAllContentPage> {
  final Controller controller = Get.find<Controller>();

  @override
  void initState() {
    super.initState();
    controller.fetchAllCreatorContent();
  }

  void _showFullView(CreatorContent content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black87,
        title: Text(content.contentTitle,
            style: const TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Description:",
                  style: TextStyle(
                      color: Colors.amber[200], fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(content.contentDescription,
                  style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 16),
              Text("Content Name: ${content.contentName}",
                  style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 8),
              Text("Actual Amount: ₹${content.actualAmount}",
                  style: const TextStyle(color: Colors.white)),
              Text("Offered Discount: ₹${content.offeredDiscount}",
                  style: const TextStyle(color: Colors.white)),
              Text("Content Cut: ${content.contentCut}",
                  style: const TextStyle(color: Colors.white)),
              Text("Status: ${content.status}",
                  style: const TextStyle(color: Colors.white)),
              Text("Created: ${content.created}",
                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
              Text("Updated: ${content.updated}",
                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: Colors.amber)),
          ),
        ],
      ),
    );
  }

  void _editContent(CreatorContent content) {
    // TODO: Navigate to your edit page, passing the content
    // Example: Get.to(EditContentPage(content: content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit feature coming soon!')),
    );
  }

  void _addContent() {
    // TODO: Navigate to your add content page
    // Example: Get.to(AddContentPage());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add feature coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Created Content'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Obx(() {
        if (controller.creatorContent.isEmpty) {
          return const Center(
            child: Text(
              "No content found. Tap + to add new content.",
              style: TextStyle(color: Colors.white70),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.creatorContent.length,
          separatorBuilder: (_, __) => const Divider(color: Colors.white12),
          itemBuilder: (context, index) {
            final content = controller.creatorContent[index];
            return Card(
              color: Colors.grey[900],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _showFullView(content),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left: Image or Video Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: _buildMediaThumbnail(content.contentName),
                      ),
                      const SizedBox(width: 16),
                      // Right: Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              content.contentTitle,
                              style: const TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              content.contentDescription,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Created: ${content.created}",
                              style: const TextStyle(color: Colors.white38, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.amber),
                        onPressed: () => _editContent(content),
                        tooltip: "Edit",
                      ),
                    ],
                  ),
                ),
              )
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: _addContent,
        backgroundColor: Colors.amber,
        tooltip: "Add New Content",
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildMediaThumbnail(String contentName) {
    // Simple check for image/video file extensions
    final isImage = contentName.toLowerCase().endsWith('.png') ||
        contentName.toLowerCase().endsWith('.jpg') ||
        contentName.toLowerCase().endsWith('.jpeg') ||
        contentName.toLowerCase().endsWith('.gif');
    final isVideo = contentName.toLowerCase().endsWith('.mp4') ||
        contentName.toLowerCase().endsWith('.mov') ||
        contentName.toLowerCase().endsWith('.avi');

    // Replace with your actual image/video URL logic if needed
    final String url = contentName; // Use network or asset path as needed

    if (isImage) {
      return Image.network(
        url,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 70,
          height: 70,
          color: Colors.grey[800],
          child: const Icon(Icons.broken_image, color: Colors.white38),
        ),
      );
    } else if (isVideo) {
      return Container(
        width: 70,
        height: 70,
        color: Colors.black26,
        child: const Icon(Icons.videocam, color: Colors.amber, size: 40),
      );
    } else {
      return Container(
        width: 70,
        height: 70,
        color: Colors.grey[800],
        child: const Icon(Icons.insert_drive_file, color: Colors.white38),
      );
    }
  }
}
