import '../../../../core/failures.dart';

/// Kontrak repository preferensi aplikasi (tema, waktu terakhir dibuka).
abstract class PrefsRepository {
  Future<({bool darkMode, Failure? failure})> getDarkMode();

  Future<({bool ok, Failure? failure})> setDarkMode(bool value);

  Future<({String? lastOpened, Failure? failure})> getLastOpened();

  Future<({bool ok, Failure? failure})> markOpenedNow();
}
