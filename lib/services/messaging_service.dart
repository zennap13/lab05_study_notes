import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class MessagingService {
  final FirebaseMessaging _messaging;

  MessagingService([FirebaseMessaging? messaging])
    : _messaging = messaging ?? FirebaseMessaging.instance;

  Future<String?> init() async {
    try {
      await _messaging.requestPermission(alert: true, badge: true, sound: true);

      String? token;
      if (kIsWeb) {
        token = await _messaging.getToken(
          vapidKey:
              "BGYMRwDtykfxdHczwZzn0ecZPBZU8zy7K1nx_Fv4jlremF_Ia9F8h1IyxJN0HRyKlcd8986o0GnCnSGxr2_K_NA",
        );
      } else {
        token = await _messaging.getToken();
      }

      print('FCM token: $token');
      return token;
    } catch (e) {
      print('Token retrieval error: $e');
      return null;
    }
  }

  void listenInForeground(
    void Function(String title, String body) onMessageReceived,
  ) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.notification?.title ?? 'Notification';
      final body = message.notification?.body ?? '';
      onMessageReceived(title, body);
    });
  }
}
