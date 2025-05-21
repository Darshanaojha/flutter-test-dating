import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibration/vibration.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../Screens/chatpage/ReceiverAudioCallPage.dart';
import '../Screens/chatpage/ReceiverVideoCallPage.dart';

class FCMService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  FCMService() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  }

  Future<void> setupNotifications() async {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      final InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);
      // Initialize local notifications
      await flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onDidReceiveNotificationResponse: onNotificationTap);
      // Listen to incoming Firebase messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        // Ensure message data is not null or empty
        if (message.data.isNotEmpty) {
          // Safely access 'type' from message.data (it can be null, so default to '0' if not present)
          String notificationType = message.data['type'] ?? '0';
          print(notificationType);

          if (notificationType == "1") {
            // Regular notification
            if (message.notification != null) {
              // Ensure message.notification is not null before passing to showNotification
              showNotification(message.notification!);
            }
          } else if (notificationType == "2" || notificationType == "3") {
            // Call notification
            if (message.notification != null) {
              // Ensure message.notification is not null before passing to showCallNotification
              showCallNotification(message.notification!, notificationType);
            }
          }
        }
      });

      // Listen to notification taps when the app is opened from a background state
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (message.notification != null) {
          // Ensure notification is not null when accessing its data
          print('Notification clicked: ${message.notification}');
        }
      });
    } catch (e) {
      // Catch any errors that occur during setup
      print("Error setting up notifications: $e");
    }
  }

  Future<void> showNotification(RemoteNotification notification) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'default_channel_id',
      'Default Channel',
      channelDescription: 'Default notification channel',
      importance: Importance.max,
      priority: Priority.high,
      autoCancel: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      platformChannelSpecifics,
    );
  }

  void showCallNotification(
      RemoteNotification notification, String notificationType) async {
    String callerName = notification.title ?? '';
    String channelName = notification.body ?? '';

    debugPrint('Caller Name: $callerName');
    debugPrint('Channel Name: $channelName');
    debugPrint('Notification Type: $notificationType');

    try {
      // Play call sound
      debugPrint('Playing call sound...');
      await AudioPlayer().play(
        AssetSource('sounds/call.mp3'),
        volume: 1.0,
        mode: PlayerMode.lowLatency,
      );

      // Vibrate
      debugPrint('Triggering vibration...');
      Vibration.vibrate(duration: 3000);

      // Create Android notification details
      debugPrint('Setting up Android notification details...');
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'call_channel',
        'Call Notifications',
        channelDescription: 'Notifications for incoming calls',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('call'),
        enableVibration: true,
        timeoutAfter: 15000,
        ongoing: true,
        enableLights: true,
        actions: [
          AndroidNotificationAction('1', 'Accept',
              showsUserInterface: true, cancelNotification: false),
          AndroidNotificationAction('2', 'Reject',
              showsUserInterface: true, cancelNotification: false),
        ],
      );

      var platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      // Show the notification
      debugPrint('Showing the notification...');
      await flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notificationType == "2" ? 'Incoming Voice Call' : "Incoming Video Call",
        '$callerName is calling you',
        platformChannelSpecifics,
        payload: jsonEncode({
          'channelName': channelName,
          'type': notificationType,
        }),
      );

      debugPrint('Notification displayed successfully.');
    } catch (e) {
      debugPrint('Error showing call notification: $e');
    }
  }

  Future<void> onNotificationTap(NotificationResponse response) async {
    if (response.payload != null && response.actionId != null) {
      final actionId = response.actionId; // Get actionId from the response
      final payload =
          jsonDecode(response.payload ?? ''); // Get payload from the response

      if (actionId == '1' && payload['type'] == "2") {
        print('Call accepted');
        Get.to(ReceiverAudioCallPage(channelName: payload['channelName']));
      } else if (actionId == '1' && payload['type'] == "3") {
        print('Call accepted');
        Get.to(ReceiverVideoCallPage(channelName: payload['channelName']));
      } else if (actionId == '2') {
        print('Call rejected');
      }
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }
}
