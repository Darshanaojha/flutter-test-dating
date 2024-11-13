import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart'; // Add the share_plus package
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../constants.dart'; // Your constants for color and text styles

class AddPartnerPage extends StatefulWidget {
  const AddPartnerPage({super.key});

  @override
  AddPartnerPageState createState() => AddPartnerPageState();
}

class AddPartnerPageState extends State<AddPartnerPage> {
  String selectedPurpose = '';
  bool isLoading = false;
  final List<String> purposes = ['Dating', 'Friendship', 'Relationship'];

  String generateInviteLink(String purpose) {
    return 'https://www.yourapp.com/invite?purpose=$purpose'; 
  }

  void shareInviteLink(String link) {
    // Share the generated invite link using the Share.share method
    Share.share(link, subject: 'Join us on this amazing platform!');
  }

  // Function to show social media sharing options
  void showSocialMediaOptions(BuildContext context, String link) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.secondaryColor,
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: ListView(
            children: [
              ListTile(
                title: Text('Share to WhatsApp', style: AppTextStyles.bodyText),
                onTap: () {
                  // Directly share to WhatsApp (opens native WhatsApp sharing)
                  Share.share(link, subject: 'Invite for WhatsApp');
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Share to Instagram', style: AppTextStyles.bodyText),
                onTap: () {
                  // Directly share to Instagram (opens native Instagram sharing)
                  Share.share(link, subject: 'Invite for Instagram');
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Share to Facebook', style: AppTextStyles.bodyText),
                onTap: () {
                  // Directly share to Facebook (opens native Facebook sharing)
                  Share.share(link, subject: 'Invite for Facebook');
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: Text('Copy Link', style: AppTextStyles.bodyText),
                onTap: () {
                  // Copy the invite link to clipboard
                  Clipboard.setData(ClipboardData(text: link));
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to show purpose selection bottom sheet
  void showPurposeSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.8,
          maxChildSize: 1.0,
          builder: (context, scrollController) {
            return Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: ListView(
                controller: scrollController,
                children: purposes.map((purpose) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: AppColors.textColor,
                        backgroundColor: AppColors.buttonColor,
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          selectedPurpose = purpose;
                        });
                        Navigator.of(context).pop(); // Close the bottom sheet
                      },
                      child: Text(
                        purpose,
                        style: AppTextStyles.bodyText,
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text("Add Partner", style: AppTextStyles.titleText),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Animated Card for the purpose question
            AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              child: isLoading
                  ? Center(
                      child: SpinKitCircle(
                        color: AppColors.buttonColor,
                        size: 50.0,
                      ),
                    )
                  : Card(
                      key: ValueKey(selectedPurpose),
                      color: AppColors.secondaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'What is your purpose for inviting?',
                              style: AppTextStyles.subheadingText,
                            ),
                            SizedBox(height: 20),
                            // Purpose selection button
                            ElevatedButton(
                              onPressed: () {
                                showPurposeSelection(context); // Show purpose selection
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: AppColors.textColor,
                                backgroundColor: AppColors.buttonColor,
                                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                selectedPurpose.isEmpty
                                    ? "Click to Select"
                                    : selectedPurpose,
                                style: AppTextStyles.bodyText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
            SizedBox(height: 40),
            // Generate & Share button
            if (selectedPurpose.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoading = true; // Show loading spinner
                  });

                  // Simulate network delay or processing before generating the link
                  Future.delayed(Duration(seconds: 2), () {
                    setState(() {
                      isLoading = false; // Hide loading spinner
                    });

                    final link = generateInviteLink(selectedPurpose);
                    showSocialMediaOptions(context, link); // Show the social media options bottom sheet
                  });
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: AppColors.textColor,
                  backgroundColor: AppColors.buttonColor,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text("Generate & Share Link", style: AppTextStyles.bodyText),
              ),
          ],
        ),
      ),
    );
  }
}
