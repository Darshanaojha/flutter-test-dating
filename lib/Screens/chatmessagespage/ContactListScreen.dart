import 'package:dating_application/Models/ResponseModels/get_all_chat_history_page.dart';
import 'package:dating_application/Screens/chatmessagespage/pinrequestpage.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../Controllers/controller.dart';
import '../../constants.dart';

import '../chatpage/ChatScreenpusher.dart';

class ContactListScreen extends StatefulWidget {
  const ContactListScreen({super.key});

  @override
  ContactListScreenState createState() => ContactListScreenState();
}

class ContactListScreenState extends State<ContactListScreen> {
  Controller controller = Get.put(Controller());
  String searchQuery = '';
  bool isLoading = true;
  RxBool isselected = false.obs;
  RxBool iswriting = false.obs;
  RxString selectedReason = ''.obs;
  RxString reportDescription = ''.obs;
  double getResponsiveFontSize(double scale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * scale;
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    await controller.fetchalluserconnections();
    await controller.fetchProfile();
    setState(() {
      isLoading = false;
    });
  }

  List<UserConnections> getFilteredUsers() {
    return controller.userConnections
        .where((user) =>
            user.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  bool isFabOpen = false;
  int selectedSection = 0; // 0 = List, 1 = Recents, 2 = Hookups

  void toggleFab() {
    setState(() {
      isFabOpen = !isFabOpen;
    });
  }

  void selectSection(int index) {
    setState(() {
      selectedSection = index;
      isFabOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double fontSize = size.width * 0.04;

    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
        title: Text(
          'Contacts',
          style: AppTextStyles.headingText.copyWith(
            fontSize: fontSize * 1.2,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppColors.gradientBackgroundList,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      cursorColor: AppColors.cursorColor,
                      onChanged: (query) {
                        setState(() {
                          searchQuery = query;
                        });
                      },
                      style: AppTextStyles.inputFieldText.copyWith(
                        fontSize: fontSize,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search Contacts...',
                        hintStyle: AppTextStyles.customTextStyle(
                            color: Colors.white70),
                        prefixIcon: Icon(Icons.search, color: Colors.white70),
                        filled: true,
                        fillColor: Colors.transparent,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 18),
                // Section Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${getFilteredUsers().length} Members',
                      style: AppTextStyles.bodyText.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize * 1.05,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: AppColors.gradientBackgroundList,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Get.to(MessageRequestPage());
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: StadiumBorder(),
                          minimumSize: Size(100, 45),
                        ),
                        child: Text(
                          'Request',
                          style: AppTextStyles.buttonText.copyWith(
                            color: Colors.white,
                            fontSize: fontSize,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Contact List
                Expanded(
                  child: isLoading
                      ? Center(
                          child: Lottie.asset(
                            "assets/animations/chatpageanimation.json",
                            repeat: true,
                            reverse: true,
                          ),
                        )
                      : Builder(
                          builder: (context) {
                            if (selectedSection == 0) {
                              return Obx(() => ListView.builder(
                                    itemCount: getFilteredUsers().length,
                                    itemBuilder: (context, index) {
                                      final connection =
                                          getFilteredUsers()[index];
                                      return Card(
                                        elevation: 6,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(24),
                                        ),
                                        margin:
                                            EdgeInsets.symmetric(vertical: 8),
                                        child: Container(
                                          decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: AppColors
                                              .gradientBackgroundList,
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                            BorderRadius.circular(24),
                                          ),
                                          child: ListTile(
                                          leading: GestureDetector(
                                            onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                              builder: (context) =>
                                                FullScreenImagePage(
                                                imageUrl: connection
                                                  .profileImage,
                                              ),
                                              ),
                                            );
                                            },
                                            child: Hero(
                                            tag: connection.profileImage,
                                            child: Stack(
                                              children: [
                                              CircleAvatar(
                                                radius: 24.0,
                                                backgroundImage: NetworkImage(
                                                  connection.profileImage),
                                              ),
                                              if (connection.useractivestatus == "1")
                                                Positioned(
                                                top: 2,
                                                right: 2,
                                                child: Container(
                                                  width: 12,
                                                  height: 12,
                                                  decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 1,
                                                  ),
                                                  ),
                                                ),
                                                ),
                                              ],
                                            ),
                                            ),
                                          ),
                                          title: Text(
                                            connection.name,
                                            style: AppTextStyles.labelText
                                              .copyWith(
                                            color: Colors.white,
                                            fontSize: fontSize * 1.1,
                                            ),
                                          ),
                                          subtitle: Row(
                                            children: [
                                            Text(
                                              _formatLastSeen(connection.lastSeen),
                                              style: AppTextStyles.bodyText.copyWith(
                                              color: Colors.white70,
                                              fontSize: fontSize * 0.7,
                                              ),
                                            ),
                                            ],
                                          ),
                                          trailing: Icon(
                                            Icons.arrow_forward_ios,
                                            color: Colors.white70),
                                          onTap: () {
                                            if (controller.userData.isEmpty) {
                                            return;
                                            }

                                            debugPrint(
                                              'User ID: ${controller.userData.first.id}');
                                            debugPrint(
                                              'Connection ID: ${connection.conectionId}');
                                            debugPrint(
                                              'Connection Name: ${connection.name}');

                                            if (controller
                                                .userData.first.id ==
                                              connection.conectionId) {
                                            connection.conectionId =
                                              connection.userId;
                                            connection.userId = controller
                                              .userData.first.id;
                                            }

                                            controller.messages.clear();
                                            controller
                                              .fetchChats(
                                                connection.conectionId)
                                              .then((value) async {
                                            if (value == true) {
                                              EncryptedSharedPreferences
                                                preferences =
                                                EncryptedSharedPreferences
                                                  .getInstance();
                                              String? token = preferences
                                                .getString('token');
                                              if (token != null &&
                                                token.isNotEmpty) {
                                              controller.token.value =
                                                token;

                                              Get.to(() => ChatScreen(
                                                  senderId: controller
                                                    .userData
                                                    .first
                                                    .id,
                                                  receiverId: connection
                                                    .conectionId,
                                                  receiverName:
                                                    connection.name,
                                                ));
                                              }
                                            }
                                            });
                                          },
                                          ),
                                        ),
                                      );
                                    },
                                  ));
                            } else if (selectedSection == 1) {
                              return Center(
                                  child: Text('Recently',
                                      style: AppTextStyles.bodyText
                                          .copyWith(color: Colors.white)));
                            } else {
                              return Center(
                                  child: Text('HookUp',
                                      style: AppTextStyles.bodyText
                                          .copyWith(color: Colors.white)));
                            }
                          },
                        ),
                ),
              ],
            ),
          ),
          if (isLoading)
            Center(
              child: Lottie.asset("assets/animations/chatpageanimation.json",
                  repeat: true, reverse: true),
            ),
        ],
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        backgroundColor: AppColors.buttonColor,
        foregroundColor: Colors.white,
        overlayColor: Colors.black,
        overlayOpacity: 0.3,
        spacing: 12,
        spaceBetweenChildren: 8,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        children: [
          SpeedDialChild(
            child: const Icon(Icons.list),
            label: 'All',
            onTap: () => selectSection(0),
            backgroundColor: Colors.deepPurple,
          ),
          SpeedDialChild(
            child: const Icon(Icons.history),
            label: 'Recent',
            onTap: () => selectSection(1),
            backgroundColor: Colors.orange,
          ),
          SpeedDialChild(
            child: const Icon(Icons.favorite),
            label: 'HookUp',
            onTap: () => selectSection(2),
            backgroundColor: Colors.pink,
          ),
        ],
      ),
    );
  }

//// report user dailog box started.....................................................===========-------------------

  void showUserOptions(
      BuildContext context, UserConnections connection, String selecteduser) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.block, color: Colors.red),
                title: Text('Block User'),
                onTap: () {
                  controller.blockToRequestModel.blockto = selecteduser;
                  controller.blockUser(controller.blockToRequestModel);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.report, color: Colors.orange),
                title: Text('Report User'),
                onTap: () async {
                  Navigator.pop(context);
                  showReportUserDialog(connection.conectionId);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void showReportUserDialog(reporttouserid) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Obx(() {
          String displayText = selectedReason.value.isEmpty
              ? 'Select Reason'
              : selectedReason.value;
          String truncatedText = displayText.length > 30
              ? '${displayText.substring(0, 30)}...'
              : displayText;

          return AlertDialog(
            title: Text('Report User'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.transparent,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: AppColors.activeColor, width: 2),
                    ),
                  ),
                  onPressed: () {
                    showBottomSheet(
                      context: context,
                      label: "Select Reason",
                      options: controller.reportReasons
                          .map((reason) => reason.title)
                          .toList(),
                      onSelected: (String? value) {
                        Get.snackbar(
                            "selected reasonId",
                            controller
                                .reportUserReasonFeedbackRequestModel.reasonId
                                .toString());
                        if (value != null && value.isNotEmpty) {
                          selectedReason.value = value;
                          isselected.value = true;
                        } else {
                          isselected.value = false;
                        }
                      },
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Text(
                          truncatedText,
                          style: AppTextStyles.bodyText,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_drop_down,
                        color: AppColors.activeColor,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                if (isselected.value)
                  TextField(
                    cursorColor: AppColors.cursorColor,
                    maxLength: 60,
                    decoration: InputDecoration(
                      hintText: 'Describe the issue...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppColors.textColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    onChanged: (value) {
                      reportDescription.value = value;
                      iswriting.value = value.isNotEmpty;
                    },
                  ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: iswriting.value
                    ? () {
                        if (selectedReason.value.isNotEmpty &&
                            reportDescription.value.isNotEmpty) {
                          controller.reportUserReasonFeedbackRequestModel
                              .reasonId = selectedReason.value;
                          controller.reportUserReasonFeedbackRequestModel
                              .reason = reportDescription.value;
                          controller.reportUserReasonFeedbackRequestModel
                              .reportAgainst = reporttouserid;
                          Get.snackbar(
                              "selected reason",
                              controller
                                  .reportUserReasonFeedbackRequestModel.reason
                                  .toString());
                          Get.snackbar(
                              "selected reasonId",
                              controller
                                  .reportUserReasonFeedbackRequestModel.reasonId
                                  .toString());
                          Get.snackbar(
                              "selected report against",
                              controller.reportUserReasonFeedbackRequestModel
                                  .reportAgainst
                                  .toString());
                          controller.reportAgainstUser(
                              controller.reportUserReasonFeedbackRequestModel);
                          Navigator.pop(context);

                          success('Report Submitted',
                              'The user has been reported.');
                        } else {
                          failure('Error',
                              'Please select a reason and provide a description.');
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                  backgroundColor: AppColors.buttonColor,
                  foregroundColor: AppColors.textColor,
                ),
                child: Text('Submit Report'),
              ),
            ],
          );
        });
      },
    );
  }

  void showBottomSheet({
    required BuildContext context,
    required String label,
    required List<String> options,
    required Function(String?) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextStyles.bodyText.copyWith(fontSize: 18),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView(
                  children: List.generate(options.length, (index) {
                    return RadioListTile<String>(
                      title:
                          Text(options[index], style: AppTextStyles.bodyText),
                      value: options[index],
                      groupValue: selectedReason.value,
                      onChanged: (String? value) {
                        onSelected(value);
                        Navigator.pop(context);
                      },
                      activeColor: AppColors.activeColor,
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // reportt dailog box ended.....................................................=================--------------------------------------------------

  String _formatLastSeen(String lastSeen) {
    // Example: parse and format the lastSeen string as needed
    // You may need to adjust this logic based on your actual lastSeen format
    if (lastSeen.isEmpty) return 'Last seen: Unknown';
    try {
      final dateTime = DateTime.parse(lastSeen);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Last seen: just now';
      } else if (difference.inMinutes < 60) {
        return 'Last seen: ${difference.inMinutes} min ago';
      } else if (difference.inHours < 24) {
        return 'Last seen: ${difference.inHours} hr ago';
      } else {
        return 'Last seen: ${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      return 'Last seen: $lastSeen';
    }
  }
}

class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImagePage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Hero(
          tag: imageUrl,
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: InteractiveViewer(
              child: Image.network(imageUrl),
            ),
          ),
        ),
      ),
    );
  }
}
