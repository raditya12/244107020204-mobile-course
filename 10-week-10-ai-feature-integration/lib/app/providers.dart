import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider presentasi lintas fitur (komposisi aplikasi).
///
/// `forceOffline` adalah state UI (toggle simulasi offline) yang dipakai fitur
/// `notes` dan `posts`. Ditempatkan di layer `app` agar kedua fitur tidak
/// saling mengimpor presentation-nya.
final forceOfflineProvider = NotifierProvider<OfflineNotifier, bool>(
  OfflineNotifier.new,
);

class OfflineNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setOffline(bool value) => state = value;
}
