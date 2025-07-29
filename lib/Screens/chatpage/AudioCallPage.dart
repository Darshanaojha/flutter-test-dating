import 'package:encrypt_shared_preferences/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../Controllers/controller.dart';
import '../../Providers/agora_provider.dart';
import '../../constants.dart';

class AudioCallPage extends StatefulWidget {
  final String caller;
  final String receiver;

  const AudioCallPage(
      {super.key, required this.caller, required this.receiver});

  @override
  AudioCallPageState createState() => AudioCallPageState();
}

class AudioCallPageState extends State<AudioCallPage> {
  Controller controller = Get.put(Controller());

  String channelName = "";
  late DateTime callStartTime;
  late DateTime callEndTime;
  String agoraToken = "";
  int? localUid;
  int? remoteUid;
  bool localUserJoined = false;
  bool isLocalAudioMuted = false; // Mute state for local user

  late RtcEngine engine;

  Future<bool> _ensurePermissions() async {
    var mic = await Permission.microphone.request();
    // Add camera if needed for video call
    if (mic.isGranted) {
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Microphone permission is required for audio calls.')),
      );
      return false;
    }
  }

  void _startCallIfPermitted() async {
    bool permitted = await _ensurePermissions();
    if (!permitted) {
      Navigator.of(context).pop(); // or show a blocking UI
      return;
    }
    channelName = generateChannelName(widget.caller, widget.receiver);
    print('channel name is $channelName');
    fetchAgoraToken().then((value) {
      if (value == null) {
        failure('Error',
            'An Error Occured while fetching the token from the server');
      } else {
        agoraToken = value;
        initializeAgora();
      }
    });
  }

  void _requestPermissions() async {
    // Request notification permission
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings notificationSettings =
        await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.authorized) {
      print('User granted notification permission');
    } else if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.denied) {
      print('User declined notification permission');
    } else if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional notification permission');
    }

    // Request camera permission
    if (await Permission.camera.isGranted) {
      print('Camera permission already granted');
    } else {
      var cameraStatus = await Permission.camera.request();
      if (cameraStatus.isPermanentlyDenied) {
        controller.showPermissionDialog('Camera', context);
      } else if (cameraStatus.isGranted) {
        print('Camera permission granted');
      } else if (cameraStatus.isDenied) {
        print('Camera permission denied');
      }
    }

    // Request location permission
    if (await Permission.location.isGranted) {
      print('Location permission already granted');
    } else {
      var locationStatus = await Permission.location.request();
      if (locationStatus.isPermanentlyDenied) {
        controller.showPermissionDialog('Location', context);
      } else if (locationStatus.isGranted) {
        print('Location permission granted');
      } else if (locationStatus.isDenied) {
        print('Location permission denied');
      }
    }

    // Request storage permission
    if (await Permission.storage.isGranted) {
      print('Storage permission already granted');
    } else {
      var storageStatus = await Permission.storage.request();
      if (storageStatus.isPermanentlyDenied) {
        controller.showPermissionDialog('Storage', context);
      } else if (storageStatus.isGranted) {
        print('Storage permission granted');
      } else if (await Permission.storage.isRestricted) {
        print('Storage permission is restricted');
      } else {
        var manageStorageStatus =
            await Permission.manageExternalStorage.request();
        if (manageStorageStatus.isPermanentlyDenied) {
          controller.showPermissionDialog('Manage External Storage', context);
        } else if (manageStorageStatus.isGranted) {
          print('Manage external storage permission granted');
        } else {
          print('Manage external storage permission denied');
        }
      }
    }

    // Request microphone permission
    if (await Permission.microphone.isGranted) {
      print('Microphone permission already granted');
    } else {
      var microphoneStatus = await Permission.microphone.request();
      if (microphoneStatus.isPermanentlyDenied) {
        controller.showPermissionDialog('Microphone', context);
      } else if (microphoneStatus.isGranted) {
        print('Microphone permission granted');
      } else if (microphoneStatus.isDenied) {
        print('Microphone permission denied');
      }
    }

    // Speaker permission (typically implicitly granted when using audio output)
    // There's no specific permission for speaker access in Flutter.
    // Just ensure that the app can play audio properly, and you'll usually be good to go.
    print('Speaker permission is assumed granted when playing audio.');
  }

  // Fetch the Agora token from the server
  Future<String?> fetchAgoraToken() async {
    try {
      final preferences = EncryptedSharedPreferences.getInstance();
      String? bearerToken = preferences.getString('token');

      if (bearerToken == null || bearerToken.isEmpty) {
        failure("Error", "Bearer Token not found");
        return null;
      }

      print("Fetching the Agora token");

      final response = await http.post(
        Uri.parse('$springbooturl/api/agora/generateToken'),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'channelName': channelName}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true) {
          localUid = data['uid'];
          return data['token'] as String;
        } else {
          failure('Error', 'Failed to fetch token: ${data['token']}');
          return null;
        }
      } else {
        failure('Error',
            'Failed to fetch token with status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      failure("Error", e.toString());
      return null;
    }
  }

  // Initialize Agora engine and setup
  Future<void> initializeAgora() async {
    print("Initializing Agora...");

    try {
      print("Initializing Agora Engine...");
      engine = createAgoraRtcEngine();
      await engine.initialize(RtcEngineContext(
        appId: AgoraConstants.AGORAAPPID,
        channelProfile:
            ChannelProfileType.channelProfileCommunication, // Audio call mode
      ));
      print("Agora Engine initialized successfully");
    } catch (e) {
      print("Error initializing Agora Engine: $e");
      return;
    }

    try {
      print("Registering Event Handlers...");
      engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            debugPrint("Local user ${connection.localUid} joined the channel");
            setState(() {
              localUid = connection.localUid;
              callStartTime = DateTime.now();
              localUserJoined = true;
            });
            AgoraProvider()
                .sendNotification(channelName, controller.userData.first.name,
                    widget.receiver, '2')
                .then((value) {
              value == true
                  ? null
                  : failure('Error', 'Failed to connect to the user');
            });
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            debugPrint("Remote user $remoteUid joined the channel");
            setState(() {
              this.remoteUid = remoteUid;
            });
          },
          onUserOffline: (RtcConnection connection, int remoteUid,
              UserOfflineReasonType reason) {
            debugPrint("Remote user $remoteUid left the channel");
            callEndTime = DateTime.now();
            setState(() {
              remoteUid = 0;
            });
          },
        ),
      );
      print("Event Handlers registered successfully");
    } catch (e) {
      print("Error registering event handlers: $e");
      return;
    }

    try {
      // Joining the channel
      print(
          "Joining channel with ID: $channelName and token: $agoraToken and localuid: $localUid");
      await engine.joinChannel(
        token: agoraToken,
        channelId: channelName,
        uid: localUid ?? 0,
        options: ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );
      print("Successfully joined the channel");
    } catch (e) {
      print("Error joining channel: $e");
    }
  }

  String generateChannelName(String caller, String receiver) {
    int callerHashCode = caller.hashCode.abs();
    int receiverHashCode = receiver.hashCode.abs();
    int firstHash =
        callerHashCode < receiverHashCode ? callerHashCode : receiverHashCode;
    int secondHash =
        callerHashCode < receiverHashCode ? receiverHashCode : callerHashCode;
    return "chat_${firstHash}_and_$secondHash";
  }

  @override
  void dispose() {
    super.dispose();
    _disposeAgora();
  }

  // Cleanup Agora resources
  Future<void> _disposeAgora() async {
    await engine.leaveChannel();
    await engine.release();
  }

  @override
  void initState() {
    super.initState();
    // _requestPermissions();
    _startCallIfPermitted();

    channelName = generateChannelName(widget.caller, widget.receiver);
    print('channel name is $channelName');
    fetchAgoraToken().then((value) {
      if (value == null) {
        failure('Error',
            'An Error Occured while fetching the token from the server');
      } else {
        agoraToken = value;
        initializeAgora();
      }
    });
  }

  // Toggle mute/unmute functionality
  void _toggleMute() async {
    setState(() {
      isLocalAudioMuted = !isLocalAudioMuted;
    });

    await engine.muteLocalAudioStream(isLocalAudioMuted);
  }

  void _endCall() async {
    await _disposeAgora();

    Get.close(2);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double fontSize = size.width * 0.045;

    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.gradientBackgroundList,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'Audio Call',
          style: AppTextStyles.headingText.copyWith(
            fontSize: fontSize * 1.1,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Remote user status
          Center(
            child: remoteUid != null
                ? Container(
                    padding: EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: AppColors.gradientBackgroundList,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.18),
                          blurRadius: 24,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(Icons.volume_up, size: 70, color: Colors.white),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.hourglass_empty,
                          size: 60, color: Colors.white70),
                      SizedBox(height: 18),
                      Text(
                        'Waiting for remote user to join...',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyText.copyWith(
                          fontSize: fontSize,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
          ),
          // Local user controls
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Mute/Unmute Button
                  GestureDetector(
                    onTap: _toggleMute,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: isLocalAudioMuted
                              ? [Colors.redAccent, Colors.deepOrange]
                              : [Colors.green, Colors.lightGreen],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(22),
                      child: Icon(
                        isLocalAudioMuted ? Icons.mic_off : Icons.mic,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 40),
                  // End Call Button
                  GestureDetector(
                    onTap: _endCall,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.red, Colors.deepOrange],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.redAccent.withOpacity(0.25),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(22),
                      child: Icon(
                        Icons.call_end,
                        size: 36,
                        color: Colors.white,
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
