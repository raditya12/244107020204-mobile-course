import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/prefs_repository_impl.dart';
import '../../domain/repositories/prefs_repository.dart';

/// Wiring DI fitur `settings`.
final prefsRepositoryProvider = Provider<PrefsRepository>(
  (ref) => PrefsRepositoryImpl(),
);

final darkModeProvider = AsyncNotifierProvider<DarkModeNotifier, bool>(
  DarkModeNotifier.new,
);

class DarkModeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final result = await ref.watch(prefsRepositoryProvider).getDarkMode();
    return result.darkMode;
  }

  Future<void> toggle() async {
    final next = !(state.value ?? false);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(prefsRepositoryProvider).setDarkMode(next);
      if (result.failure != null) {
        throw Exception(result.failure!.message);
      }
      return next;
    });
  }
}

final lastOpenedProvider = FutureProvider<String?>((ref) async {
  final repo = ref.watch(prefsRepositoryProvider);
  final previous = await repo.getLastOpened();
  await repo.markOpenedNow();
  return previous.lastOpened;
});
