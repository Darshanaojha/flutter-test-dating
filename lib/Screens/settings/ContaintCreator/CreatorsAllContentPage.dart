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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                onTap: () => _showFullView(content),
                title: Text(
                  content.contentTitle,
                  style: const TextStyle(
                      color: Colors.amber, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  content.contentDescription,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.amber),
                  onPressed: () => _editContent(content),
                  tooltip: "Edit",
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: _addContent,
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add, color: Colors.black),
        tooltip: "Add New Content",
      ),
    );
  }
}
