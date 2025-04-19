

import 'package:flutter/material.dart';
import 'package:get/get.dart';


class PostLibraryScreen extends StatefulWidget {
  const PostLibraryScreen({super.key});

  @override
  State<PostLibraryScreen> createState() => _PostLibraryScreenState();
}

class _PostLibraryScreenState extends State<PostLibraryScreen> {
  List<Map<String, dynamic>> samplePosts = List.generate(
    10,
        (index) => {
      'username': 'CreatorUser',
      'imageUrl': 'https://source.unsplash.com/random/400x400?sig=$index',
      'isVideo': index % 3 == 0,
      'description': 'This is post number $index from the post library.',
    },
  );

  void deletePost(int index) {
    setState(() {
      samplePosts.removeAt(index);
    });
    Get.snackbar(
      "Post Deleted",
      "Post $index has been removed",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.grey[900],
      colorText: Colors.white,
    );
  }

  void editPost(int index) {
    final post = samplePosts[index];
    // Get.to(() => UploadPostScreen(
    //   existingPost: post,
    //   onPostUpdated: (updatedPost) {
    //     setState(() {
    //       samplePosts[index] = updatedPost;
    //     });
    //   },
    // ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: Text("Post Library", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,


        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: samplePosts.length,
        itemBuilder: (context, index) {
          final post = samplePosts[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.black,
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const CircleAvatar(
                    radius: 18,
                    backgroundImage:
                    NetworkImage("https://source.unsplash.com/random/100x100?user"),
                  ),
                  title: Text(
                    post['username'],
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        post['isVideo'] ? Icons.videocam : Icons.image,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        color: Colors.grey[900],
                        onSelected: (value) {
                          if (value == 'edit') {
                            editPost(index);
                          } else if (value == 'delete') {
                            deletePost(index);
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: Colors.white70, size: 28),
                                SizedBox(width: 15),
                                Text('Edit', style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.white70, size: 28),
                                SizedBox(width: 15),
                                Text('Delete', style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: post['isVideo']
                        ? null
                        : DecorationImage(
                      image: NetworkImage(post['imageUrl']),
                      fit: BoxFit.cover,
                    ),
                    color: Colors.grey[900],
                  ),
                  child: post['isVideo']
                      ? const Center(
                    child: Icon(Icons.videocam, size: 64, color: Colors.white70),
                  )
                      : null,
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    post['description'],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white60, width: 1.5),
          color: Colors.black,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 2,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        // child: FloatingActionButton(
        //   onPressed: () => Get.to(() => UploadPostScreen(
        //     onPostUpdated: (newPost) {
        //       setState(() {
        //         samplePosts.add(newPost);
        //       });
        //     },
        //   )),
        //   backgroundColor: Colors.black,
        //   elevation: 0,
        //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        //   child: const Icon(Icons.add, color: Colors.white60),
        // ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        elevation: 0,
        child: const SizedBox(
          height: 60,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [],
            ),
          ),
        ),
      ),
    );
  }
}