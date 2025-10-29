import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../constants.dart'; // Assuming you have constants for Agora APP ID
import '../../Controllers/controller.dart';

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
  bool isAudioMuted = false;
  bool isVideoMuted = false;
  bool isSpeakerOn = false;
  Controller controller = Controller();

  @override
  void initState() {
    super.initState();
    _startCallIfPermitted();
  }

  Future<bool> _ensurePermissions() async {
    final camera = await Permission.camera.request();
    final mic = await Permission.microphone.request();

    if (camera.isGranted && mic.isGranted) {
      return true;
    } else {
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
      Navigator.of(context).pop();
      return;
    }
    fetchAgoraToken(widget.channelName).then((value) {
      if (value == null) {
        failure('Error', 'Failed to fetch Agora token');
      }
      else {
        agoraToken = value;
        print("[Flutter] USing Token : $agoraToken");
        print("[Flutter] Using UUID : $localUid");
        initializeAgora();
      }
    });
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

      await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      await engine.enableVideo();
      await engine.enableLocalVideo(true);
      await engine.startPreview();

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

      await engine.setVideoEncoderConfiguration(VideoEncoderConfiguration(
        dimensions:
            VideoDimensions(width: 640, height: 360),
        frameRate: 15,
        bitrate: 800,
        orientationMode:
            OrientationMode.orientationModeAdaptive,
        degradationPreference: DegradationPreference
            .maintainQuality,
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

  void toggleAudio() async {
    setState(() {
      isAudioMuted = !isAudioMuted;
    });
    await engine.muteLocalAudioStream(isAudioMuted);
  }

  void toggleVideo() async {
    setState(() {
      isVideoMuted = !isVideoMuted;
    });
    await engine.muteLocalVideoStream(isVideoMuted);
  }

  void _toggleSpeaker() async {
    setState(() {
      isSpeakerOn = !isSpeakerOn;
    });
    await engine.setEnableSpeakerphone(isSpeakerOn);
  }

  void endCall() async {
    dispose();
    await engine.leaveChannel();
    Navigator.pop(context);
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
          'Video Call',
          style: AppTextStyles.headingText.copyWith(
            fontSize: fontSize * 1.1,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          Center(child: remoteVideo()),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0, bottom: 100.0), // Adjust padding as needed
              child: SizedBox(
                width: 120,
                height: 200,
                child: Center(
                  child: localUid != null
                      ? Builder(builder: (context) {
                          debugPrint('Local UID for ReceiverVideoCallPage: $localUid');
                          return AgoraVideoView(
                            controller: VideoViewController(
                              rtcEngine: engine,
                              canvas: VideoCanvas(uid: 0), // Explicitly use uid 0 for local video
                            ),
                          );
                        })
                      : const CircularProgressIndicator(),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: toggleAudio,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: isAudioMuted
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
                      padding: EdgeInsets.all(size.width * 0.05), // Responsive padding
                      child: Icon(
                        isAudioMuted ? Icons.mic_off : Icons.mic,
                        size: size.width * 0.08, // Responsive icon size
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: size.width * 0.03), // Responsive spacing
                  GestureDetector(
                    onTap: toggleVideo,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: isVideoMuted
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
                      padding: EdgeInsets.all(size.width * 0.05), // Responsive padding
                      child: Icon(
                        isVideoMuted ? Icons.videocam_off : Icons.videocam,
                        size: size.width * 0.08, // Responsive icon size
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: size.width * 0.03), // Responsive spacing
                  GestureDetector(
                    onTap: _toggleSpeaker,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: isSpeakerOn
                              ? [Colors.blueAccent, Colors.lightBlue]
                              : [Colors.grey, Colors.blueGrey],
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
                      padding: EdgeInsets.all(size.width * 0.05), // Responsive padding
                      child: Icon(
                        isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                        size: size.width * 0.08, // Responsive icon size
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: size.width * 0.03), // Responsive spacing
                  GestureDetector(
                    onTap: endCall,
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
                      padding: EdgeInsets.all(size.width * 0.05), // Responsive padding
                      child: Icon(
                        Icons.call_end,
                        size: size.width * 0.08, // Responsive icon size
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
        child: Text(
          "Waiting for remote user...",
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      );
    }
  }
}