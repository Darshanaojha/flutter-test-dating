import 'package:dating_application/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'; // For smooth page indicator
import 'package:get/get.dart'; // For GetX bottom sheet

class LikesPage extends StatefulWidget {
  const LikesPage({super.key});

  @override
  _LikesPageState createState() => _LikesPageState();
}

// class _LikesPageState extends State<LikesPage> {
//   // Filter state
//   String selectedGender = 'All';
//   String selectedLocation = 'All';
//   String selectedDesire = 'All'; // New filter for "Desires"
//   int selectedAgeRange = 0; // 0: All, 1: 18-25, 2: 26-35, etc.

//   final List<Map<String, dynamic>> users = [
//     {
//       'name': 'John Doe',
//       'age': 25,
//       'location': 'New York',
//       'km': 10,
//       'lastSeen': '2 hours ago',
//       'desires': 'Looking for someone adventurous',
//       'gender': 'Male',
//       'images': [
//         'assets/images/image1.jpg',
//         'assets/images/image2.jpg',
//         'assets/images/image3.jpg'
//       ],
//     },
//     {
//       'name': 'Jane Smith',
//       'age': 23,
//       'location': 'Los Angeles',
//       'km': 50,
//       'lastSeen': '1 day ago',
//       'desires': 'Looking for a partner who enjoys hiking',
//       'gender': 'Female',
//       'images': [
//         'assets/images/image2.jpg',
//         'assets/images/image3.jpg',
//         'assets/images/image1.jpg'
//       ],
//     },
//     {
//       'name': 'Sam Wilson',
//       'age': 28,
//       'location': 'Chicago',
//       'km': 100,
//       'lastSeen': '3 hours ago',
//       'desires': 'Looking for someone to explore new places',
//       'gender': 'Non-Binary',
//       'images': [
//         'assets/images/image3.jpg',
//         'assets/images/image1.jpg',
//         'assets/images/image2.jpg'
//       ],
//     },
//   ];

//   bool _isLiked = false;
//   bool _isDisliked = false;
//   int _pingCount = 0;
//   int _likeCount = 10;
//   final PageController _imagePageController = PageController();

//   // Filter logic for user profiles
//   List<Map<String, dynamic>> getFilteredUsers() {
//     return users.where((user) {
//       bool matchesGender =
//           selectedGender == 'All' || user['gender'] == selectedGender;
//       bool matchesLocation =
//           selectedLocation == 'All' || user['location'] == selectedLocation;
//       bool matchesDesire =
//           selectedDesire == 'All' || user['desires'].contains(selectedDesire);
//       bool matchesAge = selectedAgeRange == 0 ||
//           (selectedAgeRange == 1 && user['age'] >= 18 && user['age'] <= 25) ||
//           (selectedAgeRange == 2 && user['age'] >= 26 && user['age'] <= 35) ||
//           (selectedAgeRange == 3 && user['age'] >= 36);
//       return matchesGender && matchesLocation && matchesDesire && matchesAge;
//     }).toList();
//   }

//   Future<void> _showPingBottomSheet() async {
//     Get.bottomSheet(
//       Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text('Send a Ping', style: AppTextStyles.bodyText),
//               SizedBox(height: 20),
//               TextField(
//                 decoration: InputDecoration(
//                   labelText: 'Write your message...',
//                   labelStyle: AppTextStyles
//                       .labelText, // Apply consistent label text style
//                   border: OutlineInputBorder(),
//                   hintText: 'Type your message here...',
//                 ),
//                 maxLines: 3,
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   setState(() {
//                     _pingCount++;
//                   });
//                   Get.back();
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('Ping sent!')),
//                   );
//                 },
//                 child: Text('Send Ping', style: AppTextStyles.buttonText),
//               ),
//             ],
//           ),
//         ),
//       ),
//       isScrollControlled: true,
//       backgroundColor: Colors.white,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Column(
//             children: [
//               // Header with number of Likes and Pings
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text('Likes: $_likeCount', style: AppTextStyles.bodyText),
//                     Text('Pings: $_pingCount', style: AppTextStyles.bodyText),
//                   ],
//                 ),
//               ),
//               // Filters section with horizontal scroll
//               Container(
//                 height: 60,
//                 child: ListView(
//                   scrollDirection: Axis.horizontal,
//                   children: [
//                     _buildFilterChip(
//                         'Gender', ['All', 'Male', 'Female', 'Non-Binary'],
//                         (value) {
//                       setState(() {
//                         selectedGender = value!;
//                       });
//                     }),
//                     _buildFilterChip('Location',
//                         ['All', 'New York', 'Los Angeles', 'Chicago'], (value) {
//                       setState(() {
//                         selectedLocation = value!;
//                       });
//                     }),
//                     _buildFilterChip('Age', ['All', '18-25', '26-35', '36+'],
//                         (value) {
//                       setState(() {
//                         selectedAgeRange =
//                             ['All', '18-25', '26-35', '36+'].indexOf(value!);
//                       });
//                     }),
//                     _buildFilterChip('Desires', [
//                       'All',
//                       'Adventurous',
//                       'Hiking',
//                       'Explore new places'
//                     ], (value) {
//                       setState(() {
//                         selectedDesire = value!;
//                       });
//                     }),
//                   ],
//                 ),
//               ),
//               // User profiles
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: getFilteredUsers().length,
//                   itemBuilder: (context, index) {
//                     var user = getFilteredUsers()[index];
//                     return Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Horizontal Image Scrolling
//                           SizedBox(
//                             height: 200,
//                             child: ListView.builder(
//                               scrollDirection: Axis.horizontal,
//                               itemCount: user['images'].length,
//                               itemBuilder: (context, imgIndex) {
//                                 return Container(
//                                   margin: EdgeInsets.only(right: 12),
//                                   child: ClipRRect(
//                                     borderRadius: BorderRadius.circular(15),
//                                     child: Image.asset(
//                                       user['images'][imgIndex],
//                                       fit: BoxFit.cover,
//                                       width: 150,
//                                       height: 200,
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                           // User Information
//                           SizedBox(height: 8),
//                           Text(user['name'], style: AppTextStyles.titleText),
//                           Row(
//                             children: [
//                               Text('${user['age']} years old | ',
//                                   style: AppTextStyles.bodyText),
//                               Text('${user['location']} | ',
//                                   style: AppTextStyles.bodyText),
//                               Text('${user['km']} km away',
//                                   style: AppTextStyles.bodyText),
//                             ],
//                           ),
//                           SizedBox(height: 4),
//                           Text('Last Seen: ${user['lastSeen']}',
//                               style: AppTextStyles.bodyText),
//                           SizedBox(height: 12),
//                           Text('Desires:', style: AppTextStyles.bodyText),
//                           Text(user['desires'], style: AppTextStyles.bodyText),
                     
//                           Row(
//                             children: [
                            
//                               FloatingActionButton(
//                                 onPressed: () {
//                                   setState(() {
//                                     _isLiked = !_isLiked;
//                                     _isDisliked =
//                                         false;
//                                   });
//                                 },
//                                 backgroundColor: Colors
//                                     .grey, // Set the background color to grey
//                                 child: Icon(
//                                   Icons.favorite,
//                                   color: _isLiked
//                                       ? AppColors.acceptColor
//                                       : AppColors.iconColor,
//                                   size: 40, // Increase icon size
//                                 ),
//                               ),
//                               SizedBox(width: 20), // Add space between buttons
//                               // Dislike Button (FloatingActionButton)
//                               FloatingActionButton(
//                                 onPressed: () {
//                                   setState(() {
//                                     _isDisliked = !_isDisliked;
//                                     _isLiked =
//                                         false; // Reset like when dislike is pressed
//                                   });
//                                 },
//                                 backgroundColor: Colors
//                                     .grey, // Set the background color to grey
//                                 child: Icon(
//                                   Icons.thumb_down,
//                                   color: _isDisliked
//                                       ? AppColors.deniedColor
//                                       : AppColors.iconColor,
//                                   size: 40, // Increase icon size
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//           // Floating "Upgrade Profile" button
//           Positioned(
//             bottom: 16,
//             right: 16,
//             child: Container(
//               width: 160, // Adjust the width as per your requirement
//               height: 60, // Optionally, adjust the height
//               child: FloatingActionButton(
//                 onPressed: () {
//                   // Add functionality for upgrading the profile
//                 },
//                 backgroundColor: AppColors.buttonColor, // Use constant color
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(
//                       30), // Optional: make the button corners rounded
//                 ),
//                 child: Text(
//                   "Upgrade",
//                   style: AppTextStyles.buttonText, // Use constant text style
//                   textAlign:
//                       TextAlign.center, // To center the text in the button
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Helper method to build filter chips with callback
//   Widget _buildFilterChip(
//       String label, List<String> options, Function(String?) onSelected) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 8.0),
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: Colors.white, width: 2), // White border
//         ),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 12.0),
//           child: DropdownButton<String>(
//             value: label == 'Gender'
//                 ? selectedGender
//                 : label == 'Location'
//                     ? selectedLocation
//                     : label == 'Desires'
//                         ? selectedDesire
//                         : selectedAgeRange == 0
//                             ? 'All'
//                             : selectedAgeRange == 1
//                                 ? '18-25'
//                                 : selectedAgeRange == 2
//                                     ? '26-35'
//                                     : '36+',
//             items: options.map((option) {
//               return DropdownMenuItem<String>(
//                 value: option,
//                 child: Text(option, style: AppTextStyles.bodyText),
//               );
//             }).toList(),
//             onChanged: onSelected,
//             hint: Text(label, style: AppTextStyles.bodyText),
//           ),
//         ),
//       ),
//     );
//   }
// }

class _LikesPageState extends State<LikesPage> {
  // Filter state
  String selectedGender = 'All';
  String selectedLocation = 'All';
  String selectedDesire = 'All'; // New filter for "Desires"
  int selectedAgeRange = 0; // 0: All, 1: 18-25, 2: 26-35, etc.
  bool _isLoading = true;  

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

  bool _isLiked = false;
  bool _isDisliked = false;
  int _pingCount = 0;
  int _likeCount = 10;
  final PageController _imagePageController = PageController();

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
  
Future<void> _showUpgradeBottomSheet() async {
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
                  fontSize: 24,
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
                  fontSize: 16,
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
                          color: Colors.white, // Icon color is white for contrast
                          size: 24, // Adjust size as needed
                        ),
                        SizedBox(width: 10),
                        // Text for the card
                        Expanded(
                          child: Text(
                            "24-hour Premium Plan - ₹299", // Plan description
                            style: AppTextStyles.bodyText.copyWith(
                              fontSize: 16,
                              color: Colors.white, // White text for readability
                            ),
                          ),
                        ),
                        // Plan Status (text)
                        Text(
                          'Selected', // Status of the plan
                          style: AppTextStyles.bodyText.copyWith(
                            fontSize: 16,
                            color: AppColors.buttonColor, // Color for the status text
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
                      borderRadius: BorderRadius.circular(12), // Curved corners
                    ),
                    child: Text(
                      '20% OFF', // Display the discount percentage
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12, // Smaller font size
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
                    SnackBar(content: Text('Profile upgraded! Enjoy your 24 hours of premium access.')),
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
    backgroundColor: Colors.transparent, // Transparent background for the full-screen effect
  );
}

  Future<void> _fetchData() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _isLoading = false;  // Data is fetched, so hide the spinner
    });
  }
@override
  void initState() {
    super.initState();
    // Fetch the data when the page is loaded
    _fetchData();
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
                    Text('Likes: $_likeCount', style: AppTextStyles.bodyText),
                    Text('Pings: $_pingCount', style: AppTextStyles.bodyText),
                  ],
                ),
              ),
              // Filters section with horizontal scroll
              Container(
                height: 60,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFilterChip(
                        'Gender', ['All', 'Male', 'Female', 'Non-Binary'],
                        (value) {
                      setState(() {
                        selectedGender = value!;
                      });
                    }),
                    _buildFilterChip('Location',
                        ['All', 'New York', 'Los Angeles', 'Chicago'], (value) {
                      setState(() {
                        selectedLocation = value!;
                      });
                    }),
                    _buildFilterChip('Age', ['All', '18-25', '26-35', '36+'],
                        (value) {
                      setState(() {
                        selectedAgeRange =
                            ['All', '18-25', '26-35', '36+'].indexOf(value!);
                      });
                    }),
                    _buildFilterChip('Desires', [
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
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.asset(
                                      user['images'][imgIndex],
                                      fit: BoxFit.cover,
                                      width: 150,
                                      height: 200,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          // User Information
                          SizedBox(height: 8),
                          Text(user['name'], style: AppTextStyles.titleText),
                          Row(
                            children: [
                              Text('${user['age']} years old | ',
                                  style: AppTextStyles.bodyText),
                              Text('${user['location']} | ',
                                  style: AppTextStyles.bodyText),
                              Text('${user['km']} km away',
                                  style: AppTextStyles.bodyText),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text('Last Seen: ${user['lastSeen']}',
                              style: AppTextStyles.bodyText),
                          SizedBox(height: 12),
                          Text('Desires:', style: AppTextStyles.bodyText),
                          Text(user['desires'], style: AppTextStyles.bodyText),
                     
                          Row(
                            children: [
                              FloatingActionButton(
                                onPressed: () {
                                  setState(() {
                                    _isLiked = !_isLiked;
                                    _isDisliked = false;
                                  });
                                },
                                backgroundColor: Colors.grey,
                                child: Icon(
                                  Icons.favorite,
                                  color: _isLiked
                                      ? AppColors.acceptColor
                                      : AppColors.iconColor,
                                  size: 40,
                                ),
                              ),
                              SizedBox(width: 20),
                              FloatingActionButton(
                                onPressed: () {
                                  setState(() {
                                    _isDisliked = !_isDisliked;
                                    _isLiked = false;
                                  });
                                },
                                backgroundColor: Colors.grey,
                                child: Icon(
                                  Icons.thumb_down,
                                  color: _isDisliked
                                      ? AppColors.deniedColor
                                      : AppColors.iconColor,
                                  size: 40,
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
            child: Container(
              width: 160,
              height: 60,
              child: FloatingActionButton(
                onPressed: () {
                  // Call the _showUpgradeBottomSheet method when pressed
                  _showUpgradeBottomSheet();
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
           if (_isLoading)
            Center(
              child: SpinKitCircle(
                size: 150.0,  // Adjust the size of the spinner
                color: AppColors.acceptColor,  // Set the spinner color
              ),
            ),
        ],
      ),
    );
  }

  // Helper method to build filter chips with callback
  Widget _buildFilterChip(
      String label, List<String> options, Function(String?) onSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: DropdownButton<String>(
            value: label == 'Gender'
                ? selectedGender
                : label == 'Location'
                    ? selectedLocation
                    : label == 'Desires'
                        ? selectedDesire
                        : selectedAgeRange == 0
                            ? 'All'
                            : selectedAgeRange == 1
                                ? '18-25'
                                : selectedAgeRange == 2
                                    ? '26-35'
                                    : '36+',
            items: options.map((option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option, style: AppTextStyles.bodyText),
              );
            }).toList(),
            onChanged: onSelected,
            hint: Text(label, style: AppTextStyles.bodyText),
          ),
        ),
      ),
    );
  }
}
