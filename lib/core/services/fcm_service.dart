import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import 'dart:io';

class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> init() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ User granted permission for FCM');
    }
  }

  Future<void> registerToken(String userId) async {
    try {
      String? token = await _messaging.getToken();
      if (token == null) return;

      debugPrint('📱 FCM Token: $token');

      // Send to Backend
      await ApiClient().post(
        '/api/DeviceTokens/register',
        data: {
          'userId': userId,
          'token': token,
          'deviceType': Platform.isIOS ? 'iOS' : 'Android',
        },
      );
    } catch (e) {
      debugPrint('❌ FCM Registration Error: $e');
    }
  }

  static Future<void> onBackgroundMessage(RemoteMessage message) async {
    debugPrint('🌙 Background message: ${message.notification?.title}');
  }
}
