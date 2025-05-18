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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit feature coming soon!')),
    );
  }

  void _addContent() {
    // TODO: Navigate to your add content page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add feature coming soon!')),
    );
  }

  Widget _buildContentCard(CreatorContent content) {
    // Replace with your actual image logic if you have URLs or assets
    final String? imageUrl = content.contentName.isNotEmpty
        ? content.contentName // Assuming this is a URL or asset path
        : null;

    return Card(
      color: Colors.grey[900],
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showFullView(content),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey[800],
                          child: const Icon(Icons.image_not_supported,
                              color: Colors.white38),
                        ),
                      )
                    : Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey[800],
                        child: const Icon(Icons.image, color: Colors.white38),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      content.contentTitle,
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      content.contentDescription,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Chip(
                          label: Text(
                            "₹${content.actualAmount}",
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: Colors.amber[200],
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: 8),
                        if (content.offeredDiscount > 0)
                          Chip(
                            label: Text(
                              "-₹${content.offeredDiscount}",
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.red[400],
                            visualDensity: VisualDensity.compact,
                          ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.amber),
                          onPressed: () => _editContent(content),
                          tooltip: "Edit",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.creatorContent.length,
          itemBuilder: (context, index) {
            final content = controller.creatorContent[index];
            return _buildContentCard(content);
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
}
