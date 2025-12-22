import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controllers/controller.dart';
import '../Models/RequestModels/update_activity_status_request_model.dart';
import '../Providers/WebSocketService.dart';
import '../Providers/fcmService.dart';
import 'package:encrypt_shared_preferences/provider.dart';
// NavigationController is defined in navigationpage.dart, but we'll use Get.isRegistered to avoid circular dependency

/// Logout service with timeout and error handling
class LogoutService {
  /// Default timeout for logout operations (in seconds)
  static const Duration defaultTimeout = Duration(seconds: 10);
  
  /// Timeout for individual operations (in seconds)
  static const Duration operationTimeout = Duration(seconds: 5);

  /// Performs logout with all async operations
  /// Returns true if successful, false otherwise
  static Future<LogoutResult> performLogout({
    Duration? timeout,
    Function(String)? onStatusUpdate,
  }) async {
    timeout ??= defaultTimeout;
    
    try {
      String? userId;
      final List<String> errors = [];

      // Get userId before clearing preferences
      try {
        final preferences = EncryptedSharedPreferences.getInstance();
        userId = await preferences.getString('userId');
        onStatusUpdate?.call('Clearing session...');
      } catch (e) {
        debugPrint('Error getting userId during logout: $e');
        errors.add('Failed to retrieve user ID');
      }

      // Update activity status
      try {
        if (Get.isRegistered<Controller>()) {
          final controller = Get.find<Controller>();
          final updateActivityStatusRequest = UpdateActivityStatusRequest(
            status: '0',
          );
          await controller
              .updateactivitystatus(updateActivityStatusRequest)
              .timeout(
                operationTimeout,
                onTimeout: () {
                  debugPrint('Activity status update timed out');
                  errors.add('Activity status update timed out');
                  return false;
                },
              );
          debugPrint('✅ Activity status updated');
        }
      } catch (e) {
        debugPrint('Error updating activity status during logout: $e');
        errors.add('Failed to update activity status');
      }

      // Disconnect WebSocket
      try {
        onStatusUpdate?.call('Syncing with server...');
        final websocketService = WebSocketService();
        if (websocketService.isConnected()) {
          websocketService.disconnect();
          debugPrint('✅ WebSocket disconnected');
        }
      } catch (e) {
        debugPrint('Error disconnecting WebSocket: $e');
        errors.add('Failed to disconnect WebSocket');
      }

      // Unsubscribe from all FCM topics
      try {
        if (userId != null) {
          await FCMService()
              .unsubscribeFromAllTopics(userId)
              .timeout(
                operationTimeout,
                onTimeout: () {
                  debugPrint('FCM unsubscribe timed out');
                  errors.add('FCM unsubscribe timed out');
                },
              );
          debugPrint('✅ Unsubscribed from all FCM topics');
        }
      } catch (e) {
        debugPrint('Error unsubscribing from FCM topics: $e');
        errors.add('Failed to unsubscribe from notifications');
      }

      // Clear preferences
      try {
        onStatusUpdate?.call('Finishing up...');
        final preferences = EncryptedSharedPreferences.getInstance();
        await preferences.clear().timeout(
              operationTimeout,
              onTimeout: () {
                debugPrint('Clear preferences timed out');
                errors.add('Failed to clear preferences');
                return false;
              },
            );
        debugPrint('✅ Preferences cleared');
      } catch (e) {
        debugPrint('Error clearing preferences: $e');
        errors.add('Failed to clear preferences');
      }

      // Delete controllers
      try {
        if (Get.isRegistered<Controller>()) {
          Get.delete<Controller>();
        }
        // Note: NavigationController deletion is handled in the navigation page
        // to avoid circular dependency. Get will clean up unreferenced controllers.
        debugPrint('✅ Controllers deleted');
      } catch (e) {
        debugPrint('Error deleting controllers: $e');
        errors.add('Failed to delete controllers');
      }

      // Create new Controller instance
      try {
        Get.put(Controller());
      } catch (e) {
        debugPrint('Error creating new Controller: $e');
        errors.add('Failed to initialize new session');
      }

      return LogoutResult(
        success: true,
        errors: errors,
      );
    } catch (e) {
      debugPrint('Unexpected error during logout: $e');
      return LogoutResult(
        success: false,
        errors: ['Unexpected error: ${e.toString()}'],
      );
    }
  }

  /// Performs logout with timeout
  static Future<LogoutResult> performLogoutWithTimeout({
    Duration? timeout,
    Function(String)? onStatusUpdate,
  }) async {
    timeout ??= defaultTimeout;

    try {
      return await performLogout(
        timeout: timeout,
        onStatusUpdate: onStatusUpdate,
      ).timeout(
        timeout,
        onTimeout: () {
          debugPrint('Logout operation timed out after ${timeout!.inSeconds} seconds');
          return LogoutResult(
            success: false,
            errors: ['Logout timed out. Some operations may not have completed.'],
            timedOut: true,
          );
        },
      );
    } catch (e) {
      debugPrint('Error in performLogoutWithTimeout: $e');
      return LogoutResult(
        success: false,
        errors: ['Logout failed: ${e.toString()}'],
      );
    }
  }
}

/// Result of logout operation
class LogoutResult {
  final bool success;
  final List<String> errors;
  final bool timedOut;

  LogoutResult({
    required this.success,
    required this.errors,
    this.timedOut = false,
  });

  String get errorMessage {
    if (errors.isEmpty) return '';
    return errors.join('\n');
  }
}

