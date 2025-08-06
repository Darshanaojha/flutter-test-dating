import 'package:dating_application/Controllers/controller.dart';
import 'package:encrypt_shared_preferences/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../constants.dart';
import '../../Providers/agora_provider.dart';

class ReceiverAudioCallPage extends StatefulWidget {
  final String channelName;

  const ReceiverAudioCallPage({super.key, required this.channelName});

  @override
  ReceiverAudioCallPageState createState() => ReceiverAudioCallPageState();
}

class ReceiverAudioCallPageState extends State<ReceiverAudioCallPage> {
  Controller controller = Get.put(Controller());

  late DateTime callStartTime;
  late DateTime callEndTime;
  late String agoraToken;
  int? localUid;
  int? remoteUid;
  bool localUserJoined = false;
  bool isLocalAudioMuted = false;
  bool isSpeakerOn = false;

  late RtcEngine engine;

  Future<bool> _ensurePermissions() async {
    var mic = await Permission.microphone.request();
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
      Navigator.of(context).pop();
      return;
    }
    fetchAgoraToken(widget.channelName).then((value) {
      if (value == null) {
        failure('Error',
            'An Error Occured while fetching the token from the server');
      } else {
        agoraToken = value;
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

  Future<void> initializeAgora() async {
    print("Initializing Agora...");

    try {
      print("Initializing Agora Engine...");
      engine = createAgoraRtcEngine();
      await engine.initialize(RtcEngineContext(
        appId: AgoraConstants.AGORAAPPID,
        channelProfile:
            ChannelProfileType.channelProfileCommunication,
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
      print(
          "Joining channel with ID: ${widget.channelName} and token: $agoraToken and localuid: $localUid");
      await engine.joinChannel(
        token: agoraToken,
        channelId: widget.channelName,
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
  void initState() {
    super.initState();
    _startCallIfPermitted();
  }

  void _toggleMute() async {
    setState(() {
      isLocalAudioMuted = !isLocalAudioMuted;
    });

    await engine.muteLocalAudioStream(isLocalAudioMuted);
  }

  void _toggleSpeaker() async {
    setState(() {
      isSpeakerOn = !isSpeakerOn;
    });
    await engine.setEnableSpeakerphone(isSpeakerOn);
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
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                  SizedBox(width: 20),
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
                      padding: EdgeInsets.all(22),
                      child: Icon(
                        isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
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