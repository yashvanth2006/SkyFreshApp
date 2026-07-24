import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:skyfresh/api_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  FirebaseMessaging? _messaging;
  String? _currentToken;

  Future<void> initialize() async {
    try {
      // Request notification permissions
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('Notification permission granted: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        _messaging = FirebaseMessaging.instance;

        // Get initial message if app was opened from notification
        RemoteMessage? initialMessage = await _messaging?.getInitialMessage();
        if (initialMessage != null) {
          print('App opened from notification: ${initialMessage.notification?.title}');
        }

        // Get FCM token
        final token = await _messaging?.getToken();
        if (token != null) {
          _currentToken = token;
          print('FCM Token: $token');
          await _sendTokenToBackend(token);
        }

        // Listen for token refreshes
        FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
          print('FCM Token refreshed: $newToken');
          _currentToken = newToken;
          _sendTokenToBackend(newToken);
        });

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          print('Received foreground message: ${message.notification?.title}');
          _showForegroundNotification(message);
        });

        // Handle messages when app is in background
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          print('App opened from background notification: ${message.notification?.title}');
        });
      }
    } catch (e) {
      print('Error initializing Firebase Messaging: $e');
    }
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      final result = await ApiService.updateFcmToken(token);
      if (result['success'] == true) {
        print('FCM token saved to backend successfully');
      } else {
        print('Failed to save FCM token: ${result['message']}');
      }
    } catch (e) {
      print('Error sending FCM token to backend: $e');
    }
  }

  void _showForegroundNotification(RemoteMessage message) {
    // This will be called when the app is in foreground
    // You can show a SnackBar or dialog here
    // For now, we'll just log it - the UI can implement a notification handler
    print('Foreground notification: ${message.notification?.title} - ${message.notification?.body}');
  }

  String? get currentToken => _currentToken;
}
