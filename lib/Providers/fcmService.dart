import '../constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FCMService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Generate and get the FCM token
  Future<String?> getToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      print('Generated FCM token: $token'); // Debugging: Print the token

      // Store the token in shared preferences
      final prefs = await SharedPreferences.getInstance();
      if (token != null) {
        await prefs.setString('fcm_token', token);
      }
      return token;
    } catch (e) {
      print('Error fetching FCM token: $e');
      return null;
    }
  }

  Future<void> sendTokenToBackend(String token) async {
    final String backendUrl = '$baseurl/Notifications/saveFcmToken';
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? bearerToken = pref.getString('token');
    if (bearerToken == null || bearerToken.isEmpty) {
      failure('Error', 'Bearer token not found');
      return;
    }
    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $bearerToken',
        },
        body: jsonEncode(<String, String>{
          'fcm_token': token,
        }),
      );
      if (response.statusCode == 200) {
        print('Token successfully sent to backend');
      } else {
        print(
            'Failed to send token to backend: ${response.body} ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending token to backend: $e');
    }
  }

  Future<void> deleteTokenFromBackend() async {
    final String backendUrl = '$baseurl/admin/Notifications/deleteFcmToken';
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? bearerToken = pref.getString('token');
    if (bearerToken != null) {
      print("bearer token $bearerToken");
    } else {
      print("bearer token is null");
    }
    try {
      final response =
          await http.post(Uri.parse(backendUrl), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $bearerToken',
      });
      if (response.statusCode == 200) {
        print('Token successfully deleted from backend');
      } else {
        print(
            'Failed to delete token from backend: ${response.body} ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting token from backend: $e');
    }
  }

  // Main method to handle token generation and sending
  Future<void> handleToken() async {
    String? token = await getToken();
    print(token);
    if (token != null) {
      await sendTokenToBackend(token);
    }
  }

  // Listen for token refreshes and handle updates
  void setupTokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      print('New FCM token: $newToken');

      // Store the new token in shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', newToken);

      await sendTokenToBackend(newToken);
    }).onError((error) {
      print('Error listening for token refresh: $error');
    });
  }

  // Refresh token manually if needed
  Future<void> refreshToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      await handleToken();
    } catch (e) {
      print('Error refreshing FCM token: $e');
    }
  }

  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      // await deleteTokenFromBackend();
    } catch (e) {
      print('Error deleting FCM token: $e');
    }
  }

  Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcm_token');
  }

  Future<void> setupNotifications() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message data: ${message.data}');
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        _showNotification(
          flutterLocalNotificationsPlugin,
          message.notification!,
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification clicked: ${message.messageId}');
      // Navigate to a specific screen or perform an action based on the notification data
    });
  }

  Future<void> _showNotification(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
      RemoteNotification notification) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'default_channel_id', // Replace with your channel ID
      'Default Channel', // Replace with your channel name
      channelDescription:
          'Default notification channel', // Replace with your channel description
      importance: Importance.max,
      priority: Priority.high,
      autoCancel: false, // Ensure the notification is not auto-cancelled
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

  // Background message handler
  Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Handling a background message: ${message.messageId}');
    // Process the message here, e.g., show a local notification
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  // Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }
}
