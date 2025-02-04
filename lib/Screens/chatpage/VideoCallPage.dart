import 'package:encrypt_shared_preferences/provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

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
  String channelName = "";
  late DateTime callStartTime;
  late DateTime callEndTime;
  String agoraToken = "";
  int? localUid;
  int? remoteUid;
  bool localUserJoined = false;

  late RtcEngine engine;
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

    // Requesting permissions for camera and microphone
    final permissionStatus = await [
      Permission.microphone,
      Permission.camera,
    ].request();

    // Check if permissions are granted
    if (!permissionStatus[Permission.microphone]!.isGranted ||
        !permissionStatus[Permission.camera]!.isGranted) {
      print("Permission Denied: Microphone or Camera");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Permission Denied"),
            content: const Text(
                "Microphone and Camera permissions are required to make a video call."),
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
      return;
    }

    print("Permissions granted for Camera and Microphone");

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
