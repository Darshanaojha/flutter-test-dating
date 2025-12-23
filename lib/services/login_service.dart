import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controllers/controller.dart';
import '../Models/RequestModels/user_login_request_model.dart';
import '../Models/ResponseModels/user_login_response_model.dart';
import '../Providers/fcmService.dart';

/// Login service with timeout and error handling
class LoginService {
  /// Default timeout for login operations (in seconds)
  static const Duration defaultTimeout = Duration(seconds: 15);
  
  /// Timeout for individual operations (in seconds)
  static const Duration operationTimeout = Duration(seconds: 8);

  /// Performs login with all async operations
  static Future<LoginResult> performLogin({
    required UserLoginRequest loginRequest,
    required Controller controller,
    Duration? timeout,
    Function(String)? onStatusUpdate,
  }) async {
    timeout ??= defaultTimeout;
    
    List<String> errors = [];

    try {
      // Step 1: Perform login API call
      try {
        onStatusUpdate?.call('Authenticating...');
        final UserLoginResponse? response = await controller
            .login(loginRequest)
            .timeout(
              operationTimeout,
              onTimeout: () {
                debugPrint('Login API call timed out');
                return null;
              },
            );

        if (response == null) {
          return LoginResult(
            success: false,
            errors: ['Login failed. Please check your credentials.'],
          );
        }

        if (!response.success) {
          return LoginResult(
            success: false,
            errors: ['Login failed: ${response.error.message}'],
          );
        }

        onStatusUpdate?.call('Setting up your account...');
        debugPrint('✅ Login successful');

        // Step 2: Subscribe to FCM topics
        try {
          onStatusUpdate?.call('Configuring notifications...');
          
          final String packagestatus = response.payload.packagestatus;
          final String userId = response.payload.userId;

          // Subscribe to appropriate topics based on package status
          if (packagestatus == '0') {
            await FCMService()
                .subscribeToTopic("unsubscribed")
                .timeout(
                  operationTimeout,
                  onTimeout: () {
                    debugPrint('FCM subscribe to unsubscribed timed out');
                    errors.add('Failed to configure notifications');
                  },
                );
          } else {
            await FCMService()
                .subscribeToTopic("subscribed")
                .timeout(
                  operationTimeout,
                  onTimeout: () {
                    debugPrint('FCM subscribe to subscribed timed out');
                    errors.add('Failed to configure notifications');
                  },
                );
          }

          // Subscribe to user-specific topic
          await FCMService()
              .subscribeToTopic(userId)
              .timeout(
                operationTimeout,
                onTimeout: () {
                  debugPrint('FCM subscribe to userId timed out');
                  errors.add('Failed to configure user notifications');
                },
              );

          // Subscribe to all users topic
          await FCMService()
              .subscribeToTopic("alluser")
              .timeout(
                operationTimeout,
                onTimeout: () {
                  debugPrint('FCM subscribe to alluser timed out');
                  errors.add('Failed to configure global notifications');
                },
              );

          debugPrint('✅ FCM topics subscribed');
        } catch (e) {
          debugPrint('Error subscribing to FCM topics: $e');
          errors.add('Failed to configure notifications: ${e.toString()}');
          // Continue even if FCM subscription fails
        }

        return LoginResult(
          success: true,
          loginResponse: response,
          errors: errors,
        );
      } catch (e) {
        debugPrint('Error during login: $e');
        return LoginResult(
          success: false,
          errors: ['Login failed: ${e.toString()}'],
        );
      }
    } catch (e) {
      debugPrint('Unexpected error during login: $e');
      return LoginResult(
        success: false,
        errors: ['Unexpected error: ${e.toString()}'],
      );
    }
  }

  /// Performs login with timeout
  static Future<LoginResult> performLoginWithTimeout({
    required UserLoginRequest loginRequest,
    required Controller controller,
    Duration? timeout,
    Function(String)? onStatusUpdate,
  }) async {
    timeout ??= defaultTimeout;

    try {
      return await performLogin(
        loginRequest: loginRequest,
        controller: controller,
        timeout: timeout,
        onStatusUpdate: onStatusUpdate,
      ).timeout(
        timeout,
        onTimeout: () {
          debugPrint('Login operation timed out after ${timeout!.inSeconds} seconds');
          return LoginResult(
            success: false,
            errors: ['Login timed out. Please try again.'],
            timedOut: true,
          );
        },
      );
    } catch (e) {
      debugPrint('Error in performLoginWithTimeout: $e');
      return LoginResult(
        success: false,
        errors: ['Login failed: ${e.toString()}'],
      );
    }
  }
}

/// Result of login operation
class LoginResult {
  final bool success;
  final UserLoginResponse? loginResponse;
  final List<String> errors;
  final bool timedOut;

  LoginResult({
    required this.success,
    this.loginResponse,
    this.errors = const [],
    this.timedOut = false,
  });

  String get errorMessage {
    if (errors.isEmpty) return '';
    return errors.join('\n');
  }

  String? get packageStatus => loginResponse?.payload.packagestatus;
  String? get userId => loginResponse?.payload.userId;
}

