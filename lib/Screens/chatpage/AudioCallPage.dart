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
  Future<String?> fetchAgoraToken() async {
    try {
      final preferences = EncryptedSharedPreferences.getInstance();
      String? bearerToken = preferences.getString('token');

      if (bearerToken == null || bearerToken.isEmpty) {
        failure("Error", "Bearer Token not found");
        return null;
      }

      final response = await http.get(
        Uri.parse('$springbooturl api/agora/generateToken'),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['success'] == true) {
          return data['message'] as String;
        } else {
          failure('Error', 'Failed to fetch token: ${data['message']}');
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

  late String channelName;
  late DateTime callStartTime;
  late DateTime callEndTime;
  late String agoraToken;
  int? localUid;
  int? remoteUid;
  bool localUserJoined = false;
  bool isLocalAudioMuted = false; // Track mute state

  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    fetchAgoraToken().then((fetchedToken) {
      if (fetchedToken != null) {
        agoraToken = fetchedToken;
      }
      _initializeAgora();
    }).catchError((error) {
      print("Error fetching token: $error");
    });
    channelName = _generateChannelName(widget.caller, widget.receiver);
  }

  Future<void> _initializeAgora() async {
    final permissionStatus = await Permission.microphone.request();

    if (!permissionStatus.isGranted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Permission Denied"),
            content: const Text(
                "Microphone permission is required to make an audio call."),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
      return; // Do not proceed further if permission is not granted
    }

    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: AgoraConstants.AGORAAPPID,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user ${connection.localUid} joined");
          setState(() {
            localUid = connection.localUid;
            callStartTime = DateTime.now();
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("remote user $remoteUid joined");
          setState(() {
            this.remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          debugPrint("remote user $remoteUid left channel");
          callEndTime = DateTime.now();
          _sendCallDataToBackend();
        },
        onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
          debugPrint(
              '[onTokenPrivilegeWillExpire] connection: ${connection.toJson()}, token: $token');
        },
      ),
    );

    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableAudio();

    await _engine.joinChannel(
      token: agoraToken,
      channelId: channelName,
      uid: 0,
      options: const ChannelMediaOptions(),
    );
  }

  String _generateChannelName(String caller, String receiver) {
    return caller.compareTo(receiver) < 0
        ? "chat_${caller}_and_$receiver"
        : "chat_${receiver}_and_$caller";
  }

  void _sendCallDataToBackend() async {
    Duration callDuration = callEndTime.difference(callStartTime);

    int durationInSeconds = callDuration.inSeconds;

    final response = await http.post(
      Uri.parse('$springbooturl api/agora/saveData'),
      body: json.encode({
        'type': 'audio',
        'caller': widget.caller,
        'receiver': widget.receiver,
        'callStartTime': callStartTime.toIso8601String(),
        'callEndTime': callEndTime.toIso8601String(),
        'callDurationSeconds': durationInSeconds,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print('Call data successfully sent');
    } else {
      print('Failed to send call data');
    }
  }

  @override
  void dispose() {
    super.dispose();
    _disposeAgora();
  }

  Future<void> _disposeAgora() async {
    await _engine.leaveChannel();
    await _engine.release();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Call'),
      ),
      body: Stack(
        children: [
          Center(
            child: _remoteAudio(),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 100,
              height: 150,
              child: Center(
                child: localUserJoined
                    ? IconButton(
                        icon: Icon(Icons.mic),
                        onPressed: _toggleMute,
                      )
                    : const CircularProgressIndicator(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _remoteAudio() {
    if (remoteUid != null) {
      return Icon(Icons.volume_up, size: 50, color: Colors.green);
    } else {
      return const Text(
        'Please wait for remote user to join',
        textAlign: TextAlign.center,
      );
    }
  }

  void _toggleMute() async {
    setState(() {
      isLocalAudioMuted = !isLocalAudioMuted;
    });

    await _engine.muteLocalAudioStream(isLocalAudioMuted);
  }
}
