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

class VideoCallPage extends StatefulWidget {
  final String caller;
  final String receiver;

  const VideoCallPage(
      {super.key, required this.caller, required this.receiver});

  @override
  VideoCallPageState createState() => VideoCallPageState();
}

class VideoCallPageState extends State<VideoCallPage> {
  Controller controller = Get.put(Controller());
  String channelName = "";
  late DateTime callStartTime;
  late DateTime callEndTime;
  String agoraToken = "";
  int? localUid;
  int? remoteUid;
  bool localUserJoined = false;

  late RtcEngine engine;

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
    var cameraStatus = await Permission.camera.request();
    if (cameraStatus.isGranted) {
      print('Camera permission granted');
    } else if (cameraStatus.isDenied) {
      print('Camera permission denied');
    }

    // Request location permission
    var locationStatus = await Permission.location.request();
    if (locationStatus.isGranted) {
      print('Location permission granted');
    } else if (locationStatus.isDenied) {
      print('Location permission denied');
    }

    // Request storage permission
    var storageStatus = await Permission.storage.request();
    if (storageStatus.isGranted) {
      print('Storage permission granted');
    } else if (await Permission.storage.isRestricted) {
      print('Storage permission is restricted');
    } else {
      // Handle Android 13+ permissions
      var manageStorageStatus =
          await Permission.manageExternalStorage.request();

      if (manageStorageStatus.isGranted) {
        print('Manage external storage permission granted');
      } else if (manageStorageStatus.isPermanentlyDenied) {
        openAppSettings();
      } else {
        print('Manage external storage permission denied');
      }
    }

    // Request microphone permission
    var microphoneStatus = await Permission.microphone.request();
    if (microphoneStatus.isGranted) {
      print('Microphone permission granted');
    } else if (microphoneStatus.isDenied) {
      print('Microphone permission denied');
    }

    // Speaker permission (typically implicitly granted when using audio output)
    // There's no specific permission for speaker access in Flutter.
    // Just ensure that the app can play audio properly, and you'll usually be good to go.
    print('Speaker permission is assumed granted when playing audio.');
  }

  Future<String?> fetchAgoraToken() async {
    try {
      final preferences = EncryptedSharedPreferences.getInstance();
      String? bearerToken = preferences.getString('token');

      if (bearerToken == null || bearerToken.isEmpty) {
        failure("Error", "Bearer Token not found");
        return null;
      }
      print("Fetching the agora token");
      final response =
          await http.post(Uri.parse('${springbooturl}api/agora/generateToken'),
              headers: {
                'Authorization': 'Bearer $bearerToken',
                'Content-Type': 'application/json',
              },
              body: jsonEncode({'channelName': channelName}));
      print(response.body.toString());
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

  @override
  void initState() {
    super.initState();
    _requestPermissions();
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

  Future<void> initializeAgora() async {
    print("Initializing Agora...");

    try {
      print("Initializing Agora Engine...");
      engine = createAgoraRtcEngine();

      await engine.initialize(RtcEngineContext(
        appId: AgoraConstants.AGORAAPPID,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
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
            });
            AgoraProvider()
                .sendNotification(channelName, controller.userData.first.name,
                    widget.receiver, '3')
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
          },
          onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
            debugPrint(
                '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
          },
        ),
      );
      print("Event Handlers registered successfully");
    } catch (e) {
      print("Error registering event handlers: $e");
      return;
    }

    try {
      print("Setting client role to Broadcaster...");
      await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      print("Client role set to Broadcaster");

      print("Enabling Video...");
      await engine.enableVideo();
      print("Video enabled");

      print("Starting Preview...");
      await engine.startPreview();
      print("Preview started");

      // Joining the channel
      ChannelMediaOptions options = const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      );
      print(
          "Joining channel with ID: $channelName and token: $agoraToken and localuid: $localUid");
      await engine.joinChannel(
        token: agoraToken,
        channelId: channelName,
        uid: localUid ?? 0,
        options: options,
      );
      print("Successfully joined the channel");

      // Set video encoder configuration for lower resolution and frame rate
      await engine.setVideoEncoderConfiguration(VideoEncoderConfiguration(
        dimensions:
            VideoDimensions(width: 640, height: 360), // Lower resolution
        frameRate: 15, // Lower frame rate
        bitrate: 800,
        orientationMode:
            OrientationMode.orientationModeAdaptive, // Auto adjust orientation
        degradationPreference: DegradationPreference
            .maintainQuality, // Prioritize quality over bitrate
      ));
    } catch (e) {
      print("Error joining channel: $e");
    }
  }

  String generateChannelName(String caller, String receiver) {
    // Convert the caller and receiver UUIDs to hashCodes and ensure they are positive integers
    int callerHashCode = caller.hashCode.abs();
    int receiverHashCode = receiver.hashCode.abs();

    // Sort the hash codes to keep it consistent and prevent duplicates
    int firstHash =
        callerHashCode < receiverHashCode ? callerHashCode : receiverHashCode;
    int secondHash =
        callerHashCode < receiverHashCode ? receiverHashCode : callerHashCode;

    // Create the channel name with the two sorted hash codes
    return "chat_${firstHash}_and_$secondHash";
  }

  @override
  void dispose() {
    super.dispose();
    _disposeAgora();
  }

  Future<void> _disposeAgora() async {
    await engine.leaveChannel();
    await engine.release();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Call'),
      ),
      body: Stack(
        children: [
          // Remote video
          Center(
            child: remoteVideo(),
          ),

          // Local video in top-left corner
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 100, // You can adjust the size based on your needs
              height: 150,
              child: Center(
                child: localUserJoined
                    ? AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: engine,
                          canvas:
                              VideoCanvas(uid: localUid ?? 0), // Use localUid
                        ),
                      )
                    : const CircularProgressIndicator(),
              ),
            ),
          ),
        ],
      ),
    );
  }

// Remote video widget
  Widget remoteVideo() {
    if (remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: engine,
          canvas: VideoCanvas(uid: remoteUid),
          connection: RtcConnection(channelId: channelName),
        ),
      );
    } else {
      return const Center(
        child:
            CircularProgressIndicator(), // Show loading spinner until remote user joins
      );
    }
  }
}
