import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../constants.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> users = [
    {
      'name': 'John Doe',
      'age': 25,
      'location': 'New York',
      'km': 10,
      'lastSeen': '2 hours ago',
      'desires': ['adventurous', 'gaming', 'hugging', 'playing', 'dancing'],
      'images': [
        'assets/images/image1.jpg',
        'assets/images/image1.jpg',
        'assets/images/image1.jpg'
      ],
    },
    {
      'name': 'Jane Smith',
      'age': 23,
      'location': 'Los Angeles',
      'km': 50,
      'lastSeen': '1 day ago',
      'desires': ['enjoys hiking', 'flaming', 'playing', 'beach', 'dancing'],
      'images': [
        'assets/images/image2.jpg',
        'assets/images/image2.jpg',
        'assets/images/image2.jpg'
      ],
    },
    {
      'name': 'Sam Wilson',
      'age': 28,
      'location': 'Chicago',
      'km': 100,
      'lastSeen': '3 hours ago',
      'desires': ['new places', 'spending', 'employment', 'playing', 'dancing'],
      'images': [
        'assets/images/image3.jpg',
        'assets/images/image3.jpg',
        'assets/images/image3.jpg'
      ],
    },
  ];

  bool _isLiked = false;
  bool _isDisliked = false;
  bool _isLoading = true;
  int _pingCount = 0;
  final TextEditingController _pingController = TextEditingController();
  final FocusNode _pingFocusNode = FocusNode();
  final PageController _pageController = PageController();
  final PageController _imagePageController = PageController();

  Future<void> _loadImage() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void dispose() {
    _pingFocusNode.dispose();
    super.dispose();
  }

  void _incrementPing() {
    setState(() {
      _pingCount++;
    });
  }

  void _showPingBottomSheet() {
    Get.bottomSheet(
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Send a Ping', style: AppTextStyles.inputFieldText),
              SizedBox(height: 20),
              TextField(
                controller: _pingController,
                cursorColor: AppColors.cursorColor,
                focusNode: _pingFocusNode,
                decoration: InputDecoration(
                  labelText: 'Write your message...',
                  labelStyle: AppTextStyles.labelText,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  fillColor: AppColors.formFieldColor,
                  filled: true,
                  hintText: 'Type your message here...',
                ),
                maxLines: 3,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_pingController.text.isNotEmpty) {
                    setState(() {
                      _pingCount--;
                    });
                    _pingController.clear();
                    Get.back();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ping sent!')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor,
                ),
                child: Text('Send Ping', style: AppTextStyles.buttonText),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: AppColors.primaryColor,
      enterBottomSheetDuration: Duration(milliseconds: 300),
      exitBottomSheetDuration: Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.all(
                          MediaQuery.of(context).size.width * 0.04,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.4,
                              child: Stack(
                                children: [
                                  if (_isLoading)
                                    Center(
                                      child: SpinKitCircle(
                                        size: 150.0,
                                        color: AppColors.acceptColor,
                                      ),
                                    ),
                                  ListView.builder(
                                    controller: _imagePageController,
                                    scrollDirection: Axis.vertical,
                                    itemCount: users[index]['images'].length,
                                    itemBuilder: (context, imgIndex) {
                                      return Container(
                                        margin: EdgeInsets.only(bottom: 12),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(15),
                                          child: Image.asset(
                                            users[index]['images'][imgIndex],
                                            fit: BoxFit.cover,
                                            width: MediaQuery.of(context).size.width * 0.9,
                                            height: MediaQuery.of(context).size.height * 0.45,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  Positioned(
                                    bottom: 10,
                                    left: 0,
                                    right: 0,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: MediaQuery.of(context).size.width * 0.1),
                                      child: SmoothPageIndicator(
                                        controller: _imagePageController,
                                        count: users[index]['images'].length,
                                        effect: ExpandingDotsEffect(
                                          dotHeight: 10,
                                          dotWidth: 10,
                                          spacing: 10,
                                          radius: 5,
                                          dotColor: Colors.grey.withOpacity(0.5),
                                          activeDotColor: AppColors.acceptColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(users[index]['name'], style: AppTextStyles.headingText),
                            Row(
                              children: [
                                Text('${users[index]['age']} years old | ', style: AppTextStyles.bodyText),
                                Text('${users[index]['location']} | ', style: AppTextStyles.bodyText),
                                Text('${users[index]['km']} km away', style: AppTextStyles.bodyText),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text('Last Seen: ${users[index]['lastSeen']}', style: AppTextStyles.bodyText),
                            SizedBox(height: 12),
                            Text('Desires:', style: AppTextStyles.subheadingText),
                            Flexible(
                              child: GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 4.0,
                                  mainAxisSpacing: 0.0,
                                ),
                                itemCount: users[index]['desires'].length,
                                itemBuilder: (context, desireIndex) {
                                  return Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Chip(
                                      label: Text(
                                        users[index]['desires'][desireIndex],
                                        style: AppTextStyles.bodyText.copyWith(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                      backgroundColor: AppColors.acceptColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      elevation: 4,
                                      labelPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                                    ),
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // These are the floating action buttons that stay fixed at the bottom
          Positioned(
            bottom: 16,
            left: 16,
            child: Row(
              children: [
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      _isLiked = !_isLiked;
                      if (_isLiked) _isDisliked = false;
                    });
                  },
                  backgroundColor: _isLiked ? AppColors.acceptColor : Colors.grey,
                  child: Icon(
                    Icons.favorite,
                    size: 30,
                    color: AppColors.iconColor,
                  ),
                ),
                SizedBox(width: 16),
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      _isDisliked = !_isDisliked;
                      if (_isDisliked) _isLiked = false;
                    });
                  },
                  backgroundColor: _isDisliked ? AppColors.deniedColor : Colors.grey,
                  child: Icon(
                    Icons.thumb_down,
                    size: 30,
                    color: AppColors.iconColor,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _showPingBottomSheet,
              backgroundColor: AppColors.buttonColor,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.chair_alt,
                    size: 30,
                    color: AppColors.textColor,
                  ),
                  if (_pingCount > 0)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: AppColors.deniedColor,
                        child: Text(
                          '$_pingCount',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textColor,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

