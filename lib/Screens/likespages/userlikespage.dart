import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import '../../constants.dart';

class LikesPage extends StatefulWidget {
  const LikesPage({super.key});

  @override
  LikesPageState createState() => LikesPageState();
}

class LikesPageState extends State<LikesPage> {
  // Filter state
  String selectedGender = 'All';
  String selectedLocation = 'All';
  String selectedDesire = 'All'; // New filter for "Desires"
  int selectedAgeRange = 0; // 0: All, 1: 18-25, 2: 26-35, etc.
  bool isLoading = true;

  final List<Map<String, dynamic>> users = [
    // Sample users

    {
      'name': 'John Doe',
      'age': 25,
      'location': 'New York',
      'km': 10,
      'lastSeen': '2 hours ago',
      'desires': 'Looking for someone adventurous',
      'gender': 'Male',
      'images': [
        'assets/images/image1.jpg',
        'assets/images/image2.jpg',
        'assets/images/image3.jpg'
      ],
    },
    {
      'name': 'Jane Smith',
      'age': 23,
      'location': 'Los Angeles',
      'km': 50,
      'lastSeen': '1 day ago',
      'desires': 'Looking for a partner who enjoys hiking',
      'gender': 'Female',
      'images': [
        'assets/images/image2.jpg',
        'assets/images/image3.jpg',
        'assets/images/image1.jpg'
      ],
    },
    {
      'name': 'Sam Wilson',
      'age': 28,
      'location': 'Chicago',
      'km': 100,
      'lastSeen': '3 hours ago',
      'desires': 'Looking for someone to explore new places',
      'gender': 'Non-Binary',
      'images': [
        'assets/images/image3.jpg',
        'assets/images/image1.jpg',
        'assets/images/image2.jpg'
      ],
    },
  ];

  bool isLiked = false;
  bool isShare = false;
  bool isSms = false;
  int pingCount = 0;
  int likeCount = 10;
  final PageController imagePageController = PageController();
  double getResponsiveFontSize(double scale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * scale; // Adjust this scale for different text elements
  }

  // Filter logic for user profiles
  List<Map<String, dynamic>> getFilteredUsers() {
    return users.where((user) {
      bool matchesGender =
          selectedGender == 'All' || user['gender'] == selectedGender;
      bool matchesLocation =
          selectedLocation == 'All' || user['location'] == selectedLocation;
      bool matchesDesire =
          selectedDesire == 'All' || user['desires'].contains(selectedDesire);
      bool matchesAge = selectedAgeRange == 0 ||
          (selectedAgeRange == 1 && user['age'] >= 18 && user['age'] <= 25) ||
          (selectedAgeRange == 2 && user['age'] >= 26 && user['age'] <= 35) ||
          (selectedAgeRange == 3 && user['age'] >= 36);
      return matchesGender && matchesLocation && matchesDesire && matchesAge;
    }).toList();
  }

  void showFullImageDialog(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black.withOpacity(0.9),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(), // Close dialog on tap
            child: Center(
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain, // Adjust the image size to fit
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> showUpgradeBottomSheet() async {
    Get.bottomSheet(
      Padding(
        padding: const EdgeInsets.all(0.0),
        child: Container(
          color: Colors.black, // Set the background color to black
          child: Column(
            mainAxisSize: MainAxisSize.min, // Minimize the space to fit content
            children: [
              // Title of the Bottom Sheet
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Found Uplift',
                  style: AppTextStyles.titleText.copyWith(
                    fontSize: getResponsiveFontSize(0.03),
                    color: Colors.white, // Set text color to white for contrast
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 10),
              // Subtitle with additional information
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'You can use 24 hours and enjoy the features, '
                  'and you can access earlier with premium benefits.',
                  style: AppTextStyles.bodyText.copyWith(
                    fontSize: getResponsiveFontSize(0.03),
                    color: Colors.white, // Set text color to white for contrast
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),

              // Orange Card with Icon, Text, and Discount Label
              Stack(
                children: [
                  // The Orange Card
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.orange, // Set card background color to orange
                    child: Padding(
                      padding: const EdgeInsets.all(24.0), // Increased padding
                      child: Row(
                        children: [
                          // Icon for the card
                          Icon(
                            Icons.calendar_today,
                            color: Colors
                                .white, // Icon color is white for contrast
                            size: 24, // Adjust size as needed
                          ),
                          SizedBox(width: 10),
                          // Text for the card
                          Expanded(
                            child: Text(
                              "24-hour Premium Plan - ₹299", // Plan description
                              style: AppTextStyles.bodyText.copyWith(
                                fontSize: getResponsiveFontSize(0.03),
                                color:
                                    Colors.white, // White text for readability
                              ),
                            ),
                          ),
                          // Plan Status (text)
                          Text(
                            'Selected', // Status of the plan
                            style: AppTextStyles.bodyText.copyWith(
                              fontSize: getResponsiveFontSize(0.03),
                              color: AppColors
                                  .buttonColor, // Color for the status text
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Positioned Discount Label (20% OFF)
                  Positioned(
                    top: 4, // Slightly higher position
                    right: 2, // Position at the top-right corner
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                      decoration: BoxDecoration(
                        color: Colors.red, // Set the background color to red
                        borderRadius:
                            BorderRadius.circular(12), // Curved corners
                      ),
                      child: Text(
                        '20% OFF', // Display the discount percentage
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize:
                              getResponsiveFontSize(0.03), // Smaller font size
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Purchase Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Simulate purchase process
                    Get.back();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Profile upgraded! Enjoy your 24 hours of premium access.')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonColor,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Purchase Now', style: AppTextStyles.buttonText),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true, // Allow bottom sheet to have a controlled size
      backgroundColor: Colors
          .transparent, // Transparent background for the full-screen effect
    );
  }

  Future<void> fetchData() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      isLoading = false; // Data is fetched, so hide the spinner
    });
  }

  @override
  void initState() {
    super.initState();
    // Fetch the data when the page is loaded
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // Header with number of Likes and Pings
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Likes: $likeCount', style: AppTextStyles.bodyText),
                    Text('Pings: $pingCount', style: AppTextStyles.bodyText),
                  ],
                ),
              ),
              // Filters section with horizontal scroll
              SizedBox(
                height: 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    buildFilterChip(
                        'Gender', ['All', 'Male', 'Female', 'Non-Binary'],
                        (value) {
                      setState(() {
                        selectedGender = value!;
                      });
                    }),
                    buildFilterChip('Location',
                        ['All', 'New York', 'Los Angeles', 'Chicago'], (value) {
                      setState(() {
                        selectedLocation = value!;
                      });
                    }),
                    buildFilterChip('Age', ['All', '18-25', '26-35', '36+'],
                        (value) {
                      setState(() {
                        selectedAgeRange =
                            ['All', '18-25', '26-35', '36+'].indexOf(value!);
                      });
                    }),
                    buildFilterChip('Desires', [
                      'All',
                      'Adventurous',
                      'Hiking',
                      'Explore new places'
                    ], (value) {
                      setState(() {
                        selectedDesire = value!;
                      });
                    }),
                  ],
                ),
              ),

              // User profiles
              Expanded(
                child: ListView.builder(
                  itemCount: getFilteredUsers().length,
                  itemBuilder: (context, index) {
                    var user = getFilteredUsers()[index];
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Horizontal Image Scrolling
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: user['images'].length,
                              itemBuilder: (context, imgIndex) {
                                return Container(
                                  margin: EdgeInsets.only(right: 12),
                                  child: GestureDetector(
                                    onTap: () => showFullImageDialog(
                                        context, user['images'][imgIndex]),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.asset(
                                        user['images'][
                                            imgIndex], // Image path from the user's data
                                        fit: BoxFit.cover,
                                        width: 150,
                                        height: 200,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          // User Information
                          SizedBox(height: 8),
                          Text(user['name'],
                              style: AppTextStyles.titleText.copyWith(
                                  fontSize: getResponsiveFontSize(0.04))),
                          Row(
                            children: [
                              Text('${user['age']} years old | ',
                                  style: AppTextStyles.bodyText.copyWith(
                                      fontSize: getResponsiveFontSize(0.03))),
                              Text('${user['location']} | ',
                                  style: AppTextStyles.bodyText.copyWith(
                                      fontSize: getResponsiveFontSize(0.03))),
                              Text('${user['km']} km away',
                                  style: AppTextStyles.bodyText.copyWith(
                                      fontSize: getResponsiveFontSize(0.03))),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text('Last Seen: ${user['lastSeen']}',
                              style: AppTextStyles.bodyText.copyWith(
                                  fontSize: getResponsiveFontSize(0.03))),
                          SizedBox(height: 12),
                          Text('Desires:',
                              style: AppTextStyles.bodyText.copyWith(
                                  fontSize: getResponsiveFontSize(0.03))),
                          Text(user['desires'],
                              style: AppTextStyles.bodyText.copyWith(
                                  fontSize: getResponsiveFontSize(0.03))),

                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    isLiked = !isLiked;
                                  });
                                },
                                icon: Icon(
                                  isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: 30,
                                  color: isLiked ? Colors.red : Colors.white,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    isShare = !isShare;
                                  });
                                },
                                icon: Icon(
                                  isShare
                                      ? Icons.share
                                      : Icons.share_sharp,
                                  size: 30,
                                  color: isShare ? Colors.red : Colors.white,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    isSms = !isSms;
                                  });
                                },
                                icon: Icon(
                                  isSms
                                      ? Icons.messenger
                                      : Icons.messenger_outline,
                                  size: 30,
                                  color: isSms ? Colors.red : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // Floating "Upgrade Profile" button
          Positioned(
            bottom: 16,
            right: 16,
            child: SizedBox(
              width: 160,
              height: 60,
              child: FloatingActionButton(
                onPressed: () {
                  // Call the showUpgradeBottomSheet method when pressed
                  showUpgradeBottomSheet();
                },
                backgroundColor: AppColors.buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  "Upgrade",
                  style: AppTextStyles.buttonText,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          if (isLoading)
            Center(
              child: SpinKitCircle(
                size: 150.0, // Adjust the size of the spinner
                color: AppColors.progressColor, // Set the spinner color
              ),
            ),
        ],
      ),
    );
  }

  Widget buildFilterChip(
      String label, List<String> options, Function(String?) onSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        decoration: BoxDecoration(
            // borderRadius: BorderRadius.circular(14),
            // border: Border.all(color: AppColors.activeColor, width: 2),
            ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: AppColors.primaryColor,
              backgroundColor: AppColors.secondaryColor, // Text color
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: AppColors.activeColor, width: 2),
              ),
            ),
            onPressed: () {
              // Open bottom sheet when button is pressed
              showBottomSheet(label, options, onSelected);
            },
            child: Row(
              mainAxisSize: MainAxisSize
                  .min, // Ensures the row takes up only as much space as needed
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodyText,
                ),
                SizedBox(width: 8), // Space between the text and the icon
                Icon(
                  Icons.arrow_drop_down, // Down arrow icon
                  color: AppColors.activeColor, // Icon color
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showBottomSheet(
      String label, List<String> options, Function(String?) onSelected) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$label Filter',
                style: AppTextStyles.headingText.copyWith(fontSize: 22),
              ),
              SizedBox(height: 16),
              ...options.map((option) {
                return RadioListTile<String>(
                  title: Text(option, style: AppTextStyles.bodyText),
                  value: option,
                  groupValue: label == 'Gender'
                      ? selectedGender
                      : label == 'Location'
                          ? selectedLocation
                          : label == 'Desires'
                              ? selectedDesire
                              : selectedAgeRange == 0
                                  ? 'All'
                                  : label == 'Age' && option == 'All'
                                      ? 'All'
                                      : option,
                  onChanged: (value) {
                    setState(() {
                      onSelected(value);
                    });
                    Navigator.pop(context);
                  },
                  activeColor: AppColors.buttonColor,
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}
