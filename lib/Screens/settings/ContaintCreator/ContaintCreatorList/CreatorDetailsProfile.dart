import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CreatorsProfilePage extends StatefulWidget {
  final String name;
  final String profileUrl;
  final int photos;
  final int videos;
  final int followers;
  final int following;

  const CreatorsProfilePage({
    super.key,
    required this.name,
    required this.profileUrl,
    required this.photos,
    required this.videos,
    required this.followers,
    required this.following,
  });

  @override
  State<CreatorsProfilePage> createState() => _CreatorProfilePageState();
}

class _CreatorProfilePageState extends State<CreatorsProfilePage> {
  int selectedTabIndex = 0;
  bool isSubscribed = false;

  late List<MediaItem> photos;
  late List<MediaItem> videos;
  late List<MediaItem> others;

  @override
  void initState() {
    super.initState();
    photos = List.generate(widget.photos, (index) {
      return MediaItem(
        url: "https://picsum.photos/id/${index + 20}/300/300",
        price:  4.99 ,
      );
    });
    videos = List.generate(widget.videos, (index) {
      return MediaItem(
        url: "https://picsum.photos/id/${index + 40}/300/300",
        price:  2.99 ,
      );
    });
    others = List.generate(4, (index) {
      return MediaItem(
        url: "https://picsum.photos/id/${index + 60}/300/300",
        price: 1.99,
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

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(widget.name, style: const TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 16),
          _buildBioSection(),
          const SizedBox(height: 20),
          _buildTabBar(),
          const SizedBox(height: 20),
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
              final media = _getMediaList()[index];

              // If the user is not subscribed, lock all media
              final isLocked = !isSubscribed;
              return GestureDetector(
                onTap: () {
                  if (media.isUnlocked || media.price == null || isSubscribed) {
                    _showMediaDialog(media);
                  } else {
                    _showPaymentDialog(media);
                  }
                },
                onLongPress: () {
                  if (media.isUnlocked || media.price == null) {
                    _showMediaDialog(media);
                  } else {
                    _showPaymentDialog(media);
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Display the media (photo/video)
                      Image.network(
                        media.url,
                        fit: BoxFit.cover,
                      ),

                      // If the media is locked, apply a blur effect
                      if (isLocked)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              color: Colors.black.withOpacity(0.4),
                            ),
                          ),
                        ),

                      // Show a lock icon on locked media
                      if (isLocked)
                        const Center(
                          child: Icon(Icons.lock_outline,
                              color: Colors.white70, size: 36),
                        ),

                      // If the media has a price, show the price tag for locked items
                      if (media.price != null && isLocked)
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '\₹${media.price!.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent,
        onPressed: () {},
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

  Widget _statItem(IconData icon, int count, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          "$count",
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }

  Widget _buildBioSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton(
              onPressed: () {},
              child: const Text('Follow'),
            ),
            const SizedBox(width: 10),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  isSubscribed = !isSubscribed;
                });
              },
              style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.pinkAccent)),
              child: Text(isSubscribed ? 'Unsubscribe' : 'Subscribe'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.edit, color: Colors.white70, size: 18),
              SizedBox(width: 8),
              Text("Add a bio...",
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
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
              const SizedBox(height: 4),
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

  // Show media dialog with full image and actions
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
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite_border,
                          color: Colors.white),
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

  // Show payment dialog for locked media
  void _showPaymentDialog(MediaItem media) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title:
              const Text("Unlock Media", style: TextStyle(color: Colors.white)),
          content: Text(
            "Pay \$${media.price?.toStringAsFixed(2)} to unlock this content?",
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text("Cancel", style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  media.isUnlocked = true;
                });
                Navigator.pop(context);
              },
              child: const Text("Pay Now"),
            ),
          ],
        );
      },
    );
  }
}

class MediaItem {
  final String url;
  final double? price;
  bool isUnlocked;

  MediaItem({
    required this.url,
    this.price,
    this.isUnlocked = false,
  });
}
