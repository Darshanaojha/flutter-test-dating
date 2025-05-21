import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../Controllers/controller.dart';
import '../../../../constants.dart';

class CreatorProfileScreen extends StatelessWidget {
  CreatorProfileScreen({super.key});

  final Controller controller = Get.find<Controller>();

  double getResponsiveFontSize(BuildContext context, double scale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * scale;
  }

  @override
  Widget build(BuildContext context) {
    // Fetch profile if not already loaded
    if (controller.userData.isEmpty) {
      controller.fetchProfile();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Obx(() => Text(
              controller.userData.isNotEmpty
                  ? controller.userData.first.name
                  : "",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Obx(() {
        if (controller.userData.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        final user = controller.userData.first;
        // Replace with your actual media lists if available
        final List<MediaItem> photos = List.generate(
            10, (index) => MediaItem(url: user.profileImage, isLiked: false));
        final List<MediaItem> videos = List.generate(
            5, (index) => MediaItem(url: user.profileImage, isLiked: false));
        final List<MediaItem> others = List.generate(
            2, (index) => MediaItem(url: user.profileImage, isLiked: false));
        int selectedTabIndex = 0;

        List<MediaItem> getMediaList() {
          switch (selectedTabIndex) {
            case 0:
              return photos;
            case 1:
              return videos;
            case 2:
              return others;
            default:
              return [];
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(context, user),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              _buildBioSection(context, user),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              _buildTabBar(context, selectedTabIndex, (i) {
                selectedTabIndex = i;
                // Use setState if you convert to StatefulWidget for tab switching
              }),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: getMediaList().length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final media = getMediaList()[index];
                  final isValidUrl =
                      media.url.isNotEmpty && media.url.startsWith('http');
                  return GestureDetector(
                    onTap: () {
                      _showMediaDialog(context, media);
                    },
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.white24, width: 1.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: isValidUrl
                                ? Image.network(
                                    media.url,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Center(
                                      child: Icon(Icons.insert_drive_file,
                                          color: Colors.white54, size: 40),
                                    ),
                                  )
                                : const Center(
                                    child: Icon(Icons.insert_drive_file,
                                        color: Colors.white54, size: 40),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent,
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, dynamic user) {
    return Row(
      children: [
        CircleAvatar(
          radius: 44,
          backgroundColor: Colors.grey[800],
          child: (user.profileImage.isNotEmpty &&
                  user.profileImage.startsWith('http'))
              ? ClipOval(
                  child: Image.network(
                    user.profileImage,
                    width: 88,
                    height: 88,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.person,
                      color: Colors.white54,
                      size: 44,
                    ),
                  ),
                )
              : const Icon(
                  Icons.person,
                  color: Colors.white54,
                  size: 44,
                ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statItem(context, FontAwesomeIcons.layerGroup, 10, "Posts"),
              _statItem(context, FontAwesomeIcons.users, 0, "Followers"),
              _statItem(context, FontAwesomeIcons.userPlus, 0, "Following"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statItem(
      BuildContext context, IconData icon, int count, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        Text(
          "$count",
          style: AppTextStyles.bodyText.copyWith(
            fontSize: getResponsiveFontSize(context, 0.03),
            color: Colors.white,
          ),
        ),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }

  Widget _buildBioSection(BuildContext context, dynamic user) {
    return Column(
      children: [
        Center(
          child: Text(
            user.bio ?? "NA",
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyText.copyWith(
              fontSize: getResponsiveFontSize(context, 0.03),
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        // GestureDetector(
        //   onTap: () {},
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: [
        //       Icon(Icons.edit, color: Colors.white70, size: 18),
        //       SizedBox(width: 8),
        //       Text(
        //         "Edit Bio",
        //         style: AppTextStyles.bodyText.copyWith(
        //           fontSize: getResponsiveFontSize(context, 0.03),
        //           color: Colors.white,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }

  Widget _buildTabBar(
      BuildContext context, int selectedTabIndex, Function(int) onTabSelected) {
    final tabs = ["Photos", "Videos", "Others"];
    final icons = [
      FontAwesomeIcons.image,
      FontAwesomeIcons.video,
      FontAwesomeIcons.ellipsis
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(3, (index) {
        final isSelected = selectedTabIndex == index;
        return GestureDetector(
          onTap: () => onTabSelected(index),
          child: Column(
            children: [
              Icon(
                icons[index],
                color: isSelected ? Colors.pinkAccent : Colors.white54,
                size: 22,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Text(
                tabs[index],
                style: TextStyle(
                  color: isSelected ? Colors.pinkAccent : Colors.white54,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showMediaDialog(BuildContext context, MediaItem media) {
    showDialog(
      context: context,
      builder: (context) {
        final isValidUrl = media.url.isNotEmpty && media.url.startsWith('http');
        return Dialog(
          backgroundColor: Colors.black,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: isValidUrl
                      ? Image.network(
                          media.url,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.insert_drive_file,
                            color: Colors.white54,
                            size: 60,
                          ),
                        )
                      : const Icon(
                          Icons.insert_drive_file,
                          color: Colors.white54,
                          size: 60,
                        ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(
                        media.isLiked
                            ? FontAwesomeIcons.solidHeart
                            : FontAwesomeIcons.heart,
                        color: media.isLiked ? Colors.red : Colors.white70,
                        size: 20,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: () {},
                    ),
                    PopupMenuButton<int>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      color: Colors.grey[900],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      onSelected: (value) {},
                      itemBuilder: (context) => [
                        PopupMenuItem<int>(
                          value: 1,
                          child: Row(
                            children: const [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                        PopupMenuItem<int>(
                          value: 2,
                          child: Row(
                            children: const [
                              Icon(Icons.edit, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('Edit',
                                  style: TextStyle(color: Colors.blue)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MediaItem {
  final String url;
  bool isLiked;

  MediaItem({
    required this.url,
    this.isLiked = false,
  });
}
