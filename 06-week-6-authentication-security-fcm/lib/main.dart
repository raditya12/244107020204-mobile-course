import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'messaging/push_service.dart';
import 'providers/app_providers.dart';
import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseReady = await _initializeFirebase();
  runApp(
    ProviderScope(
      overrides: [firebaseReadyProvider.overrideWithValue(firebaseReady)],
      child: const CampusNotifyApp(),
    ),
  );
}

/// Firebase hanya diinisialisasi bila konfigurasi native tersedia. Bila
/// `google-services.json` belum dipasang, aplikasi tetap berjalan dan
/// fitur push memakai mode demo.
Future<bool> _initializeFirebase() async {
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    return true;
  } catch (error) {
    debugPrint('Firebase belum dikonfigurasi: $error');
    return false;
  }
}

class CampusNotifyApp extends ConsumerStatefulWidget {
  const CampusNotifyApp({super.key});

  @override
  ConsumerState<CampusNotifyApp> createState() => _CampusNotifyAppState();
}

class _CampusNotifyAppState extends ConsumerState<CampusNotifyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrapPush());
  }

  Future<void> _bootstrapPush() async {
    final push = ref.read(pushServiceProvider);
    final router = ref.read(routerProvider);

    // Klik banner lokal -> teruskan payload ke GoRouter.
    push.pendingDeepLink.addListener(() {
      final route = push.pendingDeepLink.value;
      if (route != null && route.isNotEmpty) {
        push.pendingDeepLink.value = null;
        router.go(route);
      }
    });

    await push.initLocalNotifications();
    await push.requestNotificationPermission();
    push.bindListeners(router.go);
    await push.initFcmToken(onToken: (token) async {
      await ref.read(deviceRepositoryProvider).registerDevice(
            token,
            platform: defaultTargetPlatform.name,
          );
    });
    await push.handleTerminated(router.go);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Campus Notify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff1b5e20)),
      ),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
