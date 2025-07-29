import 'package:encrypt_shared_preferences/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../constants.dart'; // Assuming you have constants for Agora APP ID

class ReceiverVideoCallPage extends StatefulWidget {
  final String channelName;

  const ReceiverVideoCallPage({super.key, required this.channelName});

  @override
  ReceiverVideoCallPageState createState() => ReceiverVideoCallPageState();
}

class ReceiverVideoCallPageState extends State<ReceiverVideoCallPage> {
  late RtcEngine engine;
  String agoraToken = "";
  int? localUid;
  int? remoteUid;

  @override
  void initState() {
    super.initState();
    // _requestPermissions();
    _startCallIfPermitted();
    fetchAgoraToken(widget.channelName).then((value) {
      if (value == null) {
        failure('Error', 'Failed to fetch Agora token');
      } else {
        agoraToken = value;
        print("[Flutter] USing Token : $agoraToken");
        print("[Flutter] Using UUID : $localUid");
        initializeAgora();
      }
    });
  }

  Future<bool> _ensurePermissions() async {
    final camera = await Permission.camera.request();
    final mic = await Permission.microphone.request();
    // Add storage/location if needed

    if (camera.isGranted && mic.isGranted) {
      return true;
    } else {
      // Optionally show a dialog here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Camera and microphone permissions are required for video calls.')),
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
    fetchAgoraToken(widget.channelName).then((value) {
      if (value == null) {
        failure('Error', 'Failed to fetch Agora token');
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

  Future<String?> fetchAgoraToken(String channelName) async {
    try {
      final preferences = EncryptedSharedPreferences.getInstance();
      String? bearerToken = preferences.getString('token');

      if (bearerToken == null || bearerToken.isEmpty) {
        failure("Error", "Bearer Token not found");
        return null;
      }
      print("Fetching Agora token");
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
        failure('Error', 'Failed to fetch token');
        return null;
      }
    } catch (e) {
      failure("Error", e.toString());
      return null;
    }
  }

  Future<void> initializeAgora() async {
    try {
      // Initialize the Agora engine
      print("Initializing Agora Engine...");
      engine = createAgoraRtcEngine();
      await engine.initialize(RtcEngineContext(
        appId: AgoraConstants.AGORAAPPID,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

      engine.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            print("Local user joined: ${connection.localUid}");
            setState(() {
              localUid = connection.localUid;
            });
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            print("Remote user joined: $remoteUid");
            setState(() {
              this.remoteUid = remoteUid;
            });
          },
          onUserOffline: (RtcConnection connection, int remoteUid,
              UserOfflineReasonType reason) {
            print("Remote user offline: $remoteUid");
            setState(() {
              this.remoteUid = null;
            });
          },
        ),
      );

      // Set client role to Broadcaster and enable video
      await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      await engine.enableVideo();
      await engine.enableLocalVideo(true);
      await engine.startPreview();

      // Join the channel
      await engine.joinChannel(
        token: agoraToken,
        channelId: widget.channelName,
        uid: localUid ?? 0,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          autoSubscribeVideo: true,
          autoSubscribeAudio: true,
        ),
      );

      await engine.muteLocalVideoStream(false);
      await engine.muteLocalAudioStream(false);

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
      print("Error initializing Agora Engine: $e");
    }
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
        title: const Text('Receiver Video Call'),
      ),
      body: Stack(
        children: [
          // Remote video view
          Center(
            child: remoteVideo(),
          ),

          // Local video view in top-left corner
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 100,
              height: 150,
              child: localUid != null
                  ? AgoraVideoView(
                      controller: VideoViewController(
                        rtcEngine: engine,
                        canvas: VideoCanvas(uid: localUid!),
                      ),
                    )
                  : const CircularProgressIndicator(),
            ),
          ),

          Center(
            child: remoteUid != null
                ? AgoraVideoView(
                    controller: VideoViewController.remote(
                      rtcEngine: engine,
                      canvas: VideoCanvas(uid: remoteUid!),
                      connection: RtcConnection(channelId: widget.channelName),
                    ),
                  )
                : const CircularProgressIndicator(),
          )
        ],
      ),
    );
  }

  Widget remoteVideo() {
    if (remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: engine,
          canvas: VideoCanvas(uid: remoteUid),
          connection: RtcConnection(channelId: widget.channelName),
        ),
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }
}
