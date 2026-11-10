import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../data/api_errors.dart';
import 'package:firebase_core/firebase_core.dart';

import '../routes.dart';   // ← routeFromMessage ada di sini

final _local = FlutterLocalNotificationsPlugin();

// ---- State yang bisa di-observe UI ----
final fcmToken = ValueNotifier<String?>(null);
final permissionStatus = ValueNotifier<String>('Belum diminta');
final syncStatus = ValueNotifier<String>('Belum ada sinkronisasi');
final topicStatus = ValueNotifier<String>('Belum berlangganan');
final lastNotif = ValueNotifier<String>('Belum ada notifikasi');

/// Simpan route yang belum sempat dinavigasikan (mis. dari local notif saat app mati).
final pendingDeepLink = ValueNotifier<String?>(null);

/// Guard agar startPush hanya dijalankan sekali per app lifecycle.
bool _pushStarted = false;

String shortToken(String t) =>
    t.length <= 12 ? t : '${t.substring(0, 12)}...';

const kTopic = 'pengumuman-kampus';

/// ============================================================
/// BACKGROUND HANDLER (top-level, no BuildContext / Riverpod)
/// ============================================================
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  final route = message.data['route'] ?? '/';
  debugPrint('[BG] Message ID: ${message.messageId}');
  debugPrint('[BG] Route: $route');
  debugPrint('[BG] Data: ${message.data}');
}

void registerBackgroundHandler() {
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}

/// ============================================================
/// PERMISSION
/// ============================================================
Future<bool> requestNotificationPermission() async {
  final settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    announcement: false,
    carPlay: false,
    criticalAlert: false,
  );
  final granted =
      settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
  permissionStatus.value = granted ? 'Diizinkan' : 'Ditolak';
  return granted;
}

/// ============================================================
/// LOCAL NOTIFICATIONS (untuk foreground)
/// ============================================================
void Function(String route)? _navigate;

Future<void> initLocalNotifications() async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings();

  await _local.initialize(
    const InitializationSettings(android: android, iOS: ios),
    onDidReceiveNotificationResponse: (response) {
      final payload = response.payload;
      if (payload == null || payload.isEmpty) return;

      // Kalau navigator belum siap (cold start), simpan dulu.
      if (_navigate != null) {
        _navigate!.call(payload);
      } else {
        pendingDeepLink.value = payload;
      }
    },
  );

  const channel = AndroidNotificationChannel(
    'pengumuman',
    'Pengumuman Kampus',
    description: 'Notifikasi pengumuman dari kampus',
    importance: Importance.high,
  );
  await _local
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

/// ============================================================
/// FOREGROUND + BACKGROUND CLICK
/// ============================================================
void listenForeground(void Function(String route) go) {
  FirebaseMessaging.onMessage.listen((message) async {
    final route = routeFromMessage(message.data);
    lastNotif.value = '${message.notification?.title ?? '-'}\nRute: $route';

    const androidDetails = AndroidNotificationDetails(
      'pengumuman',
      'Pengumuman Kampus',
      channelDescription: 'Notifikasi pengumuman dari kampus',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    await _local.show(
      message.hashCode,
      message.notification?.title ?? 'Pengumuman',
      message.notification?.body ?? '',
      const NotificationDetails(android: androidDetails),
      payload: route,
    );
  });

  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    final route = routeFromMessage(message.data);
    lastNotif.value = 'Dibuka dari banner\nRute: $route';
    go(route);
  });
}

/// ============================================================
/// TERMINATED → KLIK (initial message + pending local notif)
/// ============================================================
Future<void> handleTerminated(void Function(String route) go) async {
  // 1. Cek notif yang membuka app dari terminated state
  final initial = await FirebaseMessaging.instance.getInitialMessage();
  if (initial != null) {
    final route = routeFromMessage(initial.data);
    lastNotif.value = 'Terminated → $route';
    debugPrint('[Terminated] route=$route');
    go(route);
  }

  // 2. Cek pending deep link dari local notification
  if (pendingDeepLink.value != null) {
    final route = pendingDeepLink.value!;
    pendingDeepLink.value = null;
    lastNotif.value = 'Local notif → $route';
    debugPrint('[LocalNotif] route=$route');
    go(route);
  }

  // 3. Dengarkan perubahan pendingDeepLink (jika user tap setelah init)
  pendingDeepLink.addListener(() {
    final route = pendingDeepLink.value;
    if (route == null) return;
    pendingDeepLink.value = null;
    lastNotif.value = 'Local notif (async) → $route';
    debugPrint('[LocalNotif async] route=$route');
    go(route);
  });
}

/// ============================================================
/// TOKEN LIFECYCLE
/// ============================================================
Future<void> initFcmToken({
  required Future<void> Function(String token) onToken,
}) async {
  try {
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) await onToken(token);
  } catch (e) {
    debugPrint('[FCM] getToken gagal: $e');
  }

  // Bungkus jadi void callback supaya cocok dengan Stream.listen
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    // ignore: discarded_futures
    onToken(newToken);
  });

  await subscribeTopic();
}

Future<void> subscribeTopic() async {
  await FirebaseMessaging.instance.subscribeToTopic(kTopic);
  topicStatus.value = 'Berlangganan: $kTopic';
}

Future<void> unsubscribeTopic() async {
  await FirebaseMessaging.instance.unsubscribeFromTopic(kTopic);
  topicStatus.value = 'Berhenti berlangganan: $kTopic';
}

/// ============================================================
/// ENTRY POINT
/// ============================================================
Future<void> startPush(Dio dio, void Function(String route) go) async {
  if (_pushStarted) return;
  _pushStarted = true;

  try {
    _navigate = go;

    final granted = await requestNotificationPermission();
    debugPrint('[Push] permission granted = $granted');

    await initLocalNotifications();
    listenForeground(go);

    await initFcmToken(onToken: (token) async {
      fcmToken.value = token;
      try {
        await dio.post(
          '/devices',
          data: {'fcm_token': token, 'platform': 'android'},
        );
        syncStatus.value = 'Terkirim ke backend: ${shortToken(token)}';
      } catch (e) {
        syncStatus.value =
            'Gagal kirim (${friendlyError(e)}): ${shortToken(token)}';
      }
    });

    await handleTerminated(go);
  } catch (e) {
    debugPrint('[Push] error: $e');
  }
}