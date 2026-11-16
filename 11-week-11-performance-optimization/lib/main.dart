import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/settings/presentation/providers/settings_providers.dart';
import 'infrastructure/database/db.dart';
import 'routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initializeStorage();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = ref.watch(darkModeProvider).value ?? false;
    ref.watch(lastOpenedProvider);
    return MaterialApp.router(
      routerConfig: ref.watch(routerProvider),
      title: 'Offline Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff176b62)),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff176b62),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    );
  }
}
