import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

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
  String channelName = "";
  late DateTime callStartTime;
  late DateTime callEndTime;
  String agoraToken = "";
  int? localUid;
  int? remoteUid;
  bool localUserJoined = false;
  bool isLocalAudioMuted = false; // Mute state for local user

  late RtcEngine engine;

  // Fetch the Agora token from the server
  Future<String?> fetchAgoraToken() async {
    try {
      final preferences = await EncryptedSharedPreferences.getInstance();
      String? bearerToken = preferences.getString('token');

      if (bearerToken == null || bearerToken.isEmpty) {
        failure("Error", "Bearer Token not found");
        return null;
      }

      print("Fetching the Agora token");

      final response = await http.post(
        Uri.parse('${springbooturl}api/agora/generateToken'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Call'),
      ),
      body: Stack(
        children: [
          // Display remote user's audio status (using an icon as placeholder)
          Center(
            child: remoteUid != null
                ? const Icon(Icons.volume_up, size: 50, color: Colors.green)
                : const Text(
                    'Waiting for remote user to join...',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
          ),
          // Local user controls (microphone mute/unmute)
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 100,
              child: Center(
                child: IconButton(
                  icon: Icon(
                    isLocalAudioMuted ? Icons.mic_off : Icons.mic,
                    size: 40,
                    color: isLocalAudioMuted ? Colors.red : Colors.green,
                  ),
                  onPressed: _toggleMute,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
