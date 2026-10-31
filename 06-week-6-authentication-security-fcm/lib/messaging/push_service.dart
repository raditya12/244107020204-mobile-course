import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'deep_link.dart';
import 'token_preview.dart';

/// Handler background WAJIB berupa fungsi top-level dengan
/// `@pragma('vm:entry-point')` karena berjalan di isolate terpisah.
///
/// Jangan mengakses BuildContext / Riverpod / navigasi di sini. Tugasnya hanya
/// mencatat atau menyimpan data ringan; navigasi dilakukan saat notifikasi
/// diklik.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint(
    '[FCM][background] id=${message.messageId} '
    'route=${routeFromMessage(message.data)}',
  );
}

/// Membungkus seluruh interaksi FirebaseMessaging + local notification.
///
/// `firebaseReady` bernilai false bila `google-services.json` belum dipasang,
/// sehingga aplikasi tetap berjalan (mode demo) tanpa crash.
class PushService {
  PushService({
    required this.firebaseReady,
    FlutterLocalNotificationsPlugin? local,
  }) : _local = local ?? FlutterLocalNotificationsPlugin();

  final bool firebaseReady;
  final FlutterLocalNotificationsPlugin _local;

  static const String topic = 'pengumuman-kampus';
  static const String _channelId = 'pengumuman';
  static const String _channelName = 'Pengumuman Kampus';

  final ValueNotifier<String?> pendingDeepLink = ValueNotifier<String?>(null);
  final ValueNotifier<String?> tokenPreview = ValueNotifier<String?>(null);
  final ValueNotifier<String?> lastEvent = ValueNotifier<String?>(null);
  final ValueNotifier<bool> subscribed = ValueNotifier<bool>(false);

  bool _listenersBound = false;

  /// Menyiapkan channel notifikasi lokal. Saat banner lokal diklik, payload
  /// (rute) disimpan agar diteruskan ke GoRouter oleh pemanggil.
  Future<void> initLocalNotifications() async {
    try {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings();
      await _local.initialize(
        settings: const InitializationSettings(android: android, iOS: ios),
        onDidReceiveNotificationResponse: (response) {
          pendingDeepLink.value = response.payload;
        },
      );
    } catch (error) {
      debugPrint('[push] initLocalNotifications dilewati: $error');
    }
  }

  /// Android 13+ dan iOS memerlukan izin notifikasi runtime.
  Future<bool> requestNotificationPermission() async {
    if (!firebaseReady) return false;
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
      );
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (error) {
      debugPrint('[push] requestPermission gagal: $error');
      return false;
    }
  }

  /// Mengambil token saat ini, memantau `onTokenRefresh`, lalu berlangganan
  /// topik broadcast.
  Future<void> initFcmToken({
    required Future<void> Function(String token) onToken,
  }) async {
    if (!firebaseReady) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        tokenPreview.value = previewToken(token);
        await onToken(token);
      }
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        tokenPreview.value = previewToken(newToken);
        lastEvent.value = 'onTokenRefresh: token diperbarui';
        await onToken(newToken);
      });
      await subscribeToAnnouncements();
    } catch (error) {
      debugPrint('[push] initFcmToken gagal: $error');
    }
  }

  /// Foreground: sistem TIDAK menampilkan banner otomatis, jadi ditampilkan
  /// manual via local notification. Background: `onMessageOpenedApp`.
  void bindListeners(void Function(String route) go) {
    if (!firebaseReady || _listenersBound) return;
    _listenersBound = true;

    FirebaseMessaging.onMessage.listen((message) async {
      final route = routeFromMessage(message.data);
      lastEvent.value = 'onMessage (foreground) -> $route';
      await showLocalNotification(
        title: message.notification?.title ?? 'Pengumuman',
        body: message.notification?.body ?? '',
        route: route,
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final route = routeFromMessage(message.data);
      lastEvent.value = 'onMessageOpenedApp (background) -> $route';
      go(route);
    });
  }

  /// Terminated: dibuka dari notifikasi via `getInitialMessage()`.
  Future<void> handleTerminated(void Function(String route) go) async {
    if (firebaseReady) {
      try {
        final initial = await FirebaseMessaging.instance.getInitialMessage();
        if (initial != null) {
          final route = routeFromMessage(initial.data);
          lastEvent.value = 'getInitialMessage (terminated) -> $route';
          go(route);
          return;
        }
      } catch (error) {
        debugPrint('[push] getInitialMessage gagal: $error');
      }
    }
    final pending = pendingDeepLink.value;
    if (pending != null && pending.isNotEmpty) {
      pendingDeepLink.value = null;
      go(pending);
    }
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    required String route,
  }) async {
    const android = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Notifikasi pengumuman kampus',
      importance: Importance.high,
      priority: Priority.high,
    );
    const ios = DarwinNotificationDetails();
    try {
      await _local.show(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(android: android, iOS: ios),
        payload: route,
      );
    } catch (error) {
      debugPrint('[push] show local notification gagal: $error');
    }
  }

  Future<void> subscribeToAnnouncements() async {
    if (!firebaseReady) {
      subscribed.value = true;
      return;
    }
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      subscribed.value = true;
    } catch (error) {
      debugPrint('[push] subscribe gagal: $error');
    }
  }

  Future<void> unsubscribeFromAnnouncements() async {
    if (!firebaseReady) {
      subscribed.value = false;
      return;
    }
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      subscribed.value = false;
    } catch (error) {
      debugPrint('[push] unsubscribe gagal: $error');
    }
  }

  void dispose() {
    pendingDeepLink.dispose();
    tokenPreview.dispose();
    lastEvent.dispose();
    subscribed.dispose();
  }
}
