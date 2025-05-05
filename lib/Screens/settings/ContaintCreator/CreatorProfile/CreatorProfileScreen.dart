import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../constants.dart';

class CreatorProfileScreen extends StatefulWidget {
  final String name;
  final String profileUrl;
  final int photos;
  final int videos;
  final int followers;
  final int following;

  const CreatorProfileScreen({
    super.key,
    required this.name,
    required this.profileUrl,
    required this.photos,
    required this.videos,
    required this.followers,
    required this.following,
  });

  @override
  State<CreatorProfileScreen> createState() => _CreatorProfilePageState();
}

class _CreatorProfilePageState extends State<CreatorProfileScreen> {
  int selectedTabIndex = 0;
  late List<MediaItem> photos;
  late List<MediaItem> videos;
  late List<MediaItem> others;

  @override
  void initState() {
    super.initState();
    photos = List.generate(widget.photos, (index) {
      return MediaItem(
        url: "https://picsum.photos/id/${index + 20}/300/300",
        isLiked: false,
      );
    });
    videos = List.generate(widget.videos, (index) {
      return MediaItem(
        url: "https://picsum.photos/id/${index + 40}/300/300",
        isLiked: false,
      );
    });
    others = List.generate(4, (index) {
      return MediaItem(
        url: "https://picsum.photos/id/${index + 60}/300/300",
        isLiked: false,
      );
    });
  }

  List<MediaItem> _getMediaList() {
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

  @override
  Widget build(BuildContext context) {
    final mediaList = _getMediaList();

    double getResponsiveFontSize(double scale) {
      double screenWidth = MediaQuery.of(context).size.width;
      return screenWidth * scale;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          widget.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            _buildBioSection(),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            _buildTabBar(),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: mediaList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final media = mediaList[index];
                return GestureDetector(
                  onTap: () {
                    _showMediaDialog(media);
                  },
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          media.url,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      // Positioned(
                      //   top: 8,
                      //   right: 8,
                      //   child: GestureDetector(
                      //     onTap: () {
                      //       setState(() {
                      //         media.isLiked = !media.isLiked;
                      //       });
                      //     },
                      //     child: Icon(
                      //       media.isLiked
                      //           ? FontAwesomeIcons.solidHeart
                      //           : FontAwesomeIcons.heart,
                      //       color: media.isLiked ? Colors.red : Colors.white70,
                      //       size: 20,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent,
        onPressed: () {
          // Add new post
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 44,
          backgroundImage: NetworkImage(widget.profileUrl),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statItem(FontAwesomeIcons.layerGroup, widget.photos, "Posts"),
              _statItem(FontAwesomeIcons.users, widget.followers, "Followers"),
              _statItem(
                  FontAwesomeIcons.userPlus, widget.following, "Following"),
            ],
          ),
        ),
      ],
    );
  }
   double getResponsiveFontSize(double scale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * scale;
  }

  Widget _statItem(IconData icon, int count, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.01,
        ),
        Text(
          "$count",
          style: AppTextStyles.bodyText.copyWith(
            fontSize: getResponsiveFontSize(0.03),
            color: Colors.white,
          ),
        ),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }

  Widget _buildBioSection() {
    return Column(
      children: [
        Text(
          "Photographer | Storyteller | Digital Artist",
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyText.copyWith(
            fontSize: getResponsiveFontSize(0.03),
            color: Colors.white,
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.01,
        ),
        GestureDetector(
          onTap: () {
            // Edit bio
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.edit, color: Colors.white70, size: 18),
              SizedBox(width: 8),
              Text(
                "Edit Bio",
                style: AppTextStyles.bodyText.copyWith(
                  fontSize: getResponsiveFontSize(0.03),
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
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
          onTap: () => setState(() => selectedTabIndex = index),
          child: Column(
            children: [
              Icon(
                icons[index],
                color: isSelected ? Colors.pinkAccent : Colors.white54,
                size: 22,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
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

  void _showMediaDialog(MediaItem media) {
    showDialog(
      context: context,
      builder: (context) {
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
                  child: Image.network(media.url, fit: BoxFit.cover),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
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
                      onPressed: () {
                        setState(() {
                          media.isLiked = !media.isLiked;
                        });
                      },
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
                      onSelected: (value) {
                        if (value == 1) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Item deleted')),
                          );
                        }
                      },
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
