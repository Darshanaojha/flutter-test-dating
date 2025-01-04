import 'package:dating_application/Models/ResponseModels/get_all_chat_history_page.dart';
import 'package:dating_application/Screens/chatmessagespage/pinrequestpage.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
  bool isLoading = false;

  double getResponsiveFontSize(double scale) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * scale;
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  initialize() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search TextField
                TextField(
                  cursorColor: AppColors.cursorColor,
                  onChanged: (query) {
                    setState(() {
                      searchQuery = query;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search Contacts...',
                    hintStyle:
                        AppTextStyles.customTextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: AppColors.iconColor),
                    filled: true,
                    fillColor: AppColors.formFieldColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${getFilteredUsers().length} members',
                      style: AppTextStyles.customTextStyle(color: Colors.grey),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Get.to(MessageRequestPage());
                        Get.snackbar('count',
                            controller.userConnections.length.toString());
                        print("Ping button pressed");
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: Text('Ping'),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Expanded(
                  child: FutureBuilder(
                    future: controller.fetchalluserconnections(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting ||
                          controller.userConnections.isEmpty) {
                        return Center(
                          child: Lottie.asset(
                            "assets/animations/chatpageanimation.json",
                            repeat: true,
                            reverse: true,
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error loading contacts'));
                      } else {
                        return ListView.builder(
                          itemCount: getFilteredUsers().length,
                          itemBuilder: (context, index) {
                            final connection = getFilteredUsers()[index];

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Slidable(
                                key: Key(connection.conectionId),
                                direction: Axis.horizontal,
                                endActionPane: ActionPane(
                                  motion: const StretchMotion(),
                                  dismissible:
                                      DismissiblePane(onDismissed: () {}),
                                  children: [
                                    SlidableAction(
                                      backgroundColor: Colors.red,
                                      icon: Icons.info,
                                      onPressed: (BuildContext context) async {
                                        showUserOptions(
                                            context,
                                            connection,
                                            controller
                                                .userConnections[index].userId);
                                      },
                                      label: 'More',
                                    ),
                                  ],
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    if (controller.userData.isEmpty) {}
                                    debugPrint(
                                        'User ID: ${controller.userData.first.id}');
                                    debugPrint(
                                        'Connection ID: ${connection.conectionId}');
                                    debugPrint(
                                        'Connection Name: ${connection.name}');
                                    if (controller.userData.first.id ==
                                        connection.conectionId) {
                                      connection.conectionId =
                                          connection.userId;
                                      connection.userId =
                                          controller.userData.first.id;
                                    }
                                    controller.messages.clear();
                                    controller
                                        .fetchChats(connection.conectionId)
                                        .then((value) async {
                                      if (value == true) {
                                        EncryptedSharedPreferences preferences =
                                            await EncryptedSharedPreferences
                                                .getInstance();
                                        String? token =
                                            preferences.getString('token');
                                        if (token != null && token.isNotEmpty) {
                                          controller.token.value = token;
                                          Get.to(() => ChatScreen(
                                                senderId: controller
                                                    .userData.first.id,
                                                receiverId:
                                                    connection.conectionId,
                                                receiverName: connection.name,
                                              ));
                                        }
                                      }
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  FullScreenImagePage(
                                                imageUrl:
                                                    connection.profileImage,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Hero(
                                          tag: connection.profileImage,
                                          child: CircleAvatar(
                                            radius: 30.0,
                                            backgroundImage: NetworkImage(
                                                connection.profileImage),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            connection.name,
                                            style:
                                                AppTextStyles.customTextStyle(
                                                    color: Colors.white),
                                          ),
                                          Text(
                                            'Hi there!',
                                            style:
                                                AppTextStyles.customTextStyle(
                                                    color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            Center(
              // child: CircularProgressIndicator(),
              child: Lottie.asset("assets/animations/chatpageanimation.json",
                  repeat: true, reverse: true),
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
                  showReportUserDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  RxBool isselected = false.obs;
  RxBool iswriting = false.obs;

  void showReportUserDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String displayText =
            controller.reportUserReasonFeedbackRequestModel.reasonId.isEmpty
                ? 'Select Reason'
                : controller.reportUserReasonFeedbackRequestModel.reasonId;
        String truncatedText = displayText.length > 30
            ? '${displayText.substring(0, 30)}...'
            : displayText;
        return Obx(() {
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
                        if (value != null && value.isNotEmpty) {
                          controller.reportUserReasonFeedbackRequestModel
                              .reasonId = value;
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
                      controller.reportUserReasonFeedbackRequestModel.reason =
                          value;
                      iswriting.value = value.isNotEmpty;
                    },
                  ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: iswriting.value
                    ? () {
                        if (controller.reportUserReasonFeedbackRequestModel
                                .reasonId.isNotEmpty &&
                            controller.reportUserReasonFeedbackRequestModel
                                .reason.isNotEmpty) {
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
                      groupValue: controller
                          .reportUserReasonFeedbackRequestModel.reasonId,
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
